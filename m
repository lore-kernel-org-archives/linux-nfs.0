Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merkurneu.hrz.uni-giessen.de ([134.176.2.3]:36452 "EHLO
	merkurneu.hrz.uni-giessen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756832Ab0KPOlZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Nov 2010 09:41:25 -0500
Received: from mailgw62.hrz.uni-giessen.de by merkurneu.hrz.uni-giessen.de with ESMTP for linux-nfs@vger.kernel.org; Tue, 16 Nov 2010 15:26:07 +0100
Received: from merkur.hrz.uni-giessen.de (merkur.hrz.uni-giessen.de [134.176.2.12])
	by mailgw62.hrz.uni-giessen.de (Postfix) with ESMTP id A4DD4680008D
	for <linux-nfs@vger.kernel.org>; Tue, 16 Nov 2010 15:26:00 +0100 (CET)
Received: from [134.176.2.12] by merkur.hrz.uni-giessen.de with ESMTP for linux-nfs@vger.kernel.org; Tue, 16 Nov 2010 15:26:00 +0100
From: Marvin <marvin24@gmx.de>
To: linux-nfs@vger.kernel.org
Subject: 2.6.37-rc2 client stuck in D
Date: Tue, 16 Nov 2010 15:25:59 +0100
Content-Type: Text/Plain;
  charset="us-ascii"
Message-Id: <201011161525.59555.marvin24@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

running 2.6.37-rc2 nfs4 client against a 2.6.34.7 (opensuse 11.3) server. When a KDE4 
program (e.g. rekonq / quassel) wants to download a file, the plasma desktop (may 
include a downloader called by rekonq) hangs in D state.

[76927.126008] plasma-deskto D ffff8801046ce778     0  3665      1 0x00000000
[76927.126008]  ffff880102045938 0000000000000082 ffff880117c38b40 ffff8800dfc11cc0
[76927.126008]  ffff880102045958 ffff880102045fd8 ffff880102045fd8 ffff8801046ce400
[76927.126008]  0000000000011cc0 ffff880102045fd8 ffff880102044000 0000000000011cc0
[76927.126008] Call Trace:
[76927.126008]  [<ffffffff8143e132>] ? _raw_spin_unlock_irqrestore+0x12/0x40
[76927.126008]  [<ffffffffa04476e0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
[76927.126008]  [<ffffffffa04476ff>] rpc_wait_bit_killable+0x1f/0x40 [sunrpc]
[76927.126008]  [<ffffffff8143c587>] __wait_on_bit+0x57/0x80
[76927.126008]  [<ffffffff8143be8c>] ? preempt_schedule+0x3c/0x60
[76927.126008]  [<ffffffff8143c621>] out_of_line_wait_on_bit+0x71/0x80
[76927.126008]  [<ffffffffa04476e0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
[76927.126008]  [<ffffffff8106b500>] ? wake_bit_function+0x0/0x40
[76927.126008]  [<ffffffffa0447e55>] __rpc_execute+0xe5/0x220 [sunrpc]
[76927.126008]  [<ffffffffa04485bd>] rpc_execute+0x3d/0x50 [sunrpc]
[76927.126008]  [<ffffffffa04412e0>] rpc_run_task+0xe0/0x130 [sunrpc]
[76927.126008]  [<ffffffffa044141e>] rpc_call_sync+0x3e/0x70 [sunrpc]
[76927.126008]  [<ffffffff8143e170>] ? _raw_spin_unlock+0x10/0x40
[76927.126008]  [<ffffffffa04d777d>] _nfs4_call_sync+0x1d/0x20 [nfs]
[76927.126008]  [<ffffffffa04d7c61>] _nfs4_proc_readdir+0x1f1/0x310 [nfs]
[76927.126008]  [<ffffffff8143eb86>] ? retint_kernel+0x26/0x30
[76927.126008]  [<ffffffffa04b92d8>] ? nfs_readdir_page_filler.clone.0+0xe8/0x510 
[nfs]
[76927.126008]  [<ffffffffa04d7dd8>] nfs4_proc_readdir+0x58/0x90 [nfs]
[76927.126008]  [<ffffffffa04b9910>] nfs_readdir_xdr_to_array+0x210/0x2e0 [nfs]
[76927.126008]  [<ffffffff81441d15>] ? sub_preempt_count+0x95/0xd0
[76927.126008]  [<ffffffff810d9ff6>] ? __lru_cache_add+0x76/0xc0
[76927.126008]  [<ffffffffa04b99fd>] nfs_readdir_filler+0x1d/0x80 [nfs]
[76927.126008]  [<ffffffff810cf593>] do_read_cache_page+0x73/0x170
[76927.126008]  [<ffffffffa04b99e0>] ? nfs_readdir_filler+0x0/0x80 [nfs]
[76927.126008]  [<ffffffff810cf6c4>] read_cache_page_async+0x14/0x20
[76927.126008]  [<ffffffff810cf6d9>] read_cache_page+0x9/0x20
[76927.126008]  [<ffffffffa04b9bc2>] nfs_readdir+0x162/0x4e0 [nfs]
[76927.126008]  [<ffffffff8143e170>] ? _raw_spin_unlock+0x10/0x40
[76927.126008]  [<ffffffff8112aa00>] ? filldir64+0x0/0xd0
[76927.126008]  [<ffffffffa04e23c0>] ? nfs4_decode_dirent+0x0/0x1e0 [nfs]
[76927.126008]  [<ffffffff8112aa00>] ? filldir64+0x0/0xd0
[76927.126008]  [<ffffffff8112ad10>] vfs_readdir+0xb0/0xd0
[76927.126008]  [<ffffffff8112aef0>] sys_getdents64+0x80/0xe0
[76927.126008]  [<ffffffff81003b35>] ? device_not_available+0x15/0x20
[76927.126008]  [<ffffffff81002eeb>] system_call_fastpath+0x16/0x1b
...
[76927.126008] rekonq        D ffff880118ab1500     0 17178      1 0x00000000
[76927.126008]  ffff880049b1be08 0000000000000086 ffff880049b1bdd8 ffffffff81125850
[76927.126008]  0000000000000000 ffff880049b1bfd8 ffff880049b1bfd8 ffff8800d81b0200
[76927.126008]  0000000000011cc0 ffff880049b1bfd8 ffff880049b1a000 0000000000011cc0
[76927.126008] Call Trace:
[76927.126008]  [<ffffffff81125850>] ? link_path_walk+0x80/0xb00
[76927.126008]  [<ffffffff81042a11>] ? get_parent_ip+0x11/0x50
[76927.126008]  [<ffffffff8143caca>] __mutex_lock_slowpath+0x10a/0x1c0
[76927.126008]  [<ffffffff8143c64e>] mutex_lock+0x1e/0x40
[76927.126008]  [<ffffffff81126b3e>] do_unlinkat+0x8e/0x1d0
[76927.126008]  [<ffffffff81117e8b>] ? filp_close+0x5b/0x80
[76927.126008]  [<ffffffff81128791>] sys_unlink+0x11/0x20
[76927.126008]  [<ffffffff81002eeb>] system_call_fastpath+0x16/0x1b

no other messages in the logs (client + server)

Thanks

Marvin



