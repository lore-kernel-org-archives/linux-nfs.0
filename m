Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:58647 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754094Ab3JBUEi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Oct 2013 16:04:38 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: NULL pointer dereference from Bakeathon
Date: Wed, 2 Oct 2013 20:04:36 +0000
Message-ID: <4C49F8D1-7B36-4F47-A7DB-1CAF538BC478@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I was finally able to reproduce this NULL pointer dereference that I found last week at the Bakeathon.

It hit a debug WARN_ON_ONCE right before the BUG.

To reproduce, run iozone on a 4.0 mount and kick off state recovery repeatedly.  It took a long time of constant state recoveries for me to be able to reproduce this.

The WARN_ON_ONCE is from commit 9a53c69ba1c96d6145873afbeeb53db63caa4936 on Trond's bakeathon-0913 branch. We added some debug after we talked about my hypothesis of how the BUG() happens - basically how nfs4_opendata_to_nfs4_state could return NULL.

I'll be working on a fix. More info below.

-dros



This is the WARN_ON_ONCE from 9a53c69ba1c96d6145873afbeeb53db63caa4936:

static struct nfs4_state *
_nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
{
        struct inode *inode;
        struct nfs4_state *state = NULL;
        int ret;

        if (!data->rpc_done) {
                WARN_ON_ONCE(data->rpc_cached_open == 0);
                state = nfs4_try_open_cached(data);
                goto out;
        }

the traces:

[63088.591721] ------------[ cut here ]------------
[63088.591819] WARNING: CPU: 1 PID: 6162 at /home/dros/gb_root/linux/fs/nfs/nfs4
proc.c:1321 nfs4_opendata_to_nfs4_state+0x64/0x340 [nfsv4]()
[63088.591821] Modules linked in: rpcsec_gss_krb5 auth_rpcgss oid_registry nfsv4
 nfsv3 nfs_acl nfs lockd sunrpc fscache crc32c_intel aesni_intel aes_x86_64 glue
_helper lrw gf128mul ablk_helper cryptd e1000 ppdev floppy serio_raw parport_pc 
i2c_piix4 shpchp ata_generic freq_table parport i2c_core autofs4 mptspi scsi_tra
nsport_spi mptscsih mptbase
[63088.611697] CPU: 1 PID: 6162 Comm: 192.168.10.85-m Not tainted 3.12.0-rc2-branch-dros_bat+ #11
[63088.611699] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[63088.611701]  0000000000000009 ffff88006103bbd8 ffffffff81496736 ffff88007f22f148
[63088.611704]  0000000000000000 ffff88006103bc18 ffffffff8103b18b ffff88006103bc08
[63088.611706]  ffffffffa025eb46 ffff880049370000 0000000000000000 ffff88005eb83bd0
[63088.611709] Call Trace:
[63088.645368]  [<ffffffff81496736>] dump_stack+0x55/0x76
[63088.661391]  [<ffffffff8103b18b>] warn_slowpath_common+0x81/0x9b
[63088.661417]  [<ffffffffa025eb46>] ? nfs4_opendata_to_nfs4_state+0x64/0x340 [nfsv4]
[63088.661421]  [<ffffffff8103b1bf>] warn_slowpath_null+0x1a/0x1c
[63088.661425]  [<ffffffffa025eb46>] nfs4_opendata_to_nfs4_state+0x64/0x340 [nfsv4]
[63088.661430]  [<ffffffffa025eecd>] nfs4_open_recover_helper+0xab/0xdd [nfsv4]
[63088.661434]  [<ffffffffa025efb3>] nfs4_open_recover+0xb4/0x118 [nfsv4]
[63088.661439]  [<ffffffffa0261081>] nfs4_open_reclaim+0xa6/0x15f [nfsv4]
[63088.661450]  [<ffffffffa026e094>] nfs4_do_reclaim+0x12f/0x50e [nfsv4]
[63088.661512]  [<ffffffffa027ce2a>] ? pnfs_destroy_all_layouts+0x25/0x29 [nfsv4]
[63088.661520]  [<ffffffffa026e7d6>] nfs4_run_state_manager+0x363/0x598 [nfsv4]
[63088.661526]  [<ffffffffa026e473>] ? nfs4_do_reclaim+0x50e/0x50e [nfsv4]
[63088.662019]  [<ffffffff81058784>] kthread+0xb1/0xb9
[63088.662037]  [<ffffffff810586d3>] ? __kthread_parkme+0x65/0x65
[63088.662061]  [<ffffffff814a3c2c>] ret_from_fork+0x7c/0xb0
[63088.662064]  [<ffffffff810586d3>] ? __kthread_parkme+0x65/0x65
[63088.662066] ---[ end trace 9bc02d0521752ea6 ]---
[63088.675967] BUG: unable to handle kernel NULL pointer dereference at 00000000
00000030
[63088.682833] IP: [<ffffffffa026ea2d>] __nfs4_close+0x22/0x125 [nfsv4]
[63088.682878] PGD 7a131067 PUD 7a4df067 PMD 0 
[63088.682902] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[63088.682951] Modules linked in: rpcsec_gss_krb5 auth_rpcgss oid_registry nfsv4 nfsv3 nfs_acl nfs lockd sunrpc fscache crc32c_intel aesni_intel aes_x86_64 glue_helper lrw gf128mul ablk_helper cryptd e1000 ppdev floppy serio_raw parport_pc i2c_piix4 shpchp ata_generic freq_table parport i2c_core autofs4 mptspi scsi_transport_spi mptscsih mptbase
[63088.683192] CPU: 1 PID: 6162 Comm: 192.168.10.85-m Tainted: G        W    3.12.0-rc2-branch-dros_bat+ #11
[63088.683242] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[63088.683299] task: ffff88007a522100 ti: ffff88006103a000 task.ti: ffff88006103a000
[63088.683337] RIP: 0010:[<ffffffffa026ea2d>]  [<ffffffffa026ea2d>] __nfs4_close+0x22/0x125 [nfsv4]
[63088.683390] RSP: 0018:ffff88006103bc48  EFLAGS: 00010296
[63088.683415] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
[63088.683450] RDX: 0000000000000050 RSI: 0000000000000001 RDI: 0000000000000000
[63088.683486] RBP: ffff88006103bc88 R08: 0000000000000002 R09: 0000000000000000
[63088.683568] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[63088.683618] R13: 0000000000000001 R14: 0000000000000001 R15: 0000000000000000
[63088.683668] FS:  0000000000000000(0000) GS:ffff88007f220000(0000) knlGS:0000000000000000
[63088.683723] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[63088.683796] CR2: 0000000000000030 CR3: 000000007ab5b000 CR4: 00000000000407e0
[63088.683861] Stack:
[63088.683881]  ffff8800671c30c0 0000005000000000 ffff8800792fb138 0000000000000000
[63088.683938]  0000000000000000 0000000000000001 ffff88006103bcf0 ffff88005eb84a30
[63088.683994]  ffff88006103bc98 ffffffffa026eb45 ffff88006103bcd8 ffffffffa025eee8
[63088.684059] Call Trace:
[63088.684088]  [<ffffffffa026eb45>] nfs4_close_state+0x15/0x17 [nfsv4]
[63088.684138]  [<ffffffffa025eee8>] nfs4_open_recover_helper+0xc6/0xdd [nfsv4]
[63088.684190]  [<ffffffffa025efb3>] nfs4_open_recover+0xb4/0x118 [nfsv4]
[63088.684240]  [<ffffffffa0261081>] nfs4_open_reclaim+0xa6/0x15f [nfsv4]
[63088.684291]  [<ffffffffa026e094>] nfs4_do_reclaim+0x12f/0x50e [nfsv4]
[63088.684348]  [<ffffffffa027ce2a>] ? pnfs_destroy_all_layouts+0x25/0x29 [nfsv4]
[63088.684403]  [<ffffffffa026e7d6>] nfs4_run_state_manager+0x363/0x598 [nfsv4]
[63088.684457]  [<ffffffffa026e473>] ? nfs4_do_reclaim+0x50e/0x50e [nfsv4]
[63088.684507]  [<ffffffff81058784>] kthread+0xb1/0xb9
[63088.684544]  [<ffffffff810586d3>] ? __kthread_parkme+0x65/0x65
[63088.684587]  [<ffffffff814a3c2c>] ret_from_fork+0x7c/0xb0
[63088.684628]  [<ffffffff810586d3>] ? __kthread_parkme+0x65/0x65
[63088.684669] Code: 75 fc ff ff e9 78 fc ff ff 66 66 66 66 90 55 48 89 e5 41 57 41 89 cf 41 56 41 89 f6 41 55 41 54 53 48 89 fb 48 83 ec 18 89 55 cc <4c> 8b 67 30 49 8d 7c 24 78 e8 d7 de ff ff 4d 8d 6c 24 40 4c 89 
[63088.701801] RIP  [<ffffffffa026ea2d>] __nfs4_close+0x22/0x125 [nfsv4]
[63088.701894]  RSP <ffff88006103bc48>
[63088.701996] CR2: 0000000000000030
[63088.702270] ---[ end trace 9bc02d0521752ea7 ]---


