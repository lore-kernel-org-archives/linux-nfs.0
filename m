From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: mount.nfs: access denied by server
Date: Thu, 20 Aug 2009 09:02:29 -0400
Message-ID: <1250773349.5352.23.camel@heimdal.trondhjem.org>
References: <20090820071315.GA14765@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:37824 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753751AbZHTNCb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Aug 2009 09:02:31 -0400
In-Reply-To: <20090820071315.GA14765@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-08-20 at 15:13 +0800, Wu Fengguang wrote:
> Hi,
> 
> After upgrading NFS client kernel to latest linux-next, NFS mount
> failed:
> 
>         # mount -t nfs pxe:/cc /cc
>         mount.nfs: access denied by server while mounting pxe:/cc
> 
>         # uname -a
>         Linux hp 2.6.31-rc6-next-20090818 #61 SMP Thu Aug 20 14:46:10 CST 2009 x86_64 GNU/Linux 
> 
> However server log says OK:
> 
>         Aug 20 15:02:09 wu-t61 mountd[4599]: authenticated mount request from 192.168.11.6:973 for /cc (/cc)
>         Aug 20 15:02:09 wu-t61 mountd[4599]: authenticated unmount request from 192.168.11.6:974 for /cc (/cc)
> 
> However-2: nfsroot can be mounted at boot time. Server kernel has always been 2.6.30.
> 
> Any ideas?
> 
> Thanks,
> Fengguang

Can you try again after enabling mount debugging on the NFS client?

echo 512 > /proc/sys/sunrpc/nfs_debug


Cheers
  Trond

