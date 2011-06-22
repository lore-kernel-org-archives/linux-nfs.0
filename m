Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:64785 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932180Ab1FVPPZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 11:15:25 -0400
Subject: Re: [PATCH] nfs: fix host_reliable_addrinfo
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1308745999-6551-1-git-send-email-jlayton@redhat.com>
Date: Wed, 22 Jun 2011 09:14:37 -0600
Cc: steved@redhat.com, linux-nfs@vger.kernel.org, neilb@suse.de,
        bfields@fieldses.org
Message-Id: <B477E2D7-D95D-468A-9403-9A8AE195ABAB@oracle.com>
References: <1308745999-6551-1-git-send-email-jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Jeff-

On Jun 22, 2011, at 6:33 AM, Jeff Layton wrote:

> According to Neil Brown:
> 
>    The point of the word 'reliable' is to check that the name we get
>    really does belong to the host in question - ie that both the
>    forward and reverse maps agree.

Should you correct the documenting comment for host_reliable_addrinfo() to reflect Neil's insight?

>    But the new code doesn't do that check at all.  Rather it simply
>    maps the address to a name, then discards the address and maps the
>    name back to a list of addresses and uses that list of addresses as
>    "where the request came from" for permission checking.

The patch description might also mention why this is a problem (ie, what's our exposure due to the current behavior).

> Fix this by instead using the forward lookup of the hostname just to
> verify that the original address is in the list. Then do a numeric
> lookup using the address and stick the hostname in the ai_canonname.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Reviewed-by: NeilBrown <neilb@suse.de>
> ---
> support/export/hostname.c |   26 ++++++++++++++++++++++++--
> 1 files changed, 24 insertions(+), 2 deletions(-)
> 
> diff --git a/support/export/hostname.c b/support/export/hostname.c
> index efcb75c..595333e 100644
> --- a/support/export/hostname.c
> +++ b/support/export/hostname.c
> @@ -268,7 +268,7 @@ __attribute_malloc__
> struct addrinfo *
> host_reliable_addrinfo(const struct sockaddr *sap)
> {
> -	struct addrinfo *ai;
> +	struct addrinfo *ai, *a;
> 	char *hostname;
> 
> 	hostname = host_canonname(sap);
> @@ -276,9 +276,31 @@ host_reliable_addrinfo(const struct sockaddr *sap)
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

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



