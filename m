From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 01/38: new error codes
Date: Wed, 14 Aug 2002 16:36:12 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <7643.26886642284$1029466406@news.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f4sJ-00038t-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:36:15 -0700
To: linux-kernel@vger.kernel.org, <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


This patch adds new NFSv4-only error codes to include/linux/nfs.h,
and also indicates which of the old error codes still exist in NFSv4.

--- old/include/linux/nfs.h	Thu Aug  1 16:16:13 2002
+++ new/include/linux/nfs.h	Sun Aug 11 18:09:25 2002
@@ -39,39 +39,68 @@
  * standard, but seem to be widely used nevertheless.
  */
  enum nfs_stat {
-	NFS_OK = 0,			/* v2 v3 */
-	NFSERR_PERM = 1,		/* v2 v3 */
-	NFSERR_NOENT = 2,		/* v2 v3 */
-	NFSERR_IO = 5,			/* v2 v3 */
-	NFSERR_NXIO = 6,		/* v2 v3 */
+	NFS_OK = 0,			/* v2 v3 v4 */
+	NFSERR_PERM = 1,		/* v2 v3 v4 */
+	NFSERR_NOENT = 2,		/* v2 v3 v4 */
+	NFSERR_IO = 5,			/* v2 v3 v4 */
+	NFSERR_NXIO = 6,		/* v2 v3 v4 */
 	NFSERR_EAGAIN = 11,		/* v2 v3 */
-	NFSERR_ACCES = 13,		/* v2 v3 */
-	NFSERR_EXIST = 17,		/* v2 v3 */
-	NFSERR_XDEV = 18,		/*    v3 */
-	NFSERR_NODEV = 19,		/* v2 v3 */
-	NFSERR_NOTDIR = 20,		/* v2 v3 */
-	NFSERR_ISDIR = 21,		/* v2 v3 */
-	NFSERR_INVAL = 22,		/* v2 v3 that Sun forgot */
-	NFSERR_FBIG = 27,		/* v2 v3 */
-	NFSERR_NOSPC = 28,		/* v2 v3 */
-	NFSERR_ROFS = 30,		/* v2 v3 */
-	NFSERR_MLINK = 31,		/*    v3 */
+	NFSERR_ACCES = 13,		/* v2 v3 v4 */
+	NFSERR_EXIST = 17,		/* v2 v3 v4 */
+	NFSERR_XDEV = 18,		/*    v3 v4 */
+	NFSERR_NODEV = 19,		/* v2 v3 v4 */
+	NFSERR_NOTDIR = 20,		/* v2 v3 v4 */
+	NFSERR_ISDIR = 21,		/* v2 v3 v4 */
+	NFSERR_INVAL = 22,		/* v2 v3 v4 */
+	NFSERR_FBIG = 27,		/* v2 v3 v4 */
+	NFSERR_NOSPC = 28,		/* v2 v3 v4 */
+	NFSERR_ROFS = 30,		/* v2 v3 v4 */
+	NFSERR_MLINK = 31,		/*    v3 v4 */
 	NFSERR_OPNOTSUPP = 45,		/* v2 v3 */
-	NFSERR_NAMETOOLONG = 63,	/* v2 v3 */
-	NFSERR_NOTEMPTY = 66,		/* v2 v3 */
-	NFSERR_DQUOT = 69,		/* v2 v3 */
-	NFSERR_STALE = 70,		/* v2 v3 */
+	NFSERR_NAMETOOLONG = 63,	/* v2 v3 v4 */
+	NFSERR_NOTEMPTY = 66,		/* v2 v3 v4 */
+	NFSERR_DQUOT = 69,		/* v2 v3 v4 */
+	NFSERR_STALE = 70,		/* v2 v3 v4 */
 	NFSERR_REMOTE = 71,		/* v2 v3 */
 	NFSERR_WFLUSH = 99,		/* v2    */
-	NFSERR_BADHANDLE = 10001,	/*    v3 */
+	NFSERR_BADHANDLE = 10001,	/*    v3 v4 */
 	NFSERR_NOT_SYNC = 10002,	/*    v3 */
-	NFSERR_BAD_COOKIE = 10003,	/*    v3 */
-	NFSERR_NOTSUPP = 10004,		/*    v3 */
-	NFSERR_TOOSMALL = 10005,	/*    v3 */
-	NFSERR_SERVERFAULT = 10006,	/*    v3 */
-	NFSERR_BADTYPE = 10007,		/*    v3 */
-	NFSERR_JUKEBOX = 10008		/*    v3 */
- };
+	NFSERR_BAD_COOKIE = 10003,	/*    v3 v4 */
+	NFSERR_NOTSUPP = 10004,		/*    v3 v4 */
+	NFSERR_TOOSMALL = 10005,	/*    v3 v4 */
+	NFSERR_SERVERFAULT = 10006,	/*    v3 v4 */
+	NFSERR_BADTYPE = 10007,		/*    v3 v4 */
+	NFSERR_JUKEBOX = 10008,		/*    v3 v4 */
+	NFSERR_SAME = 10009,		/*       v4 */
+	NFSERR_DENIED = 10010,		/*       v4 */
+	NFSERR_EXPIRED = 10011,		/*       v4 */
+	NFSERR_LOCKED = 10012,		/*       v4 */
+	NFSERR_GRACE = 10013,		/*       v4 */
+	NFSERR_FHEXPIRED = 10014,	/*       v4 */
+	NFSERR_SHARE_DENIED = 10015,	/*       v4 */
+	NFSERR_WRONGSEC = 10016,	/*       v4 */
+	NFSERR_CLID_INUSE = 10017,	/*       v4 */
+	NFSERR_RESOURCE = 10018,	/*       v4 */
+	NFSERR_MOVED = 10019,		/*       v4 */
+	NFSERR_NOFILEHANDLE = 10020,	/*       v4 */
+	NFSERR_MINOR_VERS_MISMATCH = 10021,   /* v4 */
+	NFSERR_STALE_CLIENTID = 10022,	/*       v4 */
+	NFSERR_STALE_STATEID = 10023,	/*       v4 */
+	NFSERR_OLD_STATEID = 10024,	/*       v4 */
+	NFSERR_BAD_STATEID = 10025,	/*       v4 */
+	NFSERR_BAD_SEQID = 10026,	/*       v4 */
+	NFSERR_NOT_SAME = 10027,	/*       v4 */
+	NFSERR_LOCK_RANGE = 10028,	/*       v4 */
+	NFSERR_SYMLINK = 10029,		/*       v4 */
+	NFSERR_READDIR_NOSPC = 10030,	/*       v4 */
+	NFSERR_LEASE_MOVED = 10031,	/*       v4 */
+	NFSERR_ATTRNOTSUPP = 10032,	/*       v4 */
+	NFSERR_NO_GRACE = 10033,	/*       v4 */
+	NFSERR_RECLAIM_BAD = 10034,	/*       v4 */
+	NFSERR_RECLAIM_CONFLICT = 10035,/*       v4 */
+	NFSERR_BAD_XDR = 10036,		/*       v4 */
+	NFSERR_LOCKS_HELD = 10037	/*       v4 */
+};

 /* NFSv2 file types - beware, these are not the same in NFSv3 */




-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
