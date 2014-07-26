Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:53925 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751921AbaGZQVx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Jul 2014 12:21:53 -0400
Date: Sat, 26 Jul 2014 17:21:43 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Christoph Hellwig <hch@lst.de>, trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: [BUG] nfs3_list_one_acl oops
Message-ID: <20140726162143.GB20396@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Today, I got a nice oops while trying to update my initramfs:

Alignment trap: not handling instruction e1901f9f at [<c020b8ec>]
Unhandled fault: alignment exception (0x001) at 0xffffffa1
Internal error: : 1 [#1] SMP ARM
Modules linked in: bnep rfcomm bluetooth nfsd exportfs hid_cypress brcmfmac brcmutil snd_soc_fsl_spdif imx_pcm_dma imx2_wdt imx_thermal imx_sdma snd_soc_imx_spdif
CPU: 2 PID: 1704 Comm: cp Not tainted 3.16.0-rc6+ #1281
task: e9be5580 ti: e3ce6000 task.ti: e3ce6000
PC is at nfs3_list_one_acl+0x38/0xa0
LR is at get_acl+0x4c/0x60
pc : [<c020b8f0>]    lr : [<c0144774>]    psr: a00d0013
sp : e3ce7f08  ip : e3ce7ee8  fp : e3ce7f2c
r10: 00000000  r9 : e3ce6000  r8 : 00000000
r7 : 00000000  r6 : c06d728c  r5 : 00000000  r4 : e3ce7f3c
r3 : 00000000  r2 : e3ce7ea4  r1 : 00003fe7  r0 : ffffffa1
Flags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 10c5387d  Table: 33dec04a  DAC: 00000015
Process cp (pid: 1704, stack limit = 0xe3ce6248)
Stack: (0xe3ce7f08 to 0xe3ce8000)
7f00:                   00000000 e3ce7f3c 00000000 e9ff3858 00000000 00000000
7f20: e3ce7f5c e3ce7f30 c020c0f8 c020b8c4 00000000 e3ce7f3c 00000000 00000000
7f40: 00000000 c020c0b4 00000000 e8c05198 e3ce7f84 e3ce7f60 c011a0d0 c020c0c0
7f60: e3d04600 e3d04600 00000000 00000000 c000ec04 00000000 e3ce7fa4 e3ce7f88
7f80: c011aed8 c011a07c 00008000 be9995a8 b6f756db 000000ea 00000000 e3ce7fa8
7fa0: c000ea80 c011aeb0 00008000 be9995a8 00000003 00000000 00000000 00022150
7fc0: 00008000 be9995a8 b6f756db 000000ea be9994d8 b6f10d99 00000003 be9995a8
7fe0: be9993a0 be999390 b6f105db b6ea8ca0 800d0010 00000003 6f74616c 69662d72
Backtrace: 
[<c020b8b8>] (nfs3_list_one_acl) from [<c020c0f8>] (nfs3_listxattr+0x44/0x80)
[<c020c0b4>] (nfs3_listxattr) from [<c011a0d0>] (listxattr+0x60/0x11c)
[<c011a070>] (listxattr) from [<c011aed8>] (SyS_flistxattr+0x34/0x58)
[<c011aea4>] (SyS_flistxattr) from [<c000ea80>] (ret_fast_syscall+0x0/0x30)
Code: 0a000016 f57ff05b f590f000 e1901f9f (e2411001) 
---[ end trace 05ecbdab16531f0b ]---

The problem is that get_acl() does *not* return NULL on error, it returns
an error code.  Hence this:

+	acl = get_acl(inode, type);
+	if (!acl)
+		return 0;

introduced by 74adf83f5d77 ("nfs: only show Posix ACLs in listxattr if
actually present") ends up breaking when get_acl() fails (as is the case
if NFS is used against a server with ACL support disabled.)

The original commit was marked for stable, which means that this brokenness
is going to spread to all stable kernels.

Fixes: 74adf83f5d77 ("nfs: only show Posix ACLs in listxattr if actually present")
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: <stable@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
---

I've included <stable@vger.kernel.org> in the Cc list so they can hold off
spreading the broken patch further into stable trees until this issue is
resolved.

 fs/nfs/nfs3acl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 8f854dde4150..ada8c66aa9e5 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -256,7 +256,7 @@ nfs3_list_one_acl(struct inode *inode, int type, const char *name, void *data,
 	char *p = data + *result;
 
 	acl = get_acl(inode, type);
-	if (!acl)
+	if (IS_ERR(acl))
 		return 0;
 
 	posix_acl_release(acl);


-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.
