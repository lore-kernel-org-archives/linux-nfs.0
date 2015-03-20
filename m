Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41163 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977AbbCTUR6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2015 16:17:58 -0400
Date: Fri, 20 Mar 2015 16:17:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Using path_equal() for checking two paths
Message-ID: <20150320201757.GB5955@fieldses.org>
References: <5505A19C.9020603@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5505A19C.9020603@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying for 4.1.--b.

On Sun, Mar 15, 2015 at 11:13:32PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/export.c  | 3 +--
>  fs/nfsd/nfs4xdr.c | 2 +-
>  2 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index c3e3b6e..2911f51 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -691,8 +691,7 @@ static int svc_export_match(struct cache_head *a, struct cache_head *b)
>  	struct svc_export *orig = container_of(a, struct svc_export, h);
>  	struct svc_export *new = container_of(b, struct svc_export, h);
>  	return orig->ex_client == new->ex_client &&
> -		orig->ex_path.dentry == new->ex_path.dentry &&
> -		orig->ex_path.mnt == new->ex_path.mnt;
> +		path_equal(&orig->ex_path, &new->ex_path);
>  }
>  
>  static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index df5e66c..a6a9b90 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2008,7 +2008,7 @@ static __be32 nfsd4_encode_path(struct xdr_stream *xdr,
>  	 * dentries/path components in an array.
>  	 */
>  	for (;;) {
> -		if (cur.dentry == root->dentry && cur.mnt == root->mnt)
> +		if (path_equal(&cur, root))
>  			break;
>  		if (cur.dentry == cur.mnt->mnt_root) {
>  			if (follow_up(&cur))
> -- 
> 2.3.1
