Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43108 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751916AbdLMPxj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Dec 2017 10:53:39 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Christoph Hellwig" <hch@infradead.org>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 2/3] pnfs/blocklayout: Revalidate SCSI disks after
 registration
Date: Wed, 13 Dec 2017 10:53:37 -0500
Message-ID: <28F67B65-DC6B-478D-BD64-EDD30C30DCC8@redhat.com>
In-Reply-To: <3F9C4DC2-0F19-4AB0-AB22-00DDF2CEAA03@redhat.com>
References: <cover.1512748321.git.bcodding@redhat.com>
 <7849a32ce8d429791eed114275496ec213dfaeb7.1512748321.git.bcodding@redhat.com>
 <20171212143825.GA11132@infradead.org>
 <3F9C4DC2-0F19-4AB0-AB22-00DDF2CEAA03@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12 Dec 2017, at 21:23, Benjamin Coddington wrote:

> On 12 Dec 2017, at 9:38, Christoph Hellwig wrote:
>
>> On Fri, Dec 08, 2017 at 12:52:58PM -0500, Benjamin Coddington wrote:
>>> If a SCSI device already has an exclusive access registrants only
>>> reservation, the device's size cannot be known by the client until 
>>> after
>>> registration.  We should therefore delay setting the block device's 
>>> length
>>> until after the registration and revalidation of the disk.
>>
>> Table 13 in sbc4r14.pdf clearly indicates READ CAPACITY is allowed 
>> even
>> for a not registered I_T nexus.  What kind of setup do you see this
>> problem with?
>
> It does indeed, I should have checked.  So it seems this patch should 
> be
> unnecessary, however I think if we do end up with d->len = 0, bad 
> things
> happen later.  My memory is fuzzy on this, I'll have to re-test it.
>
> The SCSI devices are presented by the TCM driver on a 4.11 era kernel. 
>  I
> don't know that code at all, but with quick look it seems that
> __target_execute_cmd() wants to check for reservations for all 
> commands.
>
> I think this patch should be dropped, and we can try to fix this on 
> the TCM
> side.

So, when the problem occurs with TCM, the bio calculations seem to be
botched.  do_add_page_to_bio ends up with some bad numbers..

