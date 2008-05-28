From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: root over nfs, error -93
Date: Wed, 28 May 2008 17:31:18 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0805281728470.10284@citi.umich.edu>
References: <1212009456.3786.24.camel@wf>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Julius <julius.junghans@gmx.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:32156 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766AbYE1VbS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 May 2008 17:31:18 -0400
In-Reply-To: <1212009456.3786.24.camel@wf>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 28 May 2008, Julius wrote:

> Hi,
> 
> 
> im trying to get a client boot from my server via nfs. but it fails
> with:
> 
> Root-NFS: Server returned error -93 while
> mounting /nfs-exports/pxeclient

	well, some grepping in /usr/include/ came up with:

./asm-generic/errno.h:#define   EPROTONOSUPPORT 93      /* Protocol not supported */

	what's the server setup in this picture?  and is that negative 
error value getting propagated into userland, or is that just from a 
kernel log?

	d
	.
 
> the client uses a vanilla 2.6.24.7 kernel with these settings:
> <*>   NFS file system support 
>  [*]     Provide NFSv3 client support 
>  [*]       Provide client support for the NFSv3 ACL protocol extension 
>  [*]   Root file system on NFS
>  [*]   Support for rpcbind versions 3 & 4 (EXPERIMENTAL)
> 
> 
> full config:
> http://metalfan2.me.funpic.de/.config
> 
> 
> kernel append line:
> append root=/dev/nfs nfsroot=192.168.11.3:/nfs-exports/pxeclient ip=dhcp
> 
> 
> the system successfully boots the kernel via syslinux and requests its
> ip via dhcp
> 
> 
> server:
> rpcinfo -p localhost
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     100024    1   udp  54039  status
>     100024    1   tcp  57693  status
>     100005    3   udp  48497  mountd
>     100005    3   tcp  34406  mountd
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100003    4   udp   2049  nfs
>     100021    1   udp  47061  nlockmgr
>     100021    3   udp  47061  nlockmgr
>     100021    4   udp  47061  nlockmgr
>     100003    2   tcp   2049  nfs
>     100003    3   tcp   2049  nfs
>     100003    4   tcp   2049  nfs
>     100021    1   tcp  54896  nlockmgr
>     100021    3   tcp  54896  nlockmgr
>     100021    4   tcp  54896  nlockmgr
> 
> nfs-utils-1.1.0
> 
> 
> 
> Any ideas whats wrong?
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
