Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:52144 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965077AbeCHNJE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Mar 2018 08:09:04 -0500
Date: Thu, 8 Mar 2018 08:09:01 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: nfs_commit_inode should redirty inode if the inode
 has outstanding requests
Message-ID: <20180308130901.h2qbbzsuejggogut@tonberry.usersys.redhat.com>
References: <20180302160038.1598-1-smayhew@redhat.com>
 <20180305211619.GA29226@fieldses.org>
 <1520286491.21829.13.camel@primarydata.com>
 <20180307195313.kzqdboqk5j2hyrf3@tonberry.usersys.redhat.com>
 <1520455098.2858.4.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1520455098.2858.4.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 07 Mar 2018, Trond Myklebust wrote:

> On Wed, 2018-03-07 at 14:53 -0500, Scott Mayhew wrote:
> > On Mon, 05 Mar 2018, Trond Myklebust wrote:
> > 
> > > On Mon, 2018-03-05 at 16:16 -0500, J. Bruce Fields wrote:
> > > > On Fri, Mar 02, 2018 at 11:00:38AM -0500, Scott Mayhew wrote:
> > > > > It seems that nfs_commit_inode can be called where the
> > > > > nfs_inode
> > > > > has
> > > > > outstanding requests and the commit lists are empty.  That can
> > > > > lead
> > > > > to
> > > > > invalidate_complete_page2 failing due to the associated page
> > > > > having
> > > > > private data which in turn leads to
> > > > > invalidate_inode_pages2_range
> > > > > returning -EBUSY.
> > > > 
> > > > For what it's worth, I verified that this fixes the EBUSY I was
> > > > seeing:
> > > > 
> > > > 	http://marc.info/?i=20180223160350.GF15876@fieldses.org
> > > > 
> > > 
> > > Fine, but the patch will also cause the inode to be marked as dirty
> > > in
> > > cases where there are no unstable writes to commit, but there are
> > > pages
> > > undergoing writeback.
> > > IOW: it regresses the fix that was made in dc4fd9ab01
> > > 
> > > So please do look into fixing do_launder_page().
> > > 
> > 
> > Yes, sorry... so I've been testing with this change since Friday
> > afternoon:
> > 
> > diff --git a/mm/truncate.c b/mm/truncate.c
> > index c34e2fd4f583..909734a5d3a3 100644
> > --- a/mm/truncate.c
> > +++ b/mm/truncate.c
> > @@ -647,7 +647,7 @@ invalidate_complete_page2(struct address_space
> > *mapping, struct page *page)
> >  
> >  static int do_launder_page(struct address_space *mapping, struct
> > page *page)
> >  {
> > -       if (!PageDirty(page))
> > +       if (!PageDirty(page) && !PagePrivate(page))
> >                 return 0;
> >         if (page->mapping != mapping || mapping->a_ops->launder_page
> > == NULL)
> >                 return 0;
> > 
> > But I'm frequently seeing soft lockups though, on both 4.16-rc4 and
> > on
> > the latest RHEL 7 kernel.
> > 
> > Mar  7 13:52:08 localhost kernel: watchdog: BUG: soft lockup - CPU#5
> > stuck for 23s! [xfs_io:17667]
> > Mar  7 13:52:08 localhost kernel: Modules linked in: rpcsec_gss_krb5
> > auth_rpcgss nfsv4 dns_resolver nfs lockd grace fscache sunrpc
> > crct10dif_pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon
> > i2c_piix4 joydev xfs libcrc32c qxl drm_kms_helper ttm virtio_console
> > virtio_net drm virtio_scsi serio_raw crc32c_intel ata_generic
> > virtio_pci pata_acpi qemu_fw_cfg virtio_rng virtio_ring virtio
> > Mar  7 13:52:08 localhost kernel: CPU: 5 PID: 17667 Comm: xfs_io
> > Tainted: G             L   4.16.0-rc4+ #2
> > Mar  7 13:52:08 localhost kernel: Hardware name: Red Hat RHEV
> > Hypervisor, BIOS 1.10.2-3.el7_4.1 04/01/2014
> > Mar  7 13:52:08 localhost kernel: RIP:
> > 0010:nfs_commit_inode+0x87/0x160 [nfs]
> > Mar  7 13:52:08 localhost kernel: RSP: 0018:ffffab310e627b00 EFLAGS:
> > 00000202 ORIG_RAX: ffffffffffffff12
> > Mar  7 13:52:08 localhost kernel: RAX: 0000000000000000 RBX:
> > ffff8cd834f0a3e0 RCX: 0000000000000000
> > Mar  7 13:52:08 localhost kernel: RDX: ffff8cd834f0a300 RSI:
> > 0000000000000001 RDI: ffff8cd834f0a3e0
> > Mar  7 13:52:08 localhost kernel: RBP: 0000000000000001 R08:
> > ffffab310e627c30 R09: 000000000001d400
> > Mar  7 13:52:08 localhost kernel: R10: ffff8cd836c02480 R11:
> > ffff8cd83302043c R12: ffffab310e627b70
> > Mar  7 13:52:08 localhost kernel: R13: ffffffffffffffff R14:
> > 0000000000000000 R15: ffffcd0147055f00
> > Mar  7 13:52:08 localhost kernel: FS:  00007feae2d97b80(0000)
> > GS:ffff8cd837340000(0000) knlGS:0000000000000000
> > Mar  7 13:52:08 localhost kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
> > 0000000080050033
> > Mar  7 13:52:08 localhost kernel: CR2: 00007feae2103fb8 CR3:
> > 0000000120fc2002 CR4: 00000000003606e0
> > Mar  7 13:52:08 localhost kernel: DR0: 0000000000000000 DR1:
> > 0000000000000000 DR2: 0000000000000000
> > Mar  7 13:52:08 localhost kernel: DR3: 0000000000000000 DR6:
> > 00000000fffe0ff0 DR7: 0000000000000400
> > Mar  7 13:52:08 localhost kernel: Call Trace:
> > Mar  7 13:52:08 localhost kernel: nfs_wb_page+0xd7/0x1b0 [nfs]
> 
> Ah... So the real problem is that we're not waiting for the outstanding
> commit? OK, so how about something like the following then?
> 
Yes, this works.  I ran it through a dozen fio runs on v4.1 and 1000 runs
of generic/247 on v3/v4.0/v4.1/v4.2 and didn't see any EBUSY errors.
Also ran the xfstests "quick" group (~80-90 tests) plus generic/074 on
v3/v4.0/v4.1/v4.2.  Finally, I double checked the panic on umount issue
that dc4fd9ab01ab3 fixed and that still works too.

Thanks,
Scott

> 8<------------------------------------------
> From f2b7634d8a05100631ab019d4fb5092ed5fe3c03 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Wed, 7 Mar 2018 15:22:31 -0500
> Subject: [PATCH] NFS: Don't circumvent wait for commit completion
> 
> We do want to respect the FLUSH_SYNC argument to nfs_commit_inode() to
> ensure that all outstanding COMMIT requests to the inode in question are
> complete. Currently we will exit early if we did not have to schedule
> a new COMMIT request.
> 
> Fixes: dc4fd9ab01ab3 ("nfs: don't wait on commit in nfs_commit_inode()...")
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Cc: stable@vger.kernel.org # 4.5+
> ---
>  fs/nfs/write.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 93460f1cf5a4..89ca7b725454 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1886,8 +1886,6 @@ int nfs_commit_inode(struct inode *inode, int how)
>  	if (res)
>  		error = nfs_generic_commit_list(inode, &head, how, &cinfo);
>  	nfs_commit_end(cinfo.mds);
> -	if (res == 0)
> -		return res;
>  	if (error < 0)
>  		goto out_error;
>  	if (!may_wait)
> @@ -1904,7 +1902,8 @@ int nfs_commit_inode(struct inode *inode, int how)
>  	 * that the data is on the disk.
>  	 */
>  out_mark_dirty:
> -	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> +	if (atomic_read(&cinfo.mds->rpcs_out))
> +		__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
>  	return res;
>  }
>  EXPORT_SYMBOL_GPL(nfs_commit_inode);
> -- 
> 2.14.3
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
