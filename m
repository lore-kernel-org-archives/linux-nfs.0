Return-Path: <SRS0=OjhL=OU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D99A8C07E85
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 06:13:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 606B02082F
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 06:13:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 606B02082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cn.fujitsu.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727984AbeLKGNU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Dec 2018 01:13:20 -0500
Received: from mail.cn.fujitsu.com ([183.91.158.132]:44900 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1727225AbeLKGNU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2018 01:13:20 -0500
X-IronPort-AV: E=Sophos;i="5.56,341,1539619200"; 
   d="scan'208";a="49491040"
Received: from unknown (HELO cn.fujitsu.com) ([10.167.33.5])
  by heian.cn.fujitsu.com with ESMTP; 11 Dec 2018 14:13:17 +0800
Received: from G08CNEXCHPEKD01.g08.fujitsu.local (unknown [10.167.33.80])
        by cn.fujitsu.com (Postfix) with ESMTP id 2297B4B734CA
        for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2018 14:13:14 +0800 (CST)
Received: from [10.167.225.61] (10.167.225.61) by
 G08CNEXCHPEKD01.g08.fujitsu.local (10.167.33.89) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Tue, 11 Dec 2018 14:13:17 +0800
To:     <linux-nfs@vger.kernel.org>
From:   =?UTF-8?B?Q3VpLCBZdWUv5bSUIOaCpg==?= <cuiyue-fnst@cn.fujitsu.com>
Subject: test nfstest_pnfs in no pnfs env, nfs server crashes
Message-ID: <307436e3-ef67-fc19-c172-9adfb443c4dd@cn.fujitsu.com>
Date:   Tue, 11 Dec 2018 14:13:12 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.3
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
X-Originating-IP: [10.167.225.61]
X-yoursite-MailScanner-ID: 2297B4B734CA.AA033
X-yoursite-MailScanner: Found to be clean
X-yoursite-MailScanner-From: cuiyue-fnst@cn.fujitsu.com
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

when I tested nfstest_pnfs with“pnfs”option in /etc/exports (no pnfs 
env), nfs server crashes：

test step:

1. # cat /etc/exports

/nfsroot*(rw,insecure,no_subtree_check,no_root_squash,pnfs,fsid=1)

2,   # ./nfstest_pnfs --nfsversion=4.1  -e /nfsroot --server

environment:

   rhel8.0beta(4.18.0-32.el8.x86_64)

error message:

[  118.257524] WARNING: CPU: 7 PID: 1152 at fs/nfsd/blocklayout.c:232 
nfsd4_scsi_proc_getdeviceinfo+0x1ca/0x3b0 [nfsd]
[  118.257528] Modules linked in: snd_hda_codec_generic snd_hda_intel 
snd_hda_codec snd_hda_core crct10dif_pclmul crc32_pclmul snd_hwdep 
ghash_clmulni_intel snd_pcm snd_timer sg snd soundcore i2c_piix4 
virtio_balloon pcspkr joydev nfsd auth_rpcgss nfs_acl lockd grace sunrpc 
ip_tables xfs libcrc32c sr_mod sd_mod cdrom ata_generic qxl 
drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm 
ata_piix drm libata crc32c_intel virtio_net serio_raw virtio_console 
net_failover failover dm_mirror dm_region_hash dm_log dm_mod
[  118.257596] CPU: 7 PID: 1152 Comm: nfsd Kdump: loaded Not tainted 
4.18.0-32.el8.x86_64 #1
[  118.257596] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
[  118.257612] RIP: 0010:nfsd4_scsi_proc_getdeviceinfo+0x1ca/0x3b0 [nfsd]
[  118.257614] Code: 39 00 00 4c 89 ff 48 89 34 24 e8 61 6b 9a c1 48 89 
ef e8 49 aa 85 c1 48 8b 34 24 c7 04 24 00 00 00 00 48 89 f3 e9 e6 fe ff 
ff <0f> 0b b8 ea ff ff ff 48 83 c4 08 89 c7 5b 5d 41 5c 41 5d 41 5e 41
[  118.257615] RSP: 0018:ffffb348027cbd70 EFLAGS: 00010246
[  118.257616] RAX: 0000000004120800 RBX: 00000000000000fc RCX: 
0000000000000000
[  118.257618] RDX: 00000000b25822a2 RSI: 0000000000000000 RDI: 
ffff9c0e87c03080
[  118.257621] RBP: ffff9c1031708240 R08: ffff9c10359a7140 R09: 
ffff9c0e87c03080
[  118.257622] R10: ffffe4730ad650c0 R11: ffff9c10331e5a00 R12: 
ffff9c102fb32000
[  118.257623] R13: ffff9c1032b96600 R14: ffff9c102d72aff8 R15: 
0000000000000000
[  118.257638] FS:  0000000000000000(0000) GS:ffff9c1035980000(0000) 
knlGS:0000000000000000
[  118.257639] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  118.257640] CR2: 00007f60683e61c4 CR3: 00000002b17ee000 CR4: 
00000000001406e0
[  118.257647] Call Trace:
[  118.257684]  nfsd4_getdeviceinfo+0x9b/0x130 [nfsd]
[  118.257693]  nfsd4_proc_compound+0x33e/0x640 [nfsd]
[  118.257701]  ? nfsd4_decode_compound.constprop.50+0x3b2/0x460 [nfsd]
[  118.257707]  nfsd_dispatch+0x9e/0x210 [nfsd]
[  118.257724]  svc_process_common+0x46e/0x6c0 [sunrpc]
[  118.257731]  ? nfsd_destroy+0x50/0x50 [nfsd]
[  118.257754]  svc_process+0xb7/0xf0 [sunrpc]
[  118.257760]  nfsd+0xe3/0x140 [nfsd]
[  118.257784]  kthread+0x112/0x130
[  118.257790]  ? kthread_bind+0x30/0x30
[  118.257804]  ret_from_fork+0x35/0x40
[  118.257810] ---[ end trace bfda1308b0b23ec9 ]---


