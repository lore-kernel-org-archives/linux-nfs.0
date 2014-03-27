Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45123 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756061AbaC0OaZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Mar 2014 10:30:25 -0400
Date: Thu, 27 Mar 2014 10:30:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: NFS <linux-nfs@vger.kernel.org>, jlayton@redhat.com
Subject: Re: nfsd needs "md5", but fips=1 disables it -> hang
Message-ID: <20140327143024.GA27633@fieldses.org>
References: <20140327205239.2ea29060@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140327205239.2ea29060@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 27, 2014 at 08:52:39PM +1100, NeilBrown wrote:
> 
> [I sent this 2 days ago but haven't seen it come back on the nfs
>  list and don't see it in the archives.  Maybe someone we cannot name
>  filtered it because it contains the word 'crypto' ??]

Huh.

> Apparently there is a thing called "FIPS" which lists some approved crypto
> algorithms.  And some sites need to only use those.  So they boot their
> kernel with
>     fips=1
> and anything non-fips-approved stops working.
> 
> "md5" is not fips-approved.
> 
> So
> 
> 	desc.tfm = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
> 
> in
> 
> nfs4_make_rec_clidname(char *dname, const struct xdr_netobj *clname)
> 
> 
> always fails when fips=1.  This interferes with efficient NFS service (every
> 'open' hangs).
> 
> s/md5/sha1/
> 
> makes this problem go away, because sha1 is fips-approved.
> 
> My question is: is this safe, or is the hash value used in some external way
> (in /var/lib/nfs/v4recovery ??).

Right, it's used in v4recovery, so you'd lose client state when you
rebooted the server to the new (SHA1-using) server.

Our intention was to migrate people that care about FIPS to the umh
upcall.  But rhel6 has a hack (a private md5 implementation).

Cc'ing jlayton (currently traveling) who did that work.

--b.

> 
> If changing the hash to sha1 is safe, we should do that and probably add
>   select CRYPTO_SHA1
> to Kconfig just to be safe.
> 
> If we really need to keep it stable, I guess we need to find a way to perform
> md5 computations that bypasses the fips checks.
