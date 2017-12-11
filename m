Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49395 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751543AbdLKVoJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Dec 2017 16:44:09 -0500
From: NeilBrown <neilb@suse.com>
To: Thiago Rafael Becker <thiago.becker@gmail.com>,
        viro@zeniv.linux.org.uk, schwidefsky@de.ibm.com,
        willy@infradead.org, bfields@fieldses.org
To: David Howells <dhowells@redhat.com>
Date: Tue, 12 Dec 2017 08:43:58 +1100
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Thiago Rafael Becker <thiago.becker@gmail.com>
Subject: Re: [PATCH v5] kernel: make groups_sort calling a responsibility group_info allocators
In-Reply-To: <20171211151420.18655-1-thiago.becker@gmail.com>
References: <20171211142708.GA23284@bombadil.infradead.org> <20171211151420.18655-1-thiago.becker@gmail.com>
Message-ID: <878te9os81.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 11 2017, Thiago Rafael Becker wrote:

> In testing, we found that nfsd threads may call set_groups in parallel for
> the same entry cached in auth.unix.gid, racing in the call of groups_sort,
> corrupting the groups for that entry and leading to permission denials for
> the client.
>
> This patch:
>  - Make groups_sort globally visible.
>  - Move the call to groups_sort to the modifiers of group_info
>  - Remove the call to groups_sort from set_groups
>
> Signed-off-by: Thiago Rafael Becker <thiago.becker@gmail.com>

Reviewed-by: NeilBrown <neilb@suse.com>

Thanks.  I like this better as a single patch.

I'd probably suggest "Cc: stable@vger.kernel.org".
Less important bugfixes have gone to stable...

It might be nice to enhance
  Documentation/security/credentials.rst=20
to explain that the groups list is always sorted, and must be sorted
before set_groups() or set_current_groups() is called, but
as the document doesn't mention any of this at all, this is purely
an extra enhancement and doesn't need to be included in the same patch.

David: do you agree that this sort of content would be appropriate in
that file (which you apparently authored).  Would you like to update it,
or shall I?

Thanks,
NeilBrown



