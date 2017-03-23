Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33620 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932128AbdCWSgW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Mar 2017 14:36:22 -0400
Received: by mail-io0-f182.google.com with SMTP id f84so3042548ioj.0
        for <linux-nfs@vger.kernel.org>; Thu, 23 Mar 2017 11:36:21 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 23 Mar 2017 14:36:20 -0400
Message-ID: <CAN-5tyE-HXkpiuF9WGu_r9oda0SvjyV8SpgnfYzFS=HNCwQvrg@mail.gmail.com>
Subject: NFSD oops when it receives operation it doesn't support
To: "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

I'm getting this oops when client sends an operation the server doesn't support.

in nfsd4_max_reply() it checks for NULL rsize_bop but non-supported
operation wouldn't have that set.

So maybe something like this for the fix:

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index cbeeda1..d86031b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2489,7 +2489,7 @@ bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)

 int nfsd4_max_reply(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
- if (op->opnum == OP_ILLEGAL)
+ if (op->opnum == OP_ILLEGAL || op->status == nfserr_notsupp)
  return op_encode_hdr_size * sizeof(__be32);

  BUG_ON(OPDESC(op)->op_rsize_bop == NULL);


localhost login: [ 1004.944784] ------------[ cut here ]------------
[ 1004.948710] kernel BUG at fs/nfsd/nfs4proc.c:2495!
[ 1004.950640] invalid opcode: 0000 [#1] SMP
[ 1004.951821] Modules linked in: rfcomm fuse xt_CHECKSUM
ipt_MASQUERADE nf_nat_masquerade_ipv4 tun ip6t_rpfilter ipt_REJECT
nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set
nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat
nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle
ip6table_security ip6table_raw iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle
iptable_security iptable_raw ebtable_filter ebtables ip6table_filter
ip6_tables iptable_filter vmw_vsock_vmci_transport vsock bnep
snd_seq_midi snd_seq_midi_event coretemp crct10dif_pclmul crc32_pclmul
ghash_clmulni_intel pcbc snd_ens1371 snd_ac97_codec aesni_intel
ac97_bus snd_seq ppdev uvcvideo crypto_simd cryptd glue_helper
vmw_balloon snd_pcm videobuf2_vmalloc btusb videobuf2_memops
[ 1004.967749]  btrtl videobuf2_v4l2 btbcm pcspkr btintel
videobuf2_core videodev bluetooth snd_rawmidi snd_timer nfit
snd_seq_device snd sg libnvdimm vmw_vmci shpchp i2c_piix4 soundcore
rfkill parport_pc parport acpi_cpufreq nfsd auth_rpcgss nfs_acl lockd
grace sunrpc ip_tables xfs libcrc32c sr_mod cdrom ata_generic sd_mod
pata_acpi crc32c_intel serio_raw vmwgfx drm_kms_helper syscopyarea
sysfillrect sysimgblt ata_piix ahci libahci e1000 fb_sys_fops ttm
mptspi scsi_transport_spi mptscsih mptbase drm i2c_core libata fjes
dm_mirror dm_region_hash dm_log dm_mod
[ 1004.979347] CPU: 0 PID: 5532 Comm: nfsd Tainted: G        W
4.11.0-rc3 #2
[ 1004.981579] Hardware name: VMware, Inc. VMware Virtual
Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1004.984473] task: ffff880073125a00 task.stack: ffffc900054a8000
[ 1004.986033] RIP: 0010:nfsd4_max_reply+0x31/0x40 [nfsd]
[ 1004.987259] RSP: 0018:ffffc900054abdc8 EFLAGS: 00010246
[ 1004.988466] RAX: 0000000000000000 RBX: 0000000000000040 RCX: 0000000000000003
[ 1004.989993] RDX: 0000000000000006 RSI: ffff880075dc93c0 RDI: ffff8800792a0000
[ 1004.991395] RBP: ffffc900054abe08 R08: ffffffffa04371e0 R09: ffff880043f8de00
[ 1004.992807] R10: ffff880075dca000 R11: 00000000fffffff5 R12: 0000000000000002
[ 1004.994178] R13: 0000000000000000 R14: ffff880075dc93c0 R15: ffff880075dc9000
[ 1004.995548] FS:  0000000000000000(0000) GS:ffff88007b600000(0000)
knlGS:0000000000000000
[ 1004.997104] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1004.998263] CR2: 0000557ccbfee698 CR3: 000000002b072000 CR4: 00000000001406f0
[ 1004.999663] Call Trace:
[ 1005.000159]  ? nfs4svc_decode_compoundargs+0x1c5/0x540 [nfsd]
[ 1005.001273]  nfsd_dispatch+0x54/0x1f0 [nfsd]
[ 1005.002139]  svc_process_common+0x387/0x740 [sunrpc]
[ 1005.003150]  svc_process+0x105/0x1c0 [sunrpc]
[ 1005.004002]  nfsd+0xe9/0x160 [nfsd]
[ 1005.004749]  kthread+0x101/0x140
[ 1005.005431]  ? nfsd_destroy+0x60/0x60 [nfsd]
[ 1005.006294]  ? kthread_park+0x90/0x90
[ 1005.007013]  ret_from_fork+0x2c/0x40
[ 1005.007738] Code: 63 06 3d 3c 27 00 00 74 1c 48 8d 04 40 48 c1 e0
04 48 8b 80 98 72 43 a0 48 85 c0 74 0e 55 48 89 e5 ff d0 5d c3 b8 08
00 00 00 c3 <0f> 0b 0f 1f 00 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00
00 8b
[ 1005.011446] RIP: nfsd4_max_reply+0x31/0x40 [nfsd] RSP: ffffc900054abdc8
