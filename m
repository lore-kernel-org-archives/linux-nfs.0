From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] rpc.idmapd: Type of idmap client should be defined by
 ic_id not ic_clid.
Date: Thu, 16 Sep 2010 07:15:00 -0400
Message-ID: <4C91FC34.8040401@RedHat.com>
References: <4C8EE506.1020509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63852 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422Ab0IPLPI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 07:15:08 -0400
In-Reply-To: <4C8EE506.1020509@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/13/2010 10:59 PM, Bian Naimeng wrote:
> The type of idmap_client is defined by idmap_client.ic_id for nfs,
> so nfsd should have the same style.
> 
> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
Committed...

steved.

> 
> ---
>  utils/idmapd/idmapd.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> index 9ecab66..b76607a 100644
> --- a/utils/idmapd/idmapd.c
> +++ b/utils/idmapd/idmapd.c
> @@ -119,8 +119,8 @@ struct idmap_client {
>  static struct idmap_client nfsd_ic[2] = {
>  {
>  	.ic_which = IC_IDNAME, 
> -	.ic_clid = "Server", 
> -	.ic_id = "", 
> +	.ic_clid = "", 
> +	.ic_id = "Server", 
>  	.ic_path = IC_IDNAME_CHAN, 
>  	.ic_fd = -1, 
>  	.ic_dirfd = -1, 
> @@ -128,8 +128,8 @@ static struct idmap_client nfsd_ic[2] = {
>  },
>  {
>  	.ic_which = IC_NAMEID, 
> -	.ic_clid = "Server", 
> -	.ic_id = "", 
> +	.ic_clid = "", 
> +	.ic_id = "Server", 
>  	.ic_path = IC_NAMEID_CHAN, 
>  	.ic_fd = -1, 
>  	.ic_dirfd = -1, 
> -- 1.6.5.2
> -- Regards Bian Naimeng
