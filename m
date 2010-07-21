From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/24] Remove warnings from nfsctl.c
Date: Wed, 21 Jul 2010 13:06:46 -0400
Message-ID: <20100721170646.GA26418@fieldses.org>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
 <1279669057-17509-3-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49671 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751218Ab0GURHb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 13:07:31 -0400
In-Reply-To: <1279669057-17509-3-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 20, 2010 at 07:37:15PM -0400, Steve Dickson wrote:
> nfsctl.c: In function 'expsetup':
> nfsctl.c:112: warning: signed and unsigned type in conditional expression
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  support/export/nfsctl.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/support/export/nfsctl.c b/support/export/nfsctl.c
> index 3b9876a..f89c644 100644
> --- a/support/export/nfsctl.c
> +++ b/support/export/nfsctl.c
> @@ -109,7 +109,7 @@ expsetup(struct nfsctl_export *exparg, nfs_export *exp, int unexport)
>  	str_tolower(exparg->ex_client);
>  	exparg->ex_flags    = exp->m_export.e_flags;
>  	exparg->ex_dev      = (!unexport && (exp->m_export.e_flags & NFSEXP_FSID)) ?
> -				exp->m_export.e_fsid : stb.st_dev;
> +			(__nfsd_dev_t)exp->m_export.e_fsid : stb.st_dev;

Any reason not to just define e_fsid as an __nfsd_dev_t to start off
with?

--b.

>  	exparg->ex_ino      = stb.st_ino;
>  	exparg->ex_anon_uid = exp->m_export.e_anonuid;
>  	exparg->ex_anon_gid = exp->m_export.e_anongid;
> -- 
> 1.7.0.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
