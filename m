Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:43494 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932162AbdJZIVa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 26 Oct 2017 04:21:30 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 2CF2D280066
        for <linux-nfs@vger.kernel.org>; Thu, 26 Oct 2017 10:21:28 +0200 (CEST)
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
        by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id DD2EC45D9
        for <linux-nfs@vger.kernel.org>; Thu, 26 Oct 2017 10:21:27 +0200 (MEST)
Date: Thu, 26 Oct 2017 10:21:27 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1422255296.3062600.1509006087862.JavaMail.zimbra@desy.de>
Subject: Kernel bug triggered with xfstest generic/113
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Against dCache nfs server:

[ 3987.717284] ------------[ cut here ]------------                                                                                                                                           
[ 3987.717286] kernel BUG at fs/inode.c:567!                                                                                                                                                  
[ 3987.717292] invalid opcode: 0000 [#1] SMP                                                                                                                                                  
[ 3987.717293] Modules linked in: loop nfs_layout_nfsv41_files rpcsec_gss_krb5 nfsv4 nfs lockd grace fscache binfmt_misc af_packet nf_conntrack_netbios_ns nf_conntrack_broadcast xt_tcpudp xt
_CT ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ipt_REJECT nf_reject_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack libcrc32c nfnetlink ip6table_mangle ip6ta
ble_raw ip6table_security iptable_mangle iptable_raw iptable_security ip6table_filter ip6_tables iptable_filter btrfs xor zstd_decompress zstd_compress xxhash lzo_compress zlib_deflate raid6
_pq snd_hda_codec_idt snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hda_core snd_hwdep snd_seq iTCO_wdt iTCO_vendor_support snd_seq_device snd_timer lpc_ich mfd_core tpm_tis snd_pcm 
tpm_tis_core i2c_i801 snd tpm auth_rpcgss oid_registry                                                                                                                                        
[ 3987.717340]  sunrpc ip_tables x_tables serio_raw e1000e ptp pps_core autofs4                                                                                                               
[ 3987.717349] CPU: 1 PID: 31883 Comm: rm Not tainted 4.14.0-rc6-01076-gbb176f67090c #120                                                                                                     [ 3987.717350] Hardware name: Comptronic pczW1007/DX38BT, BIOS BTX3810J.86A.1893.2008.1009.1712 10/09/2008                                                                                    
[ 3987.717353] task: ffff880107f7c480 task.stack: ffff88012a830000                             
[ 3987.717358] RIP: 0010:evict+0x161/0x180                                                     
[ 3987.717360] RSP: 0018:ffff88012a833e80 EFLAGS: 00010202                                     
[ 3987.717362] RAX: ffffffff81806110 RBX: ffff880100037800 RCX: ffff8801000378a0               
[ 3987.717364] RDX: ffffffff81806110 RSI: ffff8801000378a0 RDI: ffffffff81806108               
[ 3987.717366] RBP: ffff88012a833e98 R08: 0000000000000000 R09: ffff88012a03d6e8               
[ 3987.717368] R10: ffff88012a03d6f8 R11: ffff88012a03d6f8 R12: ffff880100037910               
[ 3987.717370] R13: ffffffffa0404540 R14: 00000000ffffff9c R15: 0000000000000000               
[ 3987.717372] FS:  00007faddfd6e700(0000) GS:ffff88012fc80000(0000) knlGS:0000000000000000    
[ 3987.717375] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033                               
[ 3987.717377] CR2: 00005653ab778470 CR3: 000000012840c000 CR4: 00000000000406e0               
[ 3987.717378] Call Trace:                                                                     
[ 3987.717382]  iput+0xf9/0x1c0                                                                
[ 3987.717385]  do_unlinkat+0x18d/0x2f0                                                        
[ 3987.717388]  SyS_unlinkat+0x16/0x30                                                         
[ 3987.717392]  entry_SYSCALL_64_fastpath+0x13/0x94                                            
[ 3987.717394] RIP: 0033:0x7faddf8a0c17                                                        
[ 3987.717396] RSP: 002b:00007ffc44a11468 EFLAGS: 00000246 ORIG_RAX: 0000000000000107          
[ 3987.717399] RAX: ffffffffffffffda RBX: 000055ccd0723428 RCX: 00007faddf8a0c17
[ 3987.717401] RDX: 0000000000000000 RSI: 000055ccd07220f0 RDI: 00000000ffffff9c
[ 3987.717403] RBP: 000055ccd0723320 R08: 0000000000000003 R09: 0000000000000000
[ 3987.717404] R10: 0000000000000100 R11: 0000000000000246 R12: 000055ccd0722060
[ 3987.717406] R13: 00007ffc44a115a0 R14: 00007faddfb6a1e4 R15: 0000000000000000
[ 3987.717408] Code: 89 df e8 23 7d fe ff eb 8f 48 83 bb 20 02 00 00 00 74 85 48 89 df e8 7f ad 01 00 0f b7 03 66 25 00 f0 e9 6b ff ff ff 0f 0b 0f 0b <0f> 0b 48 8d bb 68 01 00 00 e8 a1 9e fa
 ff 48 89 df e8 a9 f1 ff 
[ 3987.717443] RIP: evict+0x161/0x180 RSP: ffff88012a833e80
[ 3987.717445] ---[ end trace ca9a0f6be0e72301 ]---

Looks like it happens in post-test clean-up step (rm), though  some processes are still there:

root     18489 18329  0 Oct25 pts/1    00:00:00 /data/git/xfstests-dev/ltp/aio-stress -t 20 -s 10  -O -I 1000 /mnt/test/aiostress.18329.3 /mnt/test/aiostress.18329.3.20 /mnt/test/aiostress.18329.3.19 /mnt/test/aiostress.18329.3.18 /mnt/test/aiostress.18329.3.17 /mnt/test/aiostress.18329.3.16 /mnt/test/aiostress.18329.3.15 /mnt/test/aiostress.18329.3.14 /mnt/test/aiostress.18329.3.13 /mnt/test/aiostress.18329.3.12 /mnt/test/aiostress.18329.3.11 /mnt/test/aiostress.18329.3.10 /mnt/test/aiostress.18329.3.9 /mnt/test/aiostress.18329.3.8 /mnt/test/aiostress.18329.3.7 /mnt/test/aiostress.18329.3.6 /mnt/test/aiostress.18329.3.5 /mnt/test/aiostress.18329.3.4 /mnt/test/aiostress.18329.3.3 /mnt/test/aiostress.18329.3.2


I can always re-produce it.

  Tigran.
