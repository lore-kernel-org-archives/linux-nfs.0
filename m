Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:19433 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217Ab2K0VeH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2012 16:34:07 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH] Revert "mountd: handle allocation failures in auth_unix_ip upcall"
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20121127213127.GH27142@fieldses.org>
Date: Tue, 27 Nov 2012 16:33:57 -0500
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Message-Id: <59B5C309-166F-44FD-BBCD-0B467A476F2C@oracle.com>
References: <20121126220343.GA18140@fieldses.org> <73EFE585-98D4-40BE-9EDF-15CC6B14BDB2@oracle.com> <20121126221535.GB18186@fieldses.org> <A954A569-E030-4119-A349-6CB888979738@oracle.com> <20121126225116.GE18186@fieldses.org> <20121127213127.GH27142@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 27, 2012, at 4:31 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Nov 26, 2012 at 05:51:16PM -0500, J. Bruce Fields wrote:
>> On Mon, Nov 26, 2012 at 05:38:49PM -0500, Chuck Lever wrote:
>>> What exactly is the problem with the current code?
>>> 
>>> client_resolve() can return a NULL in some cases.  Why is it OK to
>>> pass a NULL "ai" to client_compose() ?  Looks like that can result in
>>> a mountd segfault.
>> 
>> Bah, I thought I'd checked this and found it was prepared to handle
>> that, but no:
>> 
>> 	client_check->check_wildcard()
>> 
>> looks like it can oops.
> 
> Right, so the real problem is just that we're skipping the downcall on
> failure instead of responding with a negative cache entry.  Thus we're
> leaving the client hanging instead of returning an error.
> 
> So, I suppose we should do the below, based on steved's suggestion
> (compiled, otherwise untested).

Thanks, this seems reasonable.


> 
> --b.
> 
> commit dfb31d861261c8461a2dc4fb7e8823f5169a9079
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue Nov 27 16:10:41 2012 -0500
> 
>    mountd: auth_unix_ip should downcall on error to prevent hangs
> 
>    Since bf6a4febaa78bf188896b7b5b02c46562dd08b70 "mountd: handle
>    allocation failures in auth_unix_ip upcall", a failure to map the
>    address of an incoming client to a name could result in a hang.
> 
>    We should be responding with an error in the case, not just skipping the
>    downcall and leaving everybody hanging.
> 
>    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index e950ec6..c13f305 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -109,12 +109,10 @@ static void auth_unix_ip(FILE *f)
> 		struct addrinfo *ai = NULL;
> 
> 		ai = client_resolve(tmp->ai_addr);
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
> 	}
> 	qword_print(f, "nfsd");
> 	qword_print(f, ipaddr);
> @@ -127,7 +125,6 @@ static void auth_unix_ip(FILE *f)
> 	xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, client?client: "DEFAULT");
> 
> 	free(client);
> -out:
> 	freeaddrinfo(tmp);
> 
> }

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



