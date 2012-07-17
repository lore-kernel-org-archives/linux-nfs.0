Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:43531 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755485Ab2GQTLh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jul 2012 15:11:37 -0400
Message-ID: <5005B8D7.8090600@netapp.com>
Date: Tue, 17 Jul 2012 15:11:19 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Trond.Myklebust@netapp.com
CC: linux-nfs@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH v3 04/12] NFS: Create an init_nfs_v4() function
References: <1342471161-22452-1-git-send-email-bjschuma@netapp.com> <1342471161-22452-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1342471161-22452-5-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch should work better, thanks Fengguang!

- Bryan



I want to initialize all of NFS v4 in a single function that will
eventually be used as the v4 module init function.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
v3:  Don't declare exit_nfs_v4() as an __exit  function
 fs/nfs/Makefile    |  2 +-
 fs/nfs/inode.c     | 67 ++++++++++++++++++++++++++++++------------------------
 fs/nfs/nfs4_fs.h   |  4 ++++
 fs/nfs/nfs4super.c | 23 +++++++++++++++++++
 4 files changed, 65 insertions(+), 31 deletions(-)
 create mode 100644 fs/nfs/nfs4super.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 7ddd45d..162a699 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -13,7 +13,7 @@ nfs-$(CONFIG_NFS_V2)	+= proc.o nfs2xdr.o
 nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
-			   delegation.o idmap.o \
+			   nfs4super.o delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
 			   nfs4namespace.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 28c9ebb..35f7e4b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -32,7 +32,6 @@
 #include <linux/lockd/bind.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
-#include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
 #include <linux/nfs_xdr.h>
