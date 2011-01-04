From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] libnsm.a: modify return value to false from 0 at nsm_drop_privileges()
Date: Tue, 04 Jan 2011 11:19:09 -0500
Message-ID: <4D23487D.2030804@RedHat.com>
References: <4D142BDA.6080809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Cc: NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38518 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750954Ab1ADQTQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 11:19:16 -0500
In-Reply-To: <4D142BDA.6080809@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/24/2010 12:12 AM, Mi Jinlong wrote:
> At nsm_drop_privileges(), for improving readability, unify
> the return value.
> 
> ---
>  support/nsm/file.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/support/nsm/file.c b/support/nsm/file.c
> index e21c7d4..98b47bf 100644
> --- a/support/nsm/file.c
> +++ b/support/nsm/file.c
> @@ -421,7 +421,7 @@ nsm_drop_privileges(const int pidfd)
>  	 */
>          if (prctl(PR_SET_KEEPCAPS, 1, 0, 0, 0) == -1) {
>                  xlog(L_ERROR, "prctl(PR_SET_KEEPCAPS) failed: %m");
> -		return 0;
> +		return false;
>  	}
>  
>  	if (setgroups(0, NULL) == -1) {
Committed... Thanks!

steved
