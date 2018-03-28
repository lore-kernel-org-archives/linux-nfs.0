Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59452 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751166AbeC1SDf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Mar 2018 14:03:35 -0400
Date: Wed, 28 Mar 2018 14:03:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Eric Biggers <ebiggers@google.com>
Cc: Michael Young <m.a.young@durham.ac.uk>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFS mounts failing when keytab present on client
Message-ID: <20180328180334.GB3354@fieldses.org>
References: <alpine.LFD.2.21.1803272126070.3013@austen3.home>
 <20180327222950.GB257332@google.com>
 <20180328154628.GA3038@fieldses.org>
 <20180328175051.GB185597@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180328175051.GB185597@google.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2018 at 10:50:51AM -0700, Eric Biggers wrote:
> On Wed, Mar 28, 2018 at 11:46:28AM -0400, J. Bruce Fields wrote:
> > On Tue, Mar 27, 2018 at 03:29:50PM -0700, Eric Biggers wrote:
> > > Hi Michael,
> > > 
> > > On Tue, Mar 27, 2018 at 11:06:14PM +0100, Michael Young wrote:
> > > > NFS mounts stopped working on one of my computers after a kernel update from
> > > > 4.15.3 to 4.15.4. I traced the problem to the commit
> > > > [46e8d06e423c4f35eac7a8b677b713b3ec9b0684] crypto: hash - prevent using
> > > > keyed hashes without setting key
> > > > and a later kernel with this patch reverted works normally.
> > > > 
> > > > The problem seems to be related to kerberos as the mount fails when the
> > > > keytab is present, but works if I rename the keytab file. This is true even
> > > > though the mount is with sec=sys . The mount should also work with sec=krb5
> > > > but that also fails in the same way. When the mount fails there are errors
> > > > in dmesg like
> > > > [ 1232.522816] gss_marshal: gss_get_mic FAILED (851968)
> > > > [ 1232.522819] RPC: couldn't encode RPC header, exit EIO
> > > > [ 1232.522856] gss_marshal: gss_get_mic FAILED (851968)
> > > > [ 1232.522857] RPC: couldn't encode RPC header, exit EIO
> > > > [ 1232.522863] NFS: nfs4_discover_server_trunking unhandled error -5.
> > > > Exiting with error EIO
> > > > [ 1232.525039] gss_marshal: gss_get_mic FAILED (851968)
> > > > [ 1232.525042] RPC: couldn't encode RPC header, exit EIO
> > > > 
> > > > 	Michael Young
> > > 
> > > Thanks for the bug report.  I think the error is coming from
> > > net/sunrpc/auth_gss/gss_krb5_crypto.c.  There are two potential problems I see.
> > > The first one, which is definitely a bug, is that make_checksum_hmac_md5()
> > > allocates an HMAC transform and request, then does these crypto API calls:
> > > 
> > > 	crypto_ahash_init()
> > > 	crypto_ahash_setkey()
> > > 	crypto_ahash_digest()
> > > 
> > > This is wrong because it makes no sense to init() the HMAC request before the
> > > key has been set, and doubly so when it's calling digest() which is shorthand
> > > for init() + update() + final().  So I think it just needs to be removed.  You
> > > can test the following patch:
> > 
> > When was this introduced? 
> > 
> > 3b5cf20cf439 "sunrpc: Use skcipher and ahash/shash"
> > 	- probably not, assuming the above was still just as wrong with
> > 	  crypto_hash_{init,setkey,digest} as it is with
> > 	  crypto_ahash_{init,setkey,digest}
> > 
> > So I'm guessing it was wrong from the start when it was added by
> > fffdaef2eb4a "gss_krb5: Add support for rc4-hmac encryption" 8 years
> > ago.  Wonder why it took this long to notice?  Did something else
> > change?
> > 
> > --b.
> 
> It was wrong from the start, but the crypto API only recently started enforcing
> that the key has to be set before init() or digest() is called.  Before that the
> code was just doing unnecessary work, at least with the software HMAC
> implementation.  Though, there are also hardware crypto drivers that implement
> HMAC-MD5, and it's not immediately obvious that they handle init() before
> setkey() as gracefully as the software implementation.

Thanks, got it.  Do you know how to find a commit id for that change?
It's not entirely fair to blame the crypto change for what was really a
latent nfs bug, but it might still be worth adding a Fixes: line just so
people know where it needs backporting.

--b.
