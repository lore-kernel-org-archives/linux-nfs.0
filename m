Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:36443 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbdEQTjc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 17 May 2017 15:39:32 -0400
Received: by mail-qt0-f177.google.com with SMTP id f55so18254484qta.3
        for <linux-nfs@vger.kernel.org>; Wed, 17 May 2017 12:39:31 -0700 (PDT)
Message-ID: <1495049969.10227.1.camel@redhat.com>
Subject: Re: [PATCH 1/4] mount: don't use IPPROTO_UDP for address resolution
From: Jeff Layton <jlayton@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org
Date: Wed, 17 May 2017 15:39:29 -0400
In-Reply-To: <1475834503-3984-2-git-send-email-stefanha@redhat.com>
References: <1475834503-3984-1-git-send-email-stefanha@redhat.com>
         <1475834503-3984-2-git-send-email-stefanha@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-10-07 at 11:01 +0100, Stefan Hajnoczi wrote:
> Although getaddrinfo(3) with IPPROTO_UDP works fine for AF_INET and
> AF_INET6, the AF_VSOCK address family does not support IPPROTO_UDP and
> produces an error.
> 
> Drop IPPROTO_UDP and use the 0 default (TCP) which works for all address
> families.  Modern NFS uses TCP anyway so it's strange to specify UDP.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
>  utils/mount/stropts.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index d5dfb5e..ab2d37b 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -885,9 +885,7 @@ static int nfs_try_mount(struct nfsmount_info *mi)
>  	int result = 0;
>  
>  	if (mi->address == NULL) {
> -		struct addrinfo hint = {
> -			.ai_protocol	= (int)IPPROTO_UDP,
> -		};
> +		struct addrinfo hint = {};
>  		int error;
>  		struct addrinfo *address;
>  

I think this is ok.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
