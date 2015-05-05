Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34177 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752612AbbEEEUI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 May 2015 00:20:08 -0400
Date: Tue, 5 May 2015 14:19:57 +1000
From: NeilBrown <neilb@suse.de>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>, Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under
 pseudo root
Message-ID: <20150505141957.2aef920e@notabene.brown>
In-Reply-To: <55483EB7.5060104@gmail.com>
References: <20150421215417.GE13782@fieldses.org>
	<553781E2.1000900@gmail.com>
	<20150422150703.GA1247@fieldses.org>
	<20150423094431.1a8aa68b@notabene.brown>
	<5538EB18.7080802@gmail.com>
	<20150424130045.6bbdb2f9@notabene.brown>
	<553E2784.6020906@gmail.com>
	<20150429125728.69ddfc6c@notabene.brown>
	<20150429191934.GA23980@fieldses.org>
	<20150430075225.21a71056@notabene.brown>
	<20150430213602.GB9509@fieldses.org>
	<55483EB7.5060104@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/vB1VdSJ7fmkZkJFE/01bJrm"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/vB1VdSJ7fmkZkJFE/01bJrm
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 05 May 2015 11:53:27 +0800 Kinglong Mee <kinglongmee@gmail.com> wro=
te:

> Cc Steve, Viro,
>=20
> On 5/1/2015 5:36 AM, J. Bruce Fields wrote:
> > On Thu, Apr 30, 2015 at 07:52:25AM +1000, NeilBrown wrote:
> >> On Wed, 29 Apr 2015 15:19:34 -0400 "J. Bruce Fields" <bfields@fieldses=
.org>
> >> wrote:
> >>> Maybe drop the locking from nfsd_buffered_readdir and *just* take the
> >>> i_mutex around lookup_one_len(), if that's the only place we need it?
>=20
> As description in other thread, before the upcall to rpc.mountd,
> nfsd have call lookup_one_len() for the file, but why rpc.mountd
> also blocked in lookup ?
>=20
> There is a bug in rpc.mountd when checking sub-directory,=20
> it sets bad patch length for child.
>=20
> If parent if "/nfs/xfs" and child is "/nfs/test", the child name
> will be truncated to "/nfs/tes" for strlen(parent), "/nfs/test"
> have exist in kernel's cache for the lookup_one_len(), but
> "/nfs/tes" is a bad path, which needs lookup_slow(), so blocked.

Testing for "/nfs/tes" certain seems like a wrong thing to do.

>=20
> static int is_subdirectory(char *child, char *parent)
> {
>         /* Check is child is strictly a subdirectory of
>          * parent or a more distant descendant.
>          */
>         size_t l =3D strlen(parent);
>=20
>         if (strcmp(parent, "/") =3D=3D 0 && child[1] !=3D 0)
>                 return 1;
>=20
>         return (same_path(child, parent, l) && child[l] =3D=3D '/');

I guess this should be:

          child[l] =3D=3D '/' && same_path(child, parent, l)

That way there would be no risk of truncating anything.

Can you please test if that one-line change removes the problem?


> }
>=20
> The following path makes a correct path, not a truncated path.
> Have be tested, everything is OK.
>=20
> thanks,
> Kinglong Mee
>=20
> -------------------------------------------------------------------------=
----------
> >From 70b9d1d93a24db8a7837998cb7eb0ff4e98480a6 Mon Sep 17 00:00:00 2001
> From: Kinglong Mee <kinglongmee@gmail.com>
> Date: Tue, 5 May 2015 11:47:20 +0800
> Subject: [PATCH] mountd: Case-insensitive path length must equal to parent
>=20
> Commit 6091c0a4c4 (mountd: add support for case-insensitive file names)
> introdues a bug cause mutex race when looking bad path.

I think we should be clear that the mutex race is already present.
I think you are right that there is a bug here which is making it easy to
trigger, but it isn't exactly "causing" the bug.

Thanks,
NeilBrown




>=20
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  utils/mountd/cache.c | 22 +++++++++++++++++++++-
>  1 file changed, 21 insertions(+), 1 deletion(-)
>=20
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 7d250f9..9d9a1bb 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -468,16 +468,36 @@ fallback:
>  	return 1;
>  }
> =20
> +static int subdir_len(char *name, int count_slashes)
> +{
> +	char *ptr =3D NULL;
> +	int i;
> +
> +	ptr =3D name;
> +	for (i =3D 0; i < count_slashes + 1; i++) {
> +		ptr =3D strchr(ptr, '/');
> +		if (NULL =3D=3D ptr)
> +			return strlen(name);
> +		ptr++;
> +	}
> +
> +	return ptr - name;
> +}
> +
>  static int is_subdirectory(char *child, char *parent)
>  {
>  	/* Check is child is strictly a subdirectory of
>  	 * parent or a more distant descendant.
>  	 */
> -	size_t l =3D strlen(parent);
> +	size_t l =3D subdir_len(child, count_slashes(parent));
> =20
>  	if (strcmp(parent, "/") =3D=3D 0 && child[1] !=3D 0)
>  		return 1;
> =20
> +	/* Case-insensitive path length must equal to parent */
> +	if (l !=3D strlen(parent))
> +		return 0;
> +
>  	return (same_path(child, parent, l) && child[l] =3D=3D '/');
>  }
> =20


--Sig_/vB1VdSJ7fmkZkJFE/01bJrm
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVUhE7Tnsnt1WYoG5AQLdhw/9FL/2vXif+OezKzvB/Wo7CP4mxnJ+PBaO
IAAJ8H+TnsYzbbXKcL5Qc0fbdBJrIqeiboldrDUlfk9aycaGTFP7DheE8Xmnwp3+
DpLxFTD5diEDB5s29JYqSQ3KJ1NJpeq4yJKpmt/egdoub2d9c9Sc/ffFvV3K+gdZ
Lh7VugZr7RnA92NhHfaKRSbmj2YQyR0Gwm74mcLfVaa1A0VIBsal5IG2gjmysXrU
9TXnHW4Y6LsfG1Iifepw9HA0R2iSdHWoNrRzXSEKq8pvAwsSIOJyBsIaEyzJU5UM
1I+RcjiueNn35Hhavdb+fuvceUzmPEzOFuwzLq+4X5ZgHnrlZrpoBhh2p7r1y50Y
YjETLVX6cRLJOUVy6FOMMb4h3sazWAXJjDRQeySSYS5THnvbuPkQmugulBR9kBer
e/vV0/pvRfSE7Memvt2Ff3AU6JKdyYtBplfzwDZEZLWBLyDUpvykfduAPEUgMX8M
wIadSJS3EF6E6vH0WsPayA4wf8Tf2/wjOoUmidvgpteBfXJl160pNOzYxm2i+R/V
XXnFqw6DlaBVWzf85Hl47S1qFuD+6YwwGG1XPC3qfBzPo5hrN3yTH4ynER/es34n
DPZr2H73xP/gRaLw2NhQyTbcEqqt/B46o038xDpEYnm3mYySPVd+70eVPrT8Cy+X
nK9ZFR1pmrA=
=ClPZ
-----END PGP SIGNATURE-----

--Sig_/vB1VdSJ7fmkZkJFE/01bJrm--
