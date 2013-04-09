Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35136 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935119Ab3DITLT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 15:11:19 -0400
Date: Tue, 9 Apr 2013 15:11:13 -0400
To: Jose Castillo <jcastillo@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>, steved@redhat.com
Subject: Re: [PATCH] Add the missing '$' in auth_unix_ip()
Message-ID: <20130409191113.GC3800@fieldses.org>
References: <1365522899-29123-1-git-send-email-jcastillo@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1365522899-29123-1-git-send-email-jcastillo@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Could you explain a little more?

I assume this is something I forgot to do as part of
c2544b77566690ebec32a2d47c9249548b1a0941 "mountd: prepend '$' to make
use_ipaddr clients self-describing" but I haven't thought about that in
a while....

--b.

On Tue, Apr 09, 2013 at 04:54:59PM +0100, Jose Castillo wrote:
> Signed-off-by: Jose Castillo <jcastillo@redhat.com>
> ---
>  utils/mountd/cache.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 978698d..e1027f3 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -80,7 +80,7 @@ static void auth_unix_ip(FILE *f)
>  	 */
>  	char *cp;
>  	char class[20];
> -	char ipaddr[INET6_ADDRSTRLEN];
> +	char ipaddr[INET6_ADDRSTRLEN + 1];
>  	char *client = NULL;
>  	struct addrinfo *tmp = NULL;
>  	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
> @@ -94,7 +94,7 @@ static void auth_unix_ip(FILE *f)
>  	    strcmp(class, "nfsd") != 0)
>  		return;
>  
> -	if (qword_get(&cp, ipaddr, sizeof(ipaddr)) <= 0)
> +	if (qword_get(&cp, ipaddr, sizeof(ipaddr) - 1) <= 0)
>  		return;
>  
>  	tmp = host_pton(ipaddr);
> @@ -116,9 +116,11 @@ static void auth_unix_ip(FILE *f)
>  	qword_print(f, "nfsd");
>  	qword_print(f, ipaddr);
>  	qword_printtimefrom(f, DEFAULT_TTL);
> -	if (use_ipaddr)
> +	if (use_ipaddr) {
> +		memmove(ipaddr + 1, ipaddr, strlen(ipaddr) + 1);
> +		ipaddr[0] = '$';
>  		qword_print(f, ipaddr);
> -	else if (client)
> +	} else if (client)
>  		qword_print(f, *client?client:"DEFAULT");
>  	qword_eol(f);
>  	xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, client?client: "DEFAULT");
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
