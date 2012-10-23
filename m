Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:55786 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933739Ab2JWU5V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2012 16:57:21 -0400
From: Nix <nix@esperi.org.uk>
To: "Ted Ts'o" <tytso@mit.edu>, linux-ext4@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Bryan Schumaker <bjschuma@netapp.com>, Peng Tao <bergwolf@gmail.com>,
        Trond.Myklebust@netapp.com, gregkh@linuxfoundation.org,
        linux-nfs@vger.kernel.org
Subject: Apparent serious progressive ext4 data corruption bug in 3.6.3 (and other stable branches?)
References: <87objupjlr.fsf@spindle.srvr.nix>
	<20121023013343.GB6370@fieldses.org> <87mwzdnuww.fsf@spindle.srvr.nix>
	<20121023143019.GA3040@fieldses.org>
	<874nllxi7e.fsf_-_@spindle.srvr.nix>
Date: Tue, 23 Oct 2012 21:57:08 +0100
In-Reply-To: <874nllxi7e.fsf_-_@spindle.srvr.nix> (nix@esperi.org.uk's message
	of "Tue, 23 Oct 2012 17:32:21 +0100")
Message-ID: <87pq48nbyz.fsf_-_@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[Bruce, Trond, I fear it may be hard for me to continue chasing this NFS
 lockd crash as long as ext4 on 3.6.3 is hosing my filesystems like
 this. Apologies.]

On 23 Oct 2012, nix@esperi.org.uk uttered the following:
> Reproduced in 3.6.3, not in 3.6.1, not tried 3.6.2. Capturing it was
> rendered somewhat difficult by an ext4/JBD2 bug which leads to data loss
> in /var on every reboot out of 3.6.1 and on some reboots out of 3.6.3 (I
> have runs of NULs in my logs now, which keep eating the oopses):
>
> [while in 3.6.1]
> [   88.565698] JBD2: Spotted dirty metadata buffer (dev = dm-5, blocknr = 0). There's a risk of filesystem corruption in case of system crash.
> [   88.799263] JBD2: Spotted dirty metadata buffer (dev = dm-5, blocknr = 0). There's a risk of filesystem corruption in case of system crash.
> [   89.648152] ------------[ cut here ]------------
> [   89.648386] WARNING: at fs/inode.c:280 drop_nlink+0x25/0x42()
> [   89.648614] Hardware name: empty
> [   89.648833] Modules linked in: firewire_ohci firewire_core [last unloaded: microcode]
> [   89.649382] Pid: 1484, comm: dhcpd Not tainted 3.6.1-dirty #1
> [   89.649610] Call Trace:
> [   89.649832]  [<ffffffff810608c0>] warn_slowpath_common+0x83/0x9b
> [   89.650063]  [<ffffffff810608f2>] warn_slowpath_null+0x1a/0x1c
> [   89.650292]  [<ffffffff8112efbf>] drop_nlink+0x25/0x42
> [   89.650533]  [<ffffffff81187112>] ext4_dec_count+0x26/0x28
> [   89.650763]  [<ffffffff8118abb8>] ext4_rename+0x4ec/0x7b4
> [   89.650993]  [<ffffffff81125d81>] ? vfs_rename+0xbe/0x3b7
> [   89.651224]  [<ffffffff81125f3f>] vfs_rename+0x27c/0x3b7
> [   89.651454]  [<ffffffff81127a53>] sys_renameat+0x1b1/0x228
> [   89.651682]  [<ffffffff8114bda1>] ? fsnotify+0x226/0x249
> [   89.651911]  [<ffffffff81239b75>] ? security_inode_permission+0x1e/0x20
> [   89.652145]  [<ffffffff8111a240>] ? vfs_write+0x116/0x142
> [   89.652372]  [<ffffffff81127ae5>] sys_rename+0x1b/0x1e
> [   89.652601]  [<ffffffff814fffa2>] system_call_fastpath+0x16/0x1b
> [...]
> [while having just booted into 3.6.1 after some time in 3.6.3: the FS
>  was clean, and fscked on the previous boot into 3.6.3 after a previous
>  instance of this bug]
> Oct 23 17:18:26 spindle crit: [   67.625319] EXT4-fs error (device dm-5): mb_free_blocks:1300: group 65, block 2143748:freeing already freed block (bit 13828)
> 
> This may well be a 3.6.1-specific bug fixed in 3.6.3, but it's hard to
> tell since most of my reboots are 3.6.1->3.6.3 or vice versa right now.

It is now quite clear that this is a bug introduced by one or more of
the post-3.6.1 ext4 patches (which have all been backported at least to
3.5, so the problem is probably there too). Rebooting from 3.6.3 back
into 3.6.1, I saw this within seconds of boot:

