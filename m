From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] update NFS/RDMA documentation
Date: Mon, 2 Jun 2008 16:38:05 -0400
Message-ID: <4B7D1A89-DB85-4E33-91AB-F93901A55CA1@oracle.com>
References: <alpine.LFD.1.10.0806021530560.26788@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Talpey <talpey@netapp.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	linux-nfs@vger.kernel.org
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:18665 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbYFBUjE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2008 16:39:04 -0400
In-Reply-To: <alpine.LFD.1.10.0806021530560.26788-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 2, 2008, at 3:33 PM, James Lentini wrote:
>
> Bruce,
>
> Below is an update to the NFS/RDMA documentation that clarifies how to
> run mount.nfs and addresses comments from you and Chuck. Could you
> please merge this for 2.6.26?
>
> Signed-off-by: James Lentini <jlentini@netapp.com>
>
> --- a/Documentation/filesystems/nfs-rdma.txt	2008-05-30  
> 16:03:01.414533000 -0400
> +++ a/Documentation/filesystems/nfs-rdma.txt	2008-06-02  
> 15:26:51.138344000 -0400
> @@ -5,7 +5,7 @@
> ################################################################################
>
>  Author: NetApp and Open Grid Computing
> - Date: April 15, 2008
> + Date: May 29, 2008
>
> Table of Contents
> ~~~~~~~~~~~~~~~~~
> @@ -60,16 +60,18 @@ Installation
>     The procedures described in this document have been tested with
>     distributions from Red Hat's Fedora Project (http://fedora.redhat.com/ 
> ).
>
> -  - Install nfs-utils-1.1.1 or greater on the client
> +  - Install nfs-utils-1.1.2 or greater on the client
>
> -    An NFS/RDMA mount point can only be obtained by using the  
> mount.nfs
> -    command in nfs-utils-1.1.1 or greater. To see which version of  
> mount.nfs
> -    you are using, type:
> +    An NFS/RDMA mount point can be obtained by using the mount.nfs  
> command in
> +    nfs-utils-1.1.2 or greater (nfs-utils-1.1.1 was the first nfs- 
> utils version
> +    with support for NFS/RDMA mounts, but for various reasons we  
> recommend using
> +    nfs-utils-1.1.2 or greater). To see which version of mount.nfs  
> you are
> +    using, type:
>
> -    > /sbin/mount.nfs -V
> +    $ /sbin/mount.nfs -V
>
> -    If the version is less than 1.1.1 or the command does not exist,
> -    then you will need to install the latest version of nfs-utils.
> +    If the version is less than 1.1.2 or the command does not exist,
> +    you should install the latest version of nfs-utils.
>
>     Download the latest package from:
>
> @@ -77,22 +79,32 @@ Installation
>
>     Uncompress the package and follow the installation instructions.
>
> -    If you will not be using GSS and NFSv4, the installation process
> -    can be simplified by disabling these features when running  
> configure:
> +    If you will not need the idmapper and gssd executables (you do  
> not need
> +    these to create an NFS/RDMA enabled mount command), the  
> installation
> +    process can be simplified by disabling these features when  
> running
> +    configure:

This explanation still seems confusing.

idmapper *is* required for NFSv4 (and I assume you can mount an NFSv4  
server over RDMA), and gssd *is* required to support secure mounts,  
all of which may co-exist with the RDMA capability.

I think you would be much better off providing a recipe for building  
and installing mount.nfs instead of trying to "insert" bits into the  
instructions in the nfs-utils README.

