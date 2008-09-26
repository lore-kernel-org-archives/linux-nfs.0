From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/2] SUNRPC: Use short-hand IPv6 ANYADDR for RPCB_SET
Date: Fri, 26 Sep 2008 17:20:00 -0400
Message-ID: <20080926212000.GB7138@fieldses.org>
References: <20080915212437.3939.82594.stgit@ellison.1015granger.net> <20080915212730.3939.35770.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: okir@suse.de, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50043 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754038AbYIZVUE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 17:20:04 -0400
In-Reply-To: <20080915212730.3939.35770.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 15, 2008 at 04:27:30PM -0500, Chuck Lever wrote:
> Clean up: When doing an RPCB_SET, make the kernel's rpcb client use the
> shorthand "::" for the universal form of the IPv6 ANY address.
> 
> Without this patch, rpcbind will advertise:
> 
>   0000:0000:0000:0000:0000:0000:0000:0000.x.y
> 
> This is cosmetic only.  It cleans up the display of information from
> /sbin/rpcinfo.

Also applied.

> + 	if (ipv6_addr_any(&address_to_register->sin6_addr))

Nit: I fixed up some initial whitespace.  Checkpatch or git apply should
warn about this.

--b.

> +		snprintf(buf, sizeof(buf), "::.%u.%u",
> +				port >> 8, port & 0xff);
> +	else
> +		snprintf(buf, sizeof(buf), NIP6_FMT".%u.%u",
> +				NIP6(address_to_register->sin6_addr),
> +				port >> 8, port & 0xff);
>  	map->r_addr = buf;
>  
>  	dprintk("RPC:       %sregistering [%u, %u, %s, '%s'] with "
> 
