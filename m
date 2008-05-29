From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: root over nfs, error -93
Date: Wed, 28 May 2008 17:04:57 -0700
Message-ID: <1212019497.7544.4.camel@localhost>
References: <1212009456.3786.24.camel@wf>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Julius <julius.junghans@gmx.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:46971 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367AbYE2AFB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 May 2008 20:05:01 -0400
In-Reply-To: <1212009456.3786.24.camel@wf>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-05-28 at 23:17 +0200, Julius wrote:
> Hi,
> 
> 
> im trying to get a client boot from my server via nfs. but it fails
> with:
> 
> Root-NFS: Server returned error -93 while
> mounting /nfs-exports/pxeclient
> 
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

I believe that the default is to try mounting NFSv2, unless you
explicitly add the 'v3' option. Try something like

append root=/dev/nfs nfsroot=192.168.11.3:/nfs-exports/pxeclient,v3 ip=dhcp


Cheers
  Trond

