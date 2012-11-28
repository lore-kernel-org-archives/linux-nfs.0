Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24007 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755404Ab2K1Oj6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 09:39:58 -0500
Message-ID: <50B62236.3080208@RedHat.com>
Date: Wed, 28 Nov 2012 09:39:50 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Revert "mountd: handle allocation failures in auth_unix_ip
 upcall"
References: <20121126220343.GA18140@fieldses.org> <73EFE585-98D4-40BE-9EDF-15CC6B14BDB2@oracle.com> <20121126221535.GB18186@fieldses.org> <A954A569-E030-4119-A349-6CB888979738@oracle.com> <20121126225116.GE18186@fieldses.org> <20121127213127.GH27142@fieldses.org>
In-Reply-To: <20121127213127.GH27142@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 27/11/12 16:31, J. Bruce Fields wrote:
> On Mon, Nov 26, 2012 at 05:51:16PM -0500, J. Bruce Fields wrote:
> commit dfb31d861261c8461a2dc4fb7e8823f5169a9079
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue Nov 27 16:10:41 2012 -0500
> 
>     mountd: auth_unix_ip should downcall on error to prevent hangs
>     
>     Since bf6a4febaa78bf188896b7b5b02c46562dd08b70 "mountd: handle
>     allocation failures in auth_unix_ip upcall", a failure to map the
>     address of an incoming client to a name could result in a hang.
>     
>     We should be responding with an error in the case, not just skipping the
>     downcall and leaving everybody hanging.
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Committed.... 

steved.
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index e950ec6..c13f305 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -109,12 +109,10 @@ static void auth_unix_ip(FILE *f)
>  		struct addrinfo *ai = NULL;
>  
>  		ai = client_resolve(tmp->ai_addr);
> -		if (ai == NULL)
> -			goto out;
> -		client = client_compose(ai);
> -		freeaddrinfo(ai);
> -		if (!client)
> -			goto out;
> +		if (ai) {
> +			client = client_compose(ai);
> +			freeaddrinfo(ai);
> +		}
>  	}
>  	qword_print(f, "nfsd");
>  	qword_print(f, ipaddr);
> @@ -127,7 +125,6 @@ static void auth_unix_ip(FILE *f)
>  	xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, client?client: "DEFAULT");
>  
>  	free(client);
> -out:
>  	freeaddrinfo(tmp);
>  
>  }
> 
