Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:58517 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755387Ab0EROr1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 May 2010 10:47:27 -0400
Message-ID: <4BF2A82C.6000704@oracle.com>
Date: Tue, 18 May 2010 10:46:04 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Jan Stilow <jstilow@mobileobjects.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS4 mount finishes after 2 hours
References: <4BF29CD8.4060008@mobileobjects.de>
In-Reply-To: <4BF29CD8.4060008@mobileobjects.de>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/18/10 09:57 AM, Jan Stilow wrote:
> hello there,
>
> I have a confusing problem to mount a nfs4 resource. The problem is that
> the mount process take about 2 hours. Also it seems only to occur on VM
> machines.
>
> In my case the nfs-server and nfs-client are both VMs in VirtualBox.
> Originally the problem occurred in a Xen environment but with VirtualBox
> it is the same. So I used VirtualBox for my tests. On "real" machines
> the problem did not occur. Server and Client are Debian Lenny machines
> with a 2.6.26-2-amd64 (Debian 2.6.26-21lenny4) kernel.
>
> At the point where mount is finished first all clients can connect as
> fast as usual. During the mount process which takes about 2h you can
> ping the server or open an ssh connection to the server. So only the nfs
> mount seems to fail. After the time period you can unmount and mount at
> will and as fast as usual.
>
> Also interesting for me is that the problem only occurs after a
> cold start of the VM but not when you restart the service or the VM. You
> really need to shut down and reboot it to reproduce these behavior.
>
> The output from a example mount and the /etc/exports configuration
> follows at the end of these mail. The mount halts after the message
> "mount.nfs4: pinging: prog 100003 vers 4 prot tcp port 2049". I also
> tried different options in /etc/exports without success.
>
> After you run "sysctl sunrpc.nfs_debug=1023" you can find "laundromat
> service - starting" and "NFSD: laundromat_main - sleeping for 90
> seconds" messages in your logs during the mount process. These messages
> also repeat from time to time. Obviously the client communicates with
> the server.

I suspect those messages do not reflect activity between the client and 
server.

> For me it looks like a problem with nfs and VM environments. So does
> anyone have an idea?

Probably the network between client and server is not fully up when the 
mount request is initiated.

It may be the case, for example, that a cold start of your guest means 
Vbox has to reassign network resources (ie a DHCP-assigned IP address) 
to the guest.  So there is probably a timing issue here that is causing 
the initial connection attempt by the kernel to be somehow lost.

Somehow enabling RPC level debugging messages before the mount might be 
illuminating.

> /etc/exports:
> ^^^^^^^^^^^^^
> /srv			192.168.56.102/32(rw,fsid=0,crossmnt,no_subtree_check)
> /srv/test		192.168.56.102/32(rw,no_subtree_check)
>
>
> The example mount:
> ^^^^^^^^^^^^^^^^^^
> nfs4-client:~# time mount -vvv -t nfs4 192.168.56.101:/ /mnt/
> mount: fstab path: "/etc/fstab"
> mount: lock path:  "/etc/mtab~"
> mount: temp path:  "/etc/mtab.tmp"
> mount: spec:  "192.168.56.101:/"
> mount: node:  "/mnt/"
> mount: types: "nfs4"
> mount: opts:  "(null)"
> mount: external mount: argv[0] = "/sbin/mount.nfs4"
> mount: external mount: argv[1] = "192.168.56.101:/"
> mount: external mount: argv[2] = "/mnt/"
> mount: external mount: argv[3] = "-v"
> mount: external mount: argv[4] = "-o"
> mount: external mount: argv[5] = "rw"
> mount.nfs4: pinging: prog 100003 vers 4 prot tcp port 2049
> 192.168.56.101:/ on /mnt type nfs4 (rw)
>
> real	118m46.858s
> user	0m0.036s
> sys	0m0.508s
>
>
> Debug log messages:
> ^^^^^^^^^^^^^^^^^^^
> May 18 15:21:24 nfs4-server kernel: [ 6322.206691] NFSD: laundromat
> service - starting
> May 18 15:21:24 nfs4-server kernel: [ 6322.206691] NFSD: laundromat_main
> - sleeping for 90 seconds
> May 18 15:22:54 nfs4-server kernel: [ 6412.209404] NFSD: laundromat
> service - starting
> May 18 15:22:54 nfs4-server kernel: [ 6412.221816] NFSD: laundromat_main
> - sleeping for 90 seconds
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

