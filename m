Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:34722 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750773AbdEBRW2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 May 2017 13:22:28 -0400
Date: Tue, 2 May 2017 19:22:22 +0200
From: Corentin Labbe <clabbe.montjoie@gmail.com>
To: Jan Kara <jack@suse.cz>
Cc: anna.schumaker@netapp.com, hch@lst.de,
        trond.myklebust@primarydata.com, axboe@fb.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [BUG] cannot mount nfs, bisected to 0db10944a76ba ("nfs: Convert
 to separately allocated bdi")
Message-ID: <20170502172222.GA28711@Red>
References: <20170428095624.GA22965@Red>
 <20170502162704.GM13916@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170502162704.GM13916@quack2.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 02, 2017 at 06:27:04PM +0200, Jan Kara wrote:
> Hello,
> 
> On Fri 28-04-17 11:56:24, Corentin Labbe wrote:
> > Since linux next-20170421, mounting nfs give me:
> > [  774.994934] ------------[ cut here ]------------
> > [  774.994975] WARNING: CPU: 1 PID: 10284 at /linux-next/fs/sysfs/dir.c:31 sysfs_warn_dup+0x64/0x74
> > [  774.994985] sysfs: cannot create duplicate filename '/devices/virtual/bdi/0:32'
> > [  774.994992] Modules linked in: axp20x_usb_power gpio_axp209 nvmem_sunxi_sid sun4i_dma sun4i_ss virt_dma
> > [  774.995047] CPU: 1 PID: 10284 Comm: mount.nfs Not tainted 4.11.0-rc4+ #14
> > [  774.995054] Hardware name: Allwinner sun7i (A20) Family
> > [  774.995085] [<c010f19c>] (unwind_backtrace) from [<c010bc74>] (show_stack+0x10/0x14)
> > [  774.995104] [<c010bc74>] (show_stack) from [<c03c6e24>] (dump_stack+0x78/0x8c)
> > [  774.995121] [<c03c6e24>] (dump_stack) from [<c0122200>] (__warn+0xe8/0x100)
> > [  774.995135] [<c0122200>] (__warn) from [<c0122250>] (warn_slowpath_fmt+0x38/0x48)
> > [  774.995150] [<c0122250>] (warn_slowpath_fmt) from [<c02ac178>] (sysfs_warn_dup+0x64/0x74)
> > [  774.995167] [<c02ac178>] (sysfs_warn_dup) from [<c02ac254>] (sysfs_create_dir_ns+0x84/0x94)
> > [  774.995184] [<c02ac254>] (sysfs_create_dir_ns) from [<c03c8b8c>] (kobject_add_internal+0x9c/0x2ec)
> > [  774.995199] [<c03c8b8c>] (kobject_add_internal) from [<c03c8e24>] (kobject_add+0x48/0x98)
> > [  774.995217] [<c03c8e24>] (kobject_add) from [<c048d75c>] (device_add+0xe4/0x5a0)
> > [  774.995232] [<c048d75c>] (device_add) from [<c048ddb4>] (device_create_groups_vargs+0xac/0xbc)
> > [  774.995247] [<c048ddb4>] (device_create_groups_vargs) from [<c048dde4>] (device_create_vargs+0x20/0x28)
> > [  774.995263] [<c048dde4>] (device_create_vargs) from [<c02075c8>] (bdi_register_va+0x44/0xfc)
> > [  774.995280] [<c02075c8>] (bdi_register_va) from [<c023d378>] (super_setup_bdi_name+0x48/0xa4)
> > [  774.995299] [<c023d378>] (super_setup_bdi_name) from [<c0312ef4>] (nfs_fill_super+0x1a4/0x204)
> > [  774.995315] [<c0312ef4>] (nfs_fill_super) from [<c03133f0>] (nfs_fs_mount_common+0x140/0x1e8)
> > [  774.995333] [<c03133f0>] (nfs_fs_mount_common) from [<c03335cc>] (nfs4_remote_mount+0x50/0x58)
> > [  774.995349] [<c03335cc>] (nfs4_remote_mount) from [<c023ef98>] (mount_fs+0x14/0xa4)
> > [  774.995368] [<c023ef98>] (mount_fs) from [<c025cba0>] (vfs_kern_mount+0x54/0x128)
> > [  774.995385] [<c025cba0>] (vfs_kern_mount) from [<c033352c>] (nfs_do_root_mount+0x80/0xa0)
> > [  774.995400] [<c033352c>] (nfs_do_root_mount) from [<c0333818>] (nfs4_try_mount+0x28/0x3c)
> > [  774.995415] [<c0333818>] (nfs4_try_mount) from [<c0313874>] (nfs_fs_mount+0x2cc/0x8c4)
> > [  774.995430] [<c0313874>] (nfs_fs_mount) from [<c023ef98>] (mount_fs+0x14/0xa4)
> > [  774.995445] [<c023ef98>] (mount_fs) from [<c025cba0>] (vfs_kern_mount+0x54/0x128)
> > [  774.995461] [<c025cba0>] (vfs_kern_mount) from [<c02600f0>] (do_mount+0x158/0xc7c)
> > [  774.995475] [<c02600f0>] (do_mount) from [<c0260f98>] (SyS_mount+0x8c/0xb4)
> > [  774.995491] [<c0260f98>] (SyS_mount) from [<c0107840>] (ret_fast_syscall+0x0/0x3c)
> > [  774.995501] ---[ end trace 0665e451f8864ff0 ]---
> ...
> > The mount command is
> > mount -t nfs -o tcp,hard,intr,async,rsize=4096,wsize=4096 192.168.1.100:/mnt/local_kernel /usr/src/
> > 
> > the mount command failling with: "mount.nfs: Cannot allocate memory"
> 
> I've tried reproducing this (both with NFSv3 and NFSv4) and failed. Also I
> have looked through the code and I fail to see how this could happen. Is
> this the only NFS mount that you have on your system? Didn't also the
> WARN_ON in super_setup_bdi_name() trigger?
> 
> Can you run with the attached debug patch and post full dmesg after the
> failure?
> 

Hello

I forgot to said that I have 6 nfs mount point.
mount -t nfs -o ro,tcp,hard,intr,async,vers=3 192.168.1.100:/usr/portage /usr/portage/
mount -t nfs -o tcp,hard,intr,async,vers=3 192.168.1.100:/usr/local/portage /usr/local/portage/
mount -t nfs -o tcp,hard,intr,async,vers=3 192.168.1.100:/mnt/tempo/portages/distfiles /usr/portage/distfiles
mount -t nfs -o tcp,hard,intr,async,vers=4 192.168.1.100:/mnt/tempo/portages/cubiedev/packages /usr/portage/packages
mount -t nfs -o tcp,hard,intr,async,vers=4,rsize=4096,wsize=4096 192.168.1.100:/var/tmp/portage/cubie /var/tmp/portage/
mount -t nfs -o tcp,hard,intr,async,rsize=4096,wsize=4096 192.168.1.100:/mnt/tempo/cubie/local_kernel /usr/src/

It's always the last which fail, but strangely inverting the two last made everything ok.

[   63.424216] Registering bdi 0:29 for server edcdcc00
[   63.424245] CPU: 1 PID: 2409 Comm: mount.nfs Not tainted 4.11.0-next-20170502+ #100
[   63.424253] Hardware name: Allwinner sun7i (A20) Family
[   63.424285] [<c010f268>] (unwind_backtrace) from [<c010bd38>] (show_stack+0x10/0x14)
[   63.424304] [<c010bd38>] (show_stack) from [<c03c7b68>] (dump_stack+0x78/0x8c)
[   63.424323] [<c03c7b68>] (dump_stack) from [<c0311664>] (nfs_fill_super+0x1a8/0x224)
[   63.424339] [<c0311664>] (nfs_fill_super) from [<c0311b7c>] (nfs_fs_mount_common+0x140/0x1e8)
[   63.424354] [<c0311b7c>] (nfs_fs_mount_common) from [<c0312834>] (nfs_try_mount+0x110/0x268)
[   63.424369] [<c0312834>] (nfs_try_mount) from [<c0312014>] (nfs_fs_mount+0x2e0/0x8ec)
[   63.424387] [<c0312014>] (nfs_fs_mount) from [<c023b66c>] (mount_fs+0x14/0xa4)
[   63.424403] [<c023b66c>] (mount_fs) from [<c0258ffc>] (vfs_kern_mount+0x54/0x128)
[   63.424418] [<c0258ffc>] (vfs_kern_mount) from [<c025c54c>] (do_mount+0x158/0xc7c)
[   63.424432] [<c025c54c>] (do_mount) from [<c025d3f4>] (SyS_mount+0x8c/0xb4)
[   63.424448] [<c025d3f4>] (SyS_mount) from [<c0107840>] (ret_fast_syscall+0x0/0x3c)
[   63.474416] Registering bdi 0:30 for server ee40b800
[   63.474442] CPU: 1 PID: 2413 Comm: mount.nfs Not tainted 4.11.0-next-20170502+ #100
[   63.474450] Hardware name: Allwinner sun7i (A20) Family
[   63.474488] [<c010f268>] (unwind_backtrace) from [<c010bd38>] (show_stack+0x10/0x14)
[   63.474507] [<c010bd38>] (show_stack) from [<c03c7b68>] (dump_stack+0x78/0x8c)
[   63.474527] [<c03c7b68>] (dump_stack) from [<c0311664>] (nfs_fill_super+0x1a8/0x224)
[   63.474544] [<c0311664>] (nfs_fill_super) from [<c0311b7c>] (nfs_fs_mount_common+0x140/0x1e8)
[   63.474559] [<c0311b7c>] (nfs_fs_mount_common) from [<c0312834>] (nfs_try_mount+0x110/0x268)
[   63.474574] [<c0312834>] (nfs_try_mount) from [<c0312014>] (nfs_fs_mount+0x2e0/0x8ec)
[   63.474591] [<c0312014>] (nfs_fs_mount) from [<c023b66c>] (mount_fs+0x14/0xa4)
[   63.474609] [<c023b66c>] (mount_fs) from [<c0258ffc>] (vfs_kern_mount+0x54/0x128)
[   63.474625] [<c0258ffc>] (vfs_kern_mount) from [<c025c54c>] (do_mount+0x158/0xc7c)
[   63.474640] [<c025c54c>] (do_mount) from [<c025d3f4>] (SyS_mount+0x8c/0xb4)
[   63.474656] [<c025d3f4>] (SyS_mount) from [<c0107840>] (ret_fast_syscall+0x0/0x3c)
[   63.532851] Registering bdi 0:31 for server edd48c00
[   63.532877] CPU: 1 PID: 2416 Comm: mount.nfs Not tainted 4.11.0-next-20170502+ #100
[   63.532885] Hardware name: Allwinner sun7i (A20) Family
[   63.532924] [<c010f268>] (unwind_backtrace) from [<c010bd38>] (show_stack+0x10/0x14)
[   63.532946] [<c010bd38>] (show_stack) from [<c03c7b68>] (dump_stack+0x78/0x8c)
[   63.532967] [<c03c7b68>] (dump_stack) from [<c0311664>] (nfs_fill_super+0x1a8/0x224)
[   63.532984] [<c0311664>] (nfs_fill_super) from [<c0311b7c>] (nfs_fs_mount_common+0x140/0x1e8)
[   63.532999] [<c0311b7c>] (nfs_fs_mount_common) from [<c0312834>] (nfs_try_mount+0x110/0x268)
[   63.533014] [<c0312834>] (nfs_try_mount) from [<c0312014>] (nfs_fs_mount+0x2e0/0x8ec)
[   63.533032] [<c0312014>] (nfs_fs_mount) from [<c023b66c>] (mount_fs+0x14/0xa4)
[   63.533049] [<c023b66c>] (mount_fs) from [<c0258ffc>] (vfs_kern_mount+0x54/0x128)
[   63.533064] [<c0258ffc>] (vfs_kern_mount) from [<c025c54c>] (do_mount+0x158/0xc7c)
[   63.533079] [<c025c54c>] (do_mount) from [<c025d3f4>] (SyS_mount+0x8c/0xb4)
[   63.533096] [<c025d3f4>] (SyS_mount) from [<c0107840>] (ret_fast_syscall+0x0/0x3c)
[   63.607887] Registering bdi 0:32 for server edc7c400
[   63.607914] CPU: 1 PID: 2419 Comm: mount.nfs Not tainted 4.11.0-next-20170502+ #100
[   63.607923] Hardware name: Allwinner sun7i (A20) Family
[   63.607955] [<c010f268>] (unwind_backtrace) from [<c010bd38>] (show_stack+0x10/0x14)
[   63.607975] [<c010bd38>] (show_stack) from [<c03c7b68>] (dump_stack+0x78/0x8c)
[   63.607995] [<c03c7b68>] (dump_stack) from [<c0311664>] (nfs_fill_super+0x1a8/0x224)
[   63.608012] [<c0311664>] (nfs_fill_super) from [<c0311b7c>] (nfs_fs_mount_common+0x140/0x1e8)
[   63.608028] [<c0311b7c>] (nfs_fs_mount_common) from [<c0332014>] (nfs4_remote_mount+0x50/0x58)
[   63.608044] [<c0332014>] (nfs4_remote_mount) from [<c023b66c>] (mount_fs+0x14/0xa4)
[   63.608060] [<c023b66c>] (mount_fs) from [<c0258ffc>] (vfs_kern_mount+0x54/0x128)
[   63.608077] [<c0258ffc>] (vfs_kern_mount) from [<c0331f74>] (nfs_do_root_mount+0x80/0xa0)
[   63.608092] [<c0331f74>] (nfs_do_root_mount) from [<c0332260>] (nfs4_try_mount+0x28/0x3c)
[   63.608105] [<c0332260>] (nfs4_try_mount) from [<c0312014>] (nfs_fs_mount+0x2e0/0x8ec)
[   63.608121] [<c0312014>] (nfs_fs_mount) from [<c023b66c>] (mount_fs+0x14/0xa4)
[   63.608135] [<c023b66c>] (mount_fs) from [<c0258ffc>] (vfs_kern_mount+0x54/0x128)
[   63.608150] [<c0258ffc>] (vfs_kern_mount) from [<c025c54c>] (do_mount+0x158/0xc7c)
[   63.608164] [<c025c54c>] (do_mount) from [<c025d3f4>] (SyS_mount+0x8c/0xb4)
[   63.608181] [<c025d3f4>] (SyS_mount) from [<c0107840>] (ret_fast_syscall+0x0/0x3c)
[   63.711978] Unregistering bdi 0:32
[   63.712008] CPU: 1 PID: 2419 Comm: mount.nfs Not tainted 4.11.0-next-20170502+ #100
[   63.712016] Hardware name: Allwinner sun7i (A20) Family
[   63.712054] [<c010f268>] (unwind_backtrace) from [<c010bd38>] (show_stack+0x10/0x14)
[   63.712072] [<c010bd38>] (show_stack) from [<c03c7b68>] (dump_stack+0x78/0x8c)
[   63.712091] [<c03c7b68>] (dump_stack) from [<c0204120>] (bdi_unregister+0x34/0x18c)
[   63.712107] [<c0204120>] (bdi_unregister) from [<c020436c>] (bdi_put+0xf4/0x13c)
[   63.712124] [<c020436c>] (bdi_put) from [<c0239728>] (generic_shutdown_super+0xdc/0xf8)
[   63.712143] [<c0239728>] (generic_shutdown_super) from [<c0311cc4>] (nfs_kill_super+0x14/0x30)
[   63.712160] [<c0311cc4>] (nfs_kill_super) from [<c0239e9c>] (deactivate_locked_super+0x58/0x7c)
[   63.712176] [<c0239e9c>] (deactivate_locked_super) from [<c025945c>] (cleanup_mnt+0x38/0x7c)
[   63.712192] [<c025945c>] (cleanup_mnt) from [<c013fd9c>] (task_work_run+0xc4/0xf8)
[   63.712209] [<c013fd9c>] (task_work_run) from [<c010b61c>] (do_work_pending+0x7c/0xa4)
[   63.712225] [<c010b61c>] (do_work_pending) from [<c0107894>] (slow_work_pending+0xc/0x20)
[   63.795383] Registering bdi 0:32 for server edd49800
[   63.795409] CPU: 1 PID: 2419 Comm: mount.nfs Not tainted 4.11.0-next-20170502+ #100
[   63.795417] Hardware name: Allwinner sun7i (A20) Family
[   63.795455] [<c010f268>] (unwind_backtrace) from [<c010bd38>] (show_stack+0x10/0x14)
[   63.795475] [<c010bd38>] (show_stack) from [<c03c7b68>] (dump_stack+0x78/0x8c)
[   63.795496] [<c03c7b68>] (dump_stack) from [<c0311664>] (nfs_fill_super+0x1a8/0x224)
[   63.795513] [<c0311664>] (nfs_fill_super) from [<c0311b7c>] (nfs_fs_mount_common+0x140/0x1e8)
[   63.795528] [<c0311b7c>] (nfs_fs_mount_common) from [<c0312834>] (nfs_try_mount+0x110/0x268)
[   63.795543] [<c0312834>] (nfs_try_mount) from [<c0312014>] (nfs_fs_mount+0x2e0/0x8ec)
[   63.795561] [<c0312014>] (nfs_fs_mount) from [<c023b66c>] (mount_fs+0x14/0xa4)
[   63.795578] [<c023b66c>] (mount_fs) from [<c0258ffc>] (vfs_kern_mount+0x54/0x128)
[   63.795594] [<c0258ffc>] (vfs_kern_mount) from [<c025c54c>] (do_mount+0x158/0xc7c)
[   63.795609] [<c025c54c>] (do_mount) from [<c025d3f4>] (SyS_mount+0x8c/0xb4)
[   63.795626] [<c025d3f4>] (SyS_mount) from [<c0107840>] (ret_fast_syscall+0x0/0x3c)
[   63.862429] Registering bdi 0:33 for server edd4a400
[   63.862455] CPU: 1 PID: 2429 Comm: mount.nfs Not tainted 4.11.0-next-20170502+ #100
[   63.862463] Hardware name: Allwinner sun7i (A20) Family
[   63.862502] [<c010f268>] (unwind_backtrace) from [<c010bd38>] (show_stack+0x10/0x14)
[   63.862521] [<c010bd38>] (show_stack) from [<c03c7b68>] (dump_stack+0x78/0x8c)
[   63.862541] [<c03c7b68>] (dump_stack) from [<c0311664>] (nfs_fill_super+0x1a8/0x224)
[   63.862560] [<c0311664>] (nfs_fill_super) from [<c0311b7c>] (nfs_fs_mount_common+0x140/0x1e8)
[   63.862575] [<c0311b7c>] (nfs_fs_mount_common) from [<c0332014>] (nfs4_remote_mount+0x50/0x58)
[   63.862593] [<c0332014>] (nfs4_remote_mount) from [<c023b66c>] (mount_fs+0x14/0xa4)
[   63.862611] [<c023b66c>] (mount_fs) from [<c0258ffc>] (vfs_kern_mount+0x54/0x128)
[   63.862628] [<c0258ffc>] (vfs_kern_mount) from [<c0331f74>] (nfs_do_root_mount+0x80/0xa0)
[   63.862643] [<c0331f74>] (nfs_do_root_mount) from [<c0332260>] (nfs4_try_mount+0x28/0x3c)
[   63.862657] [<c0332260>] (nfs4_try_mount) from [<c0312014>] (nfs_fs_mount+0x2e0/0x8ec)
[   63.862672] [<c0312014>] (nfs_fs_mount) from [<c023b66c>] (mount_fs+0x14/0xa4)
[   63.862686] [<c023b66c>] (mount_fs) from [<c0258ffc>] (vfs_kern_mount+0x54/0x128)
[   63.862701] [<c0258ffc>] (vfs_kern_mount) from [<c025c54c>] (do_mount+0x158/0xc7c)
[   63.862716] [<c025c54c>] (do_mount) from [<c025d3f4>] (SyS_mount+0x8c/0xb4)
[   63.862732] [<c025d3f4>] (SyS_mount) from [<c0107840>] (ret_fast_syscall+0x0/0x3c)
[   64.094628] Registering bdi 0:33 for server edc87800
[   64.094655] CPU: 1 PID: 2437 Comm: mount.nfs Not tainted 4.11.0-next-20170502+ #100
[   64.094663] Hardware name: Allwinner sun7i (A20) Family
[   64.094702] [<c010f268>] (unwind_backtrace) from [<c010bd38>] (show_stack+0x10/0x14)
[   64.094722] [<c010bd38>] (show_stack) from [<c03c7b68>] (dump_stack+0x78/0x8c)
[   64.094742] [<c03c7b68>] (dump_stack) from [<c0311664>] (nfs_fill_super+0x1a8/0x224)
[   64.094760] [<c0311664>] (nfs_fill_super) from [<c0311b7c>] (nfs_fs_mount_common+0x140/0x1e8)
[   64.094777] [<c0311b7c>] (nfs_fs_mount_common) from [<c0332014>] (nfs4_remote_mount+0x50/0x58)
[   64.094794] [<c0332014>] (nfs4_remote_mount) from [<c023b66c>] (mount_fs+0x14/0xa4)
[   64.094812] [<c023b66c>] (mount_fs) from [<c0258ffc>] (vfs_kern_mount+0x54/0x128)
[   64.094829] [<c0258ffc>] (vfs_kern_mount) from [<c0331f74>] (nfs_do_root_mount+0x80/0xa0)
[   64.094844] [<c0331f74>] (nfs_do_root_mount) from [<c0332260>] (nfs4_try_mount+0x28/0x3c)
[   64.094858] [<c0332260>] (nfs4_try_mount) from [<c0312014>] (nfs_fs_mount+0x2e0/0x8ec)
[   64.094873] [<c0312014>] (nfs_fs_mount) from [<c023b66c>] (mount_fs+0x14/0xa4)
[   64.094888] [<c023b66c>] (mount_fs) from [<c0258ffc>] (vfs_kern_mount+0x54/0x128)
[   64.094902] [<c0258ffc>] (vfs_kern_mount) from [<c025c54c>] (do_mount+0x158/0xc7c)
[   64.094917] [<c025c54c>] (do_mount) from [<c025d3f4>] (SyS_mount+0x8c/0xb4)
[   64.094934] [<c025d3f4>] (SyS_mount) from [<c0107840>] (ret_fast_syscall+0x0/0x3c)
[   64.095053] ------------[ cut here ]------------
[   64.095072] WARNING: CPU: 1 PID: 2437 at /mnt/linux-next/fs/sysfs/dir.c:31 sysfs_warn_dup+0x64/0x74
[   64.095081] sysfs: cannot create duplicate filename '/devices/virtual/bdi/0:33'
[   64.095088] Modules linked in: axp20x_usb_power axp20x_ac_power axp20x_adc gpio_axp209 nvmem_sunxi_sid sun4i_dma sun4i_ss virt_dma
[   64.095154] CPU: 1 PID: 2437 Comm: mount.nfs Not tainted 4.11.0-next-20170502+ #100
[   64.095162] Hardware name: Allwinner sun7i (A20) Family
[   64.095179] [<c010f268>] (unwind_backtrace) from [<c010bd38>] (show_stack+0x10/0x14)
[   64.095194] [<c010bd38>] (show_stack) from [<c03c7b68>] (dump_stack+0x78/0x8c)
[   64.095210] [<c03c7b68>] (dump_stack) from [<c01222d4>] (__warn+0xe8/0x100)
[   64.095224] [<c01222d4>] (__warn) from [<c0122324>] (warn_slowpath_fmt+0x38/0x48)
[   64.095240] [<c0122324>] (warn_slowpath_fmt) from [<c02a8d4c>] (sysfs_warn_dup+0x64/0x74)
[   64.095256] [<c02a8d4c>] (sysfs_warn_dup) from [<c02a8e28>] (sysfs_create_dir_ns+0x84/0x94)
[   64.095273] [<c02a8e28>] (sysfs_create_dir_ns) from [<c03c98d0>] (kobject_add_internal+0x9c/0x2ec)
[   64.095290] [<c03c98d0>] (kobject_add_internal) from [<c03c9b68>] (kobject_add+0x48/0x98)
[   64.095309] [<c03c9b68>] (kobject_add) from [<c048f7bc>] (device_add+0xe4/0x5a0)
[   64.095326] [<c048f7bc>] (device_add) from [<c048fe14>] (device_create_groups_vargs+0xac/0xbc)
[   64.095341] [<c048fe14>] (device_create_groups_vargs) from [<c048fe44>] (device_create_vargs+0x20/0x28)
[   64.095358] [<c048fe44>] (device_create_vargs) from [<c0203ab0>] (bdi_register_va+0x44/0xfc)
[   64.095375] [<c0203ab0>] (bdi_register_va) from [<c0239a4c>] (super_setup_bdi_name+0x44/0xa0)
[   64.095393] [<c0239a4c>] (super_setup_bdi_name) from [<c0311680>] (nfs_fill_super+0x1c4/0x224)
[   64.095409] [<c0311680>] (nfs_fill_super) from [<c0311b7c>] (nfs_fs_mount_common+0x140/0x1e8)
[   64.095423] [<c0311b7c>] (nfs_fs_mount_common) from [<c0332014>] (nfs4_remote_mount+0x50/0x58)
[   64.095437] [<c0332014>] (nfs4_remote_mount) from [<c023b66c>] (mount_fs+0x14/0xa4)
[   64.095451] [<c023b66c>] (mount_fs) from [<c0258ffc>] (vfs_kern_mount+0x54/0x128)
[   64.095467] [<c0258ffc>] (vfs_kern_mount) from [<c0331f74>] (nfs_do_root_mount+0x80/0xa0)
[   64.095482] [<c0331f74>] (nfs_do_root_mount) from [<c0332260>] (nfs4_try_mount+0x28/0x3c)
[   64.095496] [<c0332260>] (nfs4_try_mount) from [<c0312014>] (nfs_fs_mount+0x2e0/0x8ec)
[   64.095511] [<c0312014>] (nfs_fs_mount) from [<c023b66c>] (mount_fs+0x14/0xa4)
[   64.095525] [<c023b66c>] (mount_fs) from [<c0258ffc>] (vfs_kern_mount+0x54/0x128)
[   64.095538] [<c0258ffc>] (vfs_kern_mount) from [<c025c54c>] (do_mount+0x158/0xc7c)
[   64.095553] [<c025c54c>] (do_mount) from [<c025d3f4>] (SyS_mount+0x8c/0xb4)
[   64.095568] [<c025d3f4>] (SyS_mount) from [<c0107840>] (ret_fast_syscall+0x0/0x3c)
[   64.095577] ---[ end trace 5cd276530ddd30a7 ]---
[   64.095588] ------------[ cut here ]------------
[   64.095603] WARNING: CPU: 1 PID: 2437 at /mnt/linux-next/lib/kobject.c:240 kobject_add_internal+0x274/0x2ec
[   64.095612] kobject_add_internal failed for 0:33 with -EEXIST, don't try to register things with the same name in the same directory.
[   64.095618] Modules linked in: axp20x_usb_power axp20x_ac_power axp20x_adc gpio_axp209 nvmem_sunxi_sid sun4i_dma sun4i_ss virt_dma
[   64.095679] CPU: 1 PID: 2437 Comm: mount.nfs Tainted: G        W       4.11.0-next-20170502+ #100
[   64.095687] Hardware name: Allwinner sun7i (A20) Family
[   64.095702] [<c010f268>] (unwind_backtrace) from [<c010bd38>] (show_stack+0x10/0x14)
[   64.095716] [<c010bd38>] (show_stack) from [<c03c7b68>] (dump_stack+0x78/0x8c)
[   64.095730] [<c03c7b68>] (dump_stack) from [<c01222d4>] (__warn+0xe8/0x100)
[   64.095743] [<c01222d4>] (__warn) from [<c0122324>] (warn_slowpath_fmt+0x38/0x48)
[   64.095758] [<c0122324>] (warn_slowpath_fmt) from [<c03c9aa8>] (kobject_add_internal+0x274/0x2ec)
[   64.095775] [<c03c9aa8>] (kobject_add_internal) from [<c03c9b68>] (kobject_add+0x48/0x98)
[   64.095790] [<c03c9b68>] (kobject_add) from [<c048f7bc>] (device_add+0xe4/0x5a0)
[   64.095806] [<c048f7bc>] (device_add) from [<c048fe14>] (device_create_groups_vargs+0xac/0xbc)
[   64.095821] [<c048fe14>] (device_create_groups_vargs) from [<c048fe44>] (device_create_vargs+0x20/0x28)
[   64.095836] [<c048fe44>] (device_create_vargs) from [<c0203ab0>] (bdi_register_va+0x44/0xfc)
[   64.095851] [<c0203ab0>] (bdi_register_va) from [<c0239a4c>] (super_setup_bdi_name+0x44/0xa0)
[   64.095868] [<c0239a4c>] (super_setup_bdi_name) from [<c0311680>] (nfs_fill_super+0x1c4/0x224)
[   64.095883] [<c0311680>] (nfs_fill_super) from [<c0311b7c>] (nfs_fs_mount_common+0x140/0x1e8)
[   64.095897] [<c0311b7c>] (nfs_fs_mount_common) from [<c0332014>] (nfs4_remote_mount+0x50/0x58)
[   64.095911] [<c0332014>] (nfs4_remote_mount) from [<c023b66c>] (mount_fs+0x14/0xa4)
[   64.095926] [<c023b66c>] (mount_fs) from [<c0258ffc>] (vfs_kern_mount+0x54/0x128)
[   64.095940] [<c0258ffc>] (vfs_kern_mount) from [<c0331f74>] (nfs_do_root_mount+0x80/0xa0)
[   64.095955] [<c0331f74>] (nfs_do_root_mount) from [<c0332260>] (nfs4_try_mount+0x28/0x3c)
[   64.095969] [<c0332260>] (nfs4_try_mount) from [<c0312014>] (nfs_fs_mount+0x2e0/0x8ec)
[   64.095984] [<c0312014>] (nfs_fs_mount) from [<c023b66c>] (mount_fs+0x14/0xa4)
[   64.095999] [<c023b66c>] (mount_fs) from [<c0258ffc>] (vfs_kern_mount+0x54/0x128)
[   64.096012] [<c0258ffc>] (vfs_kern_mount) from [<c025c54c>] (do_mount+0x158/0xc7c)
[   64.096026] [<c025c54c>] (do_mount) from [<c025d3f4>] (SyS_mount+0x8c/0xb4)
[   64.096041] [<c025d3f4>] (SyS_mount) from [<c0107840>] (ret_fast_syscall+0x0/0x3c)
[   64.096049] ---[ end trace 5cd276530ddd30a8 ]---

