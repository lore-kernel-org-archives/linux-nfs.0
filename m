From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 09:27:00 +0800
Message-ID: <20090821012700.GA9937@localhost>
References: <20090820071315.GA14765@localhost> <1250773349.5352.23.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:22668 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751485AbZHUB1B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Aug 2009 21:27:01 -0400
In-Reply-To: <1250773349.5352.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 20, 2009 at 09:02:29PM +0800, Trond Myklebust wrote:
> On Thu, 2009-08-20 at 15:13 +0800, Wu Fengguang wrote:
> > Hi,
> > 
> > After upgrading NFS client kernel to latest linux-next, NFS mount
> > failed:
> > 
> >         # mount -t nfs pxe:/cc /cc
> >         mount.nfs: access denied by server while mounting pxe:/cc
> > 
> >         # uname -a
> >         Linux hp 2.6.31-rc6-next-20090818 #61 SMP Thu Aug 20 14:46:10 CST 2009 x86_64 GNU/Linux 
> > 
> > However server log says OK:
> > 
> >         Aug 20 15:02:09 wu-t61 mountd[4599]: authenticated mount request from 192.168.11.6:973 for /cc (/cc)
> >         Aug 20 15:02:09 wu-t61 mountd[4599]: authenticated unmount request from 192.168.11.6:974 for /cc (/cc)
> > 
> > However-2: nfsroot can be mounted at boot time. Server kernel has always been 2.6.30.
> > 
> > Any ideas?
> > 
> > Thanks,
> > Fengguang
> 
> Can you try again after enabling mount debugging on the NFS client?
> 
> echo 512 > /proc/sys/sunrpc/nfs_debug

I used 1024 and found the mount failed here in nfs_walk_authlist():

        dfprintk(MOUNT, "NFS: server does not support requested auth flavor\ n");
        nfs_umount(request);

Thanks,
Fengguang