[ 1508.078239] scsi host2: iSCSI Initiator over TCP/IP
[ 1508.080686] scsi 2:0:0:0: Direct-Access     LIO-ORG  block_1          
4.0  PQ: 0 ANSI: 5
[ 1508.081864] sd 2:0:0:0: reservation conflict
[ 1508.082221] sd 2:0:0:0: Attached scsi generic sg1 type 0
[ 1508.082754] sd 2:0:0:0: reservation conflict
[ 1508.083091] sd 2:0:0:0: reservation conflict
[ 1508.083173] scsi 2:0:0:1: Direct-Access     LIO-ORG  block_2          
4.0  PQ: 0 ANSI: 5
[ 1508.083994] sd 2:0:0:0: [sda] Read Capacity(16) failed: Result: 
hostbyte=DID_NEXUS_FAILURE driverbyte=DRIVER_OK
[ 1508.084707] sd 2:0:0:0: [sda] Sense not available.
[ 1508.085152] sd 2:0:0:0: reservation conflict
[ 1508.085664] sd 2:0:0:0: reservation conflict
[ 1508.085753] sd 2:0:0:1: Attached scsi generic sg2 type 0
[ 1508.086579] sd 2:0:0:0: reservation conflict
[ 1508.086867] sd 2:0:0:0: [sda] Read Capacity(10) failed: Result: 
hostbyte=DID_NEXUS_FAILURE driverbyte=DRIVER_OK
[ 1508.087496] sd 2:0:0:0: [sda] Sense not available.
[ 1508.088075] sd 2:0:0:1: [sdb] 20971520 512-byte logical blocks: (10.7 
GB/10.0 GiB)
[ 1508.088627] sd 2:0:0:1: [sdb] Write Protect is off
[ 1508.088951] sd 2:0:0:1: [sdb] Mode Sense: 43 00 10 08
[ 1508.088968] sd 2:0:0:0: [sda] 0 512-byte logical blocks: (0 B/0 B)
[ 1508.089360] sd 2:0:0:0: [sda] 0-byte physical blocks
[ 1508.089742] sd 2:0:0:0: reservation conflict
[ 1508.090081] sd 2:0:0:1: [sdb] Write cache: enabled, read cache: 
enabled, supports DPO and FUA
[ 1508.090671] sd 2:0:0:0: reservation conflict
[ 1508.091126] sd 2:0:0:0: reservation conflict
[ 1508.091656] sd 2:0:0:0: [sda] Test WP failed, assume Write Enabled
[ 1508.092157] sd 2:0:0:0: reservation conflict
[ 1508.092454] sd 2:0:0:0: [sda] Asking for cache data failed
[ 1508.092805] sd 2:0:0:0: [sda] Assuming drive cache: write through
[ 1508.093734] sd 2:0:0:0: reservation conflict
[ 1508.094235] sd 2:0:0:0: reservation conflict
[ 1508.095052] sd 2:0:0:0: reservation conflict
[ 1508.095460] sd 2:0:0:0: [sda] Read Capacity(16) failed: Result: 
hostbyte=DID_NEXUS_FAILURE driverbyte=DRIVER_OK
[ 1508.096083] sd 2:0:0:0: [sda] Sense not available.
[ 1508.096459] sd 2:0:0:0: reservation conflict
[ 1508.096886] sd 2:0:0:0: reservation conflict
[ 1508.097345] sd 2:0:0:0: reservation conflict
[ 1508.097791] sd 2:0:0:0: [sda] Read Capacity(10) failed: Result: 
hostbyte=DID_NEXUS_FAILURE driverbyte=DRIVER_OK
[ 1508.098696] sd 2:0:0:0: [sda] Sense not available.
[ 1508.099547] sd 2:0:0:0: reservation conflict
[ 1508.100000] sd 2:0:0:0: reservation conflict
[ 1508.100538] sd 2:0:0:0: reservation conflict
[ 1508.100891] sd 2:0:0:0: reservation conflict
[ 1508.101180] sd 2:0:0:1: [sdb] Attached SCSI disk
[ 1508.101252] sd 2:0:0:0: [sda] Attached SCSI disk
[ 1528.104541] set_pnfs_layoutdriver: Using NFSv4 I/O
[ 1528.105864] set_pnfs_layoutdriver: Using NFSv4 I/O
[ 1532.269993] find_pnfs_driver_locked: Searching for id 5, found 
ffffffffa0391000
[ 1532.270493] bl_set_layoutdriver enter
[ 1532.270728] set_pnfs_layoutdriver: pNFS module for 5 set
[ 1532.274569] pnfs_find_alloc_layout Begin ino=ffff880076c196c8 layout= 
          (null)
