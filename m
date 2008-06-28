From: Stefan Mehnert <stefanmehnert@googlemail.com>
Subject: Possible NFS Bug | Kernel 2.6.26-rc8
Date: Sat, 28 Jun 2008 23:36:06 +0200
Message-ID: <1214688966.4326.32.camel@stefan-ubuntu-vm>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:12357 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092AbYF1VgW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Jun 2008 17:36:22 -0400
Received: by fg-out-1718.google.com with SMTP id 19so496938fgg.17
        for <linux-nfs@vger.kernel.org>; Sat, 28 Jun 2008 14:36:20 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I've encountered the the problem a few times now that directory listing
in my home folder hung. The problem occurs when I shut down my test
web-server which provides an nfs share mounted into a folder in my home
directory.
When an application tries to get the directory listing of my home folder
it hangs until the server is online again. Umounting is not possible
"device is busy...". The only way to get it fixed is to restart the
system or bring the server back online.
It's good that it's so fault tolerant and can restore the connection,
but there should be a way to unmount the nfs share when the server is
gone?

Thanks,
Stefan

Kernel Messages:
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504018] ls            D
f5ea7ba0     0 27184  27093
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504023]        f5d26370
00000086 00000002 f5ea7ba0 f5ea7ba8 00000000 cccccccc cccccccc 
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504029]        c04b0240
c04b3700 c04b3700 c04b3700 f5ea7ba4 f5d264d8 c206e700 0001ac86 
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504034]        00000000
00000000 00000000 00000000 000000ff f5ea7be0 00000000 f5ea7be8 
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504039] Call Trace:
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504068]  [<f8a86999>]
nfs_wait_schedule+0x19/0x20 [nfs]
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504086]
[__wait_on_bit_lock+0x3d/0x70] __wait_on_bit_lock+0x3d/0x70
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504096]  [<f8a86980>]
nfs_wait_schedule+0x0/0x20 [nfs]
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504118]  [<f8a86980>]
nfs_wait_schedule+0x0/0x20 [nfs]
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504139]
[nfs:out_of_line_wait_on_bit_lock+0x5b/0xe0]
out_of_line_wait_on_bit_lock+0x5b/0x70
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504147]  [<c0151cb0>]
wake_bit_function+0x0/0x60
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504153]  [<f8a86ac5>]
__nfs_revalidate_inode+0x125/0x2a0 [nfs]
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504177]
[nfs:kunmap_atomic+0x3f/0x29d0] kunmap_atomic+0x3f/0xb0
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504184]
[get_page_from_freelist+0x2b3/0x480] get_page_from_freelist+0x2b3/0x480
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504184]
[nfs:kunmap_atomic+0x3f/0x29d0] kunmap_atomic+0x3f/0xb0
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504184]
[proc_alloc_inode+0x38/0x60] proc_alloc_inode+0x38/0x60
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504226]
[get_page_from_freelist+0x2b3/0x480] get_page_from_freelist+0x2b3/0x480
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504232]  [<f8a81921>]
nfs_lookup_revalidate+0x361/0x3f0 [nfs]
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504258]
[__alloc_pages_internal+0xb3/0x440] __alloc_pages_internal+0xb3/0x440
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504263]  [sunrpc:dput
+0x65/0x140] dput+0x65/0xd0
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504269]  [alloc_inode
+0x10e/0x1b0] alloc_inode+0x10e/0x1b0
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504274]
[nfs:kunmap_atomic+0x3f/0x29d0] kunmap_atomic+0x3f/0xb0
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504280]
[handle_mm_fault+0x5a5/0x7c0] handle_mm_fault+0x5a5/0x7c0
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504285]
[proc_pident_lookup+0x7a/0xb0] proc_pident_lookup+0x7a/0xb0
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504289]  [__d_lookup
+0x8a/0x100] __d_lookup+0x8a/0x100
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.504296]  [<f89b36c7>]
rpcauth_lookup_credcache+0x77/0x1c0 [sunrpc]
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506000]  [<f8a8264c>]
nfs_do_access+0x21c/0x290 [nfs]
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506024]  [<f89b3300>]
rpcauth_lookupcred+0x60/0xb0 [sunrpc]
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506051]  [<f89b31ad>]
put_rpccred+0x3d/0xd0 [sunrpc]
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506076]  [<f8a8277d>]
nfs_permission+0xbd/0x160 [nfs]
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506097]  [<f8a826c0>]
nfs_permission+0x0/0x160 [nfs]
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506118]  [permission
+0x97/0x120] permission+0x97/0x120
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506124]
[__link_path_walk+0x686/0xe50] __link_path_walk+0x686/0xe50
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506130]
[nfs:copy_to_user+0x30/0x530] copy_to_user+0x30/0x60
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506136]
[nfs:kunmap_atomic+0x3f/0x29d0] kunmap_atomic+0x3f/0xb0
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506143]  [path_walk
+0x47/0xa0] path_walk+0x47/0xa0
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506148]  [do_path_lookup
+0x72/0x1d0] do_path_lookup+0x72/0x1d0
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506151]
[security_file_alloc+0xc/0x10] security_file_alloc+0xc/0x10
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506156]  [get_empty_filp
+0x5c/0x190] get_empty_filp+0x5c/0x190
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506183]
[__path_lookup_intent_open+0x51/0xa0] __path_lookup_intent_open
+0x51/0xa0
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506192]
[path_lookup_open+0x20/0x30] path_lookup_open+0x20/0x30
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506198]  [do_filp_open
+0x7d/0x800] do_filp_open+0x7d/0x800
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506211]
[get_unused_fd_flags+0x52/0xd0] get_unused_fd_flags+0x52/0xd0
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506217]  [getname
+0xaa/0xe0] getname+0xaa/0xe0
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506222]  [do_sys_open
+0x4c/0xe0] do_sys_open+0x4c/0xe0
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506228]  [sys_open
+0x2c/0x40] sys_open+0x2c/0x40
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506233]
[sysenter_past_esp+0x78/0xb9] sysenter_past_esp+0x78/0xb9
Jun 28 22:28:32 stefan-ubuntu-vm kernel: [ 1128.506244]
=======================
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389708] bash          D
f5d69600     0 27261  25959
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389713]        f5d25f80
00000086 00000000 f5d69600 00000000 f5db7960 00000000 c021aba3 
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389719]        c04b0240
c04b3700 c04b3700 c04b3700 f4f84cf0 f5d260e8 c206e700 00000010 
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389724]        00000010
f5db7960 f4f84cf0 f5dd1be8 c0151ded f5dd1be0 00000000 f5dd1be8 
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389729] Call Trace:
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389752]
[blk_recount_segments+0x33/0x70] blk_recount_segments+0x33/0x70
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389769]
[prepare_to_wait_exclusive+0x6d/0x70] prepare_to_wait_exclusive
+0x6d/0x70
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389777]  [<f8a86999>]
nfs_wait_schedule+0x19/0x20 [nfs]
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389793]
[__wait_on_bit_lock+0x3d/0x70] __wait_on_bit_lock+0x3d/0x70
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389800]  [<f8a86980>]
nfs_wait_schedule+0x0/0x20 [nfs]
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389825]  [<f8a86980>]
nfs_wait_schedule+0x0/0x20 [nfs]
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389846]
[nfs:out_of_line_wait_on_bit_lock+0x5b/0xe0]
out_of_line_wait_on_bit_lock+0x5b/0x70
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389853]  [<c0151cb0>]
wake_bit_function+0x0/0x60
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389859]  [<f8a86ac5>]
__nfs_revalidate_inode+0x125/0x2a0 [nfs]
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389882]
[nfs:kunmap_atomic+0x3f/0x29d0] kunmap_atomic+0x3f/0xb0
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389889]
[get_page_from_freelist+0x2b3/0x480] get_page_from_freelist+0x2b3/0x480
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389900]
[__alloc_pages_internal+0xb3/0x440] __alloc_pages_internal+0xb3/0x440
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389903]
[nfs:kunmap_atomic+0x3f/0x29d0] kunmap_atomic+0x3f/0xb0
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389943]
[get_page_from_freelist+0x2b3/0x480] get_page_from_freelist+0x2b3/0x480
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389951]  [<f8a81921>]
nfs_lookup_revalidate+0x361/0x3f0 [nfs]
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389975]
[snd_pcm:getnstimeofday+0x3c/0x9530] getnstimeofday+0x3c/0xf0
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389986]  [task_tick_fair
+0x51/0x80] task_tick_fair+0x51/0x80
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389991]
[hrtimer_forward+0x104/0x150] hrtimer_forward+0x104/0x150
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.389998]
[snd_pcm:getnstimeofday+0x3c/0x9530] getnstimeofday+0x3c/0xf0
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390003]  [<f89b36c7>]
rpcauth_lookup_credcache+0x77/0x1c0 [sunrpc]
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390031]  [<f8a8264c>]
nfs_do_access+0x21c/0x290 [nfs]
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390054]  [<f89b3300>]
rpcauth_lookupcred+0x60/0xb0 [sunrpc]
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390079]  [<f89b31ad>]
put_rpccred+0x3d/0xd0 [sunrpc]
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390103]  [<f8a8277d>]
nfs_permission+0xbd/0x160 [nfs]
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390124]
[enqueue_hrtimer+0x7c/0x110] enqueue_hrtimer+0x7c/0x110
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390130]  [<f8a826c0>]
nfs_permission+0x0/0x160 [nfs]
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390151]  [permission
+0x97/0x120] permission+0x97/0x120
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390156]
[__link_path_walk+0x686/0xe50] __link_path_walk+0x686/0xe50
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390163]  [ktime_get
+0x18/0x40] ktime_get+0x18/0x40
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390169]
[nfs:rb_insert_color+0xb7/0xe0] rb_insert_color+0xb7/0xe0
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390176]  [path_walk
+0x47/0xa0] path_walk+0x47/0xa0
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390181]  [do_path_lookup
+0x72/0x1d0] do_path_lookup+0x72/0x1d0
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390185]
[security_file_alloc+0xc/0x10] security_file_alloc+0xc/0x10
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390189]  [get_empty_filp
+0x5c/0x190] get_empty_filp+0x5c/0x190
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390198]
[__path_lookup_intent_open+0x51/0xa0] __path_lookup_intent_open
+0x51/0xa0
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390198]
[path_lookup_open+0x20/0x30] path_lookup_open+0x20/0x30
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390226]  [do_filp_open
+0x7d/0x800] do_filp_open+0x7d/0x800
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390240]
[get_unused_fd_flags+0x52/0xd0] get_unused_fd_flags+0x52/0xd0
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390245]  [getname
+0xaa/0xe0] getname+0xaa/0xe0
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390249]  [do_sys_open
+0x4c/0xe0] do_sys_open+0x4c/0xe0
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390253]
[nfs:copy_to_user+0x30/0x530] copy_to_user+0x30/0x60
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390777]  [sys_open
+0x2c/0x40] sys_open+0x2c/0x40
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390782]
[sysenter_past_esp+0x78/0xb9] sysenter_past_esp+0x78/0xb9
Jun 28 22:28:44 stefan-ubuntu-vm kernel: [ 1141.390791]
=======================

