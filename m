Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:51069 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751312AbaCIXS0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Mar 2014 19:18:26 -0400
Date: Mon, 10 Mar 2014 10:18:16 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount.nfs: background mount now do directly into
 background
Message-ID: <20140310101816.17e7d98a@notabene.brown>
In-Reply-To: <1394284964-12997-1-git-send-email-steved@redhat.com>
References: <1394284964-12997-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/VwBC.yRNMarJUgKQ=uC0M.G"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/VwBC.yRNMarJUgKQ=uC0M.G
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat,  8 Mar 2014 08:22:44 -0500 Steve Dickson <steved@redhat.com> wrote:

> Modern day kernel will no longer return all timeout
> errors instead the process spins endlessly in the kernel.
> This behavior will cause the foreground mount to hang, never
> allowing the mount to go into background.
>=20
> So this patch eliminates the foreground mount cause
> background mounts to go directly into background
>=20
> Signed-off-by: Steve Dickson <steved@redhat.com>

Did NFS mounts *ever* time out (when 'soft' isn't given)?

If so, there is probably a regression which maybe should be fixed.

If not, then this has always been a bug since sting-options were introduced
and the kernel started doing the mountd filehandle lookup...

So I'm probably OK with the patch but I wonder if there is more of a story
behind this that we should be sure we understand...

Thanks,
NeilBrown


> ---
>  utils/mount/stropts.c |   31 ++++++++-----------------------
>  1 files changed, 8 insertions(+), 23 deletions(-)
>=20
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index a642394..92a7245 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -913,28 +913,6 @@ static int nfsmount_fg(struct nfsmount_info *mi)
>  }
> =20
>  /*
> - * Handle "background" NFS mount [first try]
> - *
> - * Returns a valid mount command exit code.
> - *
> - * EX_BG should cause the caller to fork and invoke nfsmount_child.
> - */
> -static int nfsmount_parent(struct nfsmount_info *mi)
> -{
> -	if (nfs_try_mount(mi))
> -		return EX_SUCCESS;
> -
> -	/* retry background mounts when the server is not up */
> -	if (nfs_is_permanent_error(errno) && errno !=3D EOPNOTSUPP) {
> -		mount_error(mi->spec, mi->node, errno);
> -		return EX_FAIL;
> -	}
> -
> -	sys_mount_errors(mi->hostname, errno, 1, 1);
> -	return EX_BG;
> -}
> -
> -/*
>   * Handle "background" NFS mount [retry daemon]
>   *
>   * Returns a valid mount command exit code: EX_SUCCESS if successful,
> @@ -982,7 +960,14 @@ static int nfsmount_child(struct nfsmount_info *mi)
>  static int nfsmount_bg(struct nfsmount_info *mi)
>  {
>  	if (!mi->child)
> -		return nfsmount_parent(mi);
> +		/*=20
> +		 * Modern day kernels no longer return all=20
> +		 * timeouts errors in all cases, instead=20
> +		 * the process spins in the kernel, which=20
> +		 * will hang a foreground mount. So background
> +		 * mounts have to go directly into background
> +		 */
> +		return EX_BG;
>  	else
>  		return nfsmount_child(mi);
>  }


--Sig_/VwBC.yRNMarJUgKQ=uC0M.G
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxz2uTnsnt1WYoG5AQLXdw/+MJumUDjzbzDx/SO3ITrNCr0aSjuXMVr7
4oUlJ7RFIJWeGvyccNZm3/DI8sG/7GwAvM7sGsckacavwB32aiUt9PCRz62exBRX
THykKOu4csZ93cVHeccss9ekvnhtOaIAsn+4eQr3W51EM/zBtDJJRABJYfDcSGgP
u5kNm5/N9BlSbao+E2Y+2GAeydz7ydMogXxrkS0nGGOJekel7RpmSKFv4wu3qWhO
PWz97Ybc+bSj0/3IV8TsiwuVTsyCJ2zZb9dZyB/qJiDYKoJ64jZ8GzG5MD/38MU8
v18LSXTa0AIUFvOovAkHeAW+FwwX8Vd3BkrMds9OLOOBGtxcoIthg9YdtNMZN3Uc
nlnuupPMD5UOKbGMwEOUZi28Ybi1C/e+8ukeQsOC10YuYADf2Hn5kqth3QP60ZgE
EpyJ5/6iR/cdEecOge2Kx19AQn2q5YfyTahhsHma7zbYRntubFkmQYYT7MmdjdnA
9J0kpRgGsVrEXMl2FGQZxfWM5MDWM3fxnJaOPYYmgwxSMpF/1Pj6WY0f5wDPFHWt
NqtxgZMyeLgwAK0ikb1y41skaLLbArvqzbM7NOSF0L1qIf5jy3RQ+1eNvn4rvaTz
EEajelg8A18B28m686KmPmY9YhfU78i3G8Ms9hZxCdqPQ294on+C8P1RRkCuhibq
UKQJRXaj02Y=
=BjUk
-----END PGP SIGNATURE-----

--Sig_/VwBC.yRNMarJUgKQ=uC0M.G--
