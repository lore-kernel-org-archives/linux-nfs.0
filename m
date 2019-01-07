Return-Path: <SRS0=jPLZ=PP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBBECC43387
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 19:58:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BF233206B7
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Jan 2019 19:58:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726540AbfAGT6U (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 7 Jan 2019 14:58:20 -0500
Received: from scorn.kernelslacker.org ([45.56.101.199]:34944 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726511AbfAGT6U (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jan 2019 14:58:20 -0500
X-Greylist: delayed 2375 seconds by postgrey-1.27 at vger.kernel.org; Mon, 07 Jan 2019 14:58:20 EST
Received: from [2601:196:4600:d3d8:ae9e:17ff:feb7:72ca] (helo=wopr.kernelslacker.org)
        by scorn.kernelslacker.org with esmtp (Exim 4.89)
        (envelope-from <davej@codemonkey.org.uk>)
        id 1ggaQ5-00066x-FP; Mon, 07 Jan 2019 14:18:41 -0500
Received: by wopr.kernelslacker.org (Postfix, from userid 1026)
        id 4D4C45603D4; Mon,  7 Jan 2019 14:18:41 -0500 (EST)
Date:   Mon, 7 Jan 2019 14:18:41 -0500
From:   Dave Jones <davej@codemonkey.org.uk>
To:     Linux Kernel <linux-kernel@vger.kernel.org>
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: kernel BUG at kernel/cred.c:825!
Message-ID: <20190107191841.nejcug5dcdrt5e3a@codemonkey.org.uk>
Mail-Followup-To: Dave Jones <davej@codemonkey.org.uk>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: NeoMutt/20170113 (1.7.2)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

[   53.980701] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[   53.981216] NFSD: starting 45-second grace period (net f0000098)
[   54.006802] CRED: Invalid credentials
[   54.006880] CRED: At ./include/linux/cred.h:253
[   54.006899] CRED: Specified credentials: 000000005daa4529 
[   54.006916] CRED: ->magic=0, put_addr=          (null)
[   54.006927] CRED: ->usage=1, subscr=0
[   54.006935] CRED: ->*uid = { 0,0,0,0 }
[   54.006944] CRED: ->*gid = { 0,0,0,0 }
[   54.006954] ------------[ cut here ]------------
[   54.006964] kernel BUG at kernel/cred.c:825!
[   54.006977] invalid opcode: 0000 [#1] SMP RIP: __invalid_creds+0x48/0x50
[   54.006987] CPU: 2 PID: 814 Comm: mount.nfs Tainted: G        W         5.0.0-rc1-backup+ #1
[   54.006997] Hardware name: ASUS All Series/Z97-DELUXE, BIOS 2602 08/18/2015
[   54.007171] RIP: 0010:__invalid_creds+0x48/0x50
[   54.007184] Code: 44 89 e2 48 89 ee 48 c7 c7 37 3e 53 ba e8 f7 8f 03 00 48 c7 c6 49 3e 53 ba 48 89 df 65 48 8b 14 25 80 4e 01 00 e8 48 fd ff ff <0f> 0b 66 0f 1f 44 00 00 0f 1f 44 00 00 55 48 89 e5 41 56 49 89 fe
[   54.007207] RSP: 0018:ffffc90000e33a30 EFLAGS: 00010286
[   54.007219] RAX: 000000000000001a RBX: ffffffffba960300 RCX: 0000000000000006
[   54.007234] RDX: 0000000000000000 RSI: ffff8884276f8818 RDI: ffff88842f895710
[   54.007246] RBP: ffffffffba5274c3 R08: 0000000000000001 R09: 0000000000000000
[   54.007254] R10: ffffc90000e33a50 R11: 0000000000000000 R12: 00000000000000fd
[   54.007261] R13: ffff88842c1a6a08 R14: ffffffffba960300 R15: ffffc90000e33d60
[   54.007269] FS:  00007f73770cb140(0000) GS:ffff88842f880000(0000) knlGS:0000000000000000
[   54.007277] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   54.007283] CR2: 00005557d17d1000 CR3: 00000004122ba006 CR4: 00000000001606e0
[   54.007359] Call Trace:
[   54.007366]  nfs4_discover_server_trunking+0x286/0x310
[   54.007376]  nfs4_init_client+0xe8/0x260
[   54.007389]  ? nfs_get_client+0x519/0x610
[   54.007401]  ? _raw_spin_unlock+0x24/0x30
[   54.007412]  ? nfs_get_client+0x519/0x610
[   54.007424]  nfs4_set_client+0xb8/0x100
[   54.007439]  nfs4_create_server+0xfe/0x270
[   54.007451]  ? pcpu_alloc+0x611/0x8a0
[   54.007462]  nfs4_remote_mount+0x28/0x50
[   54.007474]  mount_fs+0xf/0x80
[   54.007487]  vfs_kern_mount+0x62/0x160
[   54.007498]  nfs_do_root_mount+0x7f/0xc0
[   54.007510]  nfs4_try_mount+0x3f/0xc0
[   54.007521]  ? get_nfs_version+0x11/0x50
[   54.007536]  nfs_fs_mount+0x61b/0xbd0
[   54.007548]  ? rcu_read_lock_sched_held+0x66/0x70
[   54.007560]  ? nfs_clone_super+0x70/0x70
[   54.007571]  ? nfs_destroy_inode+0x20/0x20
[   54.007585]  ? mount_fs+0xf/0x80
[   54.007595]  mount_fs+0xf/0x80
[   54.007606]  vfs_kern_mount+0x62/0x160
[   54.007618]  do_mount+0x1d1/0xd40
[   54.007631]  ? copy_mount_options+0xd2/0x170
[   54.007643]  ksys_mount+0x7e/0xd0
[   54.007654]  __x64_sys_mount+0x21/0x30
[   54.007665]  do_syscall_64+0x6d/0x660
[   54.007677]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[   54.007690]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   54.007702] RIP: 0033:0x7f7377e97a1a
[   54.007713] Code: 48 8b 0d 71 e4 0b 00 f7 d8 64 89 01 48 83 c8 ff c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 49 89 ca b8 a5 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 3e e4 0b 00 f7 d8 64 89 01 48
[   54.007736] RSP: 002b:00007ffc73d9b4a8 EFLAGS: 00000202 ORIG_RAX: 00000000000000a5
[   54.007751] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f7377e97a1a
[   54.007764] RDX: 00005632beb51b50 RSI: 00005632beb51b70 RDI: 00005632beb53880
[   54.007780] RBP: 00007ffc73d9b600 R08: 00005632beb556b0 R09: 33643a303036343a
[   54.007794] R10: 0000000000000c00 R11: 0000000000000202 R12: 00007ffc73d9b600
[   54.007807] R13: 00005632beb548a0 R14: 000000000000001c R15: 00007ffc73d9b510

