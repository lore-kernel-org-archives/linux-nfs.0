From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Update to NFS/RDMA documentation
Date: Thu, 24 Apr 2008 16:35:42 -0400
Message-ID: <20080424203542.GE18573@fieldses.org>
References: <alpine.LFD.1.00.0804241553060.14137@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49925 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756636AbYDXUft (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Apr 2008 16:35:49 -0400
In-Reply-To: <alpine.LFD.1.00.0804241553060.14137-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 24, 2008 at 03:57:43PM -0400, James Lentini wrote:
> 
> Bruce,
> 
> Below is an update to the NFS/RDMA documentation that clarifies how to 
> configure the exports file. Could you please merge this for 2.6.26?

Applied; thanks.--b.

> 
> Signed-off-by: James Lentini <jlentini@netapp.com>
> 
> --- a/Documentation/filesystems/nfs-rdma.txt	2008-04-24 15:19:25.854101000 -0400
> +++ b/Documentation/filesystems/nfs-rdma.txt	2008-04-24 15:45:56.372312000 -0400
> @@ -5,7 +5,7 @@
>  ################################################################################
>  
>   Author: NetApp and Open Grid Computing
> - Date: February 25, 2008
> + Date: April 15, 2008
>  
>  Table of Contents
>  ~~~~~~~~~~~~~~~~~
> @@ -197,12 +197,16 @@ NFS/RDMA Setup
>    - On the server system, configure the /etc/exports file and
>      start the NFS/RDMA server.
>  
> -    Exports entries with the following format have been tested:
> +    Exports entries with the following formats have been tested:
>  
> -    /vol0   10.97.103.47(rw,async) 192.168.0.47(rw,async,insecure,no_root_squash)
> +    /vol0   192.168.0.47(fsid=0,rw,async,insecure,no_root_squash)
> +    /vol0   192.168.0.0/255.255.255.0(fsid=0,rw,async,insecure,no_root_squash)
>  
> -    Here the first IP address is the client's Ethernet address and the second
> -    IP address is the clients IPoIB address.
> +    The IP address(es) is(are) the client's IPoIB address for an InfiniBand HCA or the
> +    cleint's iWARP address(es) for an RNIC.
> +
> +    NOTE: The "insecure" option must be used because the NFS/RDMA client does not
> +    use a reserved port.
>  
>   Each time a machine boots:
>  
