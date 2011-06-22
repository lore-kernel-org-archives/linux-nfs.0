Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:22671 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756726Ab1FVQu2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 12:50:28 -0400
Subject: Re: [PATCH] nfs: fix host_reliable_addrinfo (try #2)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1308756953-10277-1-git-send-email-jlayton@redhat.com>
Date: Wed, 22 Jun 2011 10:50:11 -0600
Cc: linux-nfs@vger.kernel.org, neilb@suse.de
Message-Id: <268F789B-6679-4E24-A9F4-7D6E9FB44040@oracle.com>
References: <1308756953-10277-1-git-send-email-jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks.

This is a security problem, but I don't want to lose sight of the original cause of this bug, which was my lack of understanding of the function of the old code and the API contract (return only _one_ address).

For extra credit, we might check if statd has a similar issue when it matches addresses.

On Jun 22, 2011, at 9:35 AM, Jeff Layton wrote:

> According to Neil Brown:
> 
>    The point of the word 'reliable' is to check that the name we get
>    really does belong to the host in question - ie that both the
>    forward and reverse maps agree.
> 
>    But the new code doesn't do that check at all.  Rather it simply
>    maps the address to a name, then discards the address and maps the
>    name back to a list of addresses and uses that list of addresses as
>    "where the request came from" for permission checking.
> 
> This bug is exploitable via the following scenario and could allow an
> attacker access to data that they shouldn't be able to access.
> 
>    Suppose you export a filesystem to some subnet or FQDN and also to a
>    wildcard or netgroup, and I know the details of this (maybe
>    showmount -e tells me) Suppose further that I can get IP packets to
>    your server..
> 
>    Then I create a reverse mapping for my ipaddress to a domain that I
>    own, say "black.hat.org", and a forward mapping from that domain to
>    my IP address, and one of your IP addresses.
> 
>    Then I try to mount your filesystem.  The IP address gets correctly
>    mapped to "black.hat.org" and then mapped to both my IP address and
>    your IP address.
> 
>    Then you search through all of your exports and find that one of the
>    addresses: yours - is allowed to access the filesystem.
> 
>    So you create an export based on the addrinfo you have which allows
>    my IP address the same access as your IP address.
> 
> Fix this by instead using the forward lookup of the hostname just to
> verify that the original address is in the list. Then do a numeric
> lookup using the address and stick the hostname in the ai_canonname.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Reviewed-by: NeilBrown <neilb@suse.de>
> ---
> support/export/hostname.c |   36 ++++++++++++++++++++++++++++++------
> 1 files changed, 30 insertions(+), 6 deletions(-)
> 
> diff --git a/support/export/hostname.c b/support/export/hostname.c
> index efcb75c..3e949a1 100644
> --- a/support/export/hostname.c
> +++ b/support/export/hostname.c
> @@ -258,17 +258,19 @@ host_canonname(const struct sockaddr *sap)
>  * @sap: pointer to socket address to look up
>  *
>  * Reverse and forward lookups are performed to ensure the address has
> - * proper forward and reverse mappings.
> + * matching forward and reverse mappings.
>  *
> - * Returns address info structure with ai_canonname filled in, or NULL
> - * if no information is available for @sap.  Caller must free the returned
> - * structure with freeaddrinfo(3).
> + * Returns addrinfo structure with just the provided address with
> + * ai_canonname filled in. If there is a problem with resolution or
> + * the resolved records don't match up properly then it returns NULL
> + *
> + * Caller must free the returned structure with freeaddrinfo(3).
>  */
> __attribute_malloc__
> struct addrinfo *
> host_reliable_addrinfo(const struct sockaddr *sap)
> {
> -	struct addrinfo *ai;
> +	struct addrinfo *ai, *a;
> 	char *hostname;
> 
> 	hostname = host_canonname(sap);
> @@ -276,9 +278,31 @@ host_reliable_addrinfo(const struct sockaddr *sap)
> 		return NULL;
> 
> 	ai = host_addrinfo(hostname);
> +	if (!ai)
> +		goto out_free_hostname;
> 
> -	free(hostname);
> +	/* make sure there's a matching address in the list */
> +	for (a = ai; a; a = a->ai_next)
> +		if (nfs_compare_sockaddr(a->ai_addr, sap))
> +			break;
> +
> +	freeaddrinfo(ai);
> +	if (!a)
> +		goto out_free_hostname;
> +
> +	/* get addrinfo with just the original address */
> +	ai = host_numeric_addrinfo(sap);
> +	if (!ai)
> +		goto out_free_hostname;
> +
> +	/* and populate its ai_canonname field */
> +	free(ai->ai_canonname);
> +	ai->ai_canonname = hostname;
> 	return ai;
> +
> +out_free_hostname:
> +	free(hostname);
> +	return NULL;
> }
> 
> /**
> -- 
> 1.7.5.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



