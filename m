From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 8 - ensure XDR buffer is large enough for NFSv4
Date: Fri, 11 Oct 2002 10:05:22 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17znIw-0007dx-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17znZW-00087X-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 17:22:30 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 10:22:21 +1000
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet
From:	"Kendrick M. Smith" <kmsmith@umich.edu>

This patch changes the 'xdrsize' parameter to svc_create(), to be
     NFS4_SVC_XDRSIZE   if v4 is defined
else NFS3_SVC_XDRSIZE   if v3 is defined
else NFS2_SVC_XDRSIZE     (formerly NFSSVC_XDRSIZE)

This always works, since
     NFS4_SVC_XDRSIZE >= NFS3_SVC_XDRSIZE >= NFS2_SVC_XDRSIZE.

The value of NFSD_BUFSIZE has also been moved to const.h, since we need
the definition available in nfs4proc.c


 ----------- Diffstat output ------------
 ./fs/nfsd/nfssvc.c           |    3 ++-
 ./include/linux/nfsd/const.h |   10 ++++++++++
 ./include/linux/nfsd/xdr.h   |    2 +-
 3 files changed, 13 insertions(+), 2 deletions(-)

--- ./include/linux/nfsd/xdr.h	2002/10/10 23:18:00	1.1
+++ ./include/linux/nfsd/xdr.h	2002/10/10 23:18:03	1.2
@@ -119,7 +119,7 @@ union nfsd_xdrstore {
 	struct nfsd_readdirargs	readdir;
 };
 
-#define NFSSVC_XDRSIZE		sizeof(union nfsd_xdrstore)
+#define NFS2_SVC_XDRSIZE	sizeof(union nfsd_xdrstore)
 
 
 int nfssvc_decode_void(struct svc_rqst *, u32 *, void *);
--- ./include/linux/nfsd/const.h	2002/10/10 23:18:00	1.1
+++ ./include/linux/nfsd/const.h	2002/10/10 23:18:03	1.2
@@ -30,6 +30,16 @@
 # define NFS_SUPER_MAGIC	0x6969
 #endif
 
+#define NFSD_BUFSIZE		(1024 + NFSSVC_MAXBLKSIZE)
+
+#ifdef CONFIG_NFSD_V4
+# define NFSSVC_XDRSIZE		NFS4_SVC_XDRSIZE
+#elif defined(CONFIG_NFSD_V3)
+# define NFSSVC_XDRSIZE		NFS3_SVC_XDRSIZE
+#else
+# define NFSSVC_XDRSIZE		NFS2_SVC_XDRSIZE
+#endif
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_NFSD_CONST_H */
--- ./fs/nfsd/nfssvc.c	2002/10/10 23:18:00	1.1
+++ ./fs/nfsd/nfssvc.c	2002/10/10 23:18:04	1.2
@@ -31,10 +31,11 @@
 #include <linux/nfsd/stats.h>
 #include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr.h>
+#include <linux/nfsd/xdr3.h>
+#include <linux/nfsd/xdr4.h>
 #include <linux/lockd/bind.h>
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
-#define NFSD_BUFSIZE		(1024 + NFSSVC_MAXBLKSIZE)
 
 /* these signals will be delivered to an nfsd thread 
  * when handling a request


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