[ 1532.275101] __bl_alloc_layout_hdr enter
[ 1532.275387] pnfs_find_lseg:Begin
[ 1532.275599] pnfs_find_lseg:Return lseg           (null) ref 0
[ 1532.275937] --> send_layoutget
[ 1532.278518] ---> bl_alloc_lseg
[ 1532.278727] bl_alloc_lseg: number of extents 1
[ 1532.279021] nfs4_get_device_info: server ffff8800726d1000 max_resp_sz 
266240 max_pages 65
[ 1532.280246] nfs4_get_device_info getdevice info returns 0
[ 1532.280641] pNFS: using block device sda (reservation key 
0x5a30918050925eae)
[ 1532.281393] <-- nfs4_get_device_info d ffff88007f1b36c0
[ 1532.281731] bl_alloc_lseg returns 0
[ 1532.282004] pnfs_generic_layout_insert_lseg:Begin
[ 1532.282290] pnfs_generic_layout_insert_lseg: inserted lseg 
ffff880077a03e40 iomode 2 offset 0 length 8192 at tail
[ 1532.282917] pnfs_generic_layout_insert_lseg:Return
[ 1532.283304] pnfs_update_layout: inode 0:43/100 pNFS layout segment 
found for (read/write, offset: 0, length: 8192)
[ 1532.283902] pnfs_try_to_write_data: Writing ino:100 8192@0 (how 32)
[ 1532.284418] bl_write_pagelist enter, 8192@0
[ 1532.284714] do_add_page_to_bio: npg 2 rw 1 isect 0 offset 0 len 4096
[ 1532.285080] do_add_page_to_bio: npg 1 rw 1 isect 8388536 offset 0 len 
4096
[ 1532.285499] bl_submit_bio submitting write bio 4294930432@72
[ 1532.286277] bl_submit_bio submitting write bio 0@8388608
[ 1532.286610] pnfs_mark_matching_lsegs_invalid:Begin lo 
ffff88007f1b3480
[ 1532.287125] pnfs_mark_matching_lsegs_invalid: freeing lseg 
ffff880077a03e40 iomode 2 seq 1offset 0 length 8192
[ 1532.287674] mark_lseg_invalid: lseg ffff880077a03e40 ref 3
[ 1532.287979] pnfs_mark_matching_lsegs_invalid:Return 1
[ 1532.288259] pnfs_layout_io_set_failed Setting layout IOMODE_RW fail 
bit
[ 1532.288662] ------------[ cut here ]------------
[ 1532.288922] kernel BUG at block/blk-core.c:3023!
[ 1532.289181] invalid opcode: 0000 [#1] SMP
[ 1532.289405] Modules linked in: blocklayoutdriver nfsv4 dns_resolver 
nfs iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi ip6t_rpfilter 
ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat 
ebtable_broute bridge stp llc ip6table_raw ip6table_security 
ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 
ip6table_mangle iptable_raw iptable_security iptable_nat 
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack 
iptable_mangle ebtable_filter ebtables ip6table_filter ip6_tables nfsd 
auth_rpcgss nfs_acl lockd grace sunrpc virtio_blk virtio_balloon 
virtio_net virtio_console crct10dif_pclmul ppdev crc32_pclmul 
crc32c_intel ghash_clmulni_intel serio_raw parport_pc i2c_piix4 parport 
virtio_pci ata_generic virtio_ring pata_acpi virtio
[ 1532.293131] CPU: 1 PID: 1570 Comm: dd Not tainted 4.14.0.bebc6082da 
#2
[ 1532.293490] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.9.1-1.fc24 04/01/2014
[ 1532.293969] task: ffff88006f19bc00 task.stack: ffffc90001008000
[ 1532.294297] RIP: 0010:__blk_end_request_all+0x5a/0x60
[ 1532.294577] RSP: 0018:ffffc9000100b978 EFLAGS: 00010002
[ 1532.294866] RAX: 0000000000000001 RBX: ffff88007f069920 RCX: 
0000000000000000
[ 1532.295260] RDX: 0000000000000001 RSI: ffff88007e8c2f00 RDI: 
ffff88007f069920
[ 1532.295652] RBP: ffffc9000100b978 R08: ffff88007e8c2f00 R09: 
0000000000000000
[ 1532.296045] R10: ffff880077a03e40 R11: 0000000000000000 R12: 
ffff88007e5f8000
[ 1532.296437] R13: 0000000000000001 R14: 0000000000000296 R15: 
0000000000000000
[ 1532.296830] FS:  00007f43df54b700(0000) GS:ffff88007c080000(0000) 
knlGS:0000000000000000
[ 1532.297275] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1532.297592] CR2: 000055f30c939000 CR3: 000000006d968004 CR4: 
00000000001606e0
[ 1532.297987] Call Trace:
[ 1532.298129]  blk_peek_request+0x1bc/0x2c0
[ 1532.298354]  scsi_request_fn+0x3f/0x6c0
[ 1532.298569]  ? __cfq_update_io_thinktime+0x17/0x80
[ 1532.298835]  __blk_run_queue+0x3d/0x60
[ 1532.299047]  queue_unplugged+0x2a/0xa0
[ 1532.299258]  blk_flush_plug_list+0x22a/0x290
[ 1532.299496]  blk_finish_plug+0x2c/0x40
[ 1532.299708]  bl_write_pagelist+0x1f2/0x2b0 [blocklayoutdriver]
[ 1532.300039]  pnfs_generic_pg_writepages+0xb2/0x220 [nfsv4]
[ 1532.300349]  ? pnfs_generic_pg_writepages+0xb2/0x220 [nfsv4]
[ 1532.300667]  nfs_pageio_doio+0x2a/0x60 [nfs]
[ 1532.300912]  nfs_pageio_complete+0x55/0xc0 [nfs]
[ 1532.301172]  nfs_writepages+0xcb/0x120 [nfs]
[ 1532.301412]  do_writepages+0x1c/0x60
[ 1532.301614]  __filemap_fdatawrite_range+0xc6/0x100
[ 1532.301883]  filemap_write_and_wait_range+0x35/0x90
[ 1532.302156]  nfs_file_fsync+0x46/0x1f0 [nfs]
[ 1532.302394]  ? mntput+0x24/0x40
[ 1532.302571]  vfs_fsync_range+0x49/0xa0
[ 1532.302780]  vfs_fsync+0x1c/0x20
[ 1532.302979]  nfs4_file_flush+0x57/0x80 [nfsv4]
[ 1532.303236]  filp_close+0x2f/0x80
[ 1532.303422]  __close_fd+0x81/0xa0
[ 1532.303608]  SyS_close+0x23/0x50
[ 1532.303790]  entry_SYSCALL_64_fastpath+0x1a/0xa5
[ 1532.304049] RIP: 0033:0x7f43df067820
[ 1532.304249] RSP: 002b:00007ffcf4c59138 EFLAGS: 00000246 ORIG_RAX: 
0000000000000003
[ 1532.304664] RAX: ffffffffffffffda RBX: 00007f43df54b698 RCX: 
00007f43df067820
[ 1532.305057] RDX: 0000000000001000 RSI: 0000000000000000 RDI: 
0000000000000001
[ 1532.305448] RBP: 0000000000000002 R08: 0000000000000010 R09: 
0000028341f19d4c
[ 1532.305840] R10: 000055f30c938fa0 R11: 0000000000000246 R12: 
0000000000000002
[ 1532.306233] R13: 0000000000000000 R14: 7fffffffffffffff R15: 
0000000000000000
[ 1532.306624] Code: ff ff 84 c0 75 25 5d c3 0f ff 48 8b 87 50 01 00 00 
31 c9 48 85 c0 74 de 8b 48 68 8b 57 68 40 0f b6 f6 e8 ba fe ff ff 84 c0 
74 db <0f> 0b 0f 1f 40 00 0f 1f 44 00 00 55 48 89 e5 41 55 41 54 53 48
[ 1532.307661] RIP: __blk_end_request_all+0x5a/0x60 RSP: 
ffffc9000100b978
[ 1532.308022] ---[ end trace 03e5297ad9a73867 ]---

