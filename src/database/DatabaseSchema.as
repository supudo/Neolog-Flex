package database {

	public class DatabaseSchema {

		public const TABLES_CREATED:String = "TABLES_CREATED";
		
		public const CREATE_TABLE_SETTINGS:String = "CREATE TABLE IF NOT EXISTS settings (id INTEGER PRIMARY KEY AUTOINCREMENT, sname TEXT, svalue TEXT);";
		public const CREATE_TABLE_TEXTCONTENT:String = "CREATE TABLE IF NOT EXISTS text_content (id INTEGER PRIMARY KEY AUTOINCREMENT, cid NUMERIC, title TEXT, content TEXT);";
		public const CREATE_TABLE_NESTS:String = "CREATE TABLE IF NOT EXISTS nests (id INTEGER PRIMARY KEY AUTOINCREMENT, nid NUMERIC, nest TEXT, orderpos NUMERIC);";
		public const CREATE_TABLE_WORDSCOMMENTS:String = "CREATE TABLE IF NOT EXISTS wordscomments (id INTEGER PRIMARY KEY AUTOINCREMENT, commentid NUMERIC, wid NUMERIC, author TEXT, comment TEXT, commentdate DATE, commentdatestamp NUMERIC);";
		public const CREATE_TABLE_WORDS:String = "CREATE TABLE IF NOT EXISTS words (id INTEGER PRIMARY KEY AUTOINCREMENT, wid NUMERIC, wordletter TEXT, nid NUMERIC, word TEXT, example TEXT, ethimology TEXT, description TEXT, derivatives TEXT, commentcount NUMERIC, addedbyurl TEXT, addedbyemail TEXT, addedby TEXT, addedatdate DATE, addedatdatestamp NUMERIC);";

		public const GET_SETTINGS:String = "SELECT * FROM settings WHERE sname = :sname";
		public const GET_SETTINGS_ALL:String = "SELECT * FROM settings";

		public const GET_TEXTCONTENT:String = "SELECT * FROM text_content WHERE cid = :cid";

		public const GET_NESTS:String = "SELECT * FROM nests ORDER BY orderpos";
		public const GET_NESTS_COUNT:String = "SELECT n.*, (SELECT COUNT(wid) FROM words WHERE nid = n.nid) AS wordscount FROM nests AS n ORDER BY n.orderpos";
		public const GET_NEST:String = "SELECT * FROM nests WHERE nid = :nid";

		public const GET_WORDS:String = "SELECT * FROM words ORDER BY word DESC";
		public const GET_WORD:String = "SELECT * FROM words WHERE wid = :wid";
		public const GET_WORDS_FOR_NEST:String = "SELECT * FROM words WHERE nid = :nid ORDER BY word";
		public const GET_WORDS_FOR_LETTER:String = "SELECT * FROM words WHERE wordletter = :wordletter ORDER BY word";
		public const GET_WORDS_COMPLEX:String = "SELECT * FROM words WHERE wordletter = :wordletter AND nid = :nid ORDER BY word";
		public const SEARCH_WORDS:String = "SELECT * FROM words WHERE word LIKE :searchq ORDER BY word";

		public const GET_COMMENTS:String = "SELECT * FROM wordscomments WHERE wid = :wid ORDER BY commentdate DESC";
		public const GET_COMMENT:String = "SELECT * FROM wordscomments WHERE commentid = :commentid";

		public const GET_LAST_INSERT_ROWID:String = "SELECT last_insert_rowid()";
		
		public const INSERT_SETTINGS:String = "INSERT INTO settings (sname, svalue) VALUES (:sname, :svalue)";
		public const INSERT_TEXTCONTENT:String = "INSERT INTO text_content (cid, title, content) VALUES (:cid, :title, :content)";
		public const INSERT_NESTS:String = "INSERT INTO nests (nid, nest, orderpos) VALUES (:nid, :nest, :orderpos)";
		public const INSERT_WORDSCOMMENTS:String = "INSERT INTO wordscomments (commentid, wid, author, comment, commentdate, commentdatestamp) VALUES (:commentid, :wid, :author, :comment, :commentdate, :commentdatestamp)";
		public const INSERT_WORDS:String = "INSERT INTO words (wid, wordletter, nid, word, example, ethimology, description, derivatives, commentcount, addedbyurl, addedbyemail, addedby, addedatdate, addedatdatestamp) VALUES (:wid, :wordletter, :nid, :word, :example, :ethimology, :description, :derivatives, :commentcount, :addedbyurl, :addedbyemail, :addedby, :addedatdate, :addedatdatestamp)";

		public const UPDATE_SETTINGS:String = "UPDATE settings SET svalue = :svalue WHERE sname = :sname";
		public const UPDATE_TEXTCONTENT:String = "UPDATE text_content SET title = :title, content = :content WHERE cid = :cid";
		public const UPDATE_NESTS:String = "UPDATE nests SET nest = :nest, orderpos = :orderpos WHERE nid = :nid";
		public const UPDATE_WORDSCOMMENTS:String = "UPDATE wordscomments SET wid = :wid, author = :author, comment = :comment, commentdate = :commentdate, commentdatestamp = :commentdatestamp WHERE commentid = :commentid";
		public const UPDATE_WORDS:String = "UPDATE words SET wordletter = :wordletter, nid = :nid, word = :word, example = :example, ethimology = :ethimology, description = :description, derivatives = :derivatives, commentcount = :commentcount, addedbyurl = :addedbyurl, addedbyemail = :addedbyemail, addedby = :addedby, addedatdate = :addedatdate, addedatdatestamp = :addedatdatestamp WHERE wid = :wid";

		public const DELETE_SETTINGS:String = "DELETE FROM settings";
		public const DELETE_TEXTCONTENT:String = "DELETE FROM text_content";
		public const DELETE_NESTS:String = "DELETE FROM nests";
		public const DELETE_WORDSCOMMENTS:String = "DELETE FROM wordscomments";
		public const DELETE_WORDS:String = "DELETE FROM words";

		public function DatabaseSchema() {
		}
	}
}