From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] pnfsblock: Lookup list entry of layouts and tags in
	reverse order
Date: Mon, 17 May 2010 12:53:02 -0400
Message-ID: <20100517165302.GL30737@fieldses.org>
References: <20100510033610.GA5443@MDS-78.localdomain> <4BEA4ED3.3010702@panasas.com> <20100512202811.GA9296@fieldses.org> <20100517135341.GA30737@fieldses.org> <4BF151A7.1070003@panasas.com> <20100517145311.GJ30737@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>,
	linux-nfs@vger.kernel.org, iisaman@netapp.com
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40668 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753514Ab0EQQxI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 May 2010 12:53:08 -0400
In-Reply-To: <20100517145311.GJ30737@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 17, 2010 at 10:53:11AM -0400, J. Bruce Fields wrote:
> On Mon, May 17, 2010 at 05:24:39PM +0300, Boaz Harrosh wrote:
> > On 05/17/2010 04:53 PM, J. Bruce Fields wrote:
> > > On Wed, May 12, 2010 at 04:28:12PM -0400, bfields wrote:
> > >> On Wed, May 12, 2010 at 09:46:43AM +0300, Benny Halevy wrote:
> > >>> On May. 10, 2010, 6:36 +0300, Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org> wrote:
> > >>>> Optimize for sequencial write. Layout infos and tags are organized by
> > >>>> file offset. When appending data to a file whole list will be examined,
> > >>>> which introduce notable performance decrease.
> > >>>
> > >>> Looks good to me.
> > >>>
> > >>> Fred, can you please double check?
> > >>
> > >> I don't know if Fred's still up for reviewing block stuff?
> > >>
> > >> I've been trying to keep up with at least some minimal testing, but not
> > >> as well as I'd like.
> > >>
> > >> The one thing I've noticed is that the connectathon general test has
> > >> started failing right at the start with an IO error.  The last good
> > >> version I tested was b5c09c21, which was based on 33-rc6.  The earliest
> > >> bad version I tested was 419312ada, based on 34-rc2.  A quick look at
> > >> network traces from the two traces didn't turn up anything obvious.  I
> > >> haven't had the chance yet to look closer.
> > > 
> > > As of the latest (6666f47d), in my tests the client is falling back on
> > > IO to the MDS and doing no block IO at all.  b5c09c21 still works, so
> > > the problem isn't due to a change in the server I'm testing against.  I
> > > haven't investigated any more closely.
> > > 
> > 
> > You might be hitting the .commit bug, no? Still no fix. I'm using a work
> > around for objects. I'm not sure how it affects blocks. I think you should
> > see that the very first IO goes through layout driver then the IO is redone
> > through MDS, for each node. Even though write/read returned success because
> > commit returns NOT_ATTEMPTED. But I might be totally off.
> 
> I don't believe it's even attempting a GETLAYOUT.
> 
> I'll take a look at the network....--b.

Everything on the network looks fine, the server's doing the right
stuff, the client just never asks for a layout.

