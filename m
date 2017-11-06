Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:46414 "EHLO
        elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753513AbdKFRen (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Nov 2017 12:34:43 -0500
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>,
        <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>
Cc: <linux-nfs@vger.kernel.org>, "'Pradeep'" <pradeepthomas@gmail.com>,
        <nfs-ganesha-devel@lists.sourceforge.net>
References: <20171105204404.10847.33767.stgit@manet.1015granger.net>
In-Reply-To: <20171105204404.10847.33767.stgit@manet.1015granger.net>
Subject: RE: [PATCH v2] nfs: Fix ugly referral attributes
Date: Mon, 6 Nov 2017 09:34:34 -0800
Message-ID: <011b01d35725$83da88e0$8b8f9aa0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pradeep,

Could you verify this patch with nfs-ganesha? Looking at the code, it looks=
 like we will supply the attributes requested.

Thanks

Frank

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Chuck Lever
> Sent: Sunday, November 5, 2017 12:45 PM
> To: trond.myklebust@primarydata.com; anna.schumaker@netapp.com
> Cc: linux-nfs@vger.kernel.org
> Subject: [PATCH v2] nfs: Fix ugly referral attributes
> 
> Before traversing a referral and performing a mount, the mounted-on
> directory looks strange:
> 
> dr-xr-xr-x. 2 4294967294 4294967294 0 Dec 31  1969 dir.0
> 
> nfs4_get_referral is wiping out any cached attributes with what was retur=
ned
> via GETATTR(fs_locations), but the bit mask for that operation does not
> request any file attributes.
> 
> Retrieve owner and timestamp information so that the memcpy in
> nfs4_get_referral fills in more attributes.
> 
> Changes since v1:
> - Don't request attributes that the client unconditionally replaces
> - Request only MOUNTED_ON_FILEID or FILEID attribute, not both
> - encode_fs_locations() doesn't use the third bitmask word
> 
> Fixes: 6b97fd3da1ea ("NFSv4: Follow a referral")
> Suggested-by: Pradeep Thomas <pradeepthomas@gmail.com>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Cc: stable@vger.kernel.org
> ---
>  fs/nfs/nfs4proc.c |   18 ++++++++----------
>  1 file changed, 8 insertions(+), 10 deletions(-)
> 
> I could send this as an incremental, but that just seems to piss off
> distributors, who will just squash them all together anyway.
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c index 6c61e2b..2662879=

> 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -254,15 +254,12 @@ static int nfs4_map_errors(int err)  };
> 
>  const u32 nfs4_fs_locations_bitmap[3] =3D {
> -	FATTR4_WORD0_TYPE
> -	| FATTR4_WORD0_CHANGE
> +	FATTR4_WORD0_CHANGE
>  	| FATTR4_WORD0_SIZE
>  	| FATTR4_WORD0_FSID
>  	| FATTR4_WORD0_FILEID
>  	| FATTR4_WORD0_FS_LOCATIONS,
> -	FATTR4_WORD1_MODE
> -	| FATTR4_WORD1_NUMLINKS
> -	| FATTR4_WORD1_OWNER
> +	FATTR4_WORD1_OWNER
>  	| FATTR4_WORD1_OWNER_GROUP
>  	| FATTR4_WORD1_RAWDEV
>  	| FATTR4_WORD1_SPACE_USED
> @@ -6763,9 +6760,7 @@ static int _nfs4_proc_fs_locations(struct rpc_clnt
> *client, struct inode *dir,
>  				   struct page *page)
>  {
>  	struct nfs_server *server =3D NFS_SERVER(dir);
> -	u32 bitmask[3] =3D {
> -		[0] =3D FATTR4_WORD0_FSID |
> FATTR4_WORD0_FS_LOCATIONS,
> -	};
> +	u32 bitmask[3];
>  	struct nfs4_fs_locations_arg args =3D {
>  		.dir_fh =3D NFS_FH(dir),
>  		.name =3D name,
> @@ -6784,12 +6779,15 @@ static int _nfs4_proc_fs_locations(struct rpc_cln=
t
> *client, struct inode *dir,
> 
>  	dprintk("%s: start\n", __func__);
> 
> +	bitmask[0] =3D nfs4_fattr_bitmap[0] |
> FATTR4_WORD0_FS_LOCATIONS;
> +	bitmask[1] =3D nfs4_fattr_bitmap[1];
> +
>  	/* Ask for the fileid of the absent filesystem if mounted_on_fileid
>  	 * is not supported */
>  	if (NFS_SERVER(dir)->attr_bitmask[1] &
> FATTR4_WORD1_MOUNTED_ON_FILEID)
> -		bitmask[1] |=3D FATTR4_WORD1_MOUNTED_ON_FILEID;
> +		bitmask[0] &=3D ~FATTR4_WORD0_FILEID;
>  	else
> -		bitmask[0] |=3D FATTR4_WORD0_FILEID;
> +		bitmask[1] &=3D ~FATTR4_WORD1_MOUNTED_ON_FILEID;
> 
>  	nfs_fattr_init(&fs_locations->fattr);
>  	fs_locations->server =3D server;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in t=
he
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

