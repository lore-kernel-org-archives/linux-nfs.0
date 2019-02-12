Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5886C282CA
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 11:29:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9D9D22080F
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 11:29:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728084AbfBLL3G convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 06:29:06 -0500
Received: from mx1.redhat.com ([209.132.183.28]:49732 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726044AbfBLL3F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 06:29:05 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A346C5947A
        for <linux-nfs@vger.kernel.org>; Tue, 12 Feb 2019 11:29:05 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 191585D9D1;
        Tue, 12 Feb 2019 11:29:04 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
From:   David Howells <dhowells@redhat.com>
To:     linux-nfs@vger.kernel.org
cc:     dhowells@redhat.com
Subject: Oops in rpc_clnt_debugfs_register()
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <19913.1549970944.1@warthog.procyon.org.uk>
Content-Transfer-Encoding: 8BIT
Date:   Tue, 12 Feb 2019 11:29:04 +0000
Message-ID: <19914.1549970944@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 12 Feb 2019 11:29:05 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

I'm getting the attached oops during boot from the gssproxy process in
rpc_clnt_debugfs_register().  The code at this point is:

   0xffffffff8195cbdd <+450>:   mov    0x50(%rax),%rcx   <--- oopsing
   0xffffffff8195cbe1 <+454>:   mov    $0xffffffff821cc8ba,%rdx
   0xffffffff8195cbe8 <+461>:   mov    $0x18,%esi
   0xffffffff8195cbed <+466>:   lea    -0x30(%rbp),%rdi
   0xffffffff8195cbf1 <+470>:   callq  0xffffffff819db773 <snprintf>

RAX is -EACCES.

Looking in the source:

	len = snprintf(name, sizeof(name), "../../rpc_xprt/%s",
			xprt->debugfs->d_name.name);

I think xprt->debugfs is the value in RAX.

	(gdb) p &((struct dentry *)0)->d_name.name
	$5 = (const unsigned char **) 0x50 <irq_stack_union+80>

which matches the offset on the oopsing MOV instruction.

This is with linus/master (aa0c38cf39de73bf7360a3da8f1707601261e518).

David
---
BUG: unable to handle kernel NULL pointer dereference at 0000000000000043
#PF error: [normal kernel read fault]
...
RIP: 0010:rpc_clnt_debugfs_register+0x1c2/0x27e
RSP: 0018:ffff8880be407b58 EFLAGS: 00010286
RAX: fffffffffffffff3 RBX: ffff8880d56c0e00 RCX: ab0ed8627cda32e2
RDX: 000000000000000f RSI: ffffffff82462ac0 RDI: ffff8880ce487018
RBP: ffff8880be407b88 R08: 0000000000000000 R09: 0000000000000000
R10: ffffffff826ccfac R11: 0000000000000000 R12: 0000000000000000
R13: ffffffff8241b540 R14: ffff8880ce6a1000 R15: ffff8880d56c0e00
FS:  00007f195717bc80(0000) GS:ffff8880c6d80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000043 CR3: 00000000be40a004 CR4: 00000000001606e0
Call Trace:
 rpc_client_register+0x43/0x271
 rpc_new_client+0x215/0x291
 rpc_create_xprt+0xa5/0x167
 ? rpc_xprt_debugfs_register+0x8b/0xce
 ? page_mapping+0x5e/0x84
 rpc_create+0x143/0x15f
 ? __mutex_lock+0x8f/0x7b0
 ? set_gssp_clnt+0x13b/0x194
 ? mntput_no_expire+0xc0/0x39e
 gssp_rpc_create+0x76/0xdb
 set_gssp_clnt+0x147/0x194
 ? _kstrtoull+0x3b/0x8a
 write_gssp+0x90/0xcc
 proc_reg_write+0x3b/0x59
 ? proc_reg_poll+0x52/0x52
 __vfs_write+0x31/0x15b
 ? rcu_read_lock_sched_held+0x5d/0x63
 ? rcu_sync_lockdep_assert+0x28/0x4e
 ? __sb_start_write+0xb6/0x151
 ? vfs_write+0xca/0x182
 vfs_write+0xdb/0x182
 ksys_write+0x60/0xb1
 do_syscall_64+0x7d/0x1a0
 entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x7f1957711d25
Code: 00 00 75 05 48 83 c4 58 c3 e8 f7 49 ff ff 0f 1f 80 00 00 00 00 f3 0f 1e fa 8b 05 26 f7 00 00 85 c0 75 12 b8 01 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 53 c3 66 90 41 54 49 89 d4 55 48 89 f5 53 89
RSP: 002b:00007ffcc0d5f288 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000009 RCX: 00007f1957711d25
RDX: 0000000000000001 RSI: 00007ffcc0d5f296 RDI: 0000000000000009
RBP: 0000000000000000 R08: 0000000000000031 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 000055be5a699950
R13: 00007ffcc0d5f5c0 R14: 0000000000000000 R15: 0000000000000000
Modules linked in:
CR2: 0000000000000043
