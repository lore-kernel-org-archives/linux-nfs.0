From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Patch] nfs: extended buffer length for eeproo 100
Date: Fri, 20 Jun 2008 12:49:31 -0400
Message-ID: <0358F4F9-77DE-4592-80F9-72E585A5AB86@oracle.com>
References: <485BBBF5.3020509@inria.fr>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: nfsv4 <nfsv4@linux-nfs.org>, NFS list <linux-nfs@vger.kernel.org>
To: Guillaume Rousse <Guillaume.Rousse-MZpvjPyXg2s@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:14929 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754299AbYFTQvD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jun 2008 12:51:03 -0400
In-Reply-To: <485BBBF5.3020509-MZpvjPyXg2s@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 20, 2008, at 10:17 AM, Guillaume Rousse wrote:
> And old patch still present in mandriva nfs-utils package, from an  
> unknown author
> -- 
> Guillaume Rousse
> Moyens Informatiques - INRIA Futurs
> Tel: 01 69 35 69 62
> diff -uNr nfs-utils-0.2.1/support/nfs/rpcmisc.c nfs-utils-0.2.1- 
> eepro100/support/nfs/rpcmisc.c
> --- nfs-utils-0.2.1/support/nfs/rpcmisc.c	Sun Apr 30 00:14:56 2000
> +++ nfs-utils-0.2.1-eepro100/support/nfs/rpcmisc.c	Fri Jan 19  
> 13:51:45 2001
> @@ -176,7 +176,8 @@
> 		int sblen, rblen;
>
> 		/* 1024 for rpc & transport overheads */
> -		sblen = rblen = socksz + 1024;
> +		/* but, 2048 needed for eepro100 */
> +		sblen = rblen = socksz + 2048;
> 		if (setsockopt(s, SOL_SOCKET, SO_SNDBUF, &sblen, sizeof sblen) < 0  
> ||
> 		    setsockopt(s, SOL_SOCKET, SO_RCVBUF, &rblen, sizeof rblen) < 0)
> 			xlog(L_ERROR, "setsockopt failed: %s\n", strerror(errno));

I can't see why user-space applications would need a larger socket  
buffer for a specific NIC.

However, this is moot because this whole section of code has been  
ifdef'd out since 2001.  I think you can safely drop this one.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
