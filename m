From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: mount.nfs: access denied by server
Date: Sat, 22 Aug 2009 09:48:19 +0800
Message-ID: <20090822014819.GA7798@localhost>
References: <20090820071315.GA14765@localhost> <1250773349.5352.23.camel@heimdal.trondhjem.org> <20090821012700.GA9937@localhost> <1250822171.6514.29.camel@heimdal.trondhjem.org> <8C4C4FD5-733E-4327-8618-8C400FAE72C1@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	NFS list <linux-nfs@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Chuck Lever <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62883 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933075AbZHVBs0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Aug 2009 21:48:26 -0400
In-Reply-To: <8C4C4FD5-733E-4327-8618-8C400FAE72C1@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 22, 2009 at 01:50:52AM +0800, Chuck Lever wrote:
> 
> On Aug 20, 2009, at 10:36 PM, Trond Myklebust wrote:
> 
> > On Fri, 2009-08-21 at 09:27 +0800, Wu Fengguang wrote:
> >> On Thu, Aug 20, 2009 at 09:02:29PM +0800, Trond Myklebust wrote:
> >>> On Thu, 2009-08-20 at 15:13 +0800, Wu Fengguang wrote:
> >>>> Hi,
> >>>>
> >>>> After upgrading NFS client kernel to latest linux-next, NFS mount
> >>>> failed:
> >>>>
> >>>>        # mount -t nfs pxe:/cc /cc
> >>>>        mount.nfs: access denied by server while mounting pxe:/cc
> >>>>
> >>>>        # uname -a
> >>>>        Linux hp 2.6.31-rc6-next-20090818 #61 SMP Thu Aug 20  
> >>>> 14:46:10 CST 2009 x86_64 GNU/Linux
> >>>>
> >>>> However server log says OK:
> >>>>
> >>>>        Aug 20 15:02:09 wu-t61 mountd[4599]: authenticated mount  
> >>>> request from 192.168.11.6:973 for /cc (/cc)
> >>>>        Aug 20 15:02:09 wu-t61 mountd[4599]: authenticated unmount  
> >>>> request from 192.168.11.6:974 for /cc (/cc)
> >>>>
> >>>> However-2: nfsroot can be mounted at boot time. Server kernel has  
> >>>> always been 2.6.30.
> >>>>
> >>>> Any ideas?
> >>>>
> >>>> Thanks,
> >>>> Fengguang
> >>>
> >>> Can you try again after enabling mount debugging on the NFS client?
> >>>
> >>> echo 512 > /proc/sys/sunrpc/nfs_debug
> >>
> >> I used 1024 and found the mount failed here in nfs_walk_authlist():
> >>
> >>        dfprintk(MOUNT, "NFS: server does not support requested auth  
> >> flavor\ n");
> >>        nfs_umount(request);
> >
> > Thanks Fengguang!
> >
> > Chuck, this looks like one of yours. Could it be that you are hitting
> > the same Linux knfsd bug that Tom Haynes saw with a Solaris client?
> > AFAICR, the problem was that existing nfs servers do not set a default
> > auth flavour, and so you just have to try with auth_sys and see if it
> > succeeds...
> 
> With 1024 set, the mount client's XDR routines should have listed the  
> server's flavors, if any, in the system log.  Should be something like  
> "NFS: received 0 auth flavors" if the server didn't return any.  Can  
> you confirm that?

Yes. The full logs are:


Aug 21 09:54:38 hp kernel: [   74.671552] NFS: nfs mount opts='nolock,addr=192.168.11.2'
Aug 21 09:54:38 hp kernel: [   74.677150] NFS:   parsing nfs mount option 'nolock'
Aug 21 09:54:38 hp kernel: [   74.682204] NFS:   parsing nfs mount option 'addr=192.168.11.2'
Aug 21 09:54:38 hp kernel: [   74.688234] NFS: MNTPATH: '/cc'
Aug 21 09:54:38 hp kernel: [   74.691468] NFS: sending MNT request for pxe:/cc
Aug 21 09:54:38 hp kernel: [   74.704458] NFS: received 0 auth flavors
Aug 21 09:54:38 hp kernel: [   74.708587] NFS: MNT request succeeded
Aug 21 09:54:38 hp kernel: [   74.712435] NFS: server does not support requested auth flavor
Aug 21 09:54:38 hp kernel: [   74.718358] NFS: sending UMNT request for pxe:/cc


> I'll try to post a fix later today.

Thanks!

Fengguang
