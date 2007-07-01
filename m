From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/21] NFS: Add a new NFS debugging flag just for
	mount	processing
Date: Sun, 01 Jul 2007 12:12:51 -0400
Message-ID: <20070701161251.2786.17972.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5245-0004Y5-Os
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:21 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I5249-00044L-3V
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:25 -0700
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

Note to self: fix up /usr/sbin/rpcdebug too

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/nfs_fs.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 3e8dd12..589ea69 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -553,6 +553,7 @@ extern void * nfs_root_data(void);
 #define NFSDBG_ROOT		0x0080
 #define NFSDBG_CALLBACK		0x0100
 #define NFSDBG_CLIENT		0x0200
+#define NFSDBG_MOUNT		0x0400
 #define NFSDBG_ALL		0xFFFF
 
 #ifdef __KERNEL__


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
