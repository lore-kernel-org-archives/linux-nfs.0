Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:51847 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752449AbaKMAQJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Nov 2014 19:16:09 -0500
Date: Thu, 13 Nov 2014 11:15:58 +1100
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] KEYS: Ensure expired keys are renewed
Message-ID: <20141113111558.7775022e@notabene.brown>
In-Reply-To: <20141030174612.10093.61557.stgit@manet.1015granger.net>
References: <20141030174612.10093.61557.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/XE8SZ3I5yEygiZlDceIOwNl"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/XE8SZ3I5yEygiZlDceIOwNl
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 30 Oct 2014 13:46:47 -0400 Chuck Lever <chuck.lever@oracle.com> wro=
te:

> After about 10 minutes, my NFSv4 functional tests fail because the
> ownership of the test files goes to "-2". Looking at /proc/keys
> shows that the id_resolv keys that map to my test user ID have
> expired. The ownership problem persists until the expired keys are
> purged from the keyring, and fresh keys are obtained.
>=20
> I bisected the problem to 3.13 commit b2a4df200d57 ("KEYS: Expand
> the capacity of a keyring"). This commit inadvertantly changes the
> API contract of the internal function keyring_search_aux().
>=20
> The root cause appears to be that b2a4df200d57 made "no state check"
> the default behavior. "No state check" means the keyring search
> iterator function skips checking the key's expiry timeout, and
> returns expired keys.  request_key_and_link() depends on getting
> an -EAGAIN result code to know when to perform an upcall to refresh
> an expired key.
>=20
> Restore the previous default behavior of keyring_search_aux() and
> the meaning of the KEYRING_SEARCH_{DO,NO}_STATE_CHECK flags.
>=20
> Fixes: b2a4df200d57 ("KEYS: Expand the capacity of a keyring")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Resend with correct linux-nfs address.
>=20
>  security/keys/keyring.c |   11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
>=20
> diff --git a/security/keys/keyring.c b/security/keys/keyring.c
> index 8314a7d..1294582 100644
> --- a/security/keys/keyring.c
> +++ b/security/keys/keyring.c
> @@ -519,9 +519,14 @@ static int keyring_search_iterator(const void *objec=
t, void *iterator_data)
>  	struct keyring_search_context *ctx =3D iterator_data;
>  	const struct key *key =3D keyring_ptr_to_key(object);
>  	unsigned long kflags =3D key->flags;
> +	bool state_check_needed;
> =20
>  	kenter("{%d}", key->serial);
> =20
> +	state_check_needed =3D !(ctx->flags & KEYRING_SEARCH_NO_STATE_CHECK);
> +	if (ctx->flags & KEYRING_SEARCH_DO_STATE_CHECK)
> +		state_check_needed =3D true;
> +
>  	/* ignore keys not of this type */
>  	if (key->type !=3D ctx->index_key.type) {
>  		kleave(" =3D 0 [!type]");
> @@ -529,7 +534,7 @@ static int keyring_search_iterator(const void *object=
, void *iterator_data)
>  	}
> =20
>  	/* skip invalidated, revoked and expired keys */
> -	if (ctx->flags & KEYRING_SEARCH_DO_STATE_CHECK) {
> +	if (state_check_needed) {
>  		if (kflags & ((1 << KEY_FLAG_INVALIDATED) |
>  			      (1 << KEY_FLAG_REVOKED))) {
>  			ctx->result =3D ERR_PTR(-EKEYREVOKED);
> @@ -559,7 +564,7 @@ static int keyring_search_iterator(const void *object=
, void *iterator_data)
>  		goto skipped;
>  	}
> =20
> -	if (ctx->flags & KEYRING_SEARCH_DO_STATE_CHECK) {
> +	if (state_check_needed) {
>  		/* we set a different error code if we pass a negative key */
>  		if (kflags & (1 << KEY_FLAG_NEGATIVE)) {
>  			smp_rmb();
> @@ -642,8 +647,6 @@ static bool search_nested_keyrings(struct key *keyrin=
g,
>  	}
> =20
>  	ctx->skipped_ret =3D 0;
> -	if (ctx->flags & KEYRING_SEARCH_NO_STATE_CHECK)
> -		ctx->flags &=3D ~KEYRING_SEARCH_DO_STATE_CHECK;
> =20
>  	/* Start processing a new keyring */
>  descend_to_keyring:
>=20

Reviewed-by: NeilBrown <neilb@suse.de>

security/keys/internal.h says:

#define KEYRING_SEARCH_NO_STATE_CHECK   0x0001  /* Skip state checks */
#define KEYRING_SEARCH_DO_STATE_CHECK   0x0002  /* Override NO_STATE_CHECK =
*/


Your match makes it obvious that DO overrides NO.  The current code
doesn't get that right.

Is this on its way upstream yet (not in -next that I could see).

Thanks,
NeilBrown

--Sig_/XE8SZ3I5yEygiZlDceIOwNl
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVGP4Pjnsnt1WYoG5AQK2XA//SGALIO5jO3NYblT9GdnCb2GcGfQHcrdI
HTwVEoewQTCKz84PjkO1Gwdk62Z2uBhzLkhL6yGDR3x2dHf/L4TeFY2CimZV/Sez
9EyeiQONnQszNKOvBJfvQVPiCWq/o89/zXkwNNHSj5KJ6yYYpivsJ2nqLG41J2H7
kQ9Pdm90LFQ4Ayi0W73shcCCYGdkrZjSCbmszcnRg0QDvstiQhMSTU6dD6JYem8/
JrBBPFvSClnn7IP41soHquUnrnfABGfQe2sJ8KlEcZlWidNIWpi7CsljMDO9Egq1
W1ZTQxsliUitj/2505Sin+DtTYiCpcfXD66w7KYYTMZ7l+B2N8eYRGvOvMAtkrpg
ZTywhVDJRUkbh/GFbgu3YzyGf4lsdWXiXBj4GRVDwZjELZMh9zX6/5sMG8o9S0Dh
EH8toxq05ulxEmmwXD3UkNaIQhjuXm4OiOjK36EX8+Jtw+e/sCE7wcpYQzoTVhbk
vcbGDL8xmoPN7Deuhy85JANnLpfVv8LxR4zC4moyH/5os+ofYWNTi2SJ2PGqbjj2
mRQYLpCMHWgHXPdvfNJnzOgEz/aQppGVzT0kKNLNOiCnIFnku4ZjDOKOqSYjHJmB
/dcpZFeh34EF3OuKY0WMwtAFFiJecSv2C+rZxP+h1oV2YaI6fZhA8YgPusuHZmyF
qER36WdaCm0=
=lJIy
-----END PGP SIGNATURE-----

--Sig_/XE8SZ3I5yEygiZlDceIOwNl--
