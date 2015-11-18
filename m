Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39883 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756213AbbKRSFJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Nov 2015 13:05:09 -0500
Date: Wed, 18 Nov 2015 13:05:07 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: steved@redhat.com, neilb@suse.de, linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 2/2] exportfs: vet exports for subtree checking when
 testing the export fails
Message-ID: <20151118180507.GC32424@fieldses.org>
References: <1447865430-28434-1-git-send-email-jeff.layton@primarydata.com>
 <1447865430-28434-2-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1447865430-28434-2-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 18, 2015 at 11:50:30AM -0500, Jeff Layton wrote:
> I have a proposed kernel patch that would allow filesystems (such as
> NFS) to opt out of subtree checking when they are exported. We do want
> to warn people at export time however if that doesn't work. If we issued
> a test_export that fails and don't have NFSEXP_NOSUBTREECHECK already set
> in it, then try it again with that set. If that works then we know that
> the filesystem requires NFSEXP_NOSUBTREECHECK be set.

Makes sense to me, ACK.--b.

> 
> Cc: Neil Brown <neilb@suse.de>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  utils/exportfs/exportfs.c | 25 ++++++++++++++++++-------
>  1 file changed, 18 insertions(+), 7 deletions(-)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index cac01fc25f9a..1b704e85c024 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -557,6 +557,20 @@ static int test_export(char *path, int opts)
>  }
>  
>  static void
> +validate_subtree_check(nfs_export *exp)
> +{
> +	char *path = exp->m_export.e_path;
> +
> +	if (!(exp->m_export.e_flags & NFSEXP_NOSUBTREECHECK)) {
> +		if (test_export(path, exp->m_export.e_flags | NFSEXP_NOSUBTREECHECK)) {
> +			xlog(L_ERROR, "%s does not support subtree checking", path);
> +			return;
> +		}
> +	}
> +	xlog(L_ERROR, "%s does not support NFS export", path);
> +}
> +
> +static void
>  validate_export(nfs_export *exp)
>  {
>  	/* Check that the given export point is potentially exportable.
> @@ -587,16 +601,13 @@ validate_export(nfs_export *exp)
>  
>  	if ((exp->m_export.e_flags & NFSEXP_FSID) || exp->m_export.e_uuid ||
>  	    fs_has_fsid) {
> -		if ( !test_export(path, exp->m_export.e_flags)) {
> -			xlog(L_ERROR, "%s does not support NFS export", path);
> -			return;
> -		}
> -	} else if ( ! test_export(path, exp->m_export.e_flags)) {
> +		if (!test_export(path, exp->m_export.e_flags))
> +			validate_subtree_check(exp);
> +	} else if (!test_export(path, exp->m_export.e_flags)) {
>  		if (test_export(path, exp->m_export.e_flags & NFSEXP_FSID))
>  			xlog(L_ERROR, "%s requires fsid= for NFS export", path);
>  		else
> -			xlog(L_ERROR, "%s does not support NFS export", path);
> -		return;
> +			validate_subtree_check(exp);
>  
>  	}
>  }
> -- 
> 2.4.3
