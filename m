Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40772 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765AbbAWPhp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jan 2015 10:37:45 -0500
Message-ID: <54C26AC5.6030303@RedHat.com>
Date: Fri, 23 Jan 2015 10:37:41 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chris Mayo <aklhfex@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] systemd: Ensure RPC pipefs is mounted before rpc.idmapd
 starts
References: <54BFCB7C.5020902@gmail.com>
In-Reply-To: <54BFCB7C.5020902@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/21/2015 10:53 AM, Chris Mayo wrote:
> rpc.idmapd aborts on start-up if RPC pipefs is not present.
> 
> Needed if GSS services are not used.
> 
> Signed-off-by: Chris Mayo <aklhfex@gmail.com>
Committed... 

steved.

> ---
>  systemd/nfs-idmapd.service | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
> index 726038d..e84f8c8 100644
> --- a/systemd/nfs-idmapd.service
> +++ b/systemd/nfs-idmapd.service
> @@ -1,5 +1,7 @@
>  [Unit]
>  Description=NFSv4 ID-name mapping service
> +Requires=var-lib-nfs-rpc_pipefs.mount
> +After=var-lib-nfs-rpc_pipefs.mount
>  
>  BindsTo=nfs-server.service
>  
> 
