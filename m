From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 12 - new error codes for NFSv4
Date: Thu, 22 Aug 2002 10:34:44 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfvw-00050z-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  "Kendrick M. Smith" <kmsmith@umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfwE-0008Hj-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:35:02 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <kmsmith@umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:34:51 +1000
To: Linus Torvalds <torvalds@transmeta.com>
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

This set of 12 patches prepares the way for adding NFSv4 server functionality to
Linux.  They are all from the CITI team at umich.

This set only includes patches that change current files, making enhancement (and 
fixing the odd bug) to make the common code more usable for NFSv4.

Currently, NFSv4 support will require NFSv3 support be compiled in.  We might relax 
that later.

This set does NOT include:
  patch 02/38: NFSv4 protocol header
     partly because it contains a new file that contains a copyright message
     but no license message, and that makes me a bit uncomfortable.
     Kendrick:  could you please resubmit with some sort of license message
  patch 03/38: SUNRPC: support for GSSD client
     I would rather this weren't used.  I want to do out-calls to userspace
     quite differently.  I hope to have a patch to show soon (work has progressed).
     
  patches 4-19/38
     They are all CLIENT

  patch 26/38: SERVER: new routine fh_dup2()
     It is an independant new routine.  I would like to submit it
     at the same time that I submit the code that uses it.
  patch 27/38: SERVER: expand filehandle to 128 bytes
     This depends on 02/38.  See above.
  patch 34/38: SERVER: new routine exp_pseudoroot() [trivial  for now]
      Again, an independant new routine.
  patch 35-38/38: SERVER: header file for NFSv4 XDR (etc)
      This patch and the remainder will come later.  Again, there
      is a copyright claim, but no license message.

NeilBrown


### Comments for ChangeSet

From:	"Kendrick M. Smith" <kmsmith@umich.edu>

This patch adds new NFSv4-only error codes to include/linux/nfs.h,
and also indicates which of the old error codes still exist in NFSv4.

 ----------- Diffstat output ------------
 ./include/linux/nfs.h |   87 +++++++++++++++++++++++++++++++++-----------------
 1 files changed, 58 insertions(+), 29 deletions(-)

--- ./include/linux/nfs.h	2002/08/21 23:21:22	1.1
+++ ./include/linux/nfs.h	2002/08/21 23:21:27	1.2
@@ -39,40 +39,69 @@
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
- 
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
+
 /* NFSv2 file types - beware, these are not the same in NFSv3 */
 
 enum nfs_ftype {


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
