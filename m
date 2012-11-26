Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:18077 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755818Ab2KZWFZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Nov 2012 17:05:25 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH] Revert "mountd: handle allocation failures in auth_unix_ip upcall"
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20121126220343.GA18140@fieldses.org>
Date: Mon, 26 Nov 2012 17:05:22 -0500
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Message-Id: <73EFE585-98D4-40BE-9EDF-15CC6B14BDB2@oracle.com>
References: <20121126220343.GA18140@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 26, 2012, at 5:03 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> This reverts commit 485f7a21e1649797f29317b865cbb094c1f6a71d.  The
> failures handled there could be any sort of name resolution failure, not
> just an allocation, and failing to downcall (hence leaving the client
> hanging) is not the correct thing to do in those cases.

The problem is in the kernel, then: a downcall should be allowed to fail, IMO.

> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
> utils/mountd/cache.c | 12 +++---------
> 1 file changed, 3 insertions(+), 9 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 8f14032..6710eca 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -84,6 +84,7 @@ static void auth_unix_ip(FILE *f)
> 	char ipaddr[INET6_ADDRSTRLEN];
> 	char *client = NULL;
> 	struct addrinfo *tmp = NULL;
> +	struct addrinfo *ai = NULL;
> 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
> 		return;
> 
> @@ -106,16 +107,12 @@ static void auth_unix_ip(FILE *f)
> 
> 	/* addr is a valid, interesting address, find the domain name... */
> 	if (!use_ipaddr) {
> -		struct addrinfo *ai = NULL;
> -
> 		ai = client_resolve(tmp->ai_addr);
> -		if (ai == NULL)
> -			goto out;
> 		client = client_compose(ai);
> 		freeaddrinfo(ai);
> -		if (!client)
> -			goto out;
> 	}
> +	freeaddrinfo(tmp);
> +
> 	qword_print(f, "nfsd");
> 	qword_print(f, ipaddr);
> 	qword_printuint(f, time(0) + DEFAULT_TTL);
> @@ -127,9 +124,6 @@ static void auth_unix_ip(FILE *f)
> 	xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, client?client: "DEFAULT");
> 
> 	free(client);
> -out:
> -	freeaddrinfo(tmp);
> -
> }
> 
> static void auth_unix_gid(FILE *f)
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



