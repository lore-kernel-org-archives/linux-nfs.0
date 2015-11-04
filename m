Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52842 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965397AbbKDVvk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2015 16:51:40 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 2C97391356
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2015 21:51:40 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] exportfs: Restore the EAI_NONAME check in
 host_pton()
To: Scott Mayhew <smayhew@redhat.com>
References: <1446052796-10287-1-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <563A7DEA.8060706@RedHat.com>
Date: Wed, 4 Nov 2015 16:51:38 -0500
MIME-Version: 1.0
In-Reply-To: <1446052796-10287-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/28/2015 01:19 PM, Scott Mayhew wrote:
> Commit d89e3fc7 removed the EAI_NONAME check altogether instead of just
> moving the NULL check.  This causes exportfs -u to incorrectly exit
> with 1 whenever there's more than one MCL_FQDN export in the exportlist.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... 

steved.
> ---
>  support/export/hostname.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/support/export/hostname.c b/support/export/hostname.c
> index 169baa5..7a44d42 100644
> --- a/support/export/hostname.c
> +++ b/support/export/hostname.c
> @@ -134,6 +134,8 @@ host_pton(const char *paddr)
>  			break;
>  		}
>  		return ai;
> +	case EAI_NONAME:
> +		break;
>  	case EAI_SYSTEM:
>  		xlog(D_GENERAL, "%s: failed to convert %s: (%d) %m",
>  				__func__, paddr, errno);
> 
