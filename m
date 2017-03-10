Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33443 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753945AbdCJBw2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Mar 2017 20:52:28 -0500
Received: by mail-io0-f194.google.com with SMTP id f84so5729799ioj.0
        for <linux-nfs@vger.kernel.org>; Thu, 09 Mar 2017 17:52:27 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] nfsd: map the ENOKEY to nfserr_perm for avoiding warning
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <b78ad150-e465-3071-35e3-a25da3444c44@gmail.com>
Date: Fri, 10 Mar 2017 09:52:20 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ext4 and f2fs filesystems support encrypted directories and files now,
access those files may return ENOKEY error, so that the following WARNING
will be showed out.

Maybe maps ENOKEY to nfserr_perm is better than nfserr_io.

[ 1295.411759] ------------[ cut here ]------------
[ 1295.411787] WARNING: CPU: 0 PID: 12786 at fs/nfsd/nfsproc.c:796 nfserrno+0x74/0x80 [nfsd]
[ 1295.411806] nfsd: non-standard errno: -126
[ 1295.411816] Modules linked in: nfsd nfs_acl auth_rpcgss nfsv4 nfs lockd fscache tun bridge stp llc fuse ip_set nfnetlink vmw_vsock_vmci_transport vsock snd_seq_midi snd_seq_midi_event coretemp crct10dif_pclmul crc32_generic crc32_pclmul snd_ens1371 gameport ghash_clmulni_intel snd_ac97_codec f2fs intel_rapl_perf ac97_bus snd_seq ppdev snd_pcm snd_rawmidi snd_timer vmw_balloon snd_seq_device snd joydev soundcore parport_pc parport nfit acpi_cpufreq tpm_tis vmw_vmci tpm_tis_core tpm shpchp i2c_piix4 grace sunrpc xfs libcrc32c vmwgfx drm_kms_helper ttm drm crc32c_intel e1000 mptspi scsi_transport_spi serio_raw mptscsih mptbase ata_generic pata_acpi fjes [last unloaded: nfs_acl]
[ 1295.412522] CPU: 0 PID: 12786 Comm: nfsd Tainted: G        W       4.11.0-rc1+ #521
[ 1295.412959] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1295.413814] Call Trace:
[ 1295.414252]  dump_stack+0x63/0x86
[ 1295.414666]  __warn+0xcb/0xf0
[ 1295.415087]  warn_slowpath_fmt+0x5f/0x80
[ 1295.415502]  ? put_filp+0x42/0x50
[ 1295.415927]  nfserrno+0x74/0x80 [nfsd]
[ 1295.416339]  nfsd_open+0xd7/0x180 [nfsd]
[ 1295.416746]  nfs4_get_vfs_file+0x367/0x3c0 [nfsd]
[ 1295.417182]  ? security_inode_permission+0x41/0x60
[ 1295.417591]  nfsd4_process_open2+0x9b2/0x1200 [nfsd]
[ 1295.418007]  nfsd4_open+0x481/0x790 [nfsd]
[ 1295.418409]  nfsd4_proc_compound+0x395/0x680 [nfsd]
[ 1295.418812]  nfsd_dispatch+0xb8/0x1f0 [nfsd]
[ 1295.419233]  svc_process_common+0x4d9/0x830 [sunrpc]
[ 1295.419631]  svc_process+0xfe/0x1b0 [sunrpc]
[ 1295.420033]  nfsd+0xe9/0x150 [nfsd]
[ 1295.420420]  kthread+0x101/0x140
[ 1295.420802]  ? nfsd_destroy+0x60/0x60 [nfsd]
[ 1295.421199]  ? kthread_park+0x90/0x90
[ 1295.421598]  ret_from_fork+0x2c/0x40
[ 1295.421996] ---[ end trace 0d5a969cd7852e1f ]---

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfsproc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index fa82b77..03a7e9d 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -786,6 +786,7 @@ nfserrno (int errno)
 		{ nfserr_serverfault, -ESERVERFAULT },
 		{ nfserr_serverfault, -ENFILE },
 		{ nfserr_io, -EUCLEAN },
+		{ nfserr_perm, -ENOKEY },
 	};
 	int	i;
 
-- 
2.9.3

