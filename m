Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:17099 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933152Ab0BPR5H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Feb 2010 12:57:07 -0500
Message-ID: <4B7ADBF0.8010903@oracle.com>
Date: Tue, 16 Feb 2010 12:54:56 -0500
From: Chuck Lever <chuck.lever@oracle.com>
To: Daniel Goering <g_daniel@gmx.net>
CC: linux-nfs@vger.kernel.org
Subject: Re: background mounts inconsistent and partly not usable
References: <4B7ADB6B.7090709@localhost>
In-Reply-To: <4B7ADB6B.7090709@localhost>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks for the report, I'll look into it.

On 02/16/2010 12:52 PM, Daniel Goering wrote:
> Hi!
>
> I'd like to mount an NFS4 share with the option bg as described in man 5
> nfs. But all mounts are carried out in the foreground and time out after
> 2 minutes [and the client is blocked e.g. during boot for the entire
> time] instead of trying in the background for about 1 week until the
> server is back up.
>
> When I try to mount a share from an unreachable server I get something like
>
> # mount.nfs4 10.1.2.3:/ /mnt/ -v -o bg
> mount.nfs4: text-based options: 'bg,clientaddr=xxx,addr=10.1.2.3'
> mount.nfs4: mount(2): Input/output error
> mount.nfs4: mount system call failed
>
> I tracked this down to utils/mount/stropts.c, where the function
> nfs_is_permanent_error maps EIO to an permanent error and prevents the
> mount from backgrounding.
>
> I changed utils/mount/mount.c to use the old non string mount, in order
> to compare the results
>
> --- mount.c.bak	2010-02-16 18:06:09.000000000 +0100
> +++ mount.c	2010-02-16 18:06:12.000000000 +0100
> @@ -175,7 +175,7 @@
>   	if (nfs_mount_data_version>  NFS_MOUNT_VERSION)
>   		nfs_mount_data_version = NFS_MOUNT_VERSION;
>   	else
> -		if (kernel_version>  MAKE_VERSION(2, 6, 22))
> +		if (kernel_version>  MAKE_VERSION(3, 6, 22))
>   			string++;
>   }
>
>
> and I get this result, if there is no route to the host
> # mount.nfs4 10.1.2.3:/ /mnt/ -v -o bg
> mount.nfs4: pinging: prog 100003 vers 4 prot tcp port 2049
> mount.nfs4: Unable to connect to 10.1.2.3:2049, errno 113 (No route to host)
>
> instead of waiting 2 minutes this call immediately returns. If there is
> just no answer from the host instead of a "no route to host" message, I get
> # mount.nfs4 10.1.2.3:/ /mnt/ -v -o bg
> mount.nfs4: pinging: prog 100003 vers 4 prot tcp port 2049
> mount.nfs4: Unable to connect to 10.1.2.3:2049, errno 110 (Connection
> timed out)
>
> mount.nfs4: backgrounding "10.1.2.3:/"
>
> Both calls to the old non-string mount are significantly faster, and the
> last one even backgrounds, while the string mount gives EIO in both
> cases and never backgrounds.
>
> I'd like to use the bg option to be able to boot the clients
> simultaneously with the servers and the clients should just mount the
> share, as soon as it becomes available.
> Currently this is never possible with any machine running a kernel newer
> than 2.6.22, as they will all die of the EIO error. Even for an older
> Kernel this is only possible, if the server is already booting and can
> answer ARP requests, as otherwise the mount will die from the "no route
> to host" message.
> I'd prefer if mount tried to find a route for about one week, to have
> some time to turn on the servers separately [so they can spin up their
> RAIDs sequentially instead of burning the fuse by consuming lots of
> power during simultaneous spin up], but may be there are good reasons to
> have it differently.
> Nevertheless I think that it should at least be possible to mount shares
> in the background after a timeout for systems with recent kernels using
> string mount.
>
> I observed the given problems with the following systems:
> Gentoo	Kernel 2.6.31.4 	nfs-utils	1.1.4
> Gentoo	Kernel 2.6.31.4 	nfs-utils	1.2.1
> Fedora 12	Kernel 2.6.31.12	nfs-utils 	1.2.1
>
> For now I'll probably just patch nfs_is_permanent_error on all my
> systems to just map everything to temporary, but I hope there is a more
> robust solution, that will allow fast feedback on problems and still
> support background mounts.
>
>
> Cheers
> 	Daniel
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
chuck[dot]lever[at]oracle[dot]com
