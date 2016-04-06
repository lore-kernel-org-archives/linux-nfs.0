Return-Path: <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC PATCH] mount.nfs: skip option validation on remount
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <712798c489f69e39f235077f6ca85a7c133eeb58.1459949813.git.bcodding@redhat.com>
Date: Wed, 6 Apr 2016 08:10:43 -0700
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <541141C7-9928-43FE-8C45-82A914038EC1@oracle.com>
References: <712798c489f69e39f235077f6ca85a7c133eeb58.1459949813.git.bcodding@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 6, 2016, at 6:41 AM, Benjamin Coddington <bcodding@redhat.com> =
wrote:
>=20
> I'm not exactly sure this is the safest thing to do since you can pass
> -oremount on the first mount and skip option validation.  Maybe =
someone with
> better insight into the mount paths could comment.  Does mount need =
some
> refactoring?  Its logic seems arcane.. and I think there is a lot of =
dead
> code.

It's arcane because NFS mounting has a lot of corner cases
that have evolved over the years. If you have an example of
dead code, can you post it?


> This is very quick attempt to fix
> https://bugzilla.redhat.com/show_bug.cgi?id=3D1313550

"You are not authorized to access bug #1313550."

I'm guessing you want to use the existing addr=3D option on a
remount in case the DNS resolution returns a different address.
I'm uncertain why a remount should succeed in this case: if
the server has a different IP address, how was the mount working
at all?


> =
8<------------------------------------------------------------------------=
-
>=20
> A remount might fail if name resolution returns a different server =
address
> for the mount.  Since we've already validated the options the first =
time,
> skip validation if remounting.
>=20
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
> utils/mount/stropts.c |    6 +++---
> 1 files changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 86829a9..9383bb4 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -1090,15 +1090,15 @@ static const char *nfs_background_opttbl[] =3D =
{
>=20
> static int nfsmount_start(struct nfsmount_info *mi)
> {
> -	if (!nfs_validate_options(mi))
> -		return EX_FAIL;
> -
> 	/*
> 	 * Avoid retry and negotiation logic when remounting
> 	 */
> 	if (mi->flags & MS_REMOUNT)
> 		return nfs_remount(mi);
>=20
> +	if (!nfs_validate_options(mi))
> +		return EX_FAIL;
> +
> 	if (po_rightmost(mi->options, nfs_background_opttbl) =3D=3D 0)
> 		return nfsmount_bg(mi);
> 	else
> --=20
> 1.7.1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