@@ -1628,87 +1627,96 @@ static int __init init_nfs_fs(void)
 {
 	int err;
 
-	err = nfs_idmap_init();
-	if (err < 0)
-		goto out10;
-
 	err = nfs_dns_resolver_init();
 	if (err < 0)
-		goto out9;
+		goto out11;
 
 	err = register_pernet_subsys(&nfs_net_ops);
 	if (err < 0)
-		goto out8;
+		goto out10;
 
 	err = nfs_fscache_register();
 	if (err < 0)
-		goto out7;
+		goto out9;
 
 	err = nfsiod_start();
 	if (err)
-		goto out6;
+		goto out8;
 
 	err = nfs_fs_proc_init();
 	if (err)
-		goto out5;
+		goto out7;
 
 	err = nfs_init_nfspagecache();
 	if (err)
-		goto out4;
+		goto out6;
 
 	err = nfs_init_inodecache();
 	if (err)
-		goto out3;
+		goto out5;
 
 	err = nfs_init_readpagecache();
 	if (err)
-		goto out2;
+		goto out4;
 
 	err = nfs_init_writepagecache();
 	if (err)
-		goto out1;
+		goto out3;
-		goto out0;
+		goto out2;
 
 #ifdef CONFIG_PROC_FS
 	rpc_proc_register(&init_net, &nfs_rpcstat);
 #endif
+
+#ifdef CONFIG_NFS_V4
+	err = init_nfs_v4();
+	if (err)
+		goto out1;
+#endif
+
 	if ((err = register_nfs_fs()) != 0)
-		goto out;
+		goto out0;
+
 	return 0;
-out:
+out0:
+#ifdef CONFIG_NFS_V4
+	exit_nfs_v4();
+out1:
+#endif
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister(&init_net, "nfs");
 #endif
 	nfs_destroy_directcache();
-out0:
-	nfs_destroy_writepagecache();
-out1:
-	nfs_destroy_readpagecache();
 out2:
-	nfs_destroy_inodecache();
+	nfs_destroy_writepagecache();
 out3:
-	nfs_destroy_nfspagecache();
+	nfs_destroy_readpagecache();
 out4:
-	nfs_fs_proc_exit();
+	nfs_destroy_inodecache();
 out5:
-	nfsiod_stop();
+	nfs_destroy_nfspagecache();
 out6:
-	nfs_fscache_unregister();
+	nfs_fs_proc_exit();
 out7:
-	unregister_pernet_subsys(&nfs_net_ops);
+	nfsiod_stop();
 out8:
-	nfs_dns_resolver_destroy();
+	nfs_fscache_unregister();
 out9:
-	nfs_idmap_quit();
+	unregister_pernet_subsys(&nfs_net_ops);
 out10:
+	nfs_dns_resolver_destroy();
+out11:
 	return err;
 }
 
 static void __exit exit_nfs_fs(void)
 {
+#ifdef CONFIG_NFS_V4
+	exit_nfs_v4();
+#endif
 	nfs_destroy_directcache();
 	nfs_destroy_writepagecache();
 	nfs_destroy_readpagecache();
@@ -1717,7 +1725,6 @@ static void __exit exit_nfs_fs(void)
 	nfs_fscache_unregister();
 	unregister_pernet_subsys(&nfs_net_ops);
 	nfs_dns_resolver_destroy();
-	nfs_idmap_quit();
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister(&init_net, "nfs");
 #endif
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index e2c4c72..1a6ed3f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -364,6 +364,10 @@ extern void nfs4_free_lock_state(struct nfs_server *server, struct nfs4_lock_sta
 
 extern const nfs4_stateid zero_stateid;
 
+/* nfs4super.c */
+int init_nfs_v4(void);
+void exit_nfs_v4(void);
+
 /* nfs4xdr.c */
 extern struct rpc_procinfo nfs4_procedures[];
 
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
new file mode 100644
index 0000000..baa14d5
--- /dev/null
+++ b/fs/nfs/nfs4super.c
@@ -0,0 +1,23 @@
+/*
+ * Copyright (c) 2012 Bryan Schumaker <bjschuma@netapp.com>
+ */
+#include <linux/init.h>
+#include <linux/nfs_idmap.h>
+
+int __init init_nfs_v4(void)
+{
+	int err;
+
+	err = nfs_idmap_init();
+	if (err)
+		goto out;
+
+	return 0;
+out:
+	return err;
+}
+
+void exit_nfs_v4(void)
+{
+	nfs_idmap_quit();
+}
-- 
1.7.11.2



On 07/16/2012 04:39 PM, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> I want to initialize all of NFS v4 in a single function that will
> eventually be used as the v4 module init function.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/Makefile    |  2 +-
>  fs/nfs/inode.c     | 67 ++++++++++++++++++++++++++++++------------------------
>  fs/nfs/nfs4_fs.h   |  4 ++++
>  fs/nfs/nfs4super.c | 23 +++++++++++++++++++
>  4 files changed, 65 insertions(+), 31 deletions(-)
>  create mode 100644 fs/nfs/nfs4super.c
> 
> diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
> index 7ddd45d..162a699 100644
> --- a/fs/nfs/Makefile
> +++ b/fs/nfs/Makefile
> @@ -13,7 +13,7 @@ nfs-$(CONFIG_NFS_V2)	+= proc.o nfs2xdr.o
>  nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
>  nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
>  nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
> -			   delegation.o idmap.o \
> +			   nfs4super.o delegation.o idmap.o \
>  			   callback.o callback_xdr.o callback_proc.o \
>  			   nfs4namespace.o
>  nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 28c9ebb..35f7e4b 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -32,7 +32,6 @@
>  #include <linux/lockd/bind.h>
>  #include <linux/seq_file.h>
>  #include <linux/mount.h>
> -#include <linux/nfs_idmap.h>
>  #include <linux/vfs.h>
>  #include <linux/inet.h>
>  #include <linux/nfs_xdr.h>
> @@ -1628,87 +1627,96 @@ static int __init init_nfs_fs(void)
>  {
>  	int err;
>  
> -	err = nfs_idmap_init();
> -	if (err < 0)
> -		goto out10;
> -
>  	err = nfs_dns_resolver_init();
>  	if (err < 0)
> -		goto out9;
> +		goto out11;
>  
>  	err = register_pernet_subsys(&nfs_net_ops);
>  	if (err < 0)
> -		goto out8;
> +		goto out10;
>  
>  	err = nfs_fscache_register();
>  	if (err < 0)
> -		goto out7;
> +		goto out9;
>  
>  	err = nfsiod_start();
>  	if (err)
> -		goto out6;
> +		goto out8;
>  
>  	err = nfs_fs_proc_init();
>  	if (err)
> -		goto out5;
> +		goto out7;
>  
>  	err = nfs_init_nfspagecache();
>  	if (err)
> -		goto out4;
> +		goto out6;
>  
>  	err = nfs_init_inodecache();
>  	if (err)
> -		goto out3;
> +		goto out5;
>  
>  	err = nfs_init_readpagecache();
>  	if (err)
> -		goto out2;
> +		goto out4;
>  
>  	err = nfs_init_writepagecache();
>  	if (err)
> -		goto out1;
> +		goto out3;
>  
>  	err = nfs_init_directcache();
>  	if (err)
> -		goto out0;
> +		goto out2;
>  
>  #ifdef CONFIG_PROC_FS
>  	rpc_proc_register(&init_net, &nfs_rpcstat);
>  #endif
> +
> +#ifdef CONFIG_NFS_V4
> +	err = init_nfs_v4();
> +	if (err)
> +		goto out1;
> +#endif
> +
>  	if ((err = register_nfs_fs()) != 0)
> -		goto out;
> +		goto out0;
> +
>  	return 0;
> -out:
> +out0:
> +#ifdef CONFIG_NFS_V4
> +	exit_nfs_v4();
> +out1:
> +#endif
>  #ifdef CONFIG_PROC_FS
>  	rpc_proc_unregister(&init_net, "nfs");
>  #endif
>  	nfs_destroy_directcache();
> -out0:
> -	nfs_destroy_writepagecache();
> -out1:
> -	nfs_destroy_readpagecache();
>  out2:
> -	nfs_destroy_inodecache();
> +	nfs_destroy_writepagecache();
>  out3:
> -	nfs_destroy_nfspagecache();
> +	nfs_destroy_readpagecache();
>  out4:
> -	nfs_fs_proc_exit();
> +	nfs_destroy_inodecache();
>  out5:
> -	nfsiod_stop();
> +	nfs_destroy_nfspagecache();
>  out6:
> -	nfs_fscache_unregister();
> +	nfs_fs_proc_exit();
>  out7:
> -	unregister_pernet_subsys(&nfs_net_ops);
> +	nfsiod_stop();
>  out8:
> -	nfs_dns_resolver_destroy();
> +	nfs_fscache_unregister();
>  out9:
> -	nfs_idmap_quit();
> +	unregister_pernet_subsys(&nfs_net_ops);
>  out10:
> +	nfs_dns_resolver_destroy();
> +out11:
>  	return err;
>  }
>  
>  static void __exit exit_nfs_fs(void)
>  {
> +#ifdef CONFIG_NFS_V4
> +	exit_nfs_v4();
> +#endif
>  	nfs_destroy_directcache();
>  	nfs_destroy_writepagecache();
>  	nfs_destroy_readpagecache();
> @@ -1717,7 +1725,6 @@ static void __exit exit_nfs_fs(void)
>  	nfs_fscache_unregister();
>  	unregister_pernet_subsys(&nfs_net_ops);
>  	nfs_dns_resolver_destroy();
> -	nfs_idmap_quit();
>  #ifdef CONFIG_PROC_FS
>  	rpc_proc_unregister(&init_net, "nfs");
>  #endif
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index e2c4c72..1a6ed3f 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -364,6 +364,10 @@ extern void nfs4_free_lock_state(struct nfs_server *server, struct nfs4_lock_sta
>  
>  extern const nfs4_stateid zero_stateid;
>  
> +/* nfs4super.c */
> +int init_nfs_v4(void);
> +void exit_nfs_v4(void);
> +
>  /* nfs4xdr.c */
>  extern struct rpc_procinfo nfs4_procedures[];
>  
> diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
> new file mode 100644
> index 0000000..366e414
> --- /dev/null
> +++ b/fs/nfs/nfs4super.c
> @@ -0,0 +1,23 @@
> +/*
> + * Copyright (c) 2012 Bryan Schumaker <bjschuma@netapp.com>
> + */
> +#include <linux/init.h>
> +#include <linux/nfs_idmap.h>
> +
> +int __init init_nfs_v4(void)
> +{
> +	int err;
> +
> +	err = nfs_idmap_init();
> +	if (err)
> +		goto out;
> +
> +	return 0;
> +out:
> +	return err;
> +}
> +
> +void __exit exit_nfs_v4(void)
> +{
> +	nfs_idmap_quit();
> +}
> 


