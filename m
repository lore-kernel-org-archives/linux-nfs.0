Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2134CC10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 17:09:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E3AFB20880
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 17:09:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727190AbfDHRJd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 13:09:33 -0400
Received: from mail.bugwerft.de ([46.23.86.59]:58422 "EHLO mail.bugwerft.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727367AbfDHRJd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Apr 2019 13:09:33 -0400
X-Greylist: delayed 487 seconds by postgrey-1.27 at vger.kernel.org; Mon, 08 Apr 2019 13:09:30 EDT
Received: from [192.168.178.170] (pD95EFA44.dip0.t-ipconnect.de [217.94.250.68])
        by mail.bugwerft.de (Postfix) with ESMTPSA id 56AF32A9DB0;
        Mon,  8 Apr 2019 16:59:47 +0000 (UTC)
From:   Daniel Mack <daniel@zonque.org>
Openpgp: preference=signencrypt
Autocrypt: addr=daniel@zonque.org; prefer-encrypt=mutual; keydata=
 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
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Cc:     LKML <linux-kernel@vger.kernel.org>
Subject: 5.1.0-rc4: Oops in __rpc_execute() when trying to boot from NFS
Message-ID: <0412f79c-61a8-bfa4-26ce-1083a59d31e8@zonque.org>
Date:   Mon, 8 Apr 2019 19:01:21 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

I'm seeing the Oops below when trying to boot 5.1.0-rc4 on an ARM PXA3xx
platform. v5.0 did not show this effect with the same cmdline.

Relevant bits from the config are:

CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
# CONFIG_NFS_V4 is not set
# CONFIG_NFS_SWAP is not set
CONFIG_ROOT_NFS=y
CONFIG_NFS_FSCACHE=y
# CONFIG_NFSD is not set
CONFIG_NFS_COMMON=y

Anything else I can provide? I could bisect the issue if that helps.


Best regards,
Daniel


> [   10.226301] Unable to handle kernel NULL pointer dereference at virtual address 00000000
> [   10.234626] pgd = (ptrval)
> [   10.237325] [00000000] *pgd=00000000
> [   10.241157] Internal error: Oops: 80000005 [#1] PREEMPT ARM
> [   10.246708] Modules linked in:
> [   10.249750] CPU: 0 PID: 1 Comm: swapper Not tainted 5.1.0-rc4+ #585
> [   10.255967] Hardware name: Marvell PXA3xx (Device Tree Support)
> [   10.261840] PC is at   (null)
> [   10.264809] LR is at __rpc_execute+0x84/0x314
> [   10.269134] pc : [<00000000>]    lr : [<c05d32cc>]    psr: a8000013
> [   10.275352] sp : c603dbf8  ip : 00000002  fp : c0a1b4f4
> [   10.280531] r10: c663be40  r9 : c6721200  r8 : c663be40
> [   10.285710] r7 : 00000000  r6 : 00000000  r5 : c0a07008  r4 : c6630aa0
> [   10.292190] r3 : 00000000  r2 : ffff8ecc  r1 : 00001770  r0 : c6630aa0
> [   10.298671] Flags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
> [   10.305750] Control: 0000397f  Table: a0004018  DAC: 00000071
> [   10.311453] Process swapper (pid: 1, stack limit = 0x(ptrval))
> [   10.317243] Stack: (0xc603dbf8 to 0xc603e000)
> [   10.321570] dbe0:                                                       c6630aa0 00000000
> [   10.329694] dc00: 8a50acc0 8a50acc0 c6630aa0 c674f010 c603dc30 c674f000 c663be40 c05ca0b4
> [   10.337817] dc20: c0a07008 c0a07008 c603dc74 c05ca218 00000000 c674f000 00000000 00000000
> [   10.345941] dc40: c603dc74 c074c414 00000000 00000000 00000610 8a50acc0 00000000 c0a07008
> [   10.354067] dc60: c674f000 c6658e40 c603ddec c05ca2b8 c6754400 c074c428 00000000 00000000
> [   10.362191] dc80: 00000000 8a50acc0 c6721200 c674f000 c603dd30 c05cbfa8 c603dd30 c0a07008
> [   10.370315] dca0: c0a07008 c05cc1d0 00000006 c0a34820 00000000 c6742a7c 00000010 c6658d60
> [   10.378438] dcc0: 00000000 00000000 00000000 00000000 c6721100 c600a600 c600a610 00000026
> [   10.386563] dce0: c6742670 0001cb00 0001c200 c0a9147c c6742670 00000013 c0a07008 8a50acc0
> [   10.394688] dd00: c6658d80 c603dd88 c0a07008 c02b4e3c 00000000 c663be40 c603ddec c603de1c
> [   10.402811] dd20: 00000000 c6658d80 c603dd10 00000000 c0a34820 00000006 c6742a7c 00000010
> [   10.410934] dd40: 00000000 00000000 c6658d60 00000000 c0710a98 00000000 00000003 00000001
> [   10.419060] dd60: 00000000 00000000 00000000 8a50acc0 c603de1c c6742a00 c0a07008 c603de1c
> [   10.427185] dd80: c603ddec c02ab388 c6742a7c 00000010 c6658d60 c6658d80 00000003 00000006
> [   10.435310] dda0: c663be40 00000000 c603ddec c603de1c c0a34820 8a50acc0 c0a1b6cc c0a1b6cc
> [   10.443434] ddc0: c6742a00 c603de80 c603de1c c02ab400 c0a07008 00000000 00008000 c6721200
> [   10.451558] dde0: c0a07008 c6742a00 c6665036 0000000c 00000010 c6742a00 c6665036 c02ab5c0
> [   10.459682] de00: 00000080 c01c811c c6658d60 00000000 c6004780 00001000 c6060010 c666503b
> [   10.467807] de20: c6665047 c6060000 c603def4 c0a07008 000003e8 c01c9934 c6721222 c01b6c60
> [   10.475931] de40: c6721222 c672120d 00000015 8a50acc0 00000cc0 c0a1b6cc c672120d c6721200
> [   10.484055] de60: c0a07008 00008000 c6721200 c663be40 c0a1b4f4 c02ac7cc 00000000 c67211c0
> [   10.492180] de80: c02a9f28 c02a9d84 c6742a00 00000000 c663be40 8a50acc0 c0a07008 c67211c0
> [   10.500304] dea0: c6721180 00000020 c0a07008 c6665000 c67211c0 c6658d20 c0a1b4f4 c01ec264
> [   10.508429] dec0: c67211c0 c01be90c c67211c0 c6665000 00000001 00000000 c6721180 c01ddf68
> [   10.516552] dee0: 00000000 00000015 00000000 c6721180 c0924e01 c6020010 c50156e8 c6721180
> [   10.524677] df00: c08115c0 00008000 c6658d20 8a50acc0 c09248f9 00008000 c6658d20 c6721180
> [   10.532801] df20: c6665000 c07b7578 000003e8 00000000 00000000 c01de48c c6665000 c07b7578
> [   10.540925] df40: 00000005 c0a07008 c0a09408 c0a3e6d0 00000006 c090134c c09248f9 00000000
> [   10.549049] df60: 00000000 c0924e01 c09248f9 8a50acc0 00000000 c0a3e6d0 c0921858 00000000
> [   10.557172] df80: 00000000 00000000 00000000 c0901550 fffffffe 00002710 00000000 00000000
> [   10.565297] dfa0: c06748d8 c06748e0 00000000 c01010e0 00000000 00000000 00000000 00000000
> [   10.573420] dfc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> [   10.581544] dfe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
> [   10.589702] [<c05d32cc>] (__rpc_execute) from [<c05ca0b4>] (rpc_run_task+0x16c/0x178)
> [   10.597492] [<c05ca0b4>] (rpc_run_task) from [<c05ca218>] (rpc_call_sync+0x80/0xe0)
> [   10.605102] [<c05ca218>] (rpc_call_sync) from [<c05ca2b8>] (rpc_ping+0x40/0x64)
> [   10.612372] [<c05ca2b8>] (rpc_ping) from [<c05cbfa8>] (rpc_create_xprt+0xd4/0x16c)
> [   10.619897] [<c05cbfa8>] (rpc_create_xprt) from [<c05cc1d0>] (rpc_create+0x190/0x1c8)
> [   10.627680] [<c05cc1d0>] (rpc_create) from [<c02b4e3c>] (nfs_mount+0xd8/0x180)
> [   10.634873] [<c02b4e3c>] (nfs_mount) from [<c02ab388>] (nfs_request_mount.constprop.3+0x120/0x140)
> [   10.643779] [<c02ab388>] (nfs_request_mount.constprop.3) from [<c02ab400>] (nfs_try_mount+0x58/0x1d0)
> [   10.652935] [<c02ab400>] (nfs_try_mount) from [<c02ac7cc>] (nfs_fs_mount+0x3f4/0x4ec)
> [   10.660741] [<c02ac7cc>] (nfs_fs_mount) from [<c01ec264>] (legacy_get_tree+0x20/0x44)
> [   10.668545] [<c01ec264>] (legacy_get_tree) from [<c01be90c>] (vfs_get_tree+0x50/0x118)
> [   10.676427] [<c01be90c>] (vfs_get_tree) from [<c01ddf68>] (do_mount+0x990/0xc04)
> [   10.683782] [<c01ddf68>] (do_mount) from [<c01de48c>] (ksys_mount+0x70/0x98)
> [   10.690788] [<c01de48c>] (ksys_mount) from [<c090134c>] (mount_root+0x64/0x150)
> [   10.698055] [<c090134c>] (mount_root) from [<c0901550>] (prepare_namespace+0x118/0x178)
> [   10.706013] [<c0901550>] (prepare_namespace) from [<c06748e0>] (kernel_init+0x8/0x110)
> [   10.713884] [<c06748e0>] (kernel_init) from [<c01010e0>] (ret_from_fork+0x14/0x34)
> [   10.721397] Exception stack(0xc603dfb0 to 0xc603dff8)
> [   10.726407] dfa0:                                     00000000 00000000 00000000 00000000
> [   10.734528] dfc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> [   10.742649] dfe0: 00000000 00000000 00000000 00000000 00000013 00000000
> [   10.749218] Code: bad PC value
> [   10.752812] ---[ end trace f3e6d8ea2a09d643 ]---
