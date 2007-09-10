From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH 03/19] NFS: move nfs_parsed_mount_data structure
 definition
Date: Mon, 10 Sep 2007 13:43:29 -0400
Message-ID: <EXNANE01eDKvPEkGhAj000004b2@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUnX0-00031I-Iz
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 10:58:42 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUnX5-0001o6-6u
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 10:58:47 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8AHwfs4024982
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 10:58:41 -0700 (PDT)
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

NFS: move nfs_parsed_mount_data structure definition

In preparation for rearranging the nfs mount argument passing, make the
nfs_parsed_mount_data struct visible across nfs kernel files.

Signed-off-by: Tom Talpey <tmt@netapp.com>
Acked-by: Chuck Lever <chuck.lever@oracle.com>

---

 fs/nfs/internal.h |   32 ++++++++++++++++++++++++++++++++
 fs/nfs/super.c    |   30 ------------------------------
 2 files changed, 32 insertions(+), 30 deletions(-)

Index: kernel/fs/nfs/super.c
===================================================================
--- kernel.orig/fs/nfs/super.c
+++ kernel/fs/nfs/super.c
@@ -58,36 +58,6 @@
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
-
-struct nfs_parsed_mount_data {
-	int			flags;
-	int			rsize, wsize;
-	int			timeo, retrans;
-	int			acregmin, acregmax,
-				acdirmin, acdirmax;
-	int			namlen;
-	unsigned int		bsize;
-	unsigned int		auth_flavor_len;
-	rpc_authflavor_t	auth_flavors[1];
-	char			*client_address;
-
-	struct {
-		struct sockaddr_in	address;
-		unsigned int		program;
-		unsigned int		version;
-		unsigned short		port;
-		int			protocol;
-	} mount_server;
-
-	struct {
-		struct sockaddr_in	address;
-		char			*hostname;
-		char			*export_path;
-		unsigned int		program;
-		int			protocol;
-	} nfs_server;
-};
-
 enum {
 	/* Mount options that take no arguments */
 	Opt_soft, Opt_hard,
Index: kernel/fs/nfs/internal.h
===================================================================
--- kernel.orig/fs/nfs/internal.h
+++ kernel/fs/nfs/internal.h
@@ -27,6 +27,38 @@ struct nfs_clone_mount {
 	rpc_authflavor_t authflavor;
 };
 
+/*
+ * In-kernel mount arguments
+ */
+struct nfs_parsed_mount_data {
+	int			flags;
+	int			rsize, wsize;
+	int			timeo, retrans;
+	int			acregmin, acregmax,
+				acdirmin, acdirmax;
+	int			namlen;
+	unsigned int		bsize;
+	unsigned int		auth_flavor_len;
+	rpc_authflavor_t	auth_flavors[1];
+	char			*client_address;
+
+	struct {
+		struct sockaddr_in	address;
+		unsigned int		program;
+		unsigned int		version;
+		unsigned short		port;
+		int			protocol;
+	} mount_server;
+
+	struct {
+		struct sockaddr_in	address;
+		char			*hostname;
+		char			*export_path;
+		unsigned int		program;
+		int			protocol;
+	} nfs_server;
+};
+
 /* client.c */
 extern struct rpc_program nfs_program;
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
