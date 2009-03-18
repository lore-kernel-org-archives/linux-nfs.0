From: Ni Wenjuan <niwj@cn.fujitsu.com>
Subject: Re: [PATCH] Replace NFS4ERR_NOTEMPY with NFS4ERR_EXIST
Date: Wed, 18 Mar 2009 09:55:47 +0800
Message-ID: <49C054A3.9010402@cn.fujitsu.com>
References: <49B8A224.6070803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51922 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751790AbZCRB4a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2009 21:56:30 -0400
In-Reply-To: <49B8A224.6070803@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ni Wenjuan =D0=B4=B5=C0:
> Fix a test in rename operation. rename dir1 into existing,nonempty di=
r2 should
> return  NFS4ERR_EXIST instead got NFS4ERR_NOTEMPTY. RFC says if the t=
arget is a
> directory but not empty, the server will return the error, NFS4ERR_EX=
IST.
>=20
> Signed-off-by:Ni Wenjuan  <niwj@cn.fujitsu.com>
>=20
> ---
>  fs/nfsd/nfs4proc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 9fa60a3..c1e2e22 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -605,7 +605,7 @@ nfsd4_rename(struct svc_rqst *rqstp, struct
> nfsd4_compound_state *cstate,
>=20
>  	/* the underlying filesystem returns different error's than require=
d
>  	 * by NFSv4. both save_fh and current_fh have been verified.. */
> -	if (status =3D=3D nfserr_isdir)
> +	if (status =3D=3D nfserr_isdir || status =3D=3D nfserr_notempty)
>  		status =3D nfserr_exist;
>  	else if ((status =3D=3D nfserr_notdir) &&
>                    (S_ISDIR(cstate->save_fh.fh_dentry->d_inode->i_mod=
e) &&

Bruce ,do you think this patch is ok ?   Can it be accepted?

