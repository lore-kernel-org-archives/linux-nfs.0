Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34359 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752374Ab2EBVku (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 May 2012 17:40:50 -0400
Date: Wed, 2 May 2012 17:40:50 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>, NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 2/5] mountd: parse ip address earlier
Message-ID: <20120502214049.GA11858@fieldses.org>
References: <1335994675-11751-1-git-send-email-bfields@redhat.com>
 <1335994675-11751-3-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1335994675-11751-3-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 02, 2012 at 05:37:52PM -0400, J. Bruce Fields wrote:
> @@ -1057,13 +1066,8 @@ static void nfsd_export(FILE *f)
>  
>  	auth_reload();
>  
> -	if (use_ipaddr) {
> -		struct addrinfo *tmp;
> -		tmp = host_pton(dom);
> -		if (tmp == NULL)
> -			goto out;
> -		ai = client_resolve(tmp->ai_addr);
> -		freeaddrinfo(tmp);
> +	if (is_ipaddr_client(dom)) {

Sorry, this is in the wrong patch; resending in a moment.

--b.

> +		ai = lookup_client_addr(dom);
>  		if (!ai)
>  			goto out;
>  	}
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
