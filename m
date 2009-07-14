From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] SUNRPC: handle IPv6 PKTINFO when extracting
	destination address
Date: Tue, 14 Jul 2009 17:41:42 -0400
Message-ID: <20090714214141.GI2551@fieldses.org>
References: <20090713145352.2177.8095.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53693 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756250AbZGNVlo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2009 17:41:44 -0400
In-Reply-To: <20090713145352.2177.8095.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 13, 2009 at 10:54:26AM -0400, Chuck Lever wrote:
> PKTINFO is needed to scrape the caller's IP address off the socket so
> RPC datagram replies are routed correctly.  Fill in missing pieces in
> the kernel RPC server's UDP receive path to request IPv6 PKTINFO and
> correctly parse the IPv6 cmsg header.
> 
> Without this patch, kernel RPC services drop all incoming requests on
> UDP on IPv6.

Looks fine, thanks--applied for 2.6.32.

> @@ -531,16 +551,15 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
>  
>  	rqstp->rq_prot = IPPROTO_UDP;
>  
> -	if (cmh->cmsg_level != IPPROTO_IP ||
> -	    cmh->cmsg_type != IP_PKTINFO) {
> +	if (!svc_udp_get_dest_address(rqstp, cmh)) {

(Though personally I would have done this as two patches, with most of
it in a preparatory cleanup patch and the above chunk (which if I
understand right represents the only change in behavior) as the bugfix.)

--b.
