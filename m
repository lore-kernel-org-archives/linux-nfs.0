From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] update mount.nfs example in NFS/RDMA documentation
Date: Thu, 29 May 2008 18:15:58 -0400
Message-ID: <20080529221558.GF24018@fieldses.org>
References: <alpine.LFD.1.10.0805291534360.2898@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41875 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752388AbYE2WQF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 May 2008 18:16:05 -0400
In-Reply-To: <alpine.LFD.1.10.0805291534360.2898-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 29, 2008 at 03:40:49PM -0400, James Lentini wrote:
> 
> Bruce,
> 
> Below is an update to the NFS/RDMA documentation that clarifies how 
> to run mount.nfs. Could you please merge this for 2.6.26?

Sure, but:

> 
> Signed-off-by: James Lentini <jlentini@netapp.com>
> 
> --- a/Documentation/filesystems/nfs-rdma.txt	2008-05-29 15:09:38.753033000 -0400
> +++ b/Documentation/filesystems/nfs-rdma.txt	2008-05-29 15:31:33.374948000 -0400
> @@ -5,7 +5,7 @@
>  ################################################################################
>  
>   Author: NetApp and Open Grid Computing
> - Date: February 25, 2008
> + Date: May 29, 2008

I'm getting rejects--the version upstream right now is dated April 15.
Could you re-diff that?

--b.

>  
>  Table of Contents
>  ~~~~~~~~~~~~~~~~~
> @@ -242,10 +242,19 @@ NFS/RDMA Setup
>  
>      > modprobe xprtrdma.ko
>  
> -    Regardless of how the client was built (module or built-in), issue the mount.nfs command:
> +    Regardless of how the client was built (module or built-in), use the mount.nfs command to 
> +    mount the NFS/RDMA server.
> +
> +    If you have nfs-utils version 1.1.1, use this command:
>  
>      > /path/to/your/mount.nfs <IPoIB-server-name-or-address>:/<export> /mnt -i -o rdma,port=2050
>  
> +    If you have nfs-utils version 1.1.2 or later, use this command (the "-i" flag is no longer 
> +    needed; the command checks the kernel's version to see if the NFS string mount API support is 
> +    available):
> +
> +    > /path/to/your/mount.nfs <IPoIB-server-name-or-address>:/<export> /mnt -o rdma,port=2050
> +
>      To verify that the mount is using RDMA, run "cat /proc/mounts" and check the
>      "proto" field for the given mount.
>  