That looks a bit scary, I wonder if we could end up corrupting a 
filesystem
if this case isn't handled.  I think something like this is needed:

commit 670d2bebde3368b0244f5eb4af6fc581add7d4a4
Author: Benjamin Coddington <bcodding@redhat.com>
Date:   Tue Jun 13 16:02:14 2017 -0400

     pnfs/blocklayout: Ensure disk address in block device map

     It's possible that the device map is smaller than the offset into 
the
     device for the I/O we're adding.  This probably indicates an error 
of some
     sort (such as the dev->len = 0 due to the device being unreadable), 
so
     let's add a check for it and bail out.  Otherwise, we risk botching 
the bio
     calculations that follow.

     Signed-off-by: Benjamin Coddington <bcodding@redhat.com>

diff --git a/fs/nfs/blocklayout/blocklayout.c 
b/fs/nfs/blocklayout/blocklayout.c
index ec110aa87634..227a26dde9e4 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -137,6 +137,11 @@ bl_alloc_init_bio(int npg, struct block_device 
*bdev, sector_t disk_sector,
         return bio;
  }

+static bool offset_in_map(sector_t isect, struct pnfs_block_dev_map 
*map)
+{
+       return isect >= map->start && isect < map->start + map->len;
+}
+
  static struct bio *
  do_add_page_to_bio(struct bio *bio, int npg, int rw, sector_t isect,
                 struct page *page, struct pnfs_block_dev_map *map,
@@ -156,8 +161,8 @@ do_add_page_to_bio(struct bio *bio, int npg, int rw, 
sector_t isect,

         /* translate to physical disk offset */
         disk_addr = (u64)isect << SECTOR_SHIFT;
-       if (disk_addr < map->start || disk_addr >= map->start + 
map->len) {
-               if (!dev->map(dev, disk_addr, map))
+       if (!offset_in_map(isect, map)) {
+               if (!dev->map(dev, disk_addr, map) || 
!offset_in_map(isect, map))
                         return ERR_PTR(-EIO);
                 bio = bl_submit_bio(bio);
         }


Any thoughts?

Ben
