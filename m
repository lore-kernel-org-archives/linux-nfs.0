Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:32805 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751247AbdCIDn1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Mar 2017 22:43:27 -0500
Received: by mail-it0-f66.google.com with SMTP id g138so8894958itb.0
        for <linux-nfs@vger.kernel.org>; Wed, 08 Mar 2017 19:43:26 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] NFS: fix the fault nrequests decreasing for nfs_inode COPY
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <28d1102e-8288-46cb-e6b3-15f37c5dc391@gmail.com>
Date: Thu, 9 Mar 2017 11:36:36 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs_commit_file for NFSv4.2's COPY operation goes through
the commit path for normal WRITE, but without increase nrequests,
so, the nrequests decreased in nfs_commit_release_pages is fault.
After that, the nrequests will be wrong.

[ 5670.299881] ------------[ cut here ]------------
[ 5670.300295] WARNING: CPU: 0 PID: 27656 at fs/nfs/inode.c:127 nfs_clear_inode+0x66/0x90 [nfs]
[ 5670.300558] Modules linked in: nfsv4(E) nfs(E) fscache(E) tun bridge stp llc fuse ip_set nfnetlink vmw_vsock_vmci_transport vsock snd_seq_midi snd_seq_midi_event ppdev f2fs coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_ens1371 intel_rapl_perf gameport snd_ac97_codec vmw_balloon ac97_bus snd_seq snd_pcm joydev snd_rawmidi snd_timer snd_seq_device snd soundcore nfit parport_pc parport acpi_cpufreq tpm_tis tpm_tis_core tpm i2c_piix4 vmw_vmci shpchp nfsd auth_rpcgss nfs_acl lockd grace sunrpc xfs libcrc32c vmwgfx drm_kms_helper ttm drm e1000 crc32c_intel mptspi scsi_transport_spi serio_raw mptscsih mptbase ata_generic pata_acpi fjes [last unloaded: fscache]
[ 5670.302925] CPU: 0 PID: 27656 Comm: umount.nfs4 Tainted: G        W   E   4.11.0-rc1+ #519
[ 5670.303292] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 5670.304094] Call Trace:
[ 5670.304510]  dump_stack+0x63/0x86
[ 5670.304917]  __warn+0xcb/0xf0
[ 5670.305276]  warn_slowpath_null+0x1d/0x20
[ 5670.305661]  nfs_clear_inode+0x66/0x90 [nfs]
[ 5670.306093]  nfs4_evict_inode+0x61/0x70 [nfsv4]
[ 5670.306480]  evict+0xbb/0x1c0
[ 5670.306888]  dispose_list+0x4d/0x70
[ 5670.307233]  evict_inodes+0x178/0x1a0
[ 5670.307579]  generic_shutdown_super+0x44/0xf0
[ 5670.307985]  nfs_kill_super+0x21/0x40 [nfs]
[ 5670.308325]  deactivate_locked_super+0x43/0x70
[ 5670.308698]  deactivate_super+0x5a/0x60
[ 5670.309036]  cleanup_mnt+0x3f/0x90
[ 5670.309407]  __cleanup_mnt+0x12/0x20
[ 5670.309837]  task_work_run+0x80/0xa0
[ 5670.310162]  exit_to_usermode_loop+0x89/0x90
[ 5670.310497]  syscall_return_slowpath+0xaa/0xb0
[ 5670.310875]  entry_SYSCALL_64_fastpath+0xa7/0xa9
[ 5670.311197] RIP: 0033:0x7f1bb3617fe7
[ 5670.311545] RSP: 002b:00007ffecbabb828 EFLAGS: 00000206 ORIG_RAX: 00000000000000a6
[ 5670.311906] RAX: 0000000000000000 RBX: 0000000001dca1f0 RCX: 00007f1bb3617fe7
[ 5670.312239] RDX: 000000000000000c RSI: 0000000000000001 RDI: 0000000001dc83c0
[ 5670.312653] RBP: 0000000001dc83c0 R08: 0000000000000001 R09: 0000000000000000
[ 5670.312998] R10: 0000000000000755 R11: 0000000000000206 R12: 00007ffecbabc66a
[ 5670.313335] R13: 0000000001dc83a0 R14: 0000000000000000 R15: 0000000000000000
[ 5670.313758] ---[ end trace bf4bfe7764e4eb40 ]---

Cc: linux-kernel@vger.kernel.org
Fixes: 67911c8f18 ("NFS: Add nfs_commit_file()")
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/write.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e75b056..abb2c8a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1784,7 +1784,8 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 			(long long)req_offset(req));
 		if (status < 0) {
 			nfs_context_set_write_error(req->wb_context, status);
-			nfs_inode_remove_request(req);
+			if (req->wb_page)
+				nfs_inode_remove_request(req);
 			dprintk_cont(", error = %d\n", status);
 			goto next;
 		}
@@ -1793,7 +1794,8 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 		 * returned by the server against all stored verfs. */
 		if (!nfs_write_verifier_cmp(&req->wb_verf, &data->verf.verifier)) {
 			/* We have a match */
-			nfs_inode_remove_request(req);
+			if (req->wb_page)
+				nfs_inode_remove_request(req);
 			dprintk_cont(" OK\n");
 			goto next;
 		}
-- 
2.9.3

