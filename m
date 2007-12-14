From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 11/38] svc: Add xpo_accept transport function
Date: Fri, 14 Dec 2007 14:55:44 -0500
Message-ID: <20071214195544.GE23121@fieldses.org>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int> <20071211233217.15718.14380.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50821 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754056AbXLNTzs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Dec 2007 14:55:48 -0500
In-Reply-To: <20071211233217.15718.14380.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 11, 2007 at 05:32:17PM -0600, Tom Tucker wrote:
> @@ -1053,11 +1060,10 @@ svc_tcp_accept(struct svc_sock *svsk)
>  		else if (err != -EAGAIN && net_ratelimit())
>  			printk(KERN_WARNING "%s: accept failed (err %d)!\n",
>  				   serv->sv_name, -err);
> -		return;
> +		return NULL;
>  	}
>  
>  	set_bit(SK_CONN, &svsk->sk_flags);
> -	svc_sock_enqueue(svsk);
>  
>  	err = kernel_getpeername(newsock, sin, &slen);
>  	if (err < 0) {

Why did we need that svc_sock_enqueue here, and why don't we any more?
(And if we don't, but we still need the set_bit, then we need to fix the
comment at the top of the file claiming the svc_sock_enqueue() is always
required after setting SK_CONN.)

--b.
