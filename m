From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH 16/19] NFS: support RDMA mounts
Date: Mon, 10 Sep 2007 13:49:41 -0400
Message-ID: <EXNANE01FT3kMUVfNIJ000004bf@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUndN-0003lN-Vr
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:05:18 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUndS-0008WE-H1
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:05:22 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8AI5B6b027540
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 11:05:12 -0700 (PDT)
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

NFS: support RDMA mounts

Adds hooks to the string-based NFS mount to support an "rdma" protocol option.

Signed-off-by: Tom Talpey <tmt@netapp.com>

---

 fs/nfs/client.c |    2 ++
 fs/nfs/super.c  |   21 +++++++++++++++++++--
 2 files changed, 21 insertions(+), 2 deletions(-)

Index: kernel/fs/nfs/client.c
===================================================================
--- kernel.orig/fs/nfs/client.c
+++ kernel/fs/nfs/client.c
@@ -24,6 +24,7 @@
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/metrics.h>
 #include <linux/sunrpc/xprtsock.h>
+#include <linux/sunrpc/xprtrdma.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
 #include <linux/nfs4_mount.h>
@@ -342,6 +343,7 @@ static void nfs_init_timeout_values(stru
 
 	switch (proto) {
 	case XPRT_TRANSPORT_TCP:
+	case XPRT_TRANSPORT_RDMA:
 		if (!to->to_initval)
 			to->to_initval = 60 * HZ;
 		if (to->to_initval > NFS_MAX_TCP_TIMEOUT)
Index: kernel/fs/nfs/super.c
===================================================================
--- kernel.orig/fs/nfs/super.c
+++ kernel/fs/nfs/super.c
@@ -34,6 +34,7 @@
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/metrics.h>
 #include <linux/sunrpc/xprtsock.h>
+#include <linux/sunrpc/xprtrdma.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
 #include <linux/nfs4_mount.h>
@@ -68,7 +69,7 @@ enum {
 	Opt_ac, Opt_noac,
 	Opt_lock, Opt_nolock,
 	Opt_v2, Opt_v3,
-	Opt_udp, Opt_tcp,
+	Opt_udp, Opt_tcp, Opt_rdma,
 	Opt_acl, Opt_noacl,
 	Opt_rdirplus, Opt_nordirplus,
 	Opt_sharecache, Opt_nosharecache,
@@ -114,6 +115,7 @@ static match_table_t nfs_mount_option_to
 	{ Opt_v3, "v3" },
 	{ Opt_udp, "udp" },
 	{ Opt_tcp, "tcp" },
+	{ Opt_rdma, "rdma" },
 	{ Opt_acl, "acl" },
 	{ Opt_noacl, "noacl" },
 	{ Opt_rdirplus, "rdirplus" },
@@ -152,7 +154,7 @@ static match_table_t nfs_mount_option_to
 };
 
 enum {
-	Opt_xprt_udp, Opt_xprt_tcp,
+	Opt_xprt_udp, Opt_xprt_tcp, Opt_xprt_rdma,
 
 	Opt_xprt_err
 };
@@ -160,6 +162,7 @@ enum {
 static match_table_t nfs_xprt_protocol_tokens = {
 	{ Opt_xprt_udp, "udp" },
 	{ Opt_xprt_tcp, "tcp" },
+	{ Opt_xprt_rdma, "rdma" },
 
 	{ Opt_xprt_err, NULL }
 };
@@ -667,6 +670,12 @@ static int nfs_parse_mount_options(char 
 			mnt->timeo = 600;
 			mnt->retrans = 2;
 			break;
+		case Opt_rdma:
+			mnt->flags |= NFS_MOUNT_TCP; /* for side protocols */
+			mnt->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
+			mnt->timeo = 600;
+			mnt->retrans = 2;
+			break;
 		case Opt_acl:
 			mnt->flags &= ~NFS_MOUNT_NOACL;
 			break;
@@ -882,6 +891,13 @@ static int nfs_parse_mount_options(char 
 				mnt->timeo = 600;
 				mnt->retrans = 2;
 				break;
+			case Opt_xprt_rdma:
+				/* vector side protocols to TCP */
+				mnt->flags |= NFS_MOUNT_TCP;
+				mnt->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
+				mnt->timeo = 600;
+				mnt->retrans = 2;
+				break;
 			default:
 				goto out_unrec_xprt;
 			}
@@ -901,6 +917,7 @@ static int nfs_parse_mount_options(char 
 			case Opt_xprt_tcp:
 				mnt->mount_server.protocol = XPRT_TRANSPORT_TCP;
 				break;
+			case Opt_xprt_rdma: /* not used for side protocols */
 			default:
 				goto out_unrec_xprt;
 			}

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
