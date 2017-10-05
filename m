Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54492 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdJEO4x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Oct 2017 10:56:53 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0FE5A129B
        for <linux-nfs@vger.kernel.org>; Thu,  5 Oct 2017 14:56:53 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id D3AE35E1A6
        for <linux-nfs@vger.kernel.org>; Thu,  5 Oct 2017 14:56:52 +0000 (UTC)
Subject: Re: [PATCH] rpc.nfsd: Do not fail when all address families are not
 support.
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20171002142033.25493-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <e3116140-3315-e192-f6bf-26ddf284d3f6@RedHat.com>
Date: Thu, 5 Oct 2017 10:56:52 -0400
MIME-Version: 1.0
In-Reply-To: <20171002142033.25493-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/02/2017 10:20 AM, Steve Dickson wrote:
> Commit 2f8a6020 introduce a regression causing rpc.nfsd
> to fail when IPv6 is not supported. rpc.nfsd should not
> fail when there is at least one bounded socket.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed.... 

steved.
> ---
>  utils/nfsd/nfssvc.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> index e8609c1..fc36792 100644
> --- a/utils/nfsd/nfssvc.c
> +++ b/utils/nfsd/nfssvc.c
> @@ -112,7 +112,7 @@ static int
>  nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
>  {
>  	int fd, on = 1, fac = L_ERROR;
> -	int sockfd = -1, rc = 0;
> +	int sockfd = -1, rc = 0, bounded = 0;
>  	struct addrinfo *addrhead = NULL, *addr;
>  	char *proto, *family;
>  
> @@ -233,6 +233,8 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
>  			rc = errno;
>  			goto error;
>  		}
> +		bounded++;
> +
>  		close(fd);
>  		close(sockfd);
>  		sockfd = fd = -1;
> @@ -245,7 +247,7 @@ error:
>  		close(sockfd);
>  	if (addrhead)
>  		freeaddrinfo(addrhead);
> -	return rc;
> +	return (bounded ? 0 : rc);
>  }
>  
>  int
> 
