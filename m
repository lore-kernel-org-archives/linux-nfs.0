Return-Path: <SRS0=zHXY=OH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C326C43441
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 17:40:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 51D8A2081B
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 17:40:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51D8A2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729245AbeK2Ema (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 23:42:30 -0500
Received: from mail-it1-f200.google.com ([209.85.166.200]:54552 "EHLO
        mail-it1-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729164AbeK2Em3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Nov 2018 23:42:29 -0500
Received: by mail-it1-f200.google.com with SMTP id v3so3864090itf.4
        for <linux-nfs@vger.kernel.org>; Wed, 28 Nov 2018 09:40:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:date:message-id:subject:from:to;
        bh=uwmBYfUCyl3TNUOLlCazyVSPEgT4pJ2DbIAiMZTM1Ec=;
        b=m9A4iy8W5o0Liz14uiYoJGDdqDsZcqG0C5OPCzBvG7JhifDUo6H6DhJC4emD9X7naq
         xjODd6EZkBQlR0HpwaGiGonmVJxXRofLiq0oiOZJrhkfCJ6jQENOiKzR+oKjIWV8ThKb
         CLAmQ8O/07WnOxv5myJPB3oI9rcy+58IBQPyoeuInx9HNitbrddckrt0kwFpKSPjQDU6
         IOQcVIyBk6tgcwUzJ+sHpHC8XOHTeRTxVQgCh5YWZGwZK/fyOm2a+iE0t41axL5orJdu
         ulIPUqMRgsrBsZBLvcacQkLVSfEH4UK2Te0kr8r3AQ/21WgCUjlC5FAVZqKROdwUmDr5
         DOtQ==
X-Gm-Message-State: AA+aEWbhiXmVpxwIh9+o4EXFqDU5TjZKvU8mKxcMNCqiJO9/r5qBTdS4
        /eBrcSrQxlOYcsoLnnmKsv6xZQbdmOAPB3ICFWjDLgQGMoSd
X-Google-Smtp-Source: AFSGD/VbTQdLEBjcgPon4Bn5sSAB39ezRctyxWRjhSiU1Nbf8gbzw8+LOlYCuuBnpl6N20WyiQYrpF6G/ouCCwrlu/abeEUoDjKC
MIME-Version: 1.0
X-Received: by 2002:a24:1f0f:: with SMTP id d15mr3073890itd.31.1543426803948;
 Wed, 28 Nov 2018 09:40:03 -0800 (PST)
Date:   Wed, 28 Nov 2018 09:40:03 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000062ece6057bbd0e4a@google.com>
Subject: KMSAN: uninit-value in ip6_compressed_string
From:   syzbot <syzbot+047a11c361b872896a4f@syzkaller.appspotmail.com>
To:     anna.schumaker@netapp.com, bfields@fieldses.org,
        davem@davemloft.net, jlayton@kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, syzkaller-bugs@googlegroups.com,
        trond.myklebust@hammerspace.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello,

syzbot found the following crash on:

HEAD commit:    fffec98ae2a6 net: proper support for CONFIG_GENERIC_CSUM o..
git tree:       https://github.com/google/kmsan.git/master
console output: https://syzkaller.appspot.com/x/log.txt?x=156ad1f5400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=56b48b46dafe4516
dashboard link: https://syzkaller.appspot.com/bug?extid=047a11c361b872896a4f
compiler:       clang version 8.0.0 (trunk 343298)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1031326d400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=16212b0b400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+047a11c361b872896a4f@syzkaller.appspotmail.com

==================================================================
BUG: KMSAN: uninit-value in ip6_compressed_string+0x1a9/0x1460  
lib/vsprintf.c:1161
CPU: 1 PID: 6762 Comm: syz-executor445 Not tainted 4.20.0-rc3+ #95
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x32d/0x480 lib/dump_stack.c:113
  kmsan_report+0x12c/0x290 mm/kmsan/kmsan.c:683
  __msan_warning+0x76/0xc0 mm/kmsan/kmsan_instr.c:330
  ip6_compressed_string+0x1a9/0x1460 lib/vsprintf.c:1161
  ip6_addr_string+0x165/0x2b0 lib/vsprintf.c:1247
  pointer+0x110e/0x1520 lib/vsprintf.c:1911
  vsnprintf+0xabf/0x3110 lib/vsprintf.c:2300
  snprintf+0x246/0x290 lib/vsprintf.c:2429
  rpc_ntop6_noscopeid net/sunrpc/addr.c:56 [inline]
  rpc_sockaddr2uaddr+0x3aa/0x6f0 net/sunrpc/addr.c:281
  rpcb_getport_async+0x10d4/0x1770 net/sunrpc/rpcb_clnt.c:773
  call_bind+0x1a8/0x260 net/sunrpc/clnt.c:1802
  __rpc_execute+0xacb/0x19c0 net/sunrpc/sched.c:832
  rpc_execute+0x6ad/0x940 net/sunrpc/sched.c:900
  rpc_run_task+0xc42/0xe70 net/sunrpc/clnt.c:1065
  rpc_call_sync net/sunrpc/clnt.c:1094 [inline]
  rpc_ping net/sunrpc/clnt.c:2516 [inline]
  rpc_create_xprt+0x6a9/0xe80 net/sunrpc/clnt.c:480
  rpc_create+0xa78/0xb30 net/sunrpc/clnt.c:588
  nfs_create_rpc_client+0x752/0x860 fs/nfs/client.c:523
  nfs_init_client+0xb8/0x1d0 fs/nfs/client.c:634
  nfs_get_client+0x14fc/0x1720 fs/nfs/client.c:425
  nfs_init_server fs/nfs/client.c:670 [inline]
  nfs_create_server+0xbd7/0x3290 fs/nfs/client.c:954
  nfs_try_mount+0x4de/0x14b0 fs/nfs/super.c:1884
  nfs_fs_mount+0x393d/0x4000 fs/nfs/super.c:2695
  mount_fs+0x282/0x790 fs/super.c:1261
  vfs_kern_mount+0x231/0x8c0 fs/namespace.c:961
  do_new_mount fs/namespace.c:2469 [inline]
  do_mount+0xd1f/0x5ac0 fs/namespace.c:2801
  ksys_mount+0x32e/0x3d0 fs/namespace.c:3017
  __do_sys_mount fs/namespace.c:3031 [inline]
  __se_sys_mount+0xe5/0x110 fs/namespace.c:3028
  __x64_sys_mount+0x62/0x80 fs/namespace.c:3028
  do_syscall_64+0xcf/0x110 arch/x86/entry/common.c:291
  entry_SYSCALL_64_after_hwframe+0x63/0xe7
RIP: 0033:0x4401c9
Code: 18 89 d0 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 00 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 fb 13 fc ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007fff7eefaf48 EFLAGS: 00000286 ORIG_RAX: 00000000000000a5
RAX: ffffffffffffffda RBX: 0030656c69662f2e RCX: 00000000004401c9
RDX: 0000000020000180 RSI: 0000000020000140 RDI: 0000000000000000
RBP: 00000000006ca018 R08: 000000002000a000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000286 R12: 0000000000401a50
R13: 0000000000401ae0 R14: 0000000000000000 R15: 0000000000000000

Uninit was stored to memory at:
  kmsan_save_stack_with_flags mm/kmsan/kmsan.c:246 [inline]
  kmsan_save_stack mm/kmsan/kmsan.c:261 [inline]
  kmsan_internal_chain_origin+0x13d/0x240 mm/kmsan/kmsan.c:469
  kmsan_memcpy_memmove_metadata+0x1a9/0xf70 mm/kmsan/kmsan.c:344
  kmsan_memcpy_metadata+0xb/0x10 mm/kmsan/kmsan.c:362
  __msan_memcpy+0x61/0x70 mm/kmsan/kmsan_instr.c:162
  ip6_compressed_string+0x89/0x1460 lib/vsprintf.c:1154
  ip6_addr_string+0x165/0x2b0 lib/vsprintf.c:1247
  pointer+0x110e/0x1520 lib/vsprintf.c:1911
  vsnprintf+0xabf/0x3110 lib/vsprintf.c:2300
  snprintf+0x246/0x290 lib/vsprintf.c:2429
  rpc_ntop6_noscopeid net/sunrpc/addr.c:56 [inline]
  rpc_sockaddr2uaddr+0x3aa/0x6f0 net/sunrpc/addr.c:281
  rpcb_getport_async+0x10d4/0x1770 net/sunrpc/rpcb_clnt.c:773
  call_bind+0x1a8/0x260 net/sunrpc/clnt.c:1802
  __rpc_execute+0xacb/0x19c0 net/sunrpc/sched.c:832
  rpc_execute+0x6ad/0x940 net/sunrpc/sched.c:900
  rpc_run_task+0xc42/0xe70 net/sunrpc/clnt.c:1065
  rpc_call_sync net/sunrpc/clnt.c:1094 [inline]
  rpc_ping net/sunrpc/clnt.c:2516 [inline]
  rpc_create_xprt+0x6a9/0xe80 net/sunrpc/clnt.c:480
  rpc_create+0xa78/0xb30 net/sunrpc/clnt.c:588
  nfs_create_rpc_client+0x752/0x860 fs/nfs/client.c:523
  nfs_init_client+0xb8/0x1d0 fs/nfs/client.c:634
  nfs_get_client+0x14fc/0x1720 fs/nfs/client.c:425
  nfs_init_server fs/nfs/client.c:670 [inline]
  nfs_create_server+0xbd7/0x3290 fs/nfs/client.c:954
  nfs_try_mount+0x4de/0x14b0 fs/nfs/super.c:1884
  nfs_fs_mount+0x393d/0x4000 fs/nfs/super.c:2695
  mount_fs+0x282/0x790 fs/super.c:1261
  vfs_kern_mount+0x231/0x8c0 fs/namespace.c:961
  do_new_mount fs/namespace.c:2469 [inline]
  do_mount+0xd1f/0x5ac0 fs/namespace.c:2801
  ksys_mount+0x32e/0x3d0 fs/namespace.c:3017
  __do_sys_mount fs/namespace.c:3031 [inline]
  __se_sys_mount+0xe5/0x110 fs/namespace.c:3028
  __x64_sys_mount+0x62/0x80 fs/namespace.c:3028
  do_syscall_64+0xcf/0x110 arch/x86/entry/common.c:291
  entry_SYSCALL_64_after_hwframe+0x63/0xe7

Local variable description: ----addr@rpcb_getport_async
Variable was created at:
  rpcb_getport_async+0xb3/0x1770 net/sunrpc/rpcb_clnt.c:673
  call_bind+0x1a8/0x260 net/sunrpc/clnt.c:1802
==================================================================


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches
