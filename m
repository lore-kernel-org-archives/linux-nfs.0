Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:29065 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755414Ab1KYNO3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Nov 2011 08:14:29 -0500
Subject: [PATCH 2/6] NFS: split cache creation and PipeFS registration
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 25 Nov 2011 17:12:48 +0300
Message-ID: <20111125131248.6271.19003.stgit@localhost6.localdomain6>
In-Reply-To: <20111125130557.6271.95071.stgit@localhost6.localdomain6>
References: <20111125130557.6271.95071.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This precursor patch splits NFS cache creation and PipeFS registartion.
It's required for latter split of NFS DNS resolver cache creation per network
namespace context and PipeFS registration/unregistration on MOUNT/UMOUNT
events.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/cache_lib.c   |   11 +++++++++--
 fs/nfs/cache_lib.h   |    2 ++
 fs/nfs/dns_resolve.c |   11 ++++++++++-
 3 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
index d62a895..9d79a2e 100644
--- a/fs/nfs/cache_lib.c
+++ b/fs/nfs/cache_lib.c
@@ -120,7 +120,6 @@ int nfs_cache_register(struct cache_detail *cd)
 	mnt = rpc_get_mount();
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
-	sunrpc_init_cache_detail(cd);
 	ret = vfs_path_lookup(mnt->mnt_root, mnt, "/cache", 0, &path);
 	if (ret)
 		goto err;
@@ -129,7 +128,6 @@ int nfs_cache_register(struct cache_detail *cd)
 	if (!ret)
 		return ret;
 err:
-	sunrpc_destroy_cache_detail(cd);
 	rpc_put_mount();
 	return ret;
 }
@@ -141,3 +139,12 @@ void nfs_cache_unregister(struct cache_detail *cd)
 	rpc_put_mount();
 }
 
+void nfs_cache_init(struct cache_detail *cd)
+{
+	sunrpc_init_cache_detail(cd);
+}
+
+void nfs_cache_destroy(struct cache_detail *cd)
+{
+	sunrpc_destroy_cache_detail(cd);
+}
diff --git a/fs/nfs/cache_lib.h b/fs/nfs/cache_lib.h
index 7cf6caf..815dd66 100644
--- a/fs/nfs/cache_lib.h
+++ b/fs/nfs/cache_lib.h
@@ -23,5 +23,7 @@ extern struct nfs_cache_defer_req *nfs_cache_defer_req_alloc(void);
 extern void nfs_cache_defer_req_put(struct nfs_cache_defer_req *dreq);
 extern int nfs_cache_wait_for_upcall(struct nfs_cache_defer_req *dreq);
 
+extern void nfs_cache_init(struct cache_detail *cd);
+extern void nfs_cache_destroy(struct cache_detail *cd);
 extern int nfs_cache_register(struct cache_detail *cd);
 extern void nfs_cache_unregister(struct cache_detail *cd);
diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index a6e711a..619dea6 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -361,12 +361,21 @@ ssize_t nfs_dns_resolve_name(char *name, size_t namelen,
 
 int nfs_dns_resolver_init(void)
 {
-	return nfs_cache_register(&nfs_dns_resolve);
+	int err;
+
+	nfs_cache_init(&nfs_dns_resolve);
+	err = nfs_cache_register(&nfs_dns_resolve);
+	if (err) {
+		nfs_cache_destroy(&nfs_dns_resolve);
+		return err;
+	}
+	return 0;
 }
 
 void nfs_dns_resolver_destroy(void)
 {
 	nfs_cache_unregister(&nfs_dns_resolve);
+	nfs_cache_destroy(&nfs_dns_resolve);
 }
 
 #endif