[   60.290844] EXT4-fs error (device dm-3): ext4_mb_generate_buddy:741: group 202, 1583 clusters in bitmap, 1675 in gd
[   60.291426] JBD2: Spotted dirty metadata buffer (dev = dm-3, blocknr = 0). There's a risk of filesystem corruption in case of system crash.
[  116.508621] EXT4-fs error (device dm-3): ext4_mb_generate_buddy:741: group 5, 17749 clusters in bitmap, 17700 in gd
[  116.509626] EXT4-fs error (device dm-3): ext4_mb_generate_buddy:741: group 8, 15814 clusters in bitmap, 16073 in gd
[  116.510103] EXT4-fs error (device dm-3): ext4_mb_generate_buddy:741: group 10, 3349 clusters in bitmap, 3493 in gd
[  116.510571] EXT4-fs error (device dm-3): ext4_mb_generate_buddy:741: group 12, 1792 clusters in bitmap, 1648 in gd
[  116.511691] JBD2: Spotted dirty metadata buffer (dev = dm-3, blocknr = 0). There's a risk of filesystem corruption in case of system crash.
[  116.512736] EXT4-fs error (device dm-3): ext4_mb_generate_buddy:741: group 25, 14463 clusters in bitmap, 14462 in gd
[  116.513624] JBD2: Spotted dirty metadata buffer (dev = dm-3, blocknr = 0). There's a risk of filesystem corruption in case of system crash.
[  359.538550] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #73732: comm nfsd: deleted inode referenced: 10024
[  359.559220] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #73732: comm nfsd: deleted inode referenced: 10572
[  366.113780] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #73732: comm nfsd: deleted inode referenced: 10024
[  366.114837] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #73732: comm nfsd: deleted inode referenced: 10572
[  456.013682] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm vi: deleted inode referenced: 10303
[  456.384454] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm vi: deleted inode referenced: 10303
[  457.508943] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm vi: deleted inode referenced: 10303
[  457.509422] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm vi: deleted inode referenced: 10303
[  457.509897] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm vi: deleted inode referenced: 10303
[  478.779574] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm zsh: deleted inode referenced: 10303
[  478.780047] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm zsh: deleted inode referenced: 10303
[  478.780516] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm zsh: deleted inode referenced: 10303
[  478.780983] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm zsh: deleted inode referenced: 10303
[  478.782010] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm zsh: deleted inode referenced: 10303
[  478.782480] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm zsh: deleted inode referenced: 10303
[  479.826974] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm lesspipe.sh: deleted inode referenced: 10303
[  479.834091] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm lesspipe.sh: deleted inode referenced: 10303
[  479.835966] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm file: deleted inode referenced: 10303
[  479.856946] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm less: deleted inode referenced: 10303
[  479.857431] EXT4-fs error (device dm-3): ext4_lookup:1343: inode #49155: comm less: deleted inode referenced: 10303
[  679.812704] EXT4-fs error (device dm-3): mb_free_blocks:1300: group 27, block 916489:freeing already freed block (bit 31753)

(I'd provide more sample errors, but this bug has been eating
newly-written logs in /var all day, so not much has survived.)

I rebooted into 3.6.1 rescue mode and fscked everything: lots of
orphans, block group corruption and cross-linked files. The problems did
not recur upon booting from 3.6.1 into 3.6.1 again. It is quite clear
that metadata changes made in 3.6.3 are not making it to disk reliably,
thus leading to corrupted filesystems marked clean on reboot into other
kernels: pretty much every file appended to in 3.6.3 loses some or all
of its appended data, and newly allocated blocks often end up
cross-linked between multiple files.

The curious thing is this doesn't affect every filesystem: for a while
it affected only /var, and now it's affecting only /var and /home. The
massive writes to the ext4 filesystem mounted on /usr/src seem to have
gone off without incident: fsck reports no problems.


The only unusual thing about the filesystems on this machine are that
they have hardware RAID-5 (using the Areca driver), so I'm mounting with
'nobarrier': the full set of options for all my ext4 filesystems are:

rw,nosuid,nodev,relatime,journal_checksum,journal_async_commit,nobarrier,quota,
usrquota,grpquota,commit=30,stripe=16,data=ordered,usrquota,grpquota

If there's anything I can do to help, I'm happy to do it, once I've
restored my home directory from backup :(


tune2fs output for one of the afflicted filesystems (after fscking):

tune2fs 1.42.2 (9-Apr-2012)
Filesystem volume name:   home
Last mounted on:          /home
Filesystem UUID:          95bd22c2-253c-456f-8e36-b6cfb9ecd4ef
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
Filesystem features:      has_journal ext_attr resize_inode dir_index filetype needs_recovery extent flex_bg sparse_super large_file huge_file uninit_bg dir_nlink extra_isize
Filesystem flags:         signed_directory_hash
Default mount options:    (none)
Filesystem state:         clean
Errors behavior:          Continue
Filesystem OS type:       Linux
Inode count:              3276800
Block count:              13107200
Reserved block count:     655360
Free blocks:              5134852
Free inodes:              3174777
First block:              0
Block size:               4096
Fragment size:            4096
Reserved GDT blocks:      20
Blocks per group:         32768
Fragments per group:      32768
Inodes per group:         8192
Inode blocks per group:   512
RAID stripe width:        16
Flex block group size:    64
Filesystem created:       Tue May 26 21:29:41 2009
Last mount time:          Tue Oct 23 21:32:07 2012
Last write time:          Tue Oct 23 21:32:07 2012
Mount count:              2
Maximum mount count:      20
Last checked:             Tue Oct 23 21:22:16 2012
Check interval:           15552000 (6 months)
Next check after:         Sun Apr 21 21:22:16 2013
Lifetime writes:          1092 GB
Reserved blocks uid:      0 (user root)
Reserved blocks gid:      0 (group root)
First inode:              11
Inode size:               256
Required extra isize:     28
Desired extra isize:      28
Journal inode:            8
First orphan inode:       1572907
Default directory hash:   half_md4
Directory Hash Seed:      a201983d-d8a3-460b-93ca-eb7804b62c23
Journal backup:           inode blocks
