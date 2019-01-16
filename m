Return-Path: <SRS0=vPHX=PY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81971C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 19:09:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 48E66206C2
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 19:09:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727397AbfAPTJK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Jan 2019 14:09:10 -0500
Received: from mail-qt1-f196.google.com ([209.85.160.196]:46302 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727261AbfAPTJJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jan 2019 14:09:09 -0500
Received: by mail-qt1-f196.google.com with SMTP id y20so8426509qtm.13
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jan 2019 11:09:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=OwZkzptQU0+HK/ylAHkmkywrAphsJk3JuztpOisP7h4=;
        b=g/n4IEjKh/C+hVYNaN6JRMDGKnN0DpZFyjQtd0DOsdrjOvPpn2cYklPy+ub3umthmO
         kD/0QieCHKrcP0hjjiZuMzS6206ROUqPZKSK3ZtvUVlUopJwZvo/orS4b1tQs0IddGZv
         +Mbg0RYTeMet64ux+9TmWLeY1Ub71NPC1DH6GWHL0mqK1kBLW3EmCAwLsZ+IXzAr1Vgp
         2Yv4pUs2VrB6KMk4ELowhV51obBqdNw7pJmALJTgnHWlGW1nVqJ+SgGudkFw4rfCi+Im
         uSYDmPdQDxdprYko+rlJONy7/k0HzBqunUOBjFuai1m+nWs2nC2J/4vPUdlgd5XCqugh
         j9ag==
X-Gm-Message-State: AJcUukcR65kYs5oplbhzEvOZ0j9x1jRGhDxVWR6J/PRbjgRcMeg+5Xjq
        WXFi7EdgBtfJakg3D8MTgjjXmAP9z3w=
X-Google-Smtp-Source: ALg8bN72g6BOZ/DkDSJTug7/jwiWWw414sMyuv3HMnGi2M194/lpE9XDn9XSC6nSpz3HYV+B6lBGIQ==
X-Received: by 2002:aed:3722:: with SMTP id i31mr8636706qtb.289.1547665748041;
        Wed, 16 Jan 2019 11:09:08 -0800 (PST)
Received: from ?IPv6:2601:602:9800:dae6::fb21? ([2601:602:9800:dae6::fb21])
        by smtp.gmail.com with ESMTPSA id q17sm59341058qtc.19.2019.01.16.11.09.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 11:09:06 -0800 (PST)
Subject: Re: kernel BUG at kernel/cred.c:825!
To:     Dave Jones <davej@codemonkey.org.uk>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
References: <20190107191841.nejcug5dcdrt5e3a@codemonkey.org.uk>
From:   Laura Abbott <labbott@redhat.com>
Message-ID: <577c9205-ca83-459e-dd2a-5dfed1d2df25@redhat.com>
Date:   Wed, 16 Jan 2019 11:09:04 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190107191841.nejcug5dcdrt5e3a@codemonkey.org.uk>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 1/7/19 11:18 AM, Dave Jones wrote:
> [   53.980701] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
> [   53.981216] NFSD: starting 45-second grace period (net f0000098)
> [   54.006802] CRED: Invalid credentials
> [   54.006880] CRED: At ./include/linux/cred.h:253
> [   54.006899] CRED: Specified credentials: 000000005daa4529
> [   54.006916] CRED: ->magic=0, put_addr=          (null)
> [   54.006927] CRED: ->usage=1, subscr=0
> [   54.006935] CRED: ->*uid = { 0,0,0,0 }
> [   54.006944] CRED: ->*gid = { 0,0,0,0 }
> [   54.006954] ------------[ cut here ]------------
> [   54.006964] kernel BUG at kernel/cred.c:825!
> [   54.006977] invalid opcode: 0000 [#1] SMP RIP: __invalid_creds+0x48/0x50
> [   54.006987] CPU: 2 PID: 814 Comm: mount.nfs Tainted: G        W         5.0.0-rc1-backup+ #1
> [   54.006997] Hardware name: ASUS All Series/Z97-DELUXE, BIOS 2602 08/18/2015
> [   54.007171] RIP: 0010:__invalid_creds+0x48/0x50
> [   54.007184] Code: 44 89 e2 48 89 ee 48 c7 c7 37 3e 53 ba e8 f7 8f 03 00 48 c7 c6 49 3e 53 ba 48 89 df 65 48 8b 14 25 80 4e 01 00 e8 48 fd ff ff <0f> 0b 66 0f 1f 44 00 00 0f 1f 44 00 00 55 48 89 e5 41 56 49 89 fe
> [   54.007207] RSP: 0018:ffffc90000e33a30 EFLAGS: 00010286
> [   54.007219] RAX: 000000000000001a RBX: ffffffffba960300 RCX: 0000000000000006
> [   54.007234] RDX: 0000000000000000 RSI: ffff8884276f8818 RDI: ffff88842f895710
> [   54.007246] RBP: ffffffffba5274c3 R08: 0000000000000001 R09: 0000000000000000
> [   54.007254] R10: ffffc90000e33a50 R11: 0000000000000000 R12: 00000000000000fd
> [   54.007261] R13: ffff88842c1a6a08 R14: ffffffffba960300 R15: ffffc90000e33d60
> [   54.007269] FS:  00007f73770cb140(0000) GS:ffff88842f880000(0000) knlGS:0000000000000000
> [   54.007277] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   54.007283] CR2: 00005557d17d1000 CR3: 00000004122ba006 CR4: 00000000001606e0
> [   54.007359] Call Trace:
> [   54.007366]  nfs4_discover_server_trunking+0x286/0x310
> [   54.007376]  nfs4_init_client+0xe8/0x260
> [   54.007389]  ? nfs_get_client+0x519/0x610
> [   54.007401]  ? _raw_spin_unlock+0x24/0x30
> [   54.007412]  ? nfs_get_client+0x519/0x610
> [   54.007424]  nfs4_set_client+0xb8/0x100
> [   54.007439]  nfs4_create_server+0xfe/0x270
> [   54.007451]  ? pcpu_alloc+0x611/0x8a0
> [   54.007462]  nfs4_remote_mount+0x28/0x50
> [   54.007474]  mount_fs+0xf/0x80
> [   54.007487]  vfs_kern_mount+0x62/0x160
> [   54.007498]  nfs_do_root_mount+0x7f/0xc0
> [   54.007510]  nfs4_try_mount+0x3f/0xc0
> [   54.007521]  ? get_nfs_version+0x11/0x50
> [   54.007536]  nfs_fs_mount+0x61b/0xbd0
> [   54.007548]  ? rcu_read_lock_sched_held+0x66/0x70
> [   54.007560]  ? nfs_clone_super+0x70/0x70
> [   54.007571]  ? nfs_destroy_inode+0x20/0x20
> [   54.007585]  ? mount_fs+0xf/0x80
> [   54.007595]  mount_fs+0xf/0x80
> [   54.007606]  vfs_kern_mount+0x62/0x160
> [   54.007618]  do_mount+0x1d1/0xd40
> [   54.007631]  ? copy_mount_options+0xd2/0x170
> [   54.007643]  ksys_mount+0x7e/0xd0
> [   54.007654]  __x64_sys_mount+0x21/0x30
> [   54.007665]  do_syscall_64+0x6d/0x660
> [   54.007677]  ? trace_hardirqs_off_thunk+0x1a/0x1c
> [   54.007690]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> [   54.007702] RIP: 0033:0x7f7377e97a1a
> [   54.007713] Code: 48 8b 0d 71 e4 0b 00 f7 d8 64 89 01 48 83 c8 ff c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 49 89 ca b8 a5 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 3e e4 0b 00 f7 d8 64 89 01 48
> [   54.007736] RSP: 002b:00007ffc73d9b4a8 EFLAGS: 00000202 ORIG_RAX: 00000000000000a5
> [   54.007751] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f7377e97a1a
> [   54.007764] RDX: 00005632beb51b50 RSI: 00005632beb51b70 RDI: 00005632beb53880
> [   54.007780] RBP: 00007ffc73d9b600 R08: 00005632beb556b0 R09: 33643a303036343a
> [   54.007794] R10: 0000000000000c00 R11: 0000000000000202 R12: 00007ffc73d9b600
> [   54.007807] R13: 00005632beb548a0 R14: 000000000000001c R15: 00007ffc73d9b510
> 

Fedora still seems to be hitting this as of -rc2
