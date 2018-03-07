Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:40410 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934472AbeCGTxP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Mar 2018 14:53:15 -0500
Date: Wed, 7 Mar 2018 14:53:13 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: nfs_commit_inode should redirty inode if the inode
 has outstanding requests
Message-ID: <20180307195313.kzqdboqk5j2hyrf3@tonberry.usersys.redhat.com>
References: <20180302160038.1598-1-smayhew@redhat.com>
 <20180305211619.GA29226@fieldses.org>
 <1520286491.21829.13.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1520286491.21829.13.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 05 Mar 2018, Trond Myklebust wrote:

> On Mon, 2018-03-05 at 16:16 -0500, J. Bruce Fields wrote:
> > On Fri, Mar 02, 2018 at 11:00:38AM -0500, Scott Mayhew wrote:
> > > It seems that nfs_commit_inode can be called where the nfs_inode
> > > has
> > > outstanding requests and the commit lists are empty.  That can lead
> > > to
> > > invalidate_complete_page2 failing due to the associated page having
> > > private data which in turn leads to invalidate_inode_pages2_range
> > > returning -EBUSY.
> > 
> > For what it's worth, I verified that this fixes the EBUSY I was
> > seeing:
> > 
> > 	http://marc.info/?i=20180223160350.GF15876@fieldses.org
> > 
> 
> Fine, but the patch will also cause the inode to be marked as dirty in
> cases where there are no unstable writes to commit, but there are pages
> undergoing writeback.
> IOW: it regresses the fix that was made in dc4fd9ab01
> 
> So please do look into fixing do_launder_page().
> 

Yes, sorry... so I've been testing with this change since Friday
afternoon:

