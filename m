From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Another possible race in put_rpccred / rpcauth_unhash_cred
Date: Fri, 20 Nov 2009 11:48:46 -0500
Message-ID: <1258735726.2494.27.camel@localhost>
References: <19203.18009.945354.446817@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:43029 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753437AbZKTQsn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2009 11:48:43 -0500
In-Reply-To: <19203.18009.945354.446817-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-11-18 at 11:56 +1100, Neil Brown wrote: 
> Hi again Trond,
> 
>  I've been looking at a customer report of an oops in
>  rpcauth_lookup_credcache.
>    https://bugzilla.novell.com/show_bug.cgi?id=547137
>  
>  It appears that one of the hash chains in the cache has become
>  corrupted.

How about the following patch?

Cheers
  Trond
-------------------------------------------------------------------------- 
RPC: Fix two potential races in put_rpccred

From: Trond Myklebust <Trond.Myklebust@netapp.com>

It is possible for rpcauth_destroy_credcache() to cause the rpc credentials
to be unhashed while put_rpccred is waiting for the rpc_credcache_lock on
another cpu.
Should this happen, then we can end up calling hlist_del_rcu(&cred->cr_hash)
a second time, thus causing list corruption.


Should the credential actually be hashed, it is possible for
rpcauth_lookup_credcache to find and reference it before we get round to
unhashing it. We should therefore check for whether the credential is
referenced after we've unhashed it.
See https://bugzilla.novell.com/show_bug.cgi?id=547137

Reported-by: Neil Brown <neilb@suse.de>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth.c |   39 +++++++++++++++++++++++----------------
 1 files changed, 23 insertions(+), 16 deletions(-)


diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 54a4e04..7ee6f7e 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -123,16 +123,19 @@ rpcauth_unhash_cred_locked(struct rpc_cred *cred)
 	clear_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags);
 }
 
-static void
+static int
 rpcauth_unhash_cred(struct rpc_cred *cred)
 {
 	spinlock_t *cache_lock;
+	int ret;
 
 	cache_lock = &cred->cr_auth->au_credcache->lock;
 	spin_lock(cache_lock);
-	if (atomic_read(&cred->cr_count) == 0)
+	ret = atomic_read(&cred->cr_count) == 0;
+	if (ret)
 		rpcauth_unhash_cred_locked(cred);
 	spin_unlock(cache_lock);
+	return ret;
 }
 
 /*
@@ -446,31 +449,35 @@ void
 put_rpccred(struct rpc_cred *cred)
 {
 	/* Fast path for unhashed credentials */
-	if (test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0)
-		goto need_lock;
-
-	if (!atomic_dec_and_test(&cred->cr_count))
+	if (test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) == 0) {
+		if (atomic_dec_and_test(&cred->cr_count))
+			cred->cr_ops->crdestroy(cred);
 		return;
-	goto out_destroy;
-need_lock:
+	}
+
 	if (!atomic_dec_and_lock(&cred->cr_count, &rpc_credcache_lock))
 		return;
 	if (!list_empty(&cred->cr_lru)) {
 		number_cred_unused--;
 		list_del_init(&cred->cr_lru);
 	}
-	if (test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) == 0)
-		rpcauth_unhash_cred(cred);
 	if (test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0) {
-		cred->cr_expire = jiffies;
-		list_add_tail(&cred->cr_lru, &cred_unused);
-		number_cred_unused++;
-		spin_unlock(&rpc_credcache_lock);
-		return;
+		if (test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) != 0) {
+			cred->cr_expire = jiffies;
+			list_add_tail(&cred->cr_lru, &cred_unused);
+			number_cred_unused++;
+			goto out_nodestroy;
+		}
+		if (!rpcauth_unhash_cred(cred)) {
+			/* We were hashed and someone looked us up... */
+			goto out_nodestroy;
+		}
 	}
 	spin_unlock(&rpc_credcache_lock);
-out_destroy:
 	cred->cr_ops->crdestroy(cred);
+	return;
+out_nodestroy:
+	spin_unlock(&rpc_credcache_lock);
 }
 EXPORT_SYMBOL_GPL(put_rpccred);
 


