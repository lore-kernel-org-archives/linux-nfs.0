From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] update mount.nfs example in NFS/RDMA documentation
Date: Fri, 30 May 2008 11:09:19 -0400
Message-ID: <A04A3C4F-EF91-4204-B28F-E63BFEAF3241@oracle.com>
References: <alpine.LFD.1.10.0805291534360.2898@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:59261 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbYE3PKe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2008 11:10:34 -0400
In-Reply-To: <alpine.LFD.1.10.0805291534360.2898-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi James-

On May 29, 2008, at 3:40 PM, James Lentini wrote:
> Bruce,
>
> Below is an update to the NFS/RDMA documentation that clarifies how
> to run mount.nfs. Could you please merge this for 2.6.26?
>
> Signed-off-by: James Lentini <jlentini@netapp.com>
>
> --- a/Documentation/filesystems/nfs-rdma.txt	2008-05-29  
> 15:09:38.753033000 -0400
> +++ b/Documentation/filesystems/nfs-rdma.txt	2008-05-29  
> 15:31:33.374948000 -0400
> @@ -5,7 +5,7 @@
> ################################################################################
>
>  Author: NetApp and Open Grid Computing
> - Date: February 25, 2008
> + Date: May 29, 2008
>
> Table of Contents
> ~~~~~~~~~~~~~~~~~
> @@ -242,10 +242,19 @@ NFS/RDMA Setup
>
>> modprobe xprtrdma.ko
>
> -    Regardless of how the client was built (module or built-in),  
> issue the mount.nfs command:
> +    Regardless of how the client was built (module or built-in),  
> use the mount.nfs command to
> +    mount the NFS/RDMA server.
> +
> +    If you have nfs-utils version 1.1.1, use this command:
>
>> /path/to/your/mount.nfs <IPoIB-server-name-or-address>:/<export> / 
>> mnt -i -o rdma,port=2050
>
> +    If you have nfs-utils version 1.1.2 or later, use this command  
> (the "-i" flag is no longer
> +    needed; the command checks the kernel's version to see if the  
> NFS string mount API support is
> +    available):
> +
> +    > /path/to/your/mount.nfs <IPoIB-server-name-or-address>:/ 
> <export> /mnt -o rdma,port=2050
> +

Do you still need to invoke the helper directly?  I think this should  
work with a straight mount command after 1.1.2, since the "-i" flag is  
no longer necessary.

If it works, the "permanent" instructions in this documentation should  
use "mount" not "mount.nfs," and specify the command line arguments in  
the right order (doesn't mount like the "-o options" to come before  
the arguments?).  We shouldn't encourage direct use of the helper  
subcommand if we can avoid it, and it would allow admins to place rdma  
mounts in /etc/fstab and automounter maps.

In fact, since 1.1.2 is now available, why even mention 1.1.1 in the  
instructions?  It would nicely simplify the text if you start with  
1.1.2, and the scourge (or ridiculousness?) of the "-i" option need  
never be mentioned again.

Looking at other parts of nfs-rdma.txt:

The instructions describing how to build nfs-utils are slightly  
misleading.  The "--disable-gss" and "--disable-nfsv4" options do not  
affect the mount command -- the resulting mount.nfs executable still  
supports NFSv4.

The true reason to specify these options on ./configure is to prevent  
nfs-utils from building the idmapper and gssd executables, which you  
don't need to replace if you are only installing a new mount.nfs  
command, and which require that the build system have certain other  
packages installed.

You can simply extract the rebuilt mount.nfs command instead of  
installing the whole package with

	$ sudo cp utils/mount/mount.nfs /path/to/your/mount.nfs

The tcp_wrappers package is needed to build nfs-utils in any case, so  
it would be helpful to mention that too.

It's worth mentioning that several distributions already ship with  
1.1.2, so on modern systems, this build step is probably not needed.

Also, I would use a standard shell prompt in the examples (say, "$ "  
or "% ", or "# " as necessary, instead of "> "), but that's just me.

>     To verify that the mount is using RDMA, run "cat /proc/mounts"  
> and check the
>     "proto" field for the given mount.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
