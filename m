Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60064 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750733AbdALVIa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Jan 2017 16:08:30 -0500
Date: Thu, 12 Jan 2017 16:08:26 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: andros@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version 4] SVCAUTH reap the rsc cache entry on
 RPC_SS_PROC_DESTROY
Message-ID: <20170112210826.GD10501@fieldses.org>
References: <1482428286-33744-1-git-send-email-andros@netapp.com>
 <1482428286-33744-2-git-send-email-andros@netapp.com>
 <20170104202634.GA21562@fieldses.org>
 <8737gymss7.fsf@notabene.neil.brown.name>
 <20170106210111.GA31401@fieldses.org>
 <874m1bloyp.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <874m1bloyp.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 07, 2017 at 10:59:26AM +1100, NeilBrown wrote:
> How about applying
> >> >  -		rsci->h.expiry_time = get_seconds();
> >> >  +		rsci->h.expiry_time = seconds_since_boot();
> 
> first with a Cc: to stable (and a Fixes:), then this patch on top of
> that without the Cc.

Oh, good idea, thanks.  Results below.

commit 78794d189070
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Jan 9 17:15:18 2017 -0500

    svcrpc: don't leak contexts on PROC_DESTROY
    
    Context expiry times are in units of seconds since boot, not unix time.
    
    The use of get_seconds() here therefore sets the expiry time decades in
    the future.  This prevents timely freeing of contexts destroyed by
    client RPC_GSS_PROC_DESTROY requests.  We'd still free them eventually
    (when the module is unloaded or the container shut down), but a lot of
    contexts could pile up before then.
    
    Cc: stable@vger.kernel.org
    Fixes: c5b29f885afe "sunrpc: use seconds since boot in expiry cache"
    Reported-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 886e9d381771..153082598522 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1489,7 +1489,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 	case RPC_GSS_PROC_DESTROY:
 		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
 			goto auth_err;
-		rsci->h.expiry_time = get_seconds();
+		rsci->h.expiry_time = seconds_since_boot();
 		set_bit(CACHE_NEGATIVE, &rsci->h.flags);
 		if (resv->iov_len + 4 > PAGE_SIZE)
 			goto drop;
commit 987a7601aa80
Author: Neil Brown <neilb@suse.com>
Date:   Thu Dec 22 12:38:06 2016 -0500

    svcrpc: free contexts immediately on PROC_DESTROY
    
    We currently handle a client PROC_DESTROY request by turning it
    CACHE_NEGATIVE, setting the expired time to now, and then waiting for
    cache_clean to clean it up later.  Since we forgot to set the cache's
    nextcheck value, that could take up to 30 minutes.  Also, though there's
    probably no real bug in this case, setting CACHE_NEGATIVE directly like
    this probably isn't a great idea in general.
    
    So let's just remove the entry from the cache directly, and move this
    bit of cache manipulation to a helper function.
    
    Signed-off-by: Neil Brown <neilb@suse.com>
    Reported-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 62a60eeacb0a..9dcf2c8fe1c5 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -227,6 +227,7 @@ extern void sunrpc_destroy_cache_detail(struct cache_detail *cd);
 extern int sunrpc_cache_register_pipefs(struct dentry *parent, const char *,
 					umode_t, struct cache_detail *);
 extern void sunrpc_cache_unregister_pipefs(struct cache_detail *);
+extern void sunrpc_cache_unhash(struct cache_detail *, struct cache_head *);
 
 /* Must store cache_detail in seq_file->private if using next three functions */
 extern void *cache_seq_start(struct seq_file *file, loff_t *pos);
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 153082598522..a54a7a3d28f5 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1489,8 +1489,8 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 	case RPC_GSS_PROC_DESTROY:
 		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
 			goto auth_err;
-		rsci->h.expiry_time = seconds_since_boot();
-		set_bit(CACHE_NEGATIVE, &rsci->h.flags);
+		/* Delete the entry from the cache_list and call cache_put */
+		sunrpc_cache_unhash(sn->rsc_cache, &rsci->h);
 		if (resv->iov_len + 4 > PAGE_SIZE)
 			goto drop;
 		svc_putnl(resv, RPC_SUCCESS);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 8147e8d56eb2..502b9fe9817b 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1855,3 +1855,15 @@ void sunrpc_cache_unregister_pipefs(struct cache_detail *cd)
 }
 EXPORT_SYMBOL_GPL(sunrpc_cache_unregister_pipefs);
 
+void sunrpc_cache_unhash(struct cache_detail *cd, struct cache_head *h)
+{
+	write_lock(&cd->hash_lock);
+	if (!hlist_unhashed(&h->cache_list)){
+		hlist_del_init(&h->cache_list);
+		cd->entries--;
+		write_unlock(&cd->hash_lock);
+		cache_put(h, cd);
+	} else
+		write_unlock(&cd->hash_lock);
+}
+EXPORT_SYMBOL_GPL(sunrpc_cache_unhash);
