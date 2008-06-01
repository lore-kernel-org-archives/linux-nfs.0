From: Julius <julius.junghans@gmx.de>
Subject: Re: root over nfs, error -93
Date: Sun, 01 Jun 2008 10:22:11 +0200
Message-ID: <1212308531.19000.2.camel@wf>
References: <1212009456.3786.24.camel@wf>
	 <1212019497.7544.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:51874 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751426AbYFAIS6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Jun 2008 04:18:58 -0400
In-Reply-To: <1212019497.7544.4.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-05-28 at 17:04 -0700, Trond Myklebust wrote:
> On Wed, 2008-05-28 at 23:17 +0200, Julius wrote:
> > Hi,
> > 
> > 
> > im trying to get a client boot from my server via nfs. but it fails
> > with:
> > 
> > Root-NFS: Server returned error -93 while
> > mounting /nfs-exports/pxeclient
> > 
> > the client uses a vanilla 2.6.24.7 kernel with these settings:
> > <*>   NFS file system support 
> >  [*]     Provide NFSv3 client support 
> >  [*]       Provide client support for the NFSv3 ACL protocol extension 
> >  [*]   Root file system on NFS
> >  [*]   Support for rpcbind versions 3 & 4 (EXPERIMENTAL)
> > 
> > 
> > full config:
> > http://metalfan2.me.funpic.de/.config
> > 
> > 
> > kernel append line:
> > append root=/dev/nfs nfsroot=192.168.11.3:/nfs-exports/pxeclient ip=dhcp
> > 
> > 
> > the system successfully boots the kernel via syslinux and requests its
> > ip via dhcp
> > 
> > 
> > server:
> > rpcinfo -p localhost
> >    program vers proto   port
> >     100000    2   tcp    111  portmapper
> >     100000    2   udp    111  portmapper
> >     100024    1   udp  54039  status
> >     100024    1   tcp  57693  status
> >     100005    3   udp  48497  mountd
> >     100005    3   tcp  34406  mountd
> >     100003    2   udp   2049  nfs
> >     100003    3   udp   2049  nfs
> >     100003    4   udp   2049  nfs
> >     100021    1   udp  47061  nlockmgr
> >     100021    3   udp  47061  nlockmgr
> >     100021    4   udp  47061  nlockmgr
> >     100003    2   tcp   2049  nfs
> >     100003    3   tcp   2049  nfs
> >     100003    4   tcp   2049  nfs
> >     100021    1   tcp  54896  nlockmgr
> >     100021    3   tcp  54896  nlockmgr
> >     100021    4   tcp  54896  nlockmgr
> > 
> > nfs-utils-1.1.0
> > 
> > 
> > 
> > Any ideas whats wrong?
> 
> I believe that the default is to try mounting NFSv2, unless you
> explicitly add the 'v3' option. Try something like
> 
> append root=/dev/nfs nfsroot=192.168.11.3:/nfs-exports/pxeclient,v3 ip=dhcp
> 
> 
> Cheers
>   Trond

Got it running, finally. Thx to all, saved me a lot of trouble.
Ive changed the machine that serves the nfs-root and some other small
adjustments.
Turotrial will be available here:
http://wiki.archlinux.org/index.php/Diskless_network_boot_NFS_root

