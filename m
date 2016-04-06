Return-Path: <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH nfs-utils] mount.nfs: skip server address resolution on remount
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <83c9ef2c8e6c5ece11791e5c39609a1db9f716de.1459967426.git.bcodding@redhat.com>
Date: Wed, 6 Apr 2016 11:51:48 -0700
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7033B87F-A950-49A6-B062-2E7309CC046B@oracle.com>
References: <83c9ef2c8e6c5ece11791e5c39609a1db9f716de.1459967426.git.bcodding@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 6, 2016, at 11:30 AM, Benjamin Coddington <bcodding@redhat.com> =
wrote:
>=20
> A remount might fail if name resolution returns a different server =
address,
> as might occur if there are multiple name records for the server.  =
Since we
> cannot change the server's address on a remount anyway, skip the =
lookup and
> remove any set addresses in the options.

That looks better.

But I wonder, is it necessary to remove the old addr=3D option
when doing a remount?

Have you checked what the output of /proc/mounts looks like
after a remount?


> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
> utils/mount/stropts.c |   31 ++++++++++++++++++++-----------
> 1 files changed, 20 insertions(+), 11 deletions(-)
>=20
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 86829a9..634b58c 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -383,13 +383,26 @@ static int nfs_validate_options(struct =
nfsmount_info *mi)
> 	if (!nfs_nfs_proto_family(mi->options, &family))
> 		return 0;
>=20
> -	hint.ai_family =3D (int)family;
> -	error =3D getaddrinfo(mi->hostname, NULL, &hint, &mi->address);
> -	if (error !=3D 0) {
> -		nfs_error(_("%s: Failed to resolve server %s: %s"),
> -			progname, mi->hostname, gai_strerror(error));
> -		mi->address =3D NULL;
> -		return 0;
> +	/*
> +	 * A remount is not going to be able to change the server's =
address,
> +	 * nor should we try to resolve another address for the server =
as we
> +	 * may end up with a different address.
> +	 */
> +	if (mi->flags & MS_REMOUNT) {
> +		po_remove_all(mi->options, "addr");
> +	} else {
> +		hint.ai_family =3D (int)family;
> +		error =3D getaddrinfo(mi->hostname, NULL, &hint, =
&mi->address);
> +		if (error !=3D 0) {
> +			nfs_error(_("%s: Failed to resolve server %s: =
%s"),
> +				progname, mi->hostname, =
gai_strerror(error));
> +			mi->address =3D NULL;
> +			return 0;
> +		}
> +
> +		if (!nfs_append_addr_option(mi->address->ai_addr,
> +						mi->address->ai_addrlen, =
mi->options))
> +			return 0;
> 	}
>=20
> 	if (!nfs_set_version(mi))
> @@ -398,10 +411,6 @@ static int nfs_validate_options(struct =
nfsmount_info *mi)
> 	if (!nfs_append_sloppy_option(mi->options))
> 		return 0;
>=20
> -	if (!nfs_append_addr_option(mi->address->ai_addr,
> -					mi->address->ai_addrlen, =
mi->options))
> -		return 0;
> -
> 	return 1;
> }
>=20
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
