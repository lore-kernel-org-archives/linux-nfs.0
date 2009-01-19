From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Mon, 19 Jan 2009 11:24:29 +1100
Message-ID: <20090119112429.78f5dc33.sfr@canb.auug.org.au>
References: <1232223441.3966.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__19_Jan_2009_11_24_29_+1100_YrWGFK.9COO2jjcI"
Cc: Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>,
	urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	linux-media@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, bfields@fieldses.org, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org,
	dbrownell@users.sourceforge.net,
	spi-devel-general@lists.sourceforge.net, netdev@vger.kernel.org,
	greg@kroah.com, linux-usb@vger.kernel.org, dwmw2@infradead.org,
	linux-mtd@lists.infradead.org, tiwai@suse.de,
	mchehab@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jaswinder Singh Rajput <jaswinder@kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:60004 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753306AbZASAYj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 18 Jan 2009 19:24:39 -0500
In-Reply-To: <1232223441.3966.22.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Signature=_Mon__19_Jan_2009_11_24_29_+1100_YrWGFK.9COO2jjcI
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, 18 Jan 2009 01:47:21 +0530 Jaswinder Singh Rajput <jaswinder@kernel=
.org> wrote:
>
> diff --git a/include/linux/nfsd/stats.h b/include/linux/nfsd/stats.h
> index 7678cfb..0b53cfe 100644
> --- a/include/linux/nfsd/stats.h
> +++ b/include/linux/nfsd/stats.h
> @@ -29,9 +29,11 @@ struct nfsd_stats {
>  	unsigned int	ra_size;	/* size of ra cache */
>  	unsigned int	ra_depth[11];	/* number of times ra entry was found that d=
eep
>  					 * in the cache (10percentiles). [10] =3D not found */
> +#ifdef __KERNEL__
>  #ifdef CONFIG_NFSD_V4
>  	unsigned int	nfs4_opcount[LAST_NFS4_OP + 1];	/* count of individual nfs=
v4 operations */
>  #endif
> +#endif /* __KERNEL__ */
> =20
>  };

The only variable in the kernel of type "struct nfsd_stats" is only
exported to user mode via procfs, so this whole structure could probably
go inside __KERNEL__.  Then looking harder, I wonder if this header
should be exported to user mode at all.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__19_Jan_2009_11_24_29_+1100_YrWGFK.9COO2jjcI
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAklzyD0ACgkQjjKRsyhoI8yt9QCgmEHLhNSAB2fYNfqbvgl+WPEm
rRoAnRBfynsNZYdMSfUK9yUqeTiWdV62
=eQRT
-----END PGP SIGNATURE-----

--Signature=_Mon__19_Jan_2009_11_24_29_+1100_YrWGFK.9COO2jjcI--
