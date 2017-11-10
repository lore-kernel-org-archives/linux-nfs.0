Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41366 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755440AbdKJCBR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 21:01:17 -0500
From: NeilBrown <neilb@suse.com>
To: Joshua Watt <jpewhacker@gmail.com>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Fri, 10 Nov 2017 13:01:05 +1100
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: Re: [RFC 4/4] NFS: Add forcekill mount option
In-Reply-To: <20171108145942.5127-5-JPEWhacker@gmail.com>
References: <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com> <20171108145942.5127-1-JPEWhacker@gmail.com> <20171108145942.5127-5-JPEWhacker@gmail.com>
Message-ID: <87fu9mevtq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 08 2017, Joshua Watt wrote:

> Specifying the forcekill mount option causes umount() with the MNT_FORCE
> flag to not only kill all currently pending RPC tasks with -EIO, but
> also all future RPC tasks. This prevents the long delays caused by tasks
> queuing after rpc_killall_tasks() that can occur if the server drops off
> the network.
>
> Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
> ---
>  fs/nfs/super.c                 | 17 ++++++++++++++---
>  include/uapi/linux/nfs_mount.h |  1 +
>  2 files changed, 15 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 66fda2dcadd0..d972f6289aca 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -90,6 +90,7 @@ enum {
>  	Opt_resvport, Opt_noresvport,
>  	Opt_fscache, Opt_nofscache,
>  	Opt_migration, Opt_nomigration,
> +	Opt_forcekill, Opt_noforcekill,
>=20=20
>  	/* Mount options that take integer arguments */
>  	Opt_port,
> @@ -151,6 +152,8 @@ static const match_table_t nfs_mount_option_tokens =
=3D {
>  	{ Opt_nofscache, "nofsc" },
>  	{ Opt_migration, "migration" },
>  	{ Opt_nomigration, "nomigration" },
> +	{ Opt_forcekill, "forcekill" },
> +	{ Opt_noforcekill, "noforcekill" },
>=20=20
>  	{ Opt_port, "port=3D%s" },
>  	{ Opt_rsize, "rsize=3D%s" },
> @@ -637,6 +640,7 @@ static void nfs_show_mount_options(struct seq_file *m=
, struct nfs_server *nfss,
>  		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
>  		{ NFS_MOUNT_UNSHARED, ",nosharecache", "" },
>  		{ NFS_MOUNT_NORESVPORT, ",noresvport", "" },
> +		{ NFS_MOUNT_FORCEKILL, ",forcekill", ",noforcekill" },
>  		{ 0, NULL, NULL }
>  	};
>  	const struct proc_nfs_info *nfs_infop;
> @@ -896,17 +900,18 @@ EXPORT_SYMBOL_GPL(nfs_show_stats);
>   */
>  void nfs_umount_begin(struct super_block *sb)
>  {
> -	struct nfs_server *server;
> +	struct nfs_server *server =3D NFS_SB(sb);
>  	struct rpc_clnt *rpc;
> +	int kill_new_tasks =3D !!(server->flags & NFS_MOUNT_FORCEKILL);
>=20=20
>  	server =3D NFS_SB(sb);

Now that you initialized 'server' at declaration, you should really
remove this (re)initialization.

I'm not sure what I think of this patchset...
You are setting a flag which causes "umount -f" to set a different flag.
Why not just have "mount -o remount,XX" set the flag that you actually
want to set.
e.g
   mount -o remount,serverfailed /mountpoint
causes all rpcs to fail, and
   mount -o remount,noserverfailed /mountpoint

causes all rpcs to be sent to the server.
(or pick a different name than 'serverfailed').

It isn't clear what the indirection buys us.

Thanks,
NeilBrown



>  	/* -EIO all pending I/O */
>  	rpc =3D server->client_acl;
>  	if (!IS_ERR(rpc))
> -		rpc_killall_tasks(rpc, 0);
> +		rpc_killall_tasks(rpc, kill_new_tasks);
>  	rpc =3D server->client;
>  	if (!IS_ERR(rpc))
> -		rpc_killall_tasks(rpc, 0);
> +		rpc_killall_tasks(rpc, kill_new_tasks);
>  }
>  EXPORT_SYMBOL_GPL(nfs_umount_begin);
>=20=20
> @@ -1334,6 +1339,12 @@ static int nfs_parse_mount_options(char *raw,
>  		case Opt_nomigration:
>  			mnt->options &=3D ~NFS_OPTION_MIGRATION;
>  			break;
> +		case Opt_forcekill:
> +			mnt->flags |=3D NFS_MOUNT_FORCEKILL;
> +			break;
> +		case Opt_noforcekill:
> +			mnt->flags &=3D ~NFS_MOUNT_FORCEKILL;
> +			break;
>=20=20
>  		/*
>  		 * options that take numeric values
> diff --git a/include/uapi/linux/nfs_mount.h b/include/uapi/linux/nfs_moun=
t.h
> index e44e00616ab5..66821542a38f 100644
> --- a/include/uapi/linux/nfs_mount.h
> +++ b/include/uapi/linux/nfs_mount.h
> @@ -74,5 +74,6 @@ struct nfs_mount_data {
>=20=20
>  #define NFS_MOUNT_LOCAL_FLOCK	0x100000
>  #define NFS_MOUNT_LOCAL_FCNTL	0x200000
> +#define NFS_MOUNT_FORCEKILL	0x400000
>=20=20
>  #endif
> --=20
> 2.13.6

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAloFCGMACgkQOeye3VZi
gbkJOA/8CRHUl3p/FDzLmnDYZA2KSHm9FHIS10BN3osO0M9yAUVmYsxd8NvXvTvK
GDodXoMbnBHczCyPDDY4x6fAD3YfGL+qodVZL0JWJxNk8oeMC3XELLmVswp+schX
S2BuZluzDZ0Do8W3ysxoySp6FWVwG05lm/FSLf8MygANR1XzfqM/tba1AINk290g
Nueb/NDagYaSST347PZA7G0ZdNOEugC8zGsHqrFOHjWX1JvnDYcDXKP07znDTYsJ
WDJKXGwOqwEQBLwGsLMtvlAHy2LsTwGOJfk72QLFIeiXX88lagM7xRaP14cHH9sH
f2Rygz0vDgeXMLI9ugUY+iJPY878Y5Lm8B7OTPdcQxH8EmiI2mhJrxWiowdpOlnx
37khd+75C2w2lKXTdLRxdM/C3D95j6fOPQGGSGmLMQJGmvREWcgyi5+TtQNE+UYA
HyWhR6tiZUcLztPJ1UylGwKxOwctiHnB7UkOm9PBbn4/TtCW4oS++7QOBvCNh15q
MAFhs4HI5fEeFevpgkduqMllPPoxQufm9Zo+U5n5pvU4ghoZcOPwX6K4mKI6TY1G
luIJE/eMSBIh4cTZ0FDxaIHF6pZ3RwmLDCp+muzZZqkd1PiApauPTEb/1iaL2anx
dZJ8GFLwlY2nB8IiU9VSMst9KhBUqVZy/RLlihBWamDjkD6wDHk=
=sqfF
-----END PGP SIGNATURE-----
--=-=-=--
