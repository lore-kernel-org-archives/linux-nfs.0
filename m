From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/6] mount: Fix a bug in the legacy version of	nfs_name_to_address()
Date: Wed, 04 Mar 2009 17:59:54 -0500
Message-ID: <49AF07EA.5080804@RedHat.com>
References: <20090227200511.11301.33720.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57361 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753133AbZCDXCd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Mar 2009 18:02:33 -0500
In-Reply-To: <20090227200511.11301.33720.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All 6 patches have been committed...

steved.

Chuck Lever wrote:
> The legacy version of nfs_name_to_address() returned an incorrect
> value for the size of the returned address.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  utils/mount/network.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 92f75b4..b41388e 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -291,7 +291,7 @@ int nfs_name_to_address(const char *hostname,
>  	}
>  
>  	memcpy(&sin->sin_addr, hp->h_addr, hp->h_length);
> -	*salen = hp->h_length;
> +	*salen = sizeof(struct sockaddr_in);
>  	return 1;
>  }
>  #endif	/* HAVE_DECL_AI_ADDRCONFIG */
> 
