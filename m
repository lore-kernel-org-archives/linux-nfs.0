From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/17] rpcdebug: Update 'rpcdebug' tool with recently
	added	debugging flags
Date: Sun, 15 Jul 2007 23:14:53 -0400
Message-ID: <20070716031453.11209.77933.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH2w-0001gs-WD
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:14:51 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH30-0008PS-JY
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:14:54 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Add the CLIENT and MOUNT flags to rpcdebug.
---

 support/include/nfs/debug.h |    4 +++-
 tools/rpcdebug/rpcdebug.c   |    4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/support/include/nfs/debug.h b/support/include/nfs/debug.h
index 57be843..d391e91 100644
--- a/support/include/nfs/debug.h
+++ b/support/include/nfs/debug.h
@@ -9,7 +9,7 @@
 #define RPCDBG_DEBUG		0x0004
 #define RPCDBG_NFS		0x0008
 #define RPCDBG_AUTH		0x0010
-#define RPCDBG_PMAP		0x0020
+#define RPCDBG_BIND		0x0020
 #define RPCDBG_SCHED		0x0040
 #define RPCDBG_TRANS		0x0080
 #define RPCDBG_SVCSOCK		0x0100
@@ -74,6 +74,8 @@ enum {
 #define NFSDBG_FILE		0x0040
 #define NFSDBG_ROOT		0x0080
 #define NFSDBG_CALLBACK		0x0100
+#define NFSDBG_CLIENT		0x0200
+#define NFSDBG_MOUNT		0x0400
 #define NFSDBG_ALL		0xFFFF
 
 #endif /* _NFS_DEBUG_H */
diff --git a/tools/rpcdebug/rpcdebug.c b/tools/rpcdebug/rpcdebug.c
index 0a12519..275a491 100644
--- a/tools/rpcdebug/rpcdebug.c
+++ b/tools/rpcdebug/rpcdebug.c
@@ -146,7 +146,7 @@ static struct flagmap {
 	FLAG(RPC,	DEBUG),
 	FLAG(RPC,	NFS),
 	FLAG(RPC,	AUTH),
-	FLAG(RPC,	PMAP),
+	FLAG(RPC,	BIND),
 	FLAG(RPC,	SCHED),
 	FLAG(RPC,	TRANS),
 	FLAG(RPC,	SVCSOCK),
@@ -165,6 +165,8 @@ static struct flagmap {
 	FLAG(NFS,       FILE),
 	FLAG(NFS,       ROOT),
 	FLAG(NFS,       CALLBACK),
+	FLAG(NFS,       CLIENT),
+	FLAG(NFS,       MOUNT),
 	FLAG(NFS,	ALL),
 
 	/* nfsd */


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
