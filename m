Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43377 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab1BZCm3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Feb 2011 21:42:29 -0500
Message-ID: <4D686893.7010106@panasas.com>
Date: Fri, 25 Feb 2011 21:42:27 -0500
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>, Fred Isaman <iisaman@netapp.com>
Subject: Client still crashing on 2nd callback after NFS4_ERR_DELAY
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I get the below crash on the 2nd recall after the client returned
NFS_ERR_DELAY, and the server sends a retry.

602678a8:  [<6001585b>] panic_exit+0x2f/0x45
602678c8:  [<60049a3e>] notifier_call_chain+0x32/0x5e
60267908:  [<60049a8c>] atomic_notifier_call_chain+0x13/0x15
60267918:  [<601b3b9b>] panic+0x105/0x1dc
602679c8:  [<601b6056>] _raw_spin_unlock_irqrestore+0x18/0x1c
602679e8:  [<60016e5f>] free_irqs+0x74/0xde
60267a18:  [<60015162>] relay_signal+0x38/0x79
60267a28:  [<60012cef>] sigio_handler+0x5a/0x5f
60267a48:  [<600224d0>] sig_handler_common+0x84/0x98
60267a68:  [<6002257d>] real_alarm_handler+0x3c/0x3e
60267af0:  [<6012fc02>] radix_tree_delete+0x101/0x1d7
60267b38:  [<6002252f>] unblock_signals+0x4b/0x5d
60267b78:  [<60022616>] sig_handler+0x30/0x3b
60267b98:  [<60022848>] handle_signal+0x6d/0xa3
60267be8:  [<600241c8>] hard_handler+0x10/0x14
60267ca8:  [<7c1d5dfb>] do_callback_layoutrecall+0x457/0x993 [nfs]


(gdb) list *(do_callback_layoutrecall+0x457)
0x2de1f is in do_callback_layoutrecall (/usr0/export/dev/bharrosh/git/pub/linux-pnfs/fs/nfs/callback_proc.c:282).
277     dprintk("%s %d\n", __func__, __LINE__);
278                     spin_unlock(&clp->cl_lock);
279     dprintk("%s %d\n", __func__, __LINE__);
280
281                     BUG_ON(!lo);
282                     BUG_ON(!lo->plh_inode);
283                     spin_lock(&lo->plh_inode->i_lock);
284     dprintk("%s %d\n", __func__, __LINE__);
285                     if (rv == NFS4_OK) {
286                             lo->plh_block_lgets++;

Prints and BUG_ONs added by me.

Any body wants to fix this. How would lo->plh_inode be null, and why only the
second time.

Thanks
Boaz
