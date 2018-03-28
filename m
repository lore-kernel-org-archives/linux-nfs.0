Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hermes2.dur.ac.uk ([129.234.7.139]:37676 "EHLO
        hermes2.dur.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751434AbeC1IIa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2018 04:08:30 -0400
Date: Wed, 28 Mar 2018 09:00:14 +0100 (BST)
From: M A Young <m.a.young@durham.ac.uk>
To: Eric Biggers <ebiggers@google.com>
cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFS mounts failing when keytab present on client
In-Reply-To: <20180327222950.GB257332@google.com>
Message-ID: <alpine.LFD.2.21.1803280857200.2500@algedi.dur.ac.uk>
References: <alpine.LFD.2.21.1803272126070.3013@austen3.home> <20180327222950.GB257332@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 27 Mar 2018, Eric Biggers wrote:

> Hi Michael,
> 
> On Tue, Mar 27, 2018 at 11:06:14PM +0100, Michael Young wrote:
> > NFS mounts stopped working on one of my computers after a kernel update from
> > 4.15.3 to 4.15.4. I traced the problem to the commit
> > [46e8d06e423c4f35eac7a8b677b713b3ec9b0684] crypto: hash - prevent using
> > keyed hashes without setting key
> > and a later kernel with this patch reverted works normally.
> > 
> > The problem seems to be related to kerberos as the mount fails when the
> > keytab is present, but works if I rename the keytab file. This is true even
> > though the mount is with sec=sys . The mount should also work with sec=krb5
> > but that also fails in the same way. When the mount fails there are errors
> > in dmesg like
> > [ 1232.522816] gss_marshal: gss_get_mic FAILED (851968)
> > [ 1232.522819] RPC: couldn't encode RPC header, exit EIO
> > [ 1232.522856] gss_marshal: gss_get_mic FAILED (851968)
> > [ 1232.522857] RPC: couldn't encode RPC header, exit EIO
> > [ 1232.522863] NFS: nfs4_discover_server_trunking unhandled error -5.
> > Exiting with error EIO
> > [ 1232.525039] gss_marshal: gss_get_mic FAILED (851968)
> > [ 1232.525042] RPC: couldn't encode RPC header, exit EIO
> > 
> > 	Michael Young
> 
> Thanks for the bug report.  I think the error is coming from
> net/sunrpc/auth_gss/gss_krb5_crypto.c.  There are two potential problems I see.
> The first one, which is definitely a bug, is that make_checksum_hmac_md5()
> allocates an HMAC transform and request, then does these crypto API calls:
> 
> 	crypto_ahash_init()
> 	crypto_ahash_setkey()
> 	crypto_ahash_digest()
> 
> This is wrong because it makes no sense to init() the HMAC request before the
> key has been set, and doubly so when it's calling digest() which is shorthand
> for init() + update() + final().  So I think it just needs to be removed.  You
> can test the following patch:
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> index 12649c9fedab..8654494b4d0a 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> @@ -237,9 +237,6 @@ make_checksum_hmac_md5(struct krb5_ctx *kctx, char *header, int hdrlen,
>  
>         ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, NULL);
>  
> -       err = crypto_ahash_init(req);
> -       if (err)
> -               goto out;
>         err = crypto_ahash_setkey(hmac_md5, cksumkey, kctx->gk5e->keylength);
>         if (err)
>                 goto out;
> 
> If that's not it, it's also possible that the error is coming from the
> crypto_ahash_init() in make_checksum().  That can only happen if 'cksumkey' is
> NULL and the hash algorithm is keyed, which implies a logical error as it
> doesn't make sense to use a keyed hash algorithm without the key.  The callers
> do check kctx->gk5e->keyed_cksum which I'd hope would prevent this, though
> perhaps kctx->cksum can be NULL.
> 
> Eric

The patch fixes the problem.

	Michael Young
