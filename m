Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43910 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751675AbdF3Oe5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 10:34:57 -0400
Subject: Re: [PATCH nfs-utils v2 01/12] mount: don't use IPPROTO_UDP for
 address resolution
To: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Abbas Naderi <abiusx@google.com>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-2-stefanha@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <0983a632-3f1d-06eb-2ffc-e04536c6c34c@RedHat.com>
Date: Fri, 30 Jun 2017 10:34:54 -0400
MIME-Version: 1.0
In-Reply-To: <20170630132120.31578-2-stefanha@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/30/2017 09:21 AM, Stefan Hajnoczi wrote:
> Although getaddrinfo(3) with IPPROTO_UDP works fine for AF_INET and
> AF_INET6, the AF_VSOCK address family does not support IPPROTO_UDP and
> produces an error.
> 
> Drop IPPROTO_UDP and use the 0 default (TCP) which works for all address
> families.  Modern NFS uses TCP anyway so it's strange to specify UDP.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> Reviewed-by: Jeff Layton <jlayton@redhat.com>
> ---
>  utils/mount/stropts.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index c2a739b..99656dd 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -909,9 +909,7 @@ static int nfs_try_mount(struct nfsmount_info *mi)
>  	int result = 0;
>  
>  	if (mi->address == NULL) {
> -		struct addrinfo hint = {
> -			.ai_protocol	= (int)IPPROTO_UDP,
> -		};
> +		struct addrinfo hint = {};
Just curious as to why not simply pass a NULL hints parameter 
verses an empty hints structure?

steved.

>  		int error;
>  		struct addrinfo *address;
>  
> 
