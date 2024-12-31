{-# LANGUAGE OverloadedStrings #-}

import Control.Monad (forM_)
import Data.List (isPrefixOf, isSuffixOf, intersperse)
import Data.Maybe (fromMaybe)
import Hakyll
import qualified Data.Text as T
import qualified Data.Text.Slugger as Slugger
import System.FilePath (takeFileName, (</>))
import Text.Pandoc
    ( Extension(Ext_fenced_code_attributes, Ext_footnotes, 
               Ext_gfm_auto_identifiers, Ext_implicit_header_references, 
               Ext_smart)
    , Extensions
    , ReaderOptions
    , WriterOptions(writerHighlightStyle)
    , extensionsFromList
    , githubMarkdownExtensions
    , readerExtensions
    , writerExtensions
    )
import Text.Pandoc.Highlighting (Style, breezeDark, styleToCss)

--------------------------------------------------------------------------------
-- PERSONALIZATION

mySiteName :: String
mySiteName = "74k1.sh"

mySiteRoot :: String
mySiteRoot = "https://74k1.sh"

myFeedTitle :: String
myFeedTitle = "74k1.sh/blog"

myFeedDescription :: String
myFeedDescription = "Personal portfolio of Tim (74k1)"

myDescription :: String
myDescription = "Personal portfolio of Tim (74k1)"

myFeedAuthorName :: String
myFeedAuthorName = "Tim (74k1)"

myFeedAuthorEmail :: String
myFeedAuthorEmail = "mail@74k1.sh"

myFeedRoot :: String
myFeedRoot = mySiteRoot

--------------------------------------------------------------------------------
-- CONFIG

config :: Configuration
config =
    defaultConfiguration
        { destinationDirectory = "dist"
        , ignoreFile = ignoreFile'
        , previewHost = "127.0.0.1"
        , previewPort = 8000
        , providerDirectory = "src"
        , storeDirectory = "ssg/_cache"
        , tmpDirectory = "ssg/_tmp"
        , deployCommand = "echo 'No deploy command specified'"
        }
  where
    ignoreFile' path
        | "."    `isPrefixOf` fileName = False
        | "#"    `isPrefixOf` fileName = True
        | "~"    `isSuffixOf` fileName = True
        | ".swp" `isSuffixOf` fileName = True
        | otherwise = False
      where
        fileName = takeFileName path

--------------------------------------------------------------------------------
-- BUILD

main :: IO ()
main = hakyllWith config $ do
    tags <- buildTags "posts/*" (fromCapture "tags/*.html")

    forM_
        [ "favicon-32x32.png"
        , "favicon-16x16.png"
        , "fonts/*"
        , "images/*"
        , "index.html"
        , "js/*"
        , "robots.txt"
        , ".htaccess"
        , "GPG.asc"
        , "blog/posts/index.html"
        -- , "contact/svg-email-protection.svg"
        ] $ \f -> match f $ do
            route idRoute
            compile copyFileCompiler

    match "css/*" $ do
        route idRoute
        compile compressCssCompiler

    match "posts/*" $ do
        let ctx = constField "type" "article" 
                 <> tagsField "tags" tags 
                 <> postCtx

        route $ metadataRoute $ \md ->
            customRoute $ \_ -> "blog/posts" </> fileNameFromTitle md
        compile $
            pandocCompilerCustom
                >>= loadAndApplyTemplate "templates/post.html" ctx
                >>= saveSnapshot "content"
                >>= loadAndApplyTemplate "templates/default.html" ctx

    match "blog/index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let blogCtx =
                    listField "posts" postCtx (return posts)
                        <> baseCtx

            getResourceBody
                >>= applyAsTemplate blogCtx
                >>= loadAndApplyTemplate "templates/default.html" blogCtx

    -- match "index.html" $ do
    --     route idRoute
    --     compile $ do
    --         posts <- fmap (take 3) . recentFirst =<< loadAll "posts/*"
    --         let indexCtx =
    --                 listField "posts" postCtx (return posts)
    --                     <> baseCtx
    --                     <> constField "desc" "Home page"
    --
    --         getResourceBody
    --             >>= applyAsTemplate indexCtx
    --             >>= loadAndApplyTemplate "templates/default.html" indexCtx

    -- match "about/index.html" $ do
    --     route idRoute
    --     compile $ do
    --         getResourceBody
    --             >>= applyAsTemplate baseCtx
    --             >>= loadAndApplyTemplate "templates/default.html" baseCtx

    match "contact/index.html" $ do
        route idRoute
        compile $ do
            let contactCtx = 
                    baseCtx
                        <> constField "title" "Contact"
            getResourceBody
                >>= applyAsTemplate contactCtx
                >>= loadAndApplyTemplate "templates/default.html" contactCtx

    match "templates/*" $ compile templateBodyCompiler

    create ["sitemap.xml"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"

            let pages = posts
                sitemapCtx =
                    constField "root" mySiteRoot
                        <> constField "siteName" mySiteName
                        <> listField "pages" postCtx (return pages)

            makeItem ("" :: String)
                >>= loadAndApplyTemplate "templates/sitemap.xml" sitemapCtx

    create ["blog/rss.xml"] $ do
        route idRoute
        compile (feedCompiler renderRss)

    create ["blog/atom.xml"] $ do
        route idRoute
        compile (feedCompiler renderAtom)

    create ["css/code.css"] $ do
        route idRoute
        compile (makeStyle pandocHighlightStyle)

--------------------------------------------------------------------------------
-- COMPILER HELPERS

makeStyle :: Style -> Compiler (Item String)
makeStyle = makeItem . compressCss . styleToCss

--------------------------------------------------------------------------------
-- CONTEXT

baseCtx :: Context String
baseCtx =
    constField "root" mySiteRoot
        <> constField "feedTitle" myFeedTitle
        <> constField "siteName" mySiteName
        <> constField "lang" "en"
        -- <> constField "desc" myDescription  -- Fallback description
        <> defaultContext

feedCtx :: Context String
feedCtx =
    titleCtx
        <> postCtx
        <> metadataField                               -- Add this line
        <> constField "description" myFeedDescription  -- Fallback description
        <> constField "authorName" myFeedAuthorName    -- Add these feed-specific
        <> constField "authorEmail" myFeedAuthorEmail  -- required fields

postCtx :: Context String
postCtx =
    baseCtx
        <> dateField "date" "%Y-%m-%d"
        <> field "firstTag" firstTagCompiler

titleCtx :: Context String
titleCtx = field "title" updatedTitle

--------------------------------------------------------------------------------
-- TITLE HELPERS

replaceAmp :: String -> String
replaceAmp = replaceAll "&" (const "&amp;")

replaceTitleAmp :: Metadata -> String
replaceTitleAmp = replaceAmp . safeTitle

safeTitle :: Metadata -> String
safeTitle = fromMaybe "no title" . lookupString "title"

updatedTitle :: Item a -> Compiler String
updatedTitle = fmap replaceTitleAmp . getMetadata . itemIdentifier

--------------------------------------------------------------------------------
-- PANDOC

pandocCompilerCustom :: Compiler (Item String)
pandocCompilerCustom = pandocCompilerWith pandocReaderOpts pandocWriterOpts

pandocExtensionsCustom :: Extensions
pandocExtensionsCustom =
    githubMarkdownExtensions
        <> extensionsFromList
            [ Ext_fenced_code_attributes
            , Ext_gfm_auto_identifiers
            , Ext_implicit_header_references
            , Ext_smart
            , Ext_footnotes
            ]

pandocReaderOpts :: ReaderOptions
pandocReaderOpts =
    defaultHakyllReaderOptions
        { readerExtensions = pandocExtensionsCustom
        }

pandocWriterOpts :: WriterOptions
pandocWriterOpts =
    defaultHakyllWriterOptions
        { writerExtensions = pandocExtensionsCustom
        , writerHighlightStyle = Just pandocHighlightStyle
        }

pandocHighlightStyle :: Style
pandocHighlightStyle = breezeDark

--------------------------------------------------------------------------------
-- FEEDS

type FeedRenderer =
    FeedConfiguration ->
    Context String ->
    [Item String] ->
    Compiler (Item String)

feedCompiler :: FeedRenderer -> Compiler (Item String)
feedCompiler renderer =
    renderer feedConfiguration feedCtx
        =<< recentFirst
        =<< loadAllSnapshots "posts/*" "content"

feedConfiguration :: FeedConfiguration
feedConfiguration =
    FeedConfiguration
        { feedTitle = myFeedTitle
        , feedDescription = myFeedDescription
        , feedAuthorName = myFeedAuthorName
        , feedAuthorEmail = myFeedAuthorEmail
        , feedRoot = myFeedRoot
        }

--------------------------------------------------------------------------------
-- CUSTOM ROUTE

fileNameFromTitle :: Metadata -> FilePath
fileNameFromTitle =
    T.unpack . (`T.append` ".html") . Slugger.toSlug . T.pack . safeTitle

--------------------------------------------------------------------------------
-- NEW FUNCTIONS

firstTagCompiler :: Item a -> Compiler String
firstTagCompiler item = do
    metadata <- getMetadata (itemIdentifier item)
    case lookupStringList "tags" metadata of
        Just (tag:_) -> return tag
        _ -> return ""
