From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: patch 37/38: SERVER: ensure XDR buffer is large enough for NFSv4
Date: Tue, 13 Aug 2002 19:12:31 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208131912050.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ekq2-0000dO-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 16:12:34 -0700
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


This patch changes the 'xdrsize' parameter to svc_create(), to be
     NFS4_SVC_XDRSIZE   if v4 is defined
else NFS3_SVC_XDRSIZE   if v3 is defined
else NFS2_SVC_XDRSIZE     (formerly NFSSVC_XDRSIZE)

This always works, since
     NFS4_SVC_XDRSIZE >= NFS3_SVC_XDRSIZE >= NFS2_SVC_XDRSIZE.

The value of NFSD_BUFSIZE has also been moved to const.h, since we need
the definition available in nfs4proc.c
--- old/include/linux/nfsd/xdr.h	Wed Jul 24 16:03:30 2002
+++ new/include/linux/nfsd/xdr.h	Thu Aug  8 09:52:45 2002
@@ -119,7 +119,7 @@ union nfsd_xdrstore {
 	struct nfsd_readdirargs	readdir;
 };

-#define NFSSVC_XDRSIZE		sizeof(union nfsd_xdrstore)
+#define NFS2_SVC_XDRSIZE	sizeof(union nfsd_xdrstore)


 int nfssvc_decode_void(struct svc_rqst *, u32 *, void *);
--- old/include/linux/nfsd/const.h	Thu Aug  8 10:38:56 2002
+++ new/include/linux/nfsd/const.h	Thu Aug  8 09:51:10 2002
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
--- old/fs/nfsd/nfssvc.c	Wed Jul 24 16:03:18 2002
+++ new/fs/nfsd/nfssvc.c	Thu Aug  8 09:53:23 2002
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
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
