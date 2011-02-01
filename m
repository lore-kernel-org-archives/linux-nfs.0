Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:35804 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752348Ab1BAMO7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Feb 2011 07:14:59 -0500
Date: Tue, 1 Feb 2011 13:14:57 +0100
From: Jan Kara <jack@suse.cz>
To: Jesper Krogh <jesper@krogh.cc>
Cc: linux-kernel@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>, jack@suse.cz
Subject: Re: sync hangs - 2.6.35.10
Message-ID: <20110201121457.GA2059@quack.suse.cz>
References: <4D47A99A.6050204@krogh.cc>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D47A99A.6050204@krogh.cc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  Hello,

On Tue 01-02-11 07:35:06, Jesper Krogh wrote:
> I've just setup a 48 core server with 128GB of memory in a typical
> HPC setup. The only IO-activity happens over NFS and the applications
> are cpu-hogs.
> 
> The system is fully working and everthing looks apparently fine, but
> anything that issue a sync is hung for eternity.
> 
> root fs is ext4 and it appears that sync hitting that drive get hung due
> to some other things going on. There is only logging activity on
> that drive.
  OK, if that logging activity is continuous, then it would explain the
issue.

> [  508.778695] Btrfs loaded
> [ 7208.780233] INFO: task grub-probe:14787 blocked for more than 120
> seconds.
> [ 7208.780316] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> disables this message.
> [ 7208.780397] grub-probe    D 0000000000000000     0 14787  14768
> 0x00000000
> [ 7208.780402]  ffff882005f8fbb8 0000000000000086 ffff882000000000
> 0000000000015880
> [ 7208.780406]  ffff882005f8ffd8 0000000000015880 ffff882005f8ffd8
> ffff88200cd70000
> [ 7208.780410]  0000000000015880 0000000000015880 ffff882005f8ffd8
> 0000000000015880
> [ 7208.780413] Call Trace:
> [ 7208.780424]  [<ffffffff8155d3cd>] schedule_timeout+0x22d/0x310
> [ 7208.780430]  [<ffffffff8102ccae>] ? physflat_send_IPI_mask+0xe/0x10
> [ 7208.780433]  [<ffffffff8155c666>] wait_for_common+0xd6/0x180
> [ 7208.780439]  [<ffffffff810533b0>] ? default_wake_function+0x0/0x20
> [ 7208.780441]  [<ffffffff8155c7ed>] wait_for_completion+0x1d/0x20
> [ 7208.780446]  [<ffffffff81160ff3>] writeback_inodes_sb+0xb3/0xe0
> [ 7208.780449]  [<ffffffff81165c4e>] __sync_filesystem+0x4e/0xa0
> [ 7208.780452]  [<ffffffff81165d7a>] sync_filesystem+0x3a/0x70
> [ 7208.780456]  [<ffffffff8116f9fe>] fsync_bdev+0x2e/0x60
> [ 7208.780460]  [<ffffffff8128e5ce>] blkdev_ioctl+0x4ee/0x820
> [ 7208.780463]  [<ffffffff8116dfcc>] block_ioctl+0x3c/0x40
> [ 7208.780468]  [<ffffffff8114edad>] vfs_ioctl+0x3d/0xd0
> [ 7208.780471]  [<ffffffff8114f3b8>] do_vfs_ioctl+0x88/0x540
> [ 7208.780475]  [<ffffffff811586fa>] ? alloc_fd+0x10a/0x150
> [ 7208.780478]  [<ffffffff8114f8f1>] sys_ioctl+0x81/0xa0
> [ 7208.780483]  [<ffffffff8100a032>] system_call_fastpath+0x16/0x1b
> 
> Full dmesg here: http://shrek.krogh.cc/~jesper/bonnie-dmesg.txt
> 
> It seems like the problems about broken sync writeback discussed
> about a year ago .. last discussions in late january this year.
> 
> http://thread.gmane.org/gmane.linux.kernel/949268/focus=1090266
> 
> Any patches that may be relevant?
  Definitely. There have been several patches fixing livelock issues
in this area under various conditions. Considering your use case, you
might be hit by problems being fixed by commits:
6585027a5e8cb490e3a761b2f3f3c3acf722aff2
aa373cf550994623efb5d49a4d8775bafd10bbc1
b9543dac5bbc4aef0a598965b6b34f6259ab9a9b
(went into 2.6.38-rc1)

possibly also older
7624ee72aa09334af072853457a5d46d9901c3f8
(in 2.6.36-rc1)

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
