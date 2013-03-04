Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60780 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757156Ab3CDOQE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Mar 2013 09:16:04 -0500
Date: Mon, 4 Mar 2013 09:16:00 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Jan Engelhardt <jengelh@inai.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Inconsistent error codes between NFSv4 and v3 on network issues
Message-ID: <20130304141600.GA16732@pad.fieldses.org>
References: <alpine.LNX.2.01.1303011240350.11154@nerf07.vanv.qr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.LNX.2.01.1303011240350.11154@nerf07.vanv.qr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adding Chuck to cc:, as he's probably done the most mucking with the
mount code in recent years?

--b.

On Fri, Mar 01, 2013 at 12:43:58PM +0100, Jan Engelhardt wrote:
> Hi.
> 
> 
> I had here a case with a Linux 3.7.9 system, a virtual machine in a
> RFC1918 range, that did not want to mount NFS.
> 
> linux-3lzm:~ # strace -fe mount mount -t nfs 134.76.12.5:/X /mnt
> Process 1477 attached
> [pid  1515] mount("134.76.12.5:/X", "/mnt", "nfs", 0, "vers=4,addr=134.76.12.5,clientaddr=0.0.0.0") = -1 EIO (Input/output error)
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
> 
> When mounting with NFSv3, the error became clear:
> 
> # strace -fe mount -s 65536 mount -t nfs 134.76.12.5:/X /mnt -o nfsvers=3,nolock
> Process 1550 attached
> mount.nfs: Network is unreachable
> [pid  1550] +++ exited with 32 +++
> --- SIGCHLD {si_signo=SIGCHLD, si_code=CLD_EXITED, si_pid=1550, si_status=32, si_utime=0, si_stime=0} ---
> +++ exited with 32 +++
> 
> Can NFSv4 be made to return -ENETUNREACH as well?
