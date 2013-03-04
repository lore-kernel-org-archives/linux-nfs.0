Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:39205 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758085Ab3CDRrX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2013 12:47:23 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: Inconsistent error codes between NFSv4 and v3 on network issues
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <alpine.LNX.2.01.1303011240350.11154@nerf07.vanv.qr>
Date: Mon, 4 Mar 2013 12:47:15 -0500
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <6AADB1AD-6FB9-42AD-8BF2-6B0B706927E5@oracle.com>
References: <alpine.LNX.2.01.1303011240350.11154@nerf07.vanv.qr>
To: Jan Engelhardt <jengelh@inai.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 1, 2013, at 6:43 AM, Jan Engelhardt <jengelh@inai.de> wrote:

> Hi.
> 
> 
> I had here a case with a Linux 3.7.9 system, a virtual machine in a
> RFC1918 range, that did not want to mount NFS.
> 
> linux-3lzm:~ # strace -fe mount mount -t nfs 134.76.12.5:/X /mnt
> Process 1477 attached
> [pid  1515] mount("134.76.12.5:/X", "/mnt", "nfs", 0, "vers=4,addr=134.76.12.5,clientaddr=0.0.0.0") = -1 EIO (Input/output error)

"clientaddr=0.0.0.0" is interesting: perhaps the mount.nfs command should have failed right there.

But, let's find out why the kernel is returning EIO.  Enter:

 # rpcdebug -m nfs -s all
 # rpcdebug -m rpc -s call xprt

Try your NFSv4 mount command again, then post relevant excerpts from the kernel log.

By the way, does this happen on older kernels?

> mount.nfs: mount system call failed
> [pid  1477] +++ exited with 32 +++
> --- SIGCHLD {si_signo=SIGCHLD, si_code=CLD_EXITED, si_pid=1477, si_status=32, si_utime=0, si_stime=0} ---
> +++ exited with 32 +++
> 
> Nothing in dmesg...
> 
> [   84.202243] RPC: Registered named UNIX socket transport module.
> [   84.202246] RPC: Registered udp transport module.
> [   84.202248] RPC: Registered tcp transport module.
> [   84.202249] RPC: Registered tcp NFSv4.1 backchannel transport module.
> [   84.205909] FS-Cache: Loaded
> [   84.208782] FS-Cache: Netfs 'nfs' registered for caching
> [   84.215733] NFS: Registering the id_resolver key type
> [   84.215762] Key type id_resolver registered
> [   84.215763] Key type id_legacy registered

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

