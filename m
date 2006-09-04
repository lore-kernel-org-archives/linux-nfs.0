From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] make fs/lockd/host.c:nlm_lookup_host() static
Date: Mon, 4 Sep 2006 19:03:59 +0200
Message-ID: <20060904170359.GS4416@stusta.de>
References: <20060901015818.42767813.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964901AbWIDREG@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Olaf Kirch <okir@suse.de>,
	Neil Brown <neilb@suse.de>
In-Reply-To: <20060901015818.42767813.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Sep 01, 2006 at 01:58:18AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.18-rc4-mm3:
>...
> +knfsd-hide-use-of-lockds-h_monitored-flag.patch
> +knfsd-consolidate-common-code-for-statd-lockd-notification.patch
> +knfsd-when-looking-up-a-lockd-host-pass-hostname-length.patch
> +knfsd-lockd-introduce-nsm_handle.patch
> +knfsd-misc-minor-fixes-indentation-changes.patch
> +knfsd-lockd-make-nlm_host_rebooted-use-the-nsm_handle.patch
> +knfsd-lockd-make-the-nsm-upcalls-use-the-nsm_handle.patch
> +knfsd-lockd-make-the-hash-chains-use-a-hlist_node.patch
> +knfsd-lockd-change-list-of-blocked-list-to-list_node.patch
> +knfsd-change-nlm_file-to-use-a-hlist.patch
> +knfsd-lockd-make-nlm_traverse_-more-flexible.patch
> +knfsd-lockd-add-nlm_destroy_host.patch
> +knfsd-simplify-nlmsvc_invalidate_all.patch
> +knfsd-lockd-optionally-use-hostnames-for-identifying-peers.patch
> +knfsd-make-nlmclnt_next_cookie-smp-safe.patch
> +knfsd-match-granted_res-replies-using-cookies.patch
> +knfsd-export-nsm_local_state-to-user-space-via-sysctl.patch
> +knfsd-lockd-fix-use-of-h_nextrebind.patch
> +knfsd-register-all-rpc-programs-with-portmapper-by-default.patch
> 
>  nfsd updates.
>...

nlm_lookup_host() can now become static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 fs/lockd/host.c             |   48 ++++++++++++++++++------------------
 include/linux/lockd/lockd.h |    1 
 2 files changed, 24 insertions(+), 25 deletions(-)

--- linux-2.6.18-rc5-mm1/include/linux/lockd/lockd.h.old	2006-09-01 20:57:28.000000000 +0200
+++ linux-2.6.18-rc5-mm1/include/linux/lockd/lockd.h	2006-09-01 20:57:34.000000000 +0200
@@ -164,7 +164,6 @@
  */
 struct nlm_host * nlmclnt_lookup_host(const struct sockaddr_in *, int, int, const char *, int);
 struct nlm_host * nlmsvc_lookup_host(struct svc_rqst *, const char *, int);
-struct nlm_host * nlm_lookup_host(int server, const struct sockaddr_in *, int, int, const char *, int);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);
 void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);
--- linux-2.6.18-rc5-mm1/fs/lockd/host.c.old	2006-09-01 20:57:42.000000000 +0200
+++ linux-2.6.18-rc5-mm1/fs/lockd/host.c	2006-09-01 20:58:25.000000000 +0200
@@ -38,32 +38,9 @@
 					const char *, int, int);
 
 /*
- * Find an NLM server handle in the cache. If there is none, create it.
- */
-struct nlm_host *
-nlmclnt_lookup_host(const struct sockaddr_in *sin, int proto, int version,
-			const char *hostname, int hostname_len)
-{
-	return nlm_lookup_host(0, sin, proto, version,
-			       hostname, hostname_len);
-}
-
-/*
- * Find an NLM client handle in the cache. If there is none, create it.
- */
-struct nlm_host *
-nlmsvc_lookup_host(struct svc_rqst *rqstp,
-			const char *hostname, int hostname_len)
-{
-	return nlm_lookup_host(1, &rqstp->rq_addr,
-			       rqstp->rq_prot, rqstp->rq_vers,
-			       hostname, hostname_len);
-}
-
-/*
  * Common host lookup routine for server & client
  */
-struct nlm_host *
+static struct nlm_host *
 nlm_lookup_host(int server, const struct sockaddr_in *sin,
 					int proto, int version,
 					const char *hostname,
@@ -165,6 +142,29 @@
 }
 
 /*
+ * Find an NLM server handle in the cache. If there is none, create it.
+ */
+struct nlm_host *
+nlmclnt_lookup_host(const struct sockaddr_in *sin, int proto, int version,
+			const char *hostname, int hostname_len)
+{
+	return nlm_lookup_host(0, sin, proto, version,
+			       hostname, hostname_len);
+}
+
+/*
+ * Find an NLM client handle in the cache. If there is none, create it.
+ */
+struct nlm_host *
+nlmsvc_lookup_host(struct svc_rqst *rqstp,
+			const char *hostname, int hostname_len)
+{
+	return nlm_lookup_host(1, &rqstp->rq_addr,
+			       rqstp->rq_prot, rqstp->rq_vers,
+			       hostname, hostname_len);
+}
+
+/*
  * Destroy a host
  */
 static void
