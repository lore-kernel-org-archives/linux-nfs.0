Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6137C282CA
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 19:43:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7980F222C0
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 19:43:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550000597;
	bh=yQ7uRzWlIxmQe989j7CReWIOtuQNrLwAZaW9thRmk8M=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=Htu0tzeSdCHRHIwxES9VzYnTvTKKisJEPdABsDwBmos6UDppl4iN3haOjvG7PlcMt
	 9edUywkhxPpD7NSB5HFXk1ct4q7TRFjf1seDiypA7UZly0eB4c9aSnEBUTfQBdZfxt
	 0MgSzSr59NQIGrdBeXqgE40CmtjVO4QtP8U5yA0s=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731164AbfBLTnQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 14:43:16 -0500
Received: from mail.kernel.org ([198.145.29.99]:42614 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727343AbfBLTnP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 14:43:15 -0500
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id EE85C222C7;
        Tue, 12 Feb 2019 19:43:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1550000594;
        bh=yQ7uRzWlIxmQe989j7CReWIOtuQNrLwAZaW9thRmk8M=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=jwgctArCjNfhQe7LXkvPRdQu+Z/1uC4tjUMTASBJVvtzkKM+sL0J6dcOevCLKyrVM
         yejJTl7nndCeebO4fgfuN5yHCLE25WFYgbQuko4YzmZyi8ygab76Lydf4yq0HgVvhR
         GQHA43oCHtPzpu26eCSPGq43NtsTaCdnSf8egAYA=
Date:   Tue, 12 Feb 2019 20:43:11 +0100
From:   Greg KH <gregkh@linuxfoundation.org>
To:     Murphy Zhou <jencce.kernel@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [v5.0-rc3 regression] Oops when starting nfs service
Message-ID: <20190212194311.GB3471@kroah.com>
References: <20190212162157.GA27459@sh-el5.eng.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212162157.GA27459@sh-el5.eng.rdu2.redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 12, 2019 at 11:21:57AM -0500, Murphy Zhou wrote:
> Hi,
> 
> Starting nfs-server service can crash the kernel since
> commit ff9fb72bc07705c00795ca48631f7fffe24d2c6b
> Author: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Date:   Wed Jan 23 11:28:14 2019 +0100
> 
>     debugfs: return error values, not NULL
> 
> # git describe ff9fb72bc07705c00795ca48631f7fffe24d2c6b
> v5.0-rc2-3-gff9fb72bc077
> 
> Reverting this commit prevents the crash.
> 
> It can be reproduced simply by:
> # systemctl start nfs-server
> 
> Thanks.
> 
> # bisect log
> #
> git bisect start
> # good: [74e96711e3379fc66630f2a1d184947f80cf2c48] Merge tag 'platform-drivers-x86-v5.0-2' of git://git.infradead.org/linux-platform-drivers-x86
> git bisect good 74e96711e3379fc66630f2a1d184947f80cf2c48
> # bad: [27b4ad621e887ce8e5eb508a0103f13d30f6b38a] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> git bisect bad 27b4ad621e887ce8e5eb508a0103f13d30f6b38a
> # good: [bdcc5bc25548ef6b08e2e43937148f907c212292] mISDN: fix a race in dev_expire_timer()
> git bisect good bdcc5bc25548ef6b08e2e43937148f907c212292
> # good: [e22a15d1c4b36877934ab360aace41ddf8a6577c] Merge tag 'tty-5.0-rc6' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/tty
> git bisect good e22a15d1c4b36877934ab360aace41ddf8a6577c
> # bad: [680905431b9de8c7224b15b76b1826a1481cfeaf] Merge tag 'char-misc-5.0-rc6' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/char-misc
> git bisect bad 680905431b9de8c7224b15b76b1826a1481cfeaf
> # bad: [8c8e62cc983938a554d39497b5600b842f8a7965] Merge tag 'driver-core-5.0-rc6' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core
> git bisect bad 8c8e62cc983938a554d39497b5600b842f8a7965
> # good: [6d923f8fe821c0c6b5378635cbcc9da5f5ec520a] Merge tag 'iio-fixes-5.0a' of git://git.kernel.org/pub/scm/linux/kernel/git/jic23/iio into staging-linus
> git bisect good 6d923f8fe821c0c6b5378635cbcc9da5f5ec520a
> # bad: [37ea7b630ae5cdea4e8ff381d9d23abfef5939e6] debugfs: debugfs_lookup() should return NULL if not found
> git bisect bad 37ea7b630ae5cdea4e8ff381d9d23abfef5939e6
> # good: [d88c93f090f708c18195553b352b9f205e65418f] debugfs: fix debugfs_rename parameter checking
> git bisect good d88c93f090f708c18195553b352b9f205e65418f
> # bad: [ff9fb72bc07705c00795ca48631f7fffe24d2c6b] debugfs: return error values, not NULL
> git bisect bad ff9fb72bc07705c00795ca48631f7fffe24d2c6b
> # first bad commit: [ff9fb72bc07705c00795ca48631f7fffe24d2c6b] debugfs: return error values, not NULL
> [
> 
> # call trace
> #
> [ 9082.260783] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> [ 9082.442808] NFSD: starting 45-second grace period (net f00000a8)
> [ 9082.533649] BUG: unable to handle kernel NULL pointer dereference at 000000000000001b
> [ 9082.569586] #PF error: [normal kernel read fault]
> [ 9082.591405] PGD 0 P4D 0
> [ 9082.602752] Oops: 0000 [#1] SMP PTI
> [ 9082.618820] CPU: 9 PID: 1183 Comm: gssproxy Not tainted 5.0.0-rc6-master-aa0c38cf39de+ #11
> [ 9082.656683] Hardware name: HP ProLiant DL388p Gen8, BIOS P70 09/18/2013
> [ 9082.686695] RIP: 0010:rpc_clnt_debugfs_register+0xb4/0x120 [sunrpc]
> [ 9082.715173] Code: be 00 81 00 00 48 c7 c7 be b0 5e c0 e8 f5 13 79 e4 48 85 c0 74 31 48 8b 43 30 48 8b 80 f0 04 00 00 48 85 c0 0f 84 70 ff ff ff <48> 8b 48 28 48 c7 c2 c4 b0 5e c0 be 18 00 00 00 48 89 e7 e8 54 78
> [ 9082.800976] RSP: 0018:ffffadd344c97b68 EFLAGS: 00010286
> [ 9082.824946] RAX: fffffffffffffff3 RBX: ffff99b6dda0ba00 RCX: ffff99b6dda0ba00
> [ 9082.857720] RDX: fffffffffffffff3 RSI: fffffffffffffff3 RDI: ffffffffc05eb0be
> [ 9082.890558] RBP: ffff99b6dd724140 R08: ffffffffa584e760 R09: ffffffffc05e8700
> [ 9082.923165] R10: 0000000000000000 R11: ffffadd344c97b69 R12: ffff99b6eebdc800
> [ 9082.955485] R13: ffffffffa5d98c80 R14: 0000000000000000 R15: ffffadd344c97d30
> [ 9082.987929] FS:  00007f97b0b01c80(0000) GS:ffff99b6ef4c0000(0000) knlGS:0000000000000000
> [ 9083.024017] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 9083.050402] CR2: 000000000000001b CR3: 0000000827d3c004 CR4: 00000000001606e0
> [ 9083.083171] Call Trace:
> [ 9083.094594]  ? ida_alloc_range+0x35d/0x3c0
> [ 9083.113081]  rpc_client_register+0x42/0x1a0 [sunrpc]
> [ 9083.135947]  ? _cond_resched+0x15/0x30
> [ 9083.153429]  ? __kmalloc+0x164/0x200
> [ 9083.169633]  rpc_new_client+0x1d8/0x290 [sunrpc]
> [ 9083.190656]  rpc_create_xprt+0x63/0x190 [sunrpc]
> [ 9083.212003]  ? rpc_xprt_debugfs_register+0x88/0xd0 [sunrpc]
> [ 9083.237454]  rpc_create+0xfe/0x1e0 [sunrpc]
> [ 9083.256338]  ? terminate_walk+0xe4/0x100
> [ 9083.273969]  ? path_openat+0x3d8/0x1670
> [ 9083.291880]  gssp_rpc_create+0x89/0xe0 [auth_rpcgss]
> [ 9083.314561]  set_gssp_clnt+0x4c/0xa0 [auth_rpcgss]
> [ 9083.336649]  write_gssp+0x94/0xf0 [auth_rpcgss]
> [ 9083.357420]  proc_reg_write+0x39/0x60
> [ 9083.375163]  __vfs_write+0x36/0x1b0
> [ 9083.391688]  ? selinux_file_permission+0xf0/0x130
> [ 9083.415432]  ? security_file_permission+0x2e/0xe0
> [ 9083.437427]  vfs_write+0xa5/0x1a0
> [ 9083.452508]  ksys_write+0x4f/0xb0
> [ 9083.467803]  do_syscall_64+0x55/0x1a0
> [ 9083.484470]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> [ 9083.507782] RIP: 0033:0x7f97aecf8aa7
> [ 9083.524457] Code: c3 66 90 41 54 49 89 d4 55 48 89 f5 53 89 fb 48 83 ec 10 e8 fb fc ff ff 4c 89 e2 48 89 ee 89 df 41 89 c0 b8 01 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 35 44 89 c7 48 89 44 24 08 e8 34 fd ff ff 48
> [ 9083.610512] RSP: 002b:00007ffde9e42a20 EFLAGS: 00000293 ORIG_RAX: 0000000000000001
> [ 9083.645486] RAX: ffffffffffffffda RBX: 000000000000000b RCX: 00007f97aecf8aa7
> [ 9083.678203] RDX: 0000000000000001 RSI: 00007ffde9e42a56 RDI: 000000000000000b
> [ 9083.711049] RBP: 00007ffde9e42a56 R08: 0000000000000000 R09: 0000000000000007
> [ 9083.743465] R10: 0000000000000000 R11: 0000000000000293 R12: 0000000000000001
> [ 9083.775516] R13: 0000560adff33c00 R14: 0000000000000000 R15: 0000000000000001
> [ 9083.808494] Modules linked in: nfsd auth_rpcgss nfs_acl lockd grace sunrpc intel_rapl sb_edac x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm ipmi_ssif irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel intel_cstate ipmi_si intel_uncore ipmi_devintf iTCO_wdt iTCO_vendor_support pcspkr intel_rapl_perf ioatdma lpc_ich ipmi_msghandler sg hpilo hpwdt dca acpi_power_meter xfs libcrc32c ata_generic mgag200 i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sd_mod sysimgblt fb_sys_fops ttm ata_piix drm libata serio_raw crc32c_intel tg3 hpsa scsi_transport_sas dm_mirror dm_region_hash dm_log dm_mod
> [ 9084.057815] CR2: 000000000000001b
> [ 9084.072727] ---[ end trace 9d6f1665267a702c ]---
> [ 9084.094005] RIP: 0010:rpc_clnt_debugfs_register+0xb4/0x120 [sunrpc]
> [ 9084.122922] Code: be 00 81 00 00 48 c7 c7 be b0 5e c0 e8 f5 13 79 e4 48 85 c0 74 31 48 8b 43 30 48 8b 80 f0 04 00 00 48 85 c0 0f 84 70 ff ff ff <48> 8b 48 28 48 c7 c2 c4 b0 5e c0 be 18 00 00 00 48 89 e7 e8 54 78
> [ 9084.209159] RSP: 0018:ffffadd344c97b68 EFLAGS: 00010286
> [ 9084.232809] RAX: fffffffffffffff3 RBX: ffff99b6dda0ba00 RCX: ffff99b6dda0ba00
> [ 9084.265416] RDX: fffffffffffffff3 RSI: fffffffffffffff3 RDI: ffffffffc05eb0be
> [ 9084.297480] RBP: ffff99b6dd724140 R08: ffffffffa584e760 R09: ffffffffc05e8700
> [ 9084.330637] R10: 0000000000000000 R11: ffffadd344c97b69 R12: ffff99b6eebdc800
> [ 9084.363159] R13: ffffffffa5d98c80 R14: 0000000000000000 R15: ffffadd344c97d30
> [ 9084.395817] FS:  00007f97b0b01c80(0000) GS:ffff99b6ef4c0000(0000) knlGS:0000000000000000
> [ 9084.432989] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 9084.460595] CR2: 000000000000001b CR3: 0000000827d3c004 CR4: 00000000001606e0
> [ 9084.493254] Kernel panic - not syncing: Fatal exception
> [ 9084.517838] Kernel Offset: 0x23a00000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
> [ 9084.567110] ---[ end Kernel panic - not syncing: Fatal exception ]---
> [ 9084.596773] ------------[ cut here ]------------

Here's the patch that I just sent out for this issue a few minutes
before your email.  If you could verify it works for you, that would be
great.

thanks,

greg k-h


From foo@baz Tue Feb 12 19:21:57 CET 2019
Date: Tue, 12 Feb 2019 19:21:57 +0100
To: Greg KH <gregkh@linuxfoundation.org>
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH] rpc: properly check debugfs dentry before using it

debugfs can now report an error code if something went wrong instead of
just NULL.  So if the return value is to be used as a "real" dentry, it
needs to be checked if it is an error before dereferenceing it.

This is now happening because of ff9fb72bc077 ("debugfs: return error values,
not NULL")

Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@kernel.org>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Cc: netdev@vger.kernel.org
Reported-by: David Howells <dhowells@redhat.com>
Tested-by: David Howells <dhowells@redhat.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 net/sunrpc/debugfs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

I can take this through my tree if people don't object, or it can go
through the NFS tree.  It does need to get merged before 5.0-final
though.

I also have a "larger" debugfs cleanup patch for this file, but that's
not really 5.0-final material and I will send it out later.

thanks,

greg k-h

--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -146,7 +146,7 @@ rpc_clnt_debugfs_register(struct rpc_cln
 	rcu_read_lock();
 	xprt = rcu_dereference(clnt->cl_xprt);
 	/* no "debugfs" dentry? Don't bother with the symlink. */
-	if (!xprt->debugfs) {
+	if (IS_ERR_OR_NULL(xprt->debugfs)) {
 		rcu_read_unlock();
 		return;
 	}
