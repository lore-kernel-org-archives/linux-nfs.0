Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51338 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751795AbcJ1NWS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Oct 2016 09:22:18 -0400
Date: Fri, 28 Oct 2016 09:22:17 -0400
From: Fields Bruce James <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Rusty Russell <rusty@rustcorp.com.au>,
        Christoph Hellwig <hch@infradead.org>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: don't pass on-stack memory to sg_set_buf
Message-ID: <20161028132217.GB8154@fieldses.org>
References: <20161025184538.GA4612@fieldses.org>
 <A4086E5B-B808-4828-A25D-4AAB2504EC57@primarydata.com>
 <20161025195930.GB5129@fieldses.org>
 <DB39073B-8C4B-48BC-8D46-7B6173966037@primarydata.com>
 <20161028132008.GA8154@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20161028132008.GA8154@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 28, 2016 at 09:20:08AM -0400, Fields Bruce James wrote:
> On Tue, Oct 25, 2016 at 09:47:16PM +0000, Trond Myklebust wrote:
> > 
> > > On Oct 25, 2016, at 15:59, Fields Bruce James <bfields@fieldses.org> wrote:
> > > 
> > > On Tue, Oct 25, 2016 at 07:34:43PM +0000, Trond Myklebust wrote:
> > >> NACK…  I agree that there may already be borkage in RPCSEC_GSS-land, but that’s not a reason to be adding to the pile of things that need to be fixed… The allocations that lie in the RPC client’s encode/decode path do need to be GFP_NOFS….
> > > 
> > > OK.  Any disadvantage to keeping this patch with just GFP_NOFS
> > > allocations everywhere that might be in the write path?
> > 
> > It’s what we have to do everywhere else in the RPC client, so I can’t see why it should be a problem.
> 
> OK, the below is what I intend to merge if nobody spots another problem.

And we may as well fix up some more easy stuff while we're there.

And actually moving the other crypto_alloc_* calls may be pretty easy
too, I'll see if I can get to it later....

--b.

commit 7e72f3a7c4db
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Oct 26 16:03:00 2016 -0400

    sunrpc: GFP_KERNEL should be GFP_NOFS in crypto code
    
    Writes may depend on the auth_gss crypto code, so we shouldn't be
    allocating with GFP_KERNEL there.
    
    This still leaves some crypto_alloc_* calls which end up doing
    GFP_KERNEL allocations in the crypto code.  Those could probably done at
    crypto import time.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 90115ceefd49..fb39284ec174 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -200,7 +200,7 @@ make_checksum_hmac_md5(struct krb5_ctx *kctx, char *header, int hdrlen,
 	if (IS_ERR(hmac_md5))
 		goto out_free_md5;
 
-	req = ahash_request_alloc(md5, GFP_KERNEL);
+	req = ahash_request_alloc(md5, GFP_NOFS);
 	if (!req)
 		goto out_free_hmac_md5;
 
@@ -230,7 +230,7 @@ make_checksum_hmac_md5(struct krb5_ctx *kctx, char *header, int hdrlen,
 		goto out;
 
 	ahash_request_free(req);
-	req = ahash_request_alloc(hmac_md5, GFP_KERNEL);
+	req = ahash_request_alloc(hmac_md5, GFP_NOFS);
 	if (!req)
 		goto out_free_hmac_md5;
 
@@ -299,7 +299,7 @@ make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
 	if (IS_ERR(tfm))
 		goto out_free_cksum;
 
-	req = ahash_request_alloc(tfm, GFP_KERNEL);
+	req = ahash_request_alloc(tfm, GFP_NOFS);
 	if (!req)
 		goto out_free_ahash;
 
@@ -397,7 +397,7 @@ make_checksum_v2(struct krb5_ctx *kctx, char *header, int hdrlen,
 		goto out_free_cksum;
 	checksumlen = crypto_ahash_digestsize(tfm);
 
-	req = ahash_request_alloc(tfm, GFP_KERNEL);
+	req = ahash_request_alloc(tfm, GFP_NOFS);
 	if (!req)
 		goto out_free_ahash;
 
@@ -963,7 +963,7 @@ krb5_rc4_setup_seq_key(struct krb5_ctx *kctx, struct crypto_skcipher *cipher,
 	}
 
 	desc = kmalloc(sizeof(*desc) + crypto_shash_descsize(hmac),
-		       GFP_KERNEL);
+		       GFP_NOFS);
 	if (!desc) {
 		dprintk("%s: failed to allocate shash descriptor for '%s'\n",
 			__func__, kctx->gk5e->cksum_name);
@@ -1030,7 +1030,7 @@ krb5_rc4_setup_enc_key(struct krb5_ctx *kctx, struct crypto_skcipher *cipher,
 	}
 
 	desc = kmalloc(sizeof(*desc) + crypto_shash_descsize(hmac),
-		       GFP_KERNEL);
+		       GFP_NOFS);
 	if (!desc) {
 		dprintk("%s: failed to allocate shash descriptor for '%s'\n",
 			__func__, kctx->gk5e->cksum_name);
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 60595835317a..7bb2514aadd9 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -451,8 +451,7 @@ context_derive_keys_rc4(struct krb5_ctx *ctx)
 		goto out_err_free_hmac;
 
 
-	desc = kmalloc(sizeof(*desc) + crypto_shash_descsize(hmac),
-		       GFP_KERNEL);
+	desc = kmalloc(sizeof(*desc) + crypto_shash_descsize(hmac), GFP_NOFS);
 	if (!desc) {
 		dprintk("%s: failed to allocate hash descriptor for '%s'\n",
 			__func__, ctx->gk5e->cksum_name);
