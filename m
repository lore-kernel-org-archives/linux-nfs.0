From: James Lentini <jlentini@netapp.com>
Subject: Re: [PATCH] update NFS/RDMA documentation
Date: Mon, 2 Jun 2008 16:25:02 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806021624440.26788@jlentini-linux.nane.netapp.com>
References: <alpine.LFD.1.10.0806021530560.26788@jlentini-linux.nane.netapp.com> <20080602200243.GB27583@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Talpey <talpey@netapp.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56295 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755257AbYFBUZT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jun 2008 16:25:19 -0400
In-Reply-To: <20080602200243.GB27583@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Mon, 2 Jun 2008, J. Bruce Fields wrote:

> On Mon, Jun 02, 2008 at 03:33:59PM -0400, James Lentini wrote:
> > 
> > Bruce,
> > 
> > Below is an update to the NFS/RDMA documentation that clarifies how to 
> > run mount.nfs and addresses comments from you and Chuck. Could you 
> > please merge this for 2.6.26?
> 
> Yep, thanks.
> 
> Mind if we keep this wrapped at under 80 characters?

Sounds good.

> 
> --b.
> 
> commit 80d7681a66c1d800fd6a8e03346219f5e8de185d
> Author: J. Bruce Fields <bfields@citi.umich.edu>
> Date:   Mon Jun 2 16:01:51 2008 -0400
> 
>     nfs: rewrap NFS/RDMA documentation to 80 lines
>     
>     Wrap long lines.
>     
>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> 
> diff --git a/Documentation/filesystems/nfs-rdma.txt b/Documentation/filesystems/nfs-rdma.txt
> index 9ad453d..44bd766 100644
> --- a/Documentation/filesystems/nfs-rdma.txt
> +++ b/Documentation/filesystems/nfs-rdma.txt
> @@ -63,10 +63,10 @@ Installation
>    - Install nfs-utils-1.1.2 or greater on the client
>  
>      An NFS/RDMA mount point can be obtained by using the mount.nfs command in
> -    nfs-utils-1.1.2 or greater (nfs-utils-1.1.1 was the first nfs-utils version
> -    with support for NFS/RDMA mounts, but for various reasons we recommend using
> -    nfs-utils-1.1.2 or greater). To see which version of mount.nfs you are
> -    using, type:
> +    nfs-utils-1.1.2 or greater (nfs-utils-1.1.1 was the first nfs-utils
> +    version with support for NFS/RDMA mounts, but for various reasons we
> +    recommend using nfs-utils-1.1.2 or greater). To see which version of
> +    mount.nfs you are using, type:
>  
>      $ /sbin/mount.nfs -V
>  
> @@ -91,8 +91,9 @@ Installation
>  
>      After building the nfs-utils package, there will be a mount.nfs binary in
>      the utils/mount directory. This binary can be used to initiate NFS v2, v3,
> -    or v4 mounts. To initiate a v4 mount, the binary must be called mount.nfs4.
> -    The standard technique is to create a symlink called mount.nfs4 to mount.nfs.
> +    or v4 mounts. To initiate a v4 mount, the binary must be called
> +    mount.nfs4.  The standard technique is to create a symlink called
> +    mount.nfs4 to mount.nfs.
>  
>      This mount.nfs binary should be installed at /sbin/mount.nfs as follows:
>  
> @@ -214,11 +215,11 @@ NFS/RDMA Setup
>      /vol0   192.168.0.47(fsid=0,rw,async,insecure,no_root_squash)
>      /vol0   192.168.0.0/255.255.255.0(fsid=0,rw,async,insecure,no_root_squash)
>  
> -    The IP address(es) is(are) the client's IPoIB address for an InfiniBand HCA or the
> -    cleint's iWARP address(es) for an RNIC.
> +    The IP address(es) is(are) the client's IPoIB address for an InfiniBand
> +    HCA or the cleint's iWARP address(es) for an RNIC.
>  
> -    NOTE: The "insecure" option must be used because the NFS/RDMA client does not
> -    use a reserved port.
> +    NOTE: The "insecure" option must be used because the NFS/RDMA client does
> +    not use a reserved port.
>  
>   Each time a machine boots:
>  
> @@ -234,12 +235,13 @@ NFS/RDMA Setup
>  
>    - Start the NFS server
>  
> -    If the NFS/RDMA server was built as a module (CONFIG_SUNRPC_XPRT_RDMA=m in kernel config),
> -    load the RDMA transport module:
> +    If the NFS/RDMA server was built as a module (CONFIG_SUNRPC_XPRT_RDMA=m in
> +    kernel config), load the RDMA transport module:
>  
>      $ modprobe svcrdma
>  
> -    Regardless of how the server was built (module or built-in), start the server:
> +    Regardless of how the server was built (module or built-in), start the
> +    server:
>  
>      $ /etc/init.d/nfs start
>  
> @@ -253,17 +255,17 @@ NFS/RDMA Setup
>  
>    - On the client system
>  
> -    If the NFS/RDMA client was built as a module (CONFIG_SUNRPC_XPRT_RDMA=m in kernel config),
> -    load the RDMA client module:
> +    If the NFS/RDMA client was built as a module (CONFIG_SUNRPC_XPRT_RDMA=m in
> +    kernel config), load the RDMA client module:
>  
>      $ modprobe xprtrdma.ko
>  
> -    Regardless of how the client was built (module or built-in), use this command to
> -    mount the NFS/RDMA server:
> +    Regardless of how the client was built (module or built-in), use this
> +    command to mount the NFS/RDMA server:
>  
>      $ mount -o rdma,port=2050 <IPoIB-server-name-or-address>:/<export> /mnt
>  
> -    To verify that the mount is using RDMA, run "cat /proc/mounts" and check the
> -    "proto" field for the given mount.
> +    To verify that the mount is using RDMA, run "cat /proc/mounts" and check
> +    the "proto" field for the given mount.
>  
>    Congratulations! You're using NFS/RDMA!
> 
