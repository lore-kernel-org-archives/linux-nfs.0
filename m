Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34206 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751264AbdECLo6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 May 2017 07:44:58 -0400
Date: Wed, 3 May 2017 13:44:54 +0200
From: Jan Kara <jack@suse.cz>
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Cc: Jan Kara <jack@suse.cz>, anna.schumaker@netapp.com, hch@lst.de,
        trond.myklebust@primarydata.com, axboe@fb.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [BUG] cannot mount nfs, bisected to 0db10944a76ba ("nfs: Convert
 to separately allocated bdi")
Message-ID: <20170503114454.GE10084@quack2.suse.cz>
References: <20170428095624.GA22965@Red>
 <20170502162704.GM13916@quack2.suse.cz>
 <20170502172222.GA28711@Red>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ZGiS0Q5IWpPtfppv"
In-Reply-To: <20170502172222.GA28711@Red>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue 02-05-17 19:22:22, Corentin Labbe wrote:
> On Tue, May 02, 2017 at 06:27:04PM +0200, Jan Kara wrote:
> > Hello,
> > 
> > On Fri 28-04-17 11:56:24, Corentin Labbe wrote:
> > > Since linux next-20170421, mounting nfs give me:
> > > [  774.994934] ------------[ cut here ]------------
> > > [  774.994975] WARNING: CPU: 1 PID: 10284 at /linux-next/fs/sysfs/dir.c:31 sysfs_warn_dup+0x64/0x74
> > > [  774.994985] sysfs: cannot create duplicate filename '/devices/virtual/bdi/0:32'
> > > [  774.994992] Modules linked in: axp20x_usb_power gpio_axp209 nvmem_sunxi_sid sun4i_dma sun4i_ss virt_dma
> > > [  774.995047] CPU: 1 PID: 10284 Comm: mount.nfs Not tainted 4.11.0-rc4+ #14
> > > [  774.995054] Hardware name: Allwinner sun7i (A20) Family
> > > [  774.995085] [<c010f19c>] (unwind_backtrace) from [<c010bc74>] (show_stack+0x10/0x14)
> > > [  774.995104] [<c010bc74>] (show_stack) from [<c03c6e24>] (dump_stack+0x78/0x8c)
> > > [  774.995121] [<c03c6e24>] (dump_stack) from [<c0122200>] (__warn+0xe8/0x100)
> > > [  774.995135] [<c0122200>] (__warn) from [<c0122250>] (warn_slowpath_fmt+0x38/0x48)
> > > [  774.995150] [<c0122250>] (warn_slowpath_fmt) from [<c02ac178>] (sysfs_warn_dup+0x64/0x74)
> > > [  774.995167] [<c02ac178>] (sysfs_warn_dup) from [<c02ac254>] (sysfs_create_dir_ns+0x84/0x94)
> > > [  774.995184] [<c02ac254>] (sysfs_create_dir_ns) from [<c03c8b8c>] (kobject_add_internal+0x9c/0x2ec)
> > > [  774.995199] [<c03c8b8c>] (kobject_add_internal) from [<c03c8e24>] (kobject_add+0x48/0x98)
> > > [  774.995217] [<c03c8e24>] (kobject_add) from [<c048d75c>] (device_add+0xe4/0x5a0)
> > > [  774.995232] [<c048d75c>] (device_add) from [<c048ddb4>] (device_create_groups_vargs+0xac/0xbc)
> > > [  774.995247] [<c048ddb4>] (device_create_groups_vargs) from [<c048dde4>] (device_create_vargs+0x20/0x28)
> > > [  774.995263] [<c048dde4>] (device_create_vargs) from [<c02075c8>] (bdi_register_va+0x44/0xfc)
> > > [  774.995280] [<c02075c8>] (bdi_register_va) from [<c023d378>] (super_setup_bdi_name+0x48/0xa4)
> > > [  774.995299] [<c023d378>] (super_setup_bdi_name) from [<c0312ef4>] (nfs_fill_super+0x1a4/0x204)
> > > [  774.995315] [<c0312ef4>] (nfs_fill_super) from [<c03133f0>] (nfs_fs_mount_common+0x140/0x1e8)
> > > [  774.995333] [<c03133f0>] (nfs_fs_mount_common) from [<c03335cc>] (nfs4_remote_mount+0x50/0x58)
> > > [  774.995349] [<c03335cc>] (nfs4_remote_mount) from [<c023ef98>] (mount_fs+0x14/0xa4)
> > > [  774.995368] [<c023ef98>] (mount_fs) from [<c025cba0>] (vfs_kern_mount+0x54/0x128)
> > > [  774.995385] [<c025cba0>] (vfs_kern_mount) from [<c033352c>] (nfs_do_root_mount+0x80/0xa0)
> > > [  774.995400] [<c033352c>] (nfs_do_root_mount) from [<c0333818>] (nfs4_try_mount+0x28/0x3c)
> > > [  774.995415] [<c0333818>] (nfs4_try_mount) from [<c0313874>] (nfs_fs_mount+0x2cc/0x8c4)
> > > [  774.995430] [<c0313874>] (nfs_fs_mount) from [<c023ef98>] (mount_fs+0x14/0xa4)
> > > [  774.995445] [<c023ef98>] (mount_fs) from [<c025cba0>] (vfs_kern_mount+0x54/0x128)
> > > [  774.995461] [<c025cba0>] (vfs_kern_mount) from [<c02600f0>] (do_mount+0x158/0xc7c)
> > > [  774.995475] [<c02600f0>] (do_mount) from [<c0260f98>] (SyS_mount+0x8c/0xb4)
> > > [  774.995491] [<c0260f98>] (SyS_mount) from [<c0107840>] (ret_fast_syscall+0x0/0x3c)
> > > [  774.995501] ---[ end trace 0665e451f8864ff0 ]---
> > ...
> > > The mount command is
> > > mount -t nfs -o tcp,hard,intr,async,rsize=4096,wsize=4096 192.168.1.100:/mnt/local_kernel /usr/src/
> > > 
> > > the mount command failling with: "mount.nfs: Cannot allocate memory"
> > 
> > I've tried reproducing this (both with NFSv3 and NFSv4) and failed. Also I
> > have looked through the code and I fail to see how this could happen. Is
> > this the only NFS mount that you have on your system? Didn't also the
> > WARN_ON in super_setup_bdi_name() trigger?
> > 
> > Can you run with the attached debug patch and post full dmesg after the
> > failure?
> > 
> 
> Hello
> 
> I forgot to said that I have 6 nfs mount point.
> mount -t nfs -o ro,tcp,hard,intr,async,vers=3 192.168.1.100:/usr/portage /usr/portage/
> mount -t nfs -o tcp,hard,intr,async,vers=3 192.168.1.100:/usr/local/portage /usr/local/portage/
> mount -t nfs -o tcp,hard,intr,async,vers=3 192.168.1.100:/mnt/tempo/portages/distfiles /usr/portage/distfiles
> mount -t nfs -o tcp,hard,intr,async,vers=4 192.168.1.100:/mnt/tempo/portages/cubiedev/packages /usr/portage/packages
> mount -t nfs -o tcp,hard,intr,async,vers=4,rsize=4096,wsize=4096 192.168.1.100:/var/tmp/portage/cubie /var/tmp/portage/
> mount -t nfs -o tcp,hard,intr,async,rsize=4096,wsize=4096 192.168.1.100:/mnt/tempo/cubie/local_kernel /usr/src/
> 
> It's always the last which fail, but strangely inverting the two last
> made everything ok.

Thanks for more info and the debug data. I still was not able to reproduce
the issue but after pondering my head on this for some time I have found a
bug in NFS conversion which can possibly cause the behavior you observe.
Does the attached patch fix the problem for you?

If it does not, can you also post /proc/mounts and /etc/exports from you
NFS server?

								Honza


-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--ZGiS0Q5IWpPtfppv
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-nfs-Fix-bdi-handling-for-cloned-superblocks.patch"


--ZGiS0Q5IWpPtfppv--
