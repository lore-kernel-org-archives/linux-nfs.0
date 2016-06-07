Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:48884 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752632AbcFGPhl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 11:37:41 -0400
From: Oleg Drokin <green@linuxhacker.ru>
Content-Type: text/plain; charset=us-ascii
Subject: Files leak from nfsd in 4.7.1-rc1 (and more?)
Date: Tue, 7 Jun 2016 11:37:32 -0400
Message-Id: <4EDA6CFD-1FE8-4FCA-ACCF-84250BE342CB@linuxhacker.ru>
Cc: linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v1283)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

   I've been trying to better understand this problem I was having where sometimes
   a formerly NFS-exported mountpoint becomes unmountable (after nfsd stop).

   I finally traced it to a leaked filedescriptor that was allocated from
   nfsd4_open()->nfsd4_process_open2()->nfs4_get_vfs_file()->nfsd_open().

   Also together with it we see leaked credentials allocated along the same path from
   fh_verify() and groups allocated from svcauth_unix_accept()->groups_alloc() that
   are presumably used by the credentials.

   Unfortunately I was not able to make total sense out of the state handling in nfsd,
   but it's clear that one of the file descriptors inside struct nfs4_file is
   lost. I added a patch like this (always a good idea, so surprised it was not
   there already):
@@ -271,6 +274,9 @@ static void nfsd4_free_file_rcu(struct rcu_head *rcu)
 {
        struct nfs4_file *fp = container_of(rcu, struct nfs4_file, fi_rcu);
 
+       WARN_ON(fp->fi_fds[0]);
+       WARN_ON(fp->fi_fds[1]);
+       WARN_ON(fp->fi_fds[2]);
        kmem_cache_free(file_slab, fp);
 }

   And when the problem is hit, I am also triggering (Always this one which is fd[1])
[ 3588.143002] ------------[ cut here ]------------
[ 3588.143662] WARNING: CPU: 5 PID: 9 at /home/green/bk/linux/fs/nfsd/nfs4state.c:278 nfsd4_free_file_rcu+0x65/0x80 [nfsd]
[ 3588.144947] Modules linked in: loop rpcsec_gss_krb5 joydev acpi_cpufreq tpm_tis i2c_piix4 tpm virtio_console pcspkr nfsd ttm drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm floppy serio_raw virtio_blk
[ 3588.147135] CPU: 5 PID: 9 Comm: rcuos/0 Not tainted 4.7.0-rc1-vm-nfs+ #120
[ 3588.153826] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 3588.153830]  0000000000000286 00000000e2d5ccdf ffff88011965bd50 ffffffff814a11a5
[ 3588.153832]  0000000000000000 0000000000000000 ffff88011965bd90 ffffffff8108806b
[ 3588.153834]  0000011600000000 ffff8800c476a0b8 ffff8800c476a048 ffffffffc0110fc0
[ 3588.153834] Call Trace:
[ 3588.153839]  [<ffffffff814a11a5>] dump_stack+0x86/0xc1
[ 3588.153841]  [<ffffffff8108806b>] __warn+0xcb/0xf0
[ 3588.153852]  [<ffffffffc0110fc0>] ? trace_raw_output_fh_want_write+0x60/0x60 [nfsd]
[ 3588.153853]  [<ffffffff8108819d>] warn_slowpath_null+0x1d/0x20
[ 3588.153859]  [<ffffffffc0111025>] nfsd4_free_file_rcu+0x65/0x80 [nfsd]
[ 3588.153861]  [<ffffffff81109c65>] rcu_nocb_kthread+0x335/0x510
[ 3588.153862]  [<ffffffff81109baf>] ? rcu_nocb_kthread+0x27f/0x510
[ 3588.153863]  [<ffffffff81109930>] ? rcu_cpu_notify+0x3e0/0x3e0
[ 3588.153866]  [<ffffffff810af391>] kthread+0x101/0x120
[ 3588.153868]  [<ffffffff810e6c84>] ? trace_hardirqs_on_caller+0xf4/0x1b0
[ 3588.153871]  [<ffffffff8188b6af>] ret_from_fork+0x1f/0x40
[ 3588.153872]  [<ffffffff810af290>] ? kthread_create_on_node+0x250/0x250


  release_all_access() seems to be doing correct job of all that cleaning, so
  there must be some other path that I do not quite see.

  Hopefully you are more familiar with the code and can see the problem right away ;)

Bye,
    Oleg