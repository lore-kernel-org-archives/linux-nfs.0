Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:48900 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752551Ab3AHXDZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2013 18:03:25 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Fabio Estevam <festevam@gmail.com>
CC: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS crash on linux-next 20130108
Date: Tue, 8 Jan 2013 23:03:22 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA911993EDB@SACEXCMBX04-PRD.hq.netapp.com>
References: <CAOMZO5Dpez4ffFQ0E1QH+PgAAMpOH8hjWr6mJaH+dkrfNpVSVQ@mail.gmail.com>
In-Reply-To: <CAOMZO5Dpez4ffFQ0E1QH+PgAAMpOH8hjWr6mJaH+dkrfNpVSVQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-08 at 20:42 -0200, Fabio Estevam wrote:
+AD4- Hi,
+AD4- 
+AD4- Trying to mount NFS with linux 20130108 on a ARM mx51 board I get:
+AD4- 
+AD4- Unable to handle kernel NULL pointer dereference at virtual address 00000018
+AD4- pgd +AD0- 80004000
+AD4- +AFs-00000018+AF0- +ACo-pgd+AD0-00000000
+AD4- Internal error: Oops: 5 +AFsAIw-1+AF0- SMP ARM
+AD4- Modules linked in:
+AD4- CPU: 0    Not tainted  (3.8.0-rc2-next-20130108+- +ACM-998)
+AD4- PC is at xprt+AF8-release+-0x1bc/0x248
+AD4- LR is at rpc+AF8-do+AF8-put+AF8-task+-0x40/0xa0
+AD4- pc : +AFsAPA-804ed6f4+AD4AXQ-    lr : +AFsAPA-804f1814+AD4AXQ-    psr: 60000113
+AD4- sp : 9f855b90  ip : 9f855bb8  fp : 9f855bb4
+AD4- r10: 9f1fb300  r9 : 00000001  r8 : 9f855dac
+AD4- r7 : 9f855d50  r6 : 9f1fa280  r5 : 00000000  r4 : 9f1fa280
+AD4- r3 : 00000000  r2 : 00000000  r1 : 00000000  r0 : 9f1fa280
+AD4- Flags: nZCv  IRQs on  FIQs on  Mode SVC+AF8-32  ISA ARM  Segment kernel
+AD4- Control: 10c5387d  Table: 90004019  DAC: 00000017
+AD4- Process swapper/0 (pid: 1, stack limit +AD0- 0x9f854238)
+AD4- Stack: (0x9f855b90 to 0x9f856000)
+AD4- 5b80:                                     00000000 9f1fa280 00000000 00000000
+AD4- 5ba0: 9f855d50 9f855dac 9f855bd4 9f855bb8 804f1814 804ed544 00000002 00000000
+AD4- 5bc0: 9f1f6a00 00000011 9f855be4 9f855bd8 804f18a0 804f17e0 9f855c1c 9f855be8
+AD4- 5be0: 804eba8c 804f1898 9f855c1c 00000000 9f1f6a00 9f855c20 80558058 00000000
+AD4- 5c00: 00000000 00000600 80707300 9f1f6a00 9f855c44 9f855c20 804ebb3c 804eba3c
+AD4- 5c20: 8070c14c 00000000 00000000 8070c3f0 9f855d50 9f855cb8 9f855cb4 9f855c48
+AD4- 5c40: 804ebd60 804ebaf0 00000000 806e38c8 9f855c94 9f855c60 80046520 8003d9fc
+AD4- 5c60: b8c63f00 00000001 00000003 806e38d0 40000113 00000000 00000001 00000011
+AD4- 5c80: 80707300 00000000 9f1fe64c 00000010 9f1fcfc0 00000000 00000001 9f855d80
+AD4- 5ca0: 00000011 80707300 9f855d3c 9f855cb8 801a7fd4 804ebc0c 80707300 00000011
+AD4- 5cc0: 9f1fe64c 00000010 00000000 00000000 9f1fcfc0 80522438 00000000 00000001
+AD4- 5ce0: 00000001 00000000 00000000 00000000 00000000 9f1fb300 9f855dac 9f855d50
+AD4- 5d00: 00000000 9f1f7000 9f855cf0 00000000 9f801180 9f1fe600 9f855de4 806e6070
+AD4- 5d20: 00008001 9f1fcf40 00008001 9f1fcf40 9f855ddc 9f855d40 8019ee7c 801a7f10
+AD4- 5d40: 9f1fe600 00000000 00000000 9f1f8028 9f1fe600 00000000 9f855ddc 9f801180
+AD4- 5d60: 00000000 9f1fcf4d 806db178 00001000 00008001 9f1fcf40 9f855dbc 9f855d88
+AD4- 5d80: 9f1fe64c 00000010 9f1fcfc0 9f1f7000 00000001 00000011 9f1fb300 00000000
+AD4- 5da0: 9f855dac 9f855d50 80707300 0000000c 00000000 806e6070 9f1fe600 00000400
+AD4- 5dc0: 9f1fcf40 00001000 00008001 9f1fcf40 9f855e24 9f855de0 801a028c 8019ed5c
+AD4- 5de0: 00000005 8019e80c 8019d600 9f1fe600 00000000 9f1fb300 80754a08 9f1fb240
+AD4- 5e00: 806e5c70 806e5c70 00008001 9f1f8000 9f1fcf00 00008001 9f855e54 9f855e28
+AD4- 5e20: 800b728c 8019fe68 9f1f8000 00000060 806e5c70 9f1fb240 806e5c70 9f1fcf40
+AD4- 5e40: 9f1f8000 9f1fcf00 9f855e7c 9f855e58 800d15ac 800b727c 9f1f8000 00000060
+AD4- 5e60: 806e5c70 9f1f8000 806e21ec 9f1fcf40 9f855ecc 9f855e80 800d35e8 800d1564
+AD4- 5e80: 9f855e9c 9f855e90 9f80d250 9f4093b8 9f855ecc 9f855ea0 800d33f8 80514c38
+AD4- 5ea0: 00008001 9f82d000 806c6f94 00008001 00000000 000000a4 8069220c 806cea78
+AD4- 5ec0: 9f855f04 9f855ed0 800d3dbc 800d3490 9f1f8000 2e343432 80003238 9f1fcf00
+AD4- 5ee0: 9f1fcf40 9f1f8000 00000005 00000006 806dd678 000003e8 9f855f34 9f855f08
+AD4- 5f00: 80692ff0 800d3d3c 806c6a8c 00000010 806c6f94 806c6a8c 8070d4e0 806c43fd
+AD4- 5f20: 806c43c4 8070d480 9f855f54 9f855f38 8069320c 80692f9c 9f855f54 9f855f48
+AD4- 5f40: 806c43e4 00000007 9f855f94 9f855f58 806929fc 806930b0 00000007 00000007
+AD4- 5f60: 8069220c 00000000 00000000 00000000 8050b0b0 00000000 00000000 00000000
+AD4- 5f80: 00000000 00000000 9f855fac 9f855f98 8050b0c0 80692880 ffffffff 00000000
+AD4- 5fa0: 00000000 9f855fb0 8000e598 8050b0bc 00000000 00000000 00000000 00000000
+AD4- 5fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
+AD4- 5fe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
+AD4- Backtrace:
+AD4- +AFsAPA-804ed538+AD4AXQ- (xprt+AF8-release+-0x0/0x248) from +AFsAPA-804f1814+AD4AXQ-
+AD4- (rpc+AF8-do+AF8-put+AF8-task+-0x40/0xa0)
+AD4-  r8:9f855dac r7:9f855d50 r6:00000000 r5:00000000
+AD4- r4:+------------------------------+-
+AD4- r3:00000000                                         +AHw-
+AD4-            +AHw-
+AD4- +AFsAPA-804f17d4+AD4AXQ- (rpc+AF8-do+AF8-put+AF8-task+-0x0/0xa0) from +AFsAPA-804f1+AHw-  Cannot open
+AD4- /dev/ttyUSB0+ACE-  +AHw-
+AD4-  r6:00000011 r5:9f1f6a00 r4:00000000 r3:00000002    +AHw-
+AD4-            +AHw-
+AD4- +AFsAPA-804f188c+AD4AXQ- (rpc+AF8-put+AF8-task+-0x0/0x18) from
+AD4- +AFsAPA-804eba8c+------------------------------+-
+AD4- +AFsAPA-804eba30+AD4AXQ- (rpc+AF8-call+AF8-sync+-0x0/0xb4) from +AFsAPA-804ebb3c+AD4AXQ- (rpc+AF8-ping+-0x58/0x78)
+AD4-  r4:9f1f6a00
+AD4- +AFsAPA-804ebae4+AD4AXQ- (rpc+AF8-ping+-0x0/0x78) from +AFsAPA-804ebd60+AD4AXQ- (rpc+AF8-create+-0x160/0x1c0)
+AD4-  r4:9f855cb8
+AD4- +AFsAPA-804ebc00+AD4AXQ- (rpc+AF8-create+-0x0/0x1c0) from +AFsAPA-801a7fd4+AD4AXQ- (nfs+AF8-mount+-0xd0/0x11c)
+AD4-  r6:80707300 r5:00000011 r4:9f855d80
+AD4- +AFsAPA-801a7f04+AD4AXQ- (nfs+AF8-mount+-0x0/0x11c) from +AFsAPA-8019ee7c+AD4AXQ- (nfs+AF8-try+AF8-mount+-0x12c/0x244)
+AD4- +AFsAPA-8019ed50+AD4AXQ- (nfs+AF8-try+AF8-mount+-0x0/0x244) from +AFsAPA-801a028c+AD4AXQ-
+AD4- (nfs+AF8-fs+AF8-mount+-0x430/0x844)
+AD4- +AFsAPA-8019fe5c+AD4AXQ- (nfs+AF8-fs+AF8-mount+-0x0/0x844) from +AFsAPA-800b728c+AD4AXQ- (mount+AF8-fs+-0x1c/0xd8)
+AD4- +AFsAPA-800b7270+AD4AXQ- (mount+AF8-fs+-0x0/0xd8) from +AFsAPA-800d15ac+AD4AXQ- (vfs+AF8-kern+AF8-mount+-0x54/0xc8)
+AD4-  r9:9f1fcf00 r8:9f1f8000 r6:9f1fcf40 r5:806e5c70 r4:9f1fb240
+AD4- +AFsAPA-800d1558+AD4AXQ- (vfs+AF8-kern+AF8-mount+-0x0/0xc8) from +AFsAPA-800d35e8+AD4AXQ- (do+AF8-mount+-0x164/0x8ac)
+AD4-  r8:9f1fcf40 r7:806e21ec r6:9f1f8000 r5:806e5c70 r4:00000060
+AD4- r3:9f1f8000
+AD4- +AFsAPA-800d3484+AD4AXQ- (do+AF8-mount+-0x0/0x8ac) from +AFsAPA-800d3dbc+AD4AXQ- (sys+AF8-mount+-0x8c/0xc0)
+AD4- +AFsAPA-800d3d30+AD4AXQ- (sys+AF8-mount+-0x0/0xc0) from +AFsAPA-80692ff0+AD4AXQ- (mount+AF8-root+-0x60/0x114)
+AD4-  r7:000003e8 r6:806dd678 r5:00000006 r4:00000005
+AD4- +AFsAPA-80692f90+AD4AXQ- (mount+AF8-root+-0x0/0x114) from +AFsAPA-8069320c+AD4AXQ-
+AD4- (prepare+AF8-namespace+-0x168/0x1cc)
+AD4-  r7:8070d480 r6:806c43c4 r5:806c43fd r4:8070d4e0
+AD4- +AFsAPA-806930a4+AD4AXQ- (prepare+AF8-namespace+-0x0/0x1cc) from +AFsAPA-806929fc+AD4AXQ-
+AD4- (kernel+AF8-init+AF8-freeable+-0x188/0x1cc)
+AD4-  r5:00000007 r4:806c43e4
+AD4- +AFsAPA-80692874+AD4AXQ- (kernel+AF8-init+AF8-freeable+-0x0/0x1cc) from +AFsAPA-8050b0c0+AD4AXQ-
+AD4- (kernel+AF8-init+-0x10/0xec)
+AD4- +AFsAPA-8050b0b0+AD4AXQ- (kernel+AF8-init+-0x0/0xec) from +AFsAPA-8000e598+AD4AXQ- (ret+AF8-from+AF8-fork+-0x14/0x3c)
+AD4-  r4:00000000 r3:ffffffff
+AD4- Code: e5931038 eb005496 eaffff9f e590300c (e5935018)
+AD4- ---+AFs- end trace 4a377447fb5cfae4 +AF0----
+AD4- Kernel panic - not syncing: Attempted to kill init+ACE- exitcode+AD0-0x0000000b
+AD4- 
+AD4- Any ideas or suggestions?

That issue is known, and should be fixed in today's linux-next branch.
It was due to a missing test for task-+AD4-tk+AF8-client+ACEAPQ-NULL in xprt+AF8-release.
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