diff --git a/mm/truncate.c b/mm/truncate.c
index c34e2fd4f583..909734a5d3a3 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -647,7 +647,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 
 static int do_launder_page(struct address_space *mapping, struct page *page)
 {
-       if (!PageDirty(page))
+       if (!PageDirty(page) && !PagePrivate(page))
                return 0;
        if (page->mapping != mapping || mapping->a_ops->launder_page == NULL)
                return 0;

But I'm frequently seeing soft lockups though, on both 4.16-rc4 and on
the latest RHEL 7 kernel.

Mar  7 13:52:08 localhost kernel: watchdog: BUG: soft lockup - CPU#5 stuck for 23s! [xfs_io:17667]
Mar  7 13:52:08 localhost kernel: Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver nfs lockd grace fscache sunrpc crct10dif_pclmul crc32_pclmul ghash_clmulni_intel virtio_balloon i2c_piix4 joydev xfs libcrc32c qxl drm_kms_helper ttm virtio_console virtio_net drm virtio_scsi serio_raw crc32c_intel ata_generic virtio_pci pata_acpi qemu_fw_cfg virtio_rng virtio_ring virtio
Mar  7 13:52:08 localhost kernel: CPU: 5 PID: 17667 Comm: xfs_io Tainted: G             L   4.16.0-rc4+ #2
Mar  7 13:52:08 localhost kernel: Hardware name: Red Hat RHEV Hypervisor, BIOS 1.10.2-3.el7_4.1 04/01/2014
Mar  7 13:52:08 localhost kernel: RIP: 0010:nfs_commit_inode+0x87/0x160 [nfs]
Mar  7 13:52:08 localhost kernel: RSP: 0018:ffffab310e627b00 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff12
Mar  7 13:52:08 localhost kernel: RAX: 0000000000000000 RBX: ffff8cd834f0a3e0 RCX: 0000000000000000
Mar  7 13:52:08 localhost kernel: RDX: ffff8cd834f0a300 RSI: 0000000000000001 RDI: ffff8cd834f0a3e0
Mar  7 13:52:08 localhost kernel: RBP: 0000000000000001 R08: ffffab310e627c30 R09: 000000000001d400
Mar  7 13:52:08 localhost kernel: R10: ffff8cd836c02480 R11: ffff8cd83302043c R12: ffffab310e627b70
Mar  7 13:52:08 localhost kernel: R13: ffffffffffffffff R14: 0000000000000000 R15: ffffcd0147055f00
Mar  7 13:52:08 localhost kernel: FS:  00007feae2d97b80(0000) GS:ffff8cd837340000(0000) knlGS:0000000000000000
Mar  7 13:52:08 localhost kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Mar  7 13:52:08 localhost kernel: CR2: 00007feae2103fb8 CR3: 0000000120fc2002 CR4: 00000000003606e0
Mar  7 13:52:08 localhost kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Mar  7 13:52:08 localhost kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Mar  7 13:52:08 localhost kernel: Call Trace:
Mar  7 13:52:08 localhost kernel: nfs_wb_page+0xd7/0x1b0 [nfs]
Mar  7 13:52:08 localhost kernel: invalidate_inode_pages2_range+0x2aa/0x510
Mar  7 13:52:08 localhost kernel: nfs_revalidate_mapping+0xc6/0x280 [nfs]
Mar  7 13:52:08 localhost kernel: mmap_region+0x3a7/0x5e0
Mar  7 13:52:08 localhost kernel: do_mmap+0x2de/0x440
Mar  7 13:52:08 localhost kernel: vm_mmap_pgoff+0xd2/0x120
Mar  7 13:52:08 localhost kernel: SyS_mmap_pgoff+0x1c2/0x250
Mar  7 13:52:08 localhost kernel: do_syscall_64+0x74/0x180
Mar  7 13:52:08 localhost kernel: entry_SYSCALL_64_after_hwframe+0x3d/0xa2
Mar  7 13:52:08 localhost kernel: RIP: 0033:0x7feae2442e13
Mar  7 13:52:08 localhost kernel: RSP: 002b:00007fff59c5c158 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
Mar  7 13:52:08 localhost kernel: RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 00007feae2442e13
Mar  7 13:52:08 localhost kernel: RDX: 0000000000000002 RSI: 0000000000100000 RDI: 0000000000000000
Mar  7 13:52:08 localhost kernel: RBP: 000000001d300000 R08: 0000000000000003 R09: 000000001d300000
Mar  7 13:52:08 localhost kernel: R10: 0000000000000001 R11: 0000000000000246 R12: 0000000000000000
Mar  7 13:52:08 localhost kernel: R13: 0000000000100000 R14: 0000000000000001 R15: 0000000000000002
Mar  7 13:52:08 localhost kernel: Code: 00 00 48 85 c9 74 0a e8 98 9d 7d ec 48 8b 54 24 18 48 89 44 24 20 48 c7 44 24 28 00 00 00 00 48 c7 44 24 30 b0 30 43 c0 f0 ff 02 <48> 8b 7c 24 18 48 8b 47 08 48 85 c0 75 2a 45 31 e4 e8 53 d9 ff


Mar  6 17:42:11 dell-r430-8 kernel: NMI watchdog: BUG: soft lockup - CPU#1 stuck for 23s! [fio:9269]
Mar  6 17:42:11 dell-r430-8 kernel: Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver nfs lockd grace fscache sunrpc sb_edac intel_powerclamp coretemp intel_rapl iosf_mbi kvm_intel kvm irqbypass crc32_pclmul ghash_clmulni_intel aesni_intel lrw gf128mul ipmi_ssif glue_helper ablk_helper cryptd ipmi_si iTCO_wdt iTCO_vendor_support pcspkr dcdbas ipmi_devintf sg ipmi_msghandler wmi acpi_power_meter mei_me mei shpchp lpc_ich ip_tables xfs libcrc32c sr_mod sd_mod cdrom crc_t10dif crct10dif_generic mgag200 i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm crct10dif_pclmul crct10dif_common crc32c_intel ahci libahci libata tg3 i2c_core megaraid_sas ptp pps_core dm_mirror dm_region_hash dm_log dm_mod
Mar  6 17:42:11 dell-r430-8 kernel: CPU: 1 PID: 9269 Comm: fio Kdump: loaded Tainted: G             L ------------   3.10.0.jsm.test+ #10
Mar  6 17:42:11 dell-r430-8 kernel: Hardware name: Dell Inc. PowerEdge R430/03XKDV, BIOS 1.1.10 03/10/2015
Mar  6 17:42:11 dell-r430-8 kernel: task: ffff9728b830eeb0 ti: ffff9728b668c000 task.ti: ffff9728b668c000
Mar  6 17:42:11 dell-r430-8 kernel: RIP: 0010:[<ffffffff89f9f789>]  [<ffffffff89f9f789>] clear_page_dirty_for_io+0x9/0xd0
Mar  6 17:42:11 dell-r430-8 kernel: RSP: 0018:ffff9728b668fbb8  EFLAGS: 00000246
Mar  6 17:42:11 dell-r430-8 kernel: RAX: 002fffff0000082d RBX: ffff9728b668fb58 RCX: 0000000000000000
Mar  6 17:42:11 dell-r430-8 kernel: RDX: 0000000000000000 RSI: ffff9728b668fb58 RDI: ffffccfc93737180
Mar  6 17:42:11 dell-r430-8 kernel: RBP: ffff9728b668fbb8 R08: 0000000000000101 R09: ffffccfc8ddd4b80
Mar  6 17:42:11 dell-r430-8 kernel: R10: 0000000000000001 R11: 0000000000000005 R12: ffffffffffffff10
Mar  6 17:42:11 dell-r430-8 kernel: R13: ffff972913279db8 R14: ffff9728b668fb58 R15: 0000000000000000
Mar  6 17:42:11 dell-r430-8 kernel: FS:  00007fe3e484e7c0(0000) GS:ffff97295d240000(0000) knlGS:0000000000000000
Mar  6 17:42:11 dell-r430-8 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Mar  6 17:42:11 dell-r430-8 kernel: CR2: 00007fe3ddff95b0 CR3: 000000084837a000 CR4: 00000000001607e0
Mar  6 17:42:11 dell-r430-8 kernel: Call Trace:
Mar  6 17:42:11 dell-r430-8 kernel: [<ffffffffc0848ea5>] nfs_wb_single_page+0x95/0x190 [nfs]
Mar  6 17:42:11 dell-r430-8 kernel: [<ffffffffc0837dd1>] nfs_launder_page+0x41/0x90 [nfs]
Mar  6 17:42:11 dell-r430-8 kernel: [<ffffffff89fa406a>] invalidate_inode_pages2_range+0x3ca/0x470
Mar  6 17:42:11 dell-r430-8 kernel: [<ffffffff89fa4127>] invalidate_inode_pages2+0x17/0x20
Mar  6 17:42:11 dell-r430-8 kernel: [<ffffffffc083b29a>] nfs_invalidate_mapping+0x9a/0x100 [nfs]
Mar  6 17:42:11 dell-r430-8 kernel: [<ffffffffc083ba0a>] __nfs_revalidate_mapping+0x19a/0x280 [nfs]
Mar  6 17:42:11 dell-r430-8 kernel: [<ffffffffc083bf53>] nfs_revalidate_mapping_protected+0x13/0x20 [nfs]
Mar  6 17:42:11 dell-r430-8 kernel: [<ffffffffc0838344>] nfs_file_read+0x44/0xf0 [nfs]
Mar  6 17:42:11 dell-r430-8 kernel: [<ffffffffc0838300>] ? nfs_write_begin+0x290/0x290 [nfs]
Mar  6 17:42:11 dell-r430-8 kernel: [<ffffffff8a070143>] do_io_submit+0x3c3/0x870
Mar  6 17:42:11 dell-r430-8 kernel: [<ffffffff8a070600>] SyS_io_submit+0x10/0x20
Mar  6 17:42:11 dell-r430-8 kernel: [<ffffffff8a51f7d5>] system_call_fastpath+0x1c/0x21

-Scott

> > 
> > > 
> > > Instead of having nfs_commit_inode exit early when the commit lists
> > > are
> > > empty, only do so if nrequests is also 0.
> > > 
> > > Fixes: dc4fd9ab01 ("nfs: don't wait on commit in nfs_commit_inode()
> > > if there were no commit requests")
> > > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > > ---
> > >  fs/nfs/write.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > > index 7428a66..0268bd1 100644
> > > --- a/fs/nfs/write.c
> > > +++ b/fs/nfs/write.c
> > > @@ -1890,7 +1890,7 @@ int nfs_commit_inode(struct inode *inode, int
> > > how)
> > >  	if (res)
> > >  		error = nfs_generic_commit_list(inode, &head, how,
> > > &cinfo);
> > >  	nfs_commit_end(cinfo.mds);
> > > -	if (res == 0)
> > > +	if (res == 0 && !nfs_have_writebacks(inode))
> > >  		return res;
> > >  	if (error < 0)
> > >  		goto out_error;
> > > -- 
> > > 2.9.5
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-
> > > nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
