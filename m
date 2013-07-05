Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5225 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966Ab3GEVtH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jul 2013 17:49:07 -0400
Date: Fri, 5 Jul 2013 17:49:03 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: [PATCH RFC 0/2] NFS: Improve readdir performance
Message-ID: <20130705214903.GC37766@tonberry.usersys.redhat.com>
References: <1370440321-56488-1-git-send-email-smayhew@redhat.com>
 <1370441563.21544.6.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1370441563.21544.6.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 05 Jun 2013, Myklebust, Trond wrote:

> On Wed, 2013-06-05 at 09:51 -0400, Scott Mayhew wrote:
> > I was investigating some performance concerns from a customer and came across
> > something interesting.  Whenever the directory that we're reading is changed on
> > the server, we start re-reading the directory from the beginning.  On a LAN
> > connection or in a directory with a small number of entries, the impact isn't
> > too noticeable... but reading a directory with a large number of entries over a
> > WAN connection gets pretty bad.
> > 
> > For NFS v3, what happens is that after each on-the-wire READDIR we call
> > nfs_refresh_inode() and from there we get to nfs_update_inode(), where we wind
> > up setting NFS_INO_INVALID_DATA in the directory's cache_validity flags.  Then
> > on a subsequent call to nfs_readdir() we call nfs_revalidate_mapping(), and
> > seeing that NFS_INO_INVALIDATE_DATA is set we call nfs_invalidate_mapping(),
> > flushing all our cached data for the directory.  
> > 
> > So for each nfs_readdir() call, we wind up redoing all of the on-the-wire
> > readdir operations just to get back where we were, and then we're able to get
> > just one more operation's worth of entries on top of that.  If the directory on
> > the NFS server is constantly being modified then this winds up being a lot of
> > extra READDIR ops.  I had an idea that maybe we could call nfs_refresh_inode()
> > only when we've reached the end of the directory.  I talked to Jeff about it and
> > he suggested that maybe we could only revalidate if we're at the beginning of
> > the directory or if nfs_attribute_cache_expired() for the dir.  The attached
> > patches take that approach.
> > 
> > For example, on a test environment of two VMs, I have a directory of 100,000
> > entries that takes 981 READDIR operations to read if no modifications being made
> > to the directory at the same time.  If I add a 35ms delay between the client and
> > the server and start a script on the server that repeatedly creates and removes
> > a file in the directory being listed I get the following results:
> > 
> > [root@localhost ~]# mount -t nfs -o nfsvers=3,nordirplus server:/export /mnt
> > [root@localhost ~]# time /bin/ls /mnt/bigdir >/dev/null
> > 
> > real	29m52.594s
> > user	0m0.376s
> > sys	0m2.191s
> > [root@localhost ~]# mountstats --rpc /mnt | grep -A3 READDIR
> > READDIR:
> > 	49729 ops (99%) 	0 retrans (0%) 	0 major timeouts
> > 	avg bytes sent per op: 144	avg bytes received per op: 4196
> > 	backlog wait: 0.003620 	RTT: 35.889501 	total execute time: 35.925858 (milliseconds)
> > [root@localhost ~]# 
> > 
> > 
> > With the patched kernel, that same test yields these results:
> > 
> > [root@localhost ~]# time /bin/ls /mnt/bigdir >/dev/null
> > 
> > real	0m35.952s
> > user	0m0.460s
> > sys	0m0.100s
> > [root@localhost ~]# mountstats --rpc /mnt | grep -A3 READDIR
> > READDIR:
> > 	981 ops (98%) 	0 retrans (0%) 	0 major timeouts
> > 	avg bytes sent per op: 144	avg bytes received per op: 4194
> > 	backlog wait: 0.004077 	RTT: 35.887870 	total execute time: 35.926606 (milliseconds)
> > [root@localhost ~]# 
> > 
> > 
> > For NFS v4, the situation is slightly different.  We don't get post-op
> > attributes from each READDIR, so we're not calling
> > nfs_refresh_inode()/nfs_update_inode() after every operation and therefore not
> > updating read_cache_jiffies.  If we don't manage to read through the whole
> > directory before the directory attributes from the initial GETATTR expire, then
> > we're going to wind up calling __nfs_revalidate_inode() from
> > nfs_revalidate_mapping(), and the attributes that we get from that GETATTR are
> > going ultimately to lead us into nfs_invalidate_mapping() anyway.  If the
> > attached patches make sense then maybe it would be worthwhile to add a GETATTR
> > operation to the compound that gets sent for a READDIR so that
> > read_cache_jiffies stays updated.
> > 
> > Finally there's the question of the dentry cache.  Any time we find that the
> > parent directory changes we're still going to wind up doing an on-the-wire
> > LOOKUP.  I don't think there's anything that can be done about that, but at
> > least these patches prevent us doing the same LOOKUPs multiple times in the
> > course of reading through the directory.
> 
> Do these patches pass the 'rm -rf' torture test (i.e. creating lots of
> subdirectories containing random files, then calling 'rm -rf')?
> 
> I'd also like to see if the above test (and others you may be using)
> play out well with different filesystems on the server side. The main
> interest is to see how the change is affected by different readdir
> cookie schemes...
>
Hi Trond,

I did an 'rm -rf' of a kernel git tree over NFS v3 and v4 (both with and without
-o nordirplus).  I did the previously mentioned ls over WAN test.  I also did
various other tests (cthon, iozone, kernel compile, fsstress, fsx-linux).  All
of these were done using ext4, xfs, and btrfs as the backend filesystems.

If there's other tests you'd like me to run, please let me know.

-Scott