In fact, blk_initialize_mountpont is failing on the very first check:

	if (server->pnfs_blksize == 0) {
		dprintk("%s Server did not return blksize\n", __func__);
		...

After rearranging the caller:

@@ -880,9 +880,9 @@ static void nfs4_init_pnfs(struct nfs_server *server, struct nfs_fh *mntfh, stru
 
 	if (nfs4_has_session(clp) &&
 	    (clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS)) {
-		set_pnfs_layoutdriver(server, mntfh, fsinfo->layouttype);
 		pnfs_set_ds_iosize(server);
 		server->pnfs_blksize = fsinfo->blksize;
+		set_pnfs_layoutdriver(server, mntfh, fsinfo->layouttype);
 	}
 #endif /* CONFIG_NFS_V4_1 */
 }

it just fails a little later (see below).  I haven't tried to go any
farther yet.

(But: why are the layout drivers using this odd pnfs_client_operations
indirection to call back to the common pnfs code?  As far as I can tell
there's only one definition of the pnfs_client_operations, so we should
just remove that structure and call pnfs_getdevicelist, etc., by name.)

--b.

May 17 16:36:14 pearlet4 kernel: BUG: unable to handle kernel NULL pointer dereference at (null)
May 17 16:36:14 pearlet4 kernel: IP: [<ffffffff8122bc36>] _nfs4_pnfs_getdevicelist+0x26/0x110
May 17 16:36:14 pearlet4 kernel: PGD 6e11067 PUD 6e12067 PMD 0 
May 17 16:36:14 pearlet4 kernel: Oops: 0000 [#1] PREEMPT 
May 17 16:36:14 pearlet4 kernel: last sysfs file: /sys/kernel/uevent_seqnum
May 17 16:36:14 pearlet4 kernel: CPU 0 
May 17 16:36:14 pearlet4 kernel: Modules linked in: iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi
May 17 16:36:14 pearlet4 kernel:
May 17 16:36:14 pearlet4 kernel: Pid: 2794, comm: mount.nfs4 Not tainted 2.6.34-rc6-pnfs-00314-ga35e9c3 #136 /
May 17 16:36:14 pearlet4 kernel: RIP: 0010:[<ffffffff8122bc36>]  [<ffffffff8122bc36>] _nfs4_pnfs_getdevicelist+0x26/0x110
May 17 16:36:14 pearlet4 kernel: RSP: 0018:ffff880004e99538  EFLAGS: 00010246
May 17 16:36:14 pearlet4 kernel: RAX: 0000000000000000 RBX: ffff880005fff378 RCX: ffff880004e99548
May 17 16:36:14 pearlet4 kernel: RDX: ffff880004ca24c8 RSI: ffff880004e99a28 RDI: ffff880005fff378
May 17 16:36:14 pearlet4 kernel: RBP: ffff880004e995c8 R08: 0000000000000000 R09: ffff880004ca24c8
May 17 16:36:14 pearlet4 kernel: R10: 0000000000000000 R11: 0000000000000001 R12: ffff880004ca24c8
May 17 16:36:14 pearlet4 kernel: R13: ffff880004ca24c8 R14: ffff880004e995d8 R15: ffff880004e99a28
May 17 16:36:14 pearlet4 kernel: FS:  00007fed29c476f0(0000) GS:ffffffff81e1c000(0000) knlGS:0000000000000000
May 17 16:36:14 pearlet4 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
May 17 16:36:14 pearlet4 kernel: CR2: 0000000000000000 CR3: 0000000004e77000 CR4: 00000000000006f0
May 17 16:36:14 pearlet4 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
May 17 16:36:14 pearlet4 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
May 17 16:36:14 pearlet4 kernel: Process mount.nfs4 (pid: 2794, threadinfo ffff880004e98000, task ffff880004e78040)
May 17 16:36:14 pearlet4 kernel: Stack:
May 17 16:36:14 pearlet4 kernel: ffff880004e995c8 ffff880004e995c8 ffff880004e99588 ffffffff8190e5dc
May 17 16:36:14 pearlet4 kernel: <0> ffff880004e98000 ffff880004e995c8 ffff880004ca24c0 ffff880007800a80
May 17 16:36:14 pearlet4 kernel: <0> 0000000000000000 ffff880007800a80 ffff880004ca24c0 ffffffff810d46c6
May 17 16:36:14 pearlet4 kernel: Call Trace:
May 17 16:36:14 pearlet4 kernel: [<ffffffff8190e5dc>] ? klist_next+0x8c/0xf0
May 17 16:36:14 pearlet4 kernel: [<ffffffff810d46c6>] ? poison_obj+0x36/0x50
May 17 16:36:14 pearlet4 kernel: [<ffffffff810d4a18>] ? cache_alloc_debugcheck_after+0xe8/0x1f0
May 17 16:36:14 pearlet4 kernel: [<ffffffff8122c21e>] nfs4_pnfs_getdevicelist+0x4e/0xa0
May 17 16:36:14 pearlet4 kernel: [<ffffffff810d677d>] ? kmem_cache_alloc_notrace+0xfd/0x1a0
May 17 16:36:14 pearlet4 kernel: [<ffffffff81250e81>] bl_initialize_mountpoint+0x161/0x6a0
May 17 16:36:14 pearlet4 kernel: [<ffffffff812497c9>] set_pnfs_layoutdriver+0x89/0x120
May 17 16:36:14 pearlet4 kernel: [<ffffffff8120c71f>] nfs_probe_fsinfo+0x54f/0x5f0
May 17 16:36:14 pearlet4 kernel: [<ffffffff8120d789>] nfs_clone_server+0x129/0x270
May 17 16:36:14 pearlet4 kernel: [<ffffffff810d46c6>] ? poison_obj+0x36/0x50
May 17 16:36:14 pearlet4 kernel: [<ffffffff810d4a18>] ? cache_alloc_debugcheck_after+0xe8/0x1f0
May 17 16:36:14 pearlet4 kernel: [<ffffffff810f6db1>] ? alloc_vfsmnt+0xa1/0x180
May 17 16:36:14 pearlet4 kernel: [<ffffffff810d627d>] ? __kmalloc_track_caller+0x16d/0x2b0
May 17 16:36:14 pearlet4 kernel: [<ffffffff810f6db1>] ? alloc_vfsmnt+0xa1/0x180
May 17 16:36:14 pearlet4 kernel: [<ffffffff81219fa1>] nfs4_xdev_get_sb+0x61/0x340
May 17 16:36:14 pearlet4 kernel: [<ffffffff810dd15a>] vfs_kern_mount+0x8a/0x1e0
May 17 16:36:14 pearlet4 kernel: [<ffffffff81224f23>] nfs_follow_mountpoint+0x3b3/0x4b0
May 17 16:36:14 pearlet4 kernel: [<ffffffff810e73b7>] link_path_walk+0xb67/0xd20
May 17 16:36:14 pearlet4 kernel: [<ffffffff810e76b0>] path_walk+0x60/0xd0
May 17 16:36:14 pearlet4 kernel: [<ffffffff810e778d>] vfs_path_lookup+0x6d/0x90
May 17 16:36:14 pearlet4 kernel: [<ffffffff8121988d>] nfs_follow_remote_path+0x6d/0x170
May 17 16:36:14 pearlet4 kernel: [<ffffffff810637fd>] ? trace_hardirqs_on_caller+0x14d/0x190
May 17 16:36:14 pearlet4 kernel: [<ffffffff812197fb>] ? nfs_do_root_mount+0x8b/0xb0
May 17 16:36:14 pearlet4 kernel: [<ffffffff81219abf>] nfs4_try_mount+0x6f/0xd0
May 17 16:36:14 pearlet4 kernel: [<ffffffff81219bc2>] nfs4_get_sb+0xa2/0x360
May 17 16:36:14 pearlet4 kernel: [<ffffffff810dd15a>] vfs_kern_mount+0x8a/0x1e0
May 17 16:36:14 pearlet4 kernel: [<ffffffff810dd322>] do_kern_mount+0x52/0x130
May 17 16:36:14 pearlet4 kernel: [<ffffffff81926cda>] ? _lock_kernel+0x6a/0x16a
May 17 16:36:14 pearlet4 kernel: [<ffffffff810f788e>] do_mount+0x2de/0x850
May 17 16:36:14 pearlet4 kernel: [<ffffffff810f585a>] ? copy_mount_options+0xea/0x190
May 17 16:36:14 pearlet4 kernel: [<ffffffff810f7e98>] sys_mount+0x98/0xf0
May 17 16:36:14 pearlet4 kernel: [<ffffffff81002518>] system_call_fastpath+0x16/0x1b
May 17 16:36:14 pearlet4 kernel: Code: 00 00 00 00 00 55 48 89 e5 53 48 81 ec 88 00 00 00 0f 1f 44 00 00 48 8b 87 70 02 00 00 f6 05 75 38 7e 01 10 48 8d 4d 80 48 89 fb <8b> 00 48 89 55 80 48 8d 55 d0 48 c7 45 d8 00 00 00 00 48 c7 45 
May 17 16:36:14 pearlet4 kernel: RIP  [<ffffffff8122bc36>] _nfs4_pnfs_getdevicelist+0x26/0x110
May 17 16:36:14 pearlet4 kernel: RSP <ffff880004e99538>
May 17 16:36:14 pearlet4 kernel: CR2: 0000000000000000
May 17 16:36:14 pearlet4 kernel: ---[ end trace 3956532521eb7ba1 ]---
May 17 16:36:14 pearlet4 kernel: mount.nfs4 used greatest stack depth: 2104 bytes left
May 17 16:36:21 pearlet4 kernel: eth0: no IPv6 routers present
May 17 16:40:32 pearlet4 ntpd[2255]: synchronized to 91.189.94.4, stratum 2
May 17 16:40:32 pearlet4 ntpd[2255]: kernel time sync status change 2001