> -    > ./configure --disable-gss --disable-nfsv4
> +    $ ./configure --disable-gss --disable-nfsv4
>
>
> -    For more information on this see the package's README and  
> INSTALL files.
> +    To build nfs-utils you will need the tcp_wrappers package  
> installed. For
> +    more information on this see the package's README and INSTALL  
> files.
>
>     After building the nfs-utils package, there will be a mount.nfs  
> binary in
>     the utils/mount directory. This binary can be used to initiate  
> NFS v2, v3,
>     or v4 mounts. To initiate a v4 mount, the binary must be called  
> mount.nfs4.
>     The standard technique is to create a symlink called mount.nfs4  
> to mount.nfs.
>
> -    NOTE: mount.nfs and therefore nfs-utils-1.1.1 or greater is  
> only needed
> +    This mount.nfs binary should be installed at /sbin/mount.nfs as  
> follows:
> +
> +    $ sudo cp utils/mount/mount.nfs /sbin/mount.nfs
> +
> +    In this location, mount.nfs will be invoked automatically for  
> NFS mounts
> +    by the system mount commmand.
> +
> +    NOTE: mount.nfs and therefore nfs-utils-1.1.2 or greater is  
> only needed
>     on the NFS client machine. You do not need this specific version  
> of
>     nfs-utils on the server. Furthermore, only the mount.nfs command  
> from
> -    nfs-utils-1.1.1 is needed on the client.
> +    nfs-utils-1.1.2 is needed on the client.
>
>   - Install a Linux kernel with NFS/RDMA
>
> @@ -156,8 +168,8 @@ Check RDMA and NFS Setup
>     this time. For example, if you are using a Mellanox Tavor/Sinai/ 
> Arbel
>     card:
>
> -    > modprobe ib_mthca
> -    > modprobe ib_ipoib
> +    $ modprobe ib_mthca
> +    $ modprobe ib_ipoib
>
>     If you are using InfiniBand, make sure there is a Subnet Manager  
> (SM)
>     running on the network. If your IB switch has an embedded SM,  
> you can
> @@ -166,7 +178,7 @@ Check RDMA and NFS Setup
>
>     If an SM is running on your network, you should see the following:
>
> -    > cat /sys/class/infiniband/driverX/ports/1/state
> +    $ cat /sys/class/infiniband/driverX/ports/1/state
>     4: ACTIVE
>
>     where driverX is mthca0, ipath5, ehca3, etc.
> @@ -174,10 +186,10 @@ Check RDMA and NFS Setup
>     To further test the InfiniBand software stack, use IPoIB (this
>     assumes you have two IB hosts named host1 and host2):
>
> -    host1> ifconfig ib0 a.b.c.x
> -    host2> ifconfig ib0 a.b.c.y
> -    host1> ping a.b.c.y
> -    host2> ping a.b.c.x
> +    host1$ ifconfig ib0 a.b.c.x
> +    host2$ ifconfig ib0 a.b.c.y
> +    host1$ ping a.b.c.y
> +    host2$ ping a.b.c.x
>
>     For other device types, follow the appropriate procedures.
>
> @@ -214,9 +226,9 @@ NFS/RDMA Setup
>
>     For InfiniBand using a Mellanox adapter:
>
> -    > modprobe ib_mthca
> -    > modprobe ib_ipoib
> -    > ifconfig ib0 a.b.c.d
> +    $ modprobe ib_mthca
> +    $ modprobe ib_ipoib
> +    $ ifconfig ib0 a.b.c.d
>
>     NOTE: use unique addresses for the client and server
>
> @@ -225,30 +237,31 @@ NFS/RDMA Setup
>     If the NFS/RDMA server was built as a module  
> (CONFIG_SUNRPC_XPRT_RDMA=m in kernel config),
>     load the RDMA transport module:
>
> -    > modprobe svcrdma
> +    $ modprobe svcrdma
>
>     Regardless of how the server was built (module or built-in),  
> start the server:
>
> -    > /etc/init.d/nfs start
> +    $ /etc/init.d/nfs start
>
>     or
>
> -    > service nfs start
> +    $ service nfs start

I would expect that these commands, as well as the modprobe commands  
you mentioned above, require root privileges.  Since you specified  
"sudo" in your nfs-utils build instructions, you might want to use  
"sudo" here, or explicitly state that the administrator must be root  
to execute these commands successfully.

>      Instruct the server to listen on the RDMA transport:
>
> -    > echo rdma 2050 > /proc/fs/nfsd/portlist
> +    $ echo rdma 2050 > /proc/fs/nfsd/portlist
>
>   - On the client system
>
>     If the NFS/RDMA client was built as a module  
> (CONFIG_SUNRPC_XPRT_RDMA=m in kernel config),
>     load the RDMA client module:
>
> -    > modprobe xprtrdma.ko
> +    $ modprobe xprtrdma.ko
>
> -    Regardless of how the client was built (module or built-in),  
> issue the mount.nfs command:
> +    Regardless of how the client was built (module or built-in),  
> use this command to
> +    mount the NFS/RDMA server:
>
> -    > /path/to/your/mount.nfs <IPoIB-server-name-or-address>:/ 
> <export> /mnt -i -o rdma,port=2050
> +    $ mount -o rdma,port=2050 <IPoIB-server-name-or-address>:/ 
> <export> /mnt
>
>     To verify that the mount is using RDMA, run "cat /proc/mounts"  
> and check the
>     "proto" field for the given mount.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
