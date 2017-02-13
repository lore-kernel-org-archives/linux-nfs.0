Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52960 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750753AbdBMEqu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 12 Feb 2017 23:46:50 -0500
From: NeilBrown <neilb@suse.com>
To: Chris Siebenmann <cks.nfs01@cs.toronto.edu>, linux-nfs@vger.kernel.org
Date: Mon, 13 Feb 2017 15:46:10 +1100
Cc: cks.nfs01@cs.toronto.edu
Subject: Re: Manual page bug: two inaccuracies in nfsd(7)
In-Reply-To: <20170210185410.7425E5A06F8@apps1.cs.toronto.edu>
References: <20170210185410.7425E5A06F8@apps1.cs.toronto.edu>
Message-ID: <87tw7y4s19.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Fri, Feb 10 2017, Chris Siebenmann wrote:

>  I was recently reading this manual page as part of exploring running
> an NFS server on Ubuntu 16.04 (with Ubuntu's kernel '4.4.0') and found
> two inaccuracies with the current state of the kernel (or at least how
> it looks to me based on both experimentation and code).
>
>  First, there is no /proc/net/rpc/auth.domain directory and cache any
> more. This was removed from the kernel in 2006 (in commit efc36aa5608f),
> so I think it should be safe to remove from current versions of the
> manpage.

I agree.

>
>  Second, the manpage says about the 'flush' files to be found in eg
> /proc/net/rpc/auth.unix.ip:
>
> 	When a number of seconds since epoch (1 Jan 1970) is written to
> 	this file, all entries in the cache that were last updated before
> 	that file become invalidated and will be flushed out. Writing
> 	1 will flush everything. [...]
>
> The bit about 'writing 1 will flush everything' does not appear to be
> accurate.

I was never accurate.  I vaguely remember writing it.  I must have been
confused.

Would you be able to create a patch which fixes these issues, and post
it, with a signed-off-by ?

Thanks,
NeilBrown



>            Experimentally, writing 1 does not work (it flushes nothing),
> and in the current kernel code there is no special handling for a write of
> '1' to the "flush" files in net/sunrpc/cache.c's write_flush() function,
> which I believe is where this is implemented. Based on the implementation,
> the only way to flush everything is to write a time in the future to
> "flush".
>
>  Based on looking at the kernel logs and code diffs, this may have
> changed in commit 778620364ef5, 'sunrpc/cache: make cache flushing more
> reliable', which gitk tells me came between v4.3-rc3 and v4.4-rc1 (it
> was made in October 2015). The commit description definitely talks about
> changing how cache expiry works, and it touches write_flush() et al in
> various ways. This may call for a kernel change to make it work again,
> but even if so I would suggest that the manpage be updated to reflect
> that writing 1 doesn't work in a range of kernel versions (some of which
> will be in the field for years to come, eg Ubuntu 16.04 LTS).
>
> 	- cks
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlihOhIACgkQOeye3VZi
gbnW9A/8CAAAqx+/1ENovmw7K8nao1tyvmfUXj+xD2n6gLLn8XlV/dq/lN4zYRkK
T84E3s4jqDzBV/PY5iegamCq7Xq6s64BzDufKZNRMWm+PlcF/cZIw+qMFRIoGcll
C/E3YgHmJLpPDBMx0ETwZuv3Rh3IB6ureYHOLzc8TiNRDe1VLERzMTHUJtNFumd7
DVU3oI1FRyFRjiBkJXcqk5SBy4SPrUhWqPpjRaDlM0RcAfhkakgvZ2lDWQNBo9/Z
Dtx/QV0gzlwNVwK94+mTWsVAy5gXY/gbfoQKY6QAFFacF4J9Vu2bMIuhFmdV94nS
Ad3OEa9xsX1YMHFiDK3yHCYGQHlfS9wE9Bo4f8jeaacS7V/BjKK8KNqIJwPO2Xj2
SkCCqS+U29AeCXaJ+ikwgcJYaO99S46vttNqgx2OrSna6KO9wAZWutgzhze5yjZi
Jlv959O6aKfS06FBWO24ERCBlJZvv+NRwIFjn/kwFXtpOnCZaYimn2y3eYJtr5Zn
f0PdFfywpwVRed1dTt37E83cW+TnMfvHt/+2Vtj+tMnJiPqW/MzUfkY2TDXDiO6x
S3+/exncDSOZXKgK2D5P7b92LTMdz3NIWencpuHP5FFuqN+U+giQYWBqAMq/5aLJ
/YPQPovLr1dpqySlA9LPzR4NBkhFizl44JO6AJc1waNLD47omD8=
=JpS7
-----END PGP SIGNATURE-----
--=-=-=--
