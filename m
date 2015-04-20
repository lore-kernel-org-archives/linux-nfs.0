Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38272 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751223AbbDTS5V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Apr 2015 14:57:21 -0400
Date: Mon, 20 Apr 2015 14:57:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC 02/39] uapi: Remove kernel internal declaration
Message-ID: <20150420185720.GA27895@fieldses.org>
References: <cover.1427471526.git.agruenba@redhat.com>
 <063d443cc0ddc5db271cdaa6649443eb699736d0.1427471526.git.agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <063d443cc0ddc5db271cdaa6649443eb699736d0.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2015 at 05:50:00PM +0100, Andreas Gruenbacher wrote:
> The enum nfs4_acl_whotype is only used in nfs4d's internal nfs4 acl
> representation. No longer expose it to user space.

I'll go ahead and apply that now.

--b.

> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  include/linux/nfs4.h      | 7 +++++++
>  include/uapi/linux/nfs4.h | 7 -------
>  2 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index ed43cb7..32201c2 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -16,6 +16,13 @@
>  #include <linux/uidgid.h>
>  #include <uapi/linux/nfs4.h>
>  
> +enum nfs4_acl_whotype {
> +	NFS4_ACL_WHO_NAMED = 0,
> +	NFS4_ACL_WHO_OWNER,
> +	NFS4_ACL_WHO_GROUP,
> +	NFS4_ACL_WHO_EVERYONE,
> +};
> +
>  struct nfs4_ace {
>  	uint32_t	type;
>  	uint32_t	flag;
> diff --git a/include/uapi/linux/nfs4.h b/include/uapi/linux/nfs4.h
> index 35f5f4c..adc0aff 100644
> --- a/include/uapi/linux/nfs4.h
> +++ b/include/uapi/linux/nfs4.h
> @@ -162,13 +162,6 @@
>   */
>  #define NFS4_MAX_BACK_CHANNEL_OPS 2
>  
> -enum nfs4_acl_whotype {
> -	NFS4_ACL_WHO_NAMED = 0,
> -	NFS4_ACL_WHO_OWNER,
> -	NFS4_ACL_WHO_GROUP,
> -	NFS4_ACL_WHO_EVERYONE,
> -};
> -
>  #endif /* _UAPI_LINUX_NFS4_H */
>  
>  /*
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
