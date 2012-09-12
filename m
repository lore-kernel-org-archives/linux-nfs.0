Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:37001 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194Ab2ILVUh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Sep 2012 17:20:37 -0400
Date: Wed, 12 Sep 2012 14:20:35 -0700
From: Simon Kirby <sim@hostway.ca>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [3.6-rc3] rdirplus broken? (EBUSY)
Message-ID: <20120912212035.GB28555@hostway.ca>
References: <20120827215510.GL24761@hostway.ca>
 <20120911192523.GA11160@hostway.ca>
 <20120912121613.GC3009@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120912121613.GC3009@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 12, 2012 at 08:16:13AM -0400, J. Bruce Fields wrote:

> On Tue, Sep 11, 2012 at 12:25:23PM -0700, Simon Kirby wrote:
> > On Mon, Aug 27, 2012 at 02:55:10PM -0700, Simon Kirby wrote:
> > 
> > > Something seems broiken in 3.6-rc[123] which was fine in 3.5 and earlier.
> > > This is a 3.4.1 knfsd server with ext3 and XFS-based NFS exports:
> > > 
> > > /	192.168.13.0/24(rw,no_root_squash,no_subtree_check,async)
> > > /pics	192.168.13.0/24(rw,no_root_squash,no_subtree_check,async)
> > > /raid	192.168.13.0/24(rw,no_root_squash,no_subtree_check,async)
> > > 
> > > and a 3.6-rc3 client with this in fstab:
> > > 
> > > flick:/		/flick		nfs	rw,vers=3
> > > flick:/raid	/flick/raid	nfs	rw,vers=3
> > > flick:/pics	/flick/pics	nfs	rw,vers=3
> > > 
> > > This seems to fail now as follows:
> > > 
> > > [sroot@oof:/]# mount flick
> > > [sroot@oof:/]# mount flick/raid
> > > [sroot@oof:/]# mount flick/pics
> > > [sroot@oof:/]# ls -l flick
> > > ls: cannot access flick/pics: Device or resource busy
> > > ls: cannot access flick/raid: Device or resource busy
> > > total 2180
> > > drwxr-xr-x  45 root root    4096 Jun 18 14:19 ./
> > > drwxr-xr-x  58 root root    4096 Jul  3 22:24 ../
> > > ...
> > > ??????????   ? ?    ?          ?            ? pics
> > > ??????????   ? ?    ?          ?            ? raid
> > > ...
> > > [sroot@oof:/]# cd flick/pics
> > > flick/pics: Device or resource busy.
> > > 
> > > These mount points are now stuck and cannot be unmounted until
> > > I reboot (umount -l fails with EBUSY).
> > > 
> > > If I mount with "nordirplus", I can't seem to get it to break. However,
> > > sometimes it will work regardless. I can bisect this if it would help..
> > 
> > This is still the case with 3.6-rc5. I hadn't noticed any problem since
> > mounting with nordirplus, and it broke immediately after removing the
> > option again. I will bisect.
> 
> The symptoms sound similar to
> http://marc.info/?l=linux-fsdevel&m=134738157303017&w=2
> 
> Might be worth checking whether it's that patch?

Indeed! I tried this hack:

diff --git a/fs/dcache.c b/fs/dcache.c
index 8086636..649a112 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2404,6 +2404,10 @@ out_unalias:
 	if (likely(!d_mountpoint(alias))) {
 		__d_move(alias, dentry);
 		ret = alias;
+	} else {
+		printk(KERN_WARNING "VFS: __d_move()ing a d_mountpoint(), uh oh\n");
+		__d_move(alias, dentry);
+		ret = alias;
 	}
 out_err:
 	spin_unlock(&inode->i_lock);

With this applied, "ls -l flick" prints:

[   77.217420] VFS: __d_move()ing a d_mountpoint(), uh oh
[   77.222390] VFS: __d_move()ing a d_mountpoint(), uh oh

...and "pics" and "raid" then work as they did before, or with "nordirplus"
set. So, is something broken with nordirplus or the NFS layer, or should
__d_unalias() really move a mountpoint? With nordirplus, it works without
complaining about moving a mountpoint.

Simon-