> ---
>  arch/s390/kernel/compat_linux.c   | 1 +
>  fs/nfsd/auth.c                    | 3 +++
>  include/linux/cred.h              | 1 +
>  kernel/groups.c                   | 5 +++--
>  kernel/uid16.c                    | 1 +
>  net/sunrpc/auth_gss/gss_rpc_xdr.c | 1 +
>  net/sunrpc/auth_gss/svcauth_gss.c | 1 +
>  net/sunrpc/svcauth_unix.c         | 2 ++
>  8 files changed, 13 insertions(+), 2 deletions(-)
>
> diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_li=
nux.c
> index f04db37..59eea9c 100644
> --- a/arch/s390/kernel/compat_linux.c
> +++ b/arch/s390/kernel/compat_linux.c
> @@ -263,6 +263,7 @@ COMPAT_SYSCALL_DEFINE2(s390_setgroups16, int, gidsets=
ize, u16 __user *, grouplis
>  		return retval;
>  	}
>=20=20
> +	groups_sort(group_info);
>  	retval =3D set_current_groups(group_info);
>  	put_group_info(group_info);
>=20=20
> diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
> index 697f8ae..f650e47 100644
> --- a/fs/nfsd/auth.c
> +++ b/fs/nfsd/auth.c
> @@ -60,6 +60,9 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_exp=
ort *exp)
>  				gi->gid[i] =3D exp->ex_anon_gid;
>  			else
>  				gi->gid[i] =3D rqgi->gid[i];
> +
> +			/* Each thread allocates its own gi, no race */
> +			groups_sort(gi);
>  		}
>  	} else {
>  		gi =3D get_group_info(rqgi);
> diff --git a/include/linux/cred.h b/include/linux/cred.h
> index 099058e..6312865 100644
> --- a/include/linux/cred.h
> +++ b/include/linux/cred.h
> @@ -83,6 +83,7 @@ extern int set_current_groups(struct group_info *);
>  extern void set_groups(struct cred *, struct group_info *);
>  extern int groups_search(const struct group_info *, kgid_t);
>  extern bool may_setgroups(void);
> +extern void groups_sort(struct group_info *);
>=20=20
>  /*
>   * The security context of a task
> diff --git a/kernel/groups.c b/kernel/groups.c
> index e357bc8..daae2f2 100644
> --- a/kernel/groups.c
> +++ b/kernel/groups.c
> @@ -86,11 +86,12 @@ static int gid_cmp(const void *_a, const void *_b)
>  	return gid_gt(a, b) - gid_lt(a, b);
>  }
>=20=20
> -static void groups_sort(struct group_info *group_info)
> +void groups_sort(struct group_info *group_info)
>  {
>  	sort(group_info->gid, group_info->ngroups, sizeof(*group_info->gid),
>  	     gid_cmp, NULL);
>  }
> +EXPORT_SYMBOL(groups_sort);
>=20=20
>  /* a simple bsearch */
>  int groups_search(const struct group_info *group_info, kgid_t grp)
> @@ -122,7 +123,6 @@ int groups_search(const struct group_info *group_info=
, kgid_t grp)
>  void set_groups(struct cred *new, struct group_info *group_info)
>  {
>  	put_group_info(new->group_info);
> -	groups_sort(group_info);
>  	get_group_info(group_info);
>  	new->group_info =3D group_info;
>  }
> @@ -206,6 +206,7 @@ SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __u=
ser *, grouplist)
>  		return retval;
>  	}
>=20=20
> +	groups_sort(group_info);
>  	retval =3D set_current_groups(group_info);
>  	put_group_info(group_info);
>=20=20
> diff --git a/kernel/uid16.c b/kernel/uid16.c
> index ce74a49..ef1da2a 100644
> --- a/kernel/uid16.c
> +++ b/kernel/uid16.c
> @@ -192,6 +192,7 @@ SYSCALL_DEFINE2(setgroups16, int, gidsetsize, old_gid=
_t __user *, grouplist)
>  		return retval;
>  	}
>=20=20
> +	groups_sort(group_info);
>  	retval =3D set_current_groups(group_info);
>  	put_group_info(group_info);
>=20=20
> diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_=
rpc_xdr.c
> index c4778ca..444380f 100644
> --- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
> +++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
> @@ -231,6 +231,7 @@ static int gssx_dec_linux_creds(struct xdr_stream *xd=
r,
>  			goto out_free_groups;
>  		creds->cr_group_info->gid[i] =3D kgid;
>  	}
> +	groups_sort(creds->cr_group_info);
>=20=20
>  	return 0;
>  out_free_groups:
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svca=
uth_gss.c
> index 5dd4e6c..2653119 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -481,6 +481,7 @@ static int rsc_parse(struct cache_detail *cd,
>  				goto out;
>  			rsci.cred.cr_group_info->gid[i] =3D kgid;
>  		}
> +		groups_sort(rsci.cred.cr_group_info);
>=20=20
>  		/* mech name */
>  		len =3D qword_get(&mesg, buf, mlen);
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index 740b67d..af7f28f 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -520,6 +520,7 @@ static int unix_gid_parse(struct cache_detail *cd,
>  		ug.gi->gid[i] =3D kgid;
>  	}
>=20=20
> +	groups_sort(ug.gi);
>  	ugp =3D unix_gid_lookup(cd, uid);
>  	if (ugp) {
>  		struct cache_head *ch;
> @@ -819,6 +820,7 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *a=
uthp)
>  		kgid_t kgid =3D make_kgid(&init_user_ns, svc_getnl(argv));
>  		cred->cr_group_info->gid[i] =3D kgid;
>  	}
> +	groups_sort(cred->cr_group_info);
>  	if (svc_getu32(argv) !=3D htonl(RPC_AUTH_NULL) || svc_getu32(argv) !=3D=
 0) {
>  		*authp =3D rpc_autherr_badverf;
>  		return SVC_DENIED;
> --=20
> 2.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlou/B4ACgkQOeye3VZi
gbn4Cg//W2se+9COOuHRQYktquLXhW2EQZj5LZukwDgo8OZO5mOKSBcrg0BAKOp0
IByKhNV697MFLkpTAUMEXpx6To+anPry6a6xd0J14Cwbu2na9mBXoE3Q5NXzo1dA
wNmkvQ2o9Vp47fm7S/p2rd0VR4DAOeBXzGHn/MRK/cmU15jOtwXvxeHx4/VNCWkp
YuMuS3BOTsbNob0FVX57ediYpuMTPJbU/CQlslSvZ2s8DjnsjK22De/DhtpNUeDu
NLKffcqqGHCAm5QJCnKmuwmWn59/CzTclmI2ytmbrZMeu+Wh0htXZiSYaTfsxXHK
7QpGE0ZabxngGb6NVPoCAr7LPKc9lOPjkNT0cCg2TR+cbBUzpilmjKK/GOct2+mf
LyQ4yHwFWvPvk+W+u480llAt0YjmpGCdSTsFPktMlnIninwdpSmeaa9i9fyCH8Ew
NIKe1OxqVIrV8F2yafehv+pDCUXH+LKbmRvkJNIB8gaSURH7ZNTA0bbMjNmcw5xt
U5luJ5/9cEnQMvwTBIYVnIMAVhxg2kMfTOh+aPMeKTrU3KYuqMMixNwFCy8H4r4n
++RgkIr63j7GZVcsrr/P7z2eyeJK6nLosr5wjH63eQTXGTrfHnRwNPYyGDafSE84
Tppy5EdfmaCjmz4exKzS3Y62MabTapK43NAsEp2KWhqDYbWANyc=
=vzDf
-----END PGP SIGNATURE-----
--=-=-=--
