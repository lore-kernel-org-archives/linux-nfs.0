Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35781 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755777Ab3CUNUH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Mar 2013 09:20:07 -0400
Date: Thu, 21 Mar 2013 09:20:07 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] mountd: Add a default flavor to an export's e_secinfo
 list
Message-ID: <20130321132007.GA27838@fieldses.org>
References: <20130320223129.11659.35205.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130320223129.11659.35205.stgit@seurat.1015granger.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 20, 2013 at 06:31:30PM -0400, Chuck Lever wrote:
> The list of security flavors that mountd allows for the NFSv4
> pseudo-fs is constructed from the union of flavors of all current
> exports.
> 
> exports(5) documents that the default security flavor for an
> export, if "sec=" is not specified, is "sys".  Suppose
> /etc/exports contains:
> 
> /a	*(rw)
> /b	*(rw,sec=krb5:krb5i:krb5p)
> 
> The resulting security flavor list for the pseudo-fs is missing
> "sec=sys".  /proc/net/rpc/nfsd.export/content contains:
> 
> /a	*(rw,root_squash,sync,wdelay,no_subtree_check,
> 		uuid=095c95bc:08e4407a:91ab8601:05fe0bbf)
> /b	*(rw,root_squash,sync,wdelay,no_subtree_check,
> 		uuid=2a6fe811:0cf044a7:8fc75ebe:65180068,
> 		sec=390003:390004:390005)
> /	*(ro,root_squash,sync,no_wdelay,v4root,fsid=0,
> 		uuid=2a6fe811:0cf044a7:8fc75ebe:65180068,
> 		sec=390003:390004:390005)
> 
> The root entry is not correct, as there does exist an export whose
> unspecified default security flavor is "sys".  The security settings
> on the root cause sec=sys mount attempts to be incorrectly rejected.
> 
> The reason is that when the line in /etc/exports for "/a" is parsed,
> the e_secinfo list for that exportent is left empty.  Thus the union
> of e_secinfo lists created by set_pseudofs_security() is
> "krb5:krb5i:krb5p".
> 
> I fixed this by ensuring that if no "sec=" option is specified for
> an export, its e_secinfo list gets at least an entry for AUTH_UNIX.
> 
> [ Yes, we could make the security flavors allowed for the pseudo-fs
> a fixed list of all flavors the server supports.  That becomes
> complicated by the special meaning of AUTH_NULL, and we still have
> to check /etc/exports for whether Kerberos flavors should be listed.
> I opted for a simple approach for now. ]
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

Makes sense to me.--b.

> ---
> 
>  support/nfs/exports.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index 84a2b08..6c08a2b 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -643,6 +643,8 @@ bad_option:
>  			cp++;
>  	}
>  
> +	if (ep->e_secinfo[0].flav == NULL)
> +		secinfo_addflavor(find_flavor("sys"), ep);
>  	fix_pseudoflavor_flags(ep);
>  	ep->e_squids = squids;
>  	ep->e_sqgids = sqgids;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
