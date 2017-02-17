Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33372 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754788AbdBQTJv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 14:09:51 -0500
Date: Fri, 17 Feb 2017 14:09:51 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd/idmap: return nfserr_inval for zero length
 principals
Message-ID: <20170217190951.GD10894@fieldses.org>
References: <25d503f0-c330-1401-2ed6-693c97fa8970@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <25d503f0-c330-1401-2ed6-693c97fa8970@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for taking care of this!  Applying.--b.

On Sun, Feb 05, 2017 at 10:02:01PM +0800, Kinglong Mee wrote:
> Tigran Mkrtchyan's pynfs testcase for zero length principals fail as,
> 
> SATT16   st_setattr.testEmptyPrincipal                            : FAILURE
>            Setting empty owner should return NFS4ERR_INVAL,
>            instead got NFS4ERR_BADOWNER
> SATT17   st_setattr.testEmptyGroupPrincipal                       : FAILURE
>            Setting empty owner_group should return NFS4ERR_INVAL,
>            instead got NFS4ERR_BADOWNER
> 
> This patch checks the principal and return nfserr_inval directly.
> It should be check after decoding in nfs4xdr.c, but it's simple before
> process in nfsd_map_xxxx, so adds it in nfs4idmap.c.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4idmap.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
> index 5b20577..6b9b6cc 100644
> --- a/fs/nfsd/nfs4idmap.c
> +++ b/fs/nfsd/nfs4idmap.c
> @@ -628,6 +628,10 @@ nfsd_map_name_to_uid(struct svc_rqst *rqstp, const char *name, size_t namelen,
>  {
>  	__be32 status;
>  	u32 id = -1;
> +
> +	if (name == NULL || namelen == 0)
> +		return nfserr_inval;
> +
>  	status = do_name_to_id(rqstp, IDMAP_TYPE_USER, name, namelen, &id);
>  	*uid = make_kuid(&init_user_ns, id);
>  	if (!uid_valid(*uid))
> @@ -641,6 +645,10 @@ nfsd_map_name_to_gid(struct svc_rqst *rqstp, const char *name, size_t namelen,
>  {
>  	__be32 status;
>  	u32 id = -1;
> +
> +	if (name == NULL || namelen == 0)
> +		return nfserr_inval;
> +
>  	status = do_name_to_id(rqstp, IDMAP_TYPE_GROUP, name, namelen, &id);
>  	*gid = make_kgid(&init_user_ns, id);
>  	if (!gid_valid(*gid))
> -- 
> 2.9.3
