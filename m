From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: FLushing cached writes in nfs_getattr() and stat() delay
Date: Thu, 06 Nov 2008 14:32:02 -0500
Message-ID: <1225999922.387.42.camel@heimdal.trondhjem.org>
References: <200811061034.06486.asid@hp.com>
	 <1225997396.387.30.camel@heimdal.trondhjem.org>
	 <200811061422.58920.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Alex Sidorenko <alexandre.sidorenko@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:56811 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932AbYKFTcG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Nov 2008 14:32:06 -0500
In-Reply-To: <200811061422.58920.alexandre.sidorenko@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-11-06 at 14:22 -0500, Alex Sidorenko wrote:
> On November 6, 2008 01:49:56 pm Trond Myklebust wrote:
> > On Thu, 2008-11-06 at 10:34 -0500, Alex Sidorenko wrote:
> > > I understand the reasoning behind that. From application point of view,
> > > NFS file/directory should behave the same as on local FS. If we have
> > > queued many writes, without this patch stat() will return incorrect
> > > results, both for mtime and file length. Some applications may depend on
> > > stat() results being correct.
> > >
> > > At the same time, the fact that we have to wait forever while copying big
> > > files and doing 'ls -l' on that directory (or on the file being written)
> > > is not very good either (two HP customers have complained about this
> > > after migrating from RHEL4 to RHEL5).
> >
> > In order to relax that requirement, we'd have to introduce some
> > mechanism for the application to notify the filesystem that they don't
> > care about strictly correct c/mtimes. As you noted above, returning
> > incorrect mtimes may trip up some applications (backup applications, and
> > mail readers are a couple of business critical cases that come to mind).
> >
> > > The problem is still there in 2.6.27. I am not sure what can be done to
> > > both reduce the stat() delay and guarantee reasonable stat() results.
> > >
> > > It is interesting that with 'noac' stat() returns much faster (just 1-3s
> > > delay).
> >
> > That would be because 'noac' enforces synchronous writes. If you don't
> > care about the degraded write performance, you can do the same thing
> > without all the extra getattr clutter that noac introduces, by simply
> > mounting with -osync.
> 
> Hi Trond,
> 
> In my experiments on 2.6.24 I saw practically no performance degradation while 
> doing 'cp' of a 4Gb file with 'noac', with 'sync' the performance is really 
> bad. And writes are still definitely ASYNC, here is what I see using 
> Systemtap script on entry to rpc_execute
> 
> from /etc/mtab:
> 
> cats:/data /mnt nfs rw,udp,noac,hard,intr,addr=192.168.0.33 0 0
> 
> $ dd if=/dev/zero of=/mnt/win/big bs=100m count=1
> 
> From stap output:
> rpc_execute p_proc=7 WRITE qlen=0 prio=1 flags=0x1
> --ts=4
> rpc_execute p_proc=7 WRITE qlen=0 prio=1 flags=0x1
> ...
> 
> So we still have RPC_TASK_ASYNC set.
> 
> I did not check experimentally 'noac' on 2.6.27 but I still think that 'noac' 
> does not make writes sync. nfs_commit_rpcsetup() still sets RPC_TASK_ASYNC by 
> default and I don't see NFS_MOUNT_NOACL setting FLUSH_SYNC anywhere.

I repeat: 'noac' automatically sets the 'sync' flag, as you can see
below:

# mount -t nfs -onoac fas960-1:/vol/san /mnt
# cat /proc/mounts | grep nfs
fas960-1:/vol/san /mnt nfs rw,sync,vers=3,rsize=65536,wsize=65536,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,nointr,noac,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=141.211.133.16,mountvers=3,mountproto=tcp,addr=141.211.133.16 0 0

Trond

