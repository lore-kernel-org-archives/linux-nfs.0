From: Catalin Marinas <catalin.marinas@arm.com>
Subject: NULL pointer dereference in __put_nfs_open_context()
Date: Tue, 11 Aug 2009 12:38:39 +0100
Message-ID: <1249990719.27150.52.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:52589 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752308AbZHKL5M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Aug 2009 07:57:12 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

While running LTP on 2.6.31-rc5 (plus some additional patches but not
related to NFS) on an ARM platform with the root filesystem over NFS I
get the oops below with diotest4 (in testcases/kernel/io/direct_io/):


Unable to handle kernel NULL pointer dereference at virtual address 00000008
pgd = cc3bc000 [00000008] *pgd=7b0bf031st4, *pte=00000000:  Out of range 
Internal error: Oops: 17 [#6] PREEMPT
Modules linked in:
CPU: 0    Tainted: G      D     (2.6.31-rc5 #285)
PC is at __put_nfs_open_context+0x4/0x68
LR is at put_nfs_open_context+0x9/0xc
pc : [<c00e3c0c>]    lr : [<c00e3cc5>]    psr: 60000033
sp : de63fda0  ip : cb0bb800  fp : c3dca110
r10: 00000000  r9 : de63ff48  r8 : fffffff2
r7 : dad86348  r6 : 00001000  r5 : 00000000  r4 : d7f971e0
r3 : 00000000  r2 : de63fda0  r1 : 00000000  r0 : 00000000
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA Thumb  Segment user
Control: 70c5387d  Table: 7c3bc019  DAC: 00000015
Process diotest4 (pid: 12915, stack limit = 0xde63e2f0)
Stack: (0xde63fda0 to 0xde640000)
fda0: d7f971e0 00000000 00001000 dad86348 fffffff2 c00e3cc5 d7f971e0 c00e9459 
fdc0: d7f971e0 c00e7aa5 00000001 00000000 d7f9735c 00000000 cc3c6b70 c010fd6d 
fde0: 00000001 de63feb8 00000000 00000000 c3dca000 c3dca008 de63e000 00001000 
fe00: 00001000 40044000 c292da80 de63ff4c 00001000 00000000 00001000 00000000 
fe20: 00000026 00000000 df343440 de63fe40 c02089b0 00000000 df9fc200 00000001 
fe40: 00000000 00000000 00000000 df2eec80 c3dca110 c3da84b0 deee0c40 00001000 
fe60: de63feb8 00001000 de63ff48 00000001 c3dca110 c00e2a1b 00001000 00000000 
fe80: 00000000 00000000 00000000 de63feb8 deee0c40 de63ff80 00001000 de63ff80 
fea0: de63e000 00000000 00000fff c0075049 00001000 00000000 de72c000 00000001 
fec0: 00000000 00000001 ffffffff deee0c40 00000000 00000000 00000000 00000000 
fee0: df32b600 df801f00 00000000 00000000 de72b0c0 df32b600 c004467d de63fefc 
ff00: de63fefc c0070bef 00001000 00000000 00000018 c0c65500 de72c0d8 c0073ebb 
ff20: 00001000 c0070f33 de63e000 c0c65500 df801f00 c0071047 df801f00 00001000 
ff40: 00000000 deee0c40 40044000 00001000 deee0c40 c0074fe1 40044000 c00759a1 
ff60: deee0c40 40044000 deee0c40 40044000 00001000 00000000 00001000 c0075acd 
ff80: 00001000 00000000 00001000 00000000 fffff000 00001000 00000004 00000003 
ffa0: c0027e08 c0027c41 fffff000 00001000 00000004 40044000 00001000 00001000 
ffc0: fffff000 00001000 00000004 00000003 fffff000 0001a000 00000001 00000fff 
ffe0: 00000002 bebbfb68 0000a228 400e3c0c 60000010 00000004 00000000 00000000 
[<c00e3c0c>] (__put_nfs_open_context+0x4/0x68) from [<c00e3cc5>] (put_nfs_open_context+0x9/0xc)
[<c00e3cc5>] (put_nfs_open_context+0x9/0xc) from [<c00e9459>] (nfs_readdata_release+0xd/0x14)
[<c00e9459>] (nfs_readdata_release+0xd/0x14) from [<c00e7aa5>] (nfs_file_direct_read+0x261/0x438)
[<c00e7aa5>] (nfs_file_direct_read+0x261/0x438) from [<c00e2a1b>] (nfs_file_read+0x4b/0xdc)
[<c00e2a1b>] (nfs_file_read+0x4b/0xdc) from [<c0075049>] (do_sync_read+0x69/0x98)
[<c0075049>] (do_sync_read+0x69/0x98) from [<c00759a1>] (vfs_read+0x69/0x11c)
[<c00759a1>] (vfs_read+0x69/0x11c) from [<c0075acd>] (sys_read+0x2d/0x48)
[<c0075acd>] (sys_read+0x2d/0x48) from [<c0027c41>] (ret_fast_syscall+0x1/0x40)


The patch below fixes the problem. Basically, the nfs_readdata_release()
is called from nfs_direct_read_schedule_segment() before
data->args.context was initialised, hence the oops. The same happens on
the nfs_writedata_release() path.


diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 73ea5e8..737bac1 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -71,7 +71,8 @@ void nfs_readdata_release(void *data)
 {
 	struct nfs_read_data *rdata = data;
 
-	put_nfs_open_context(rdata->args.context);
+	if (rdata->args.context)
+		put_nfs_open_context(rdata->args.context);
 	nfs_readdata_free(rdata);
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0a0a2ff..493cf17 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -98,7 +98,8 @@ void nfs_writedata_release(void *data)
 {
 	struct nfs_write_data *wdata = data;
 
-	put_nfs_open_context(wdata->args.context);
+	if (wdata->args.context)
+		put_nfs_open_context(wdata->args.context);
 	nfs_writedata_free(wdata);
 }
 

FYI, the diotest4 output is something like below (mixed with the oops
above but I tried to separate them):

diotest4    1  PASS  :  Negative Offset
diotest4    2  PASS  :  removed
diotest4    3  FAIL  :  read allows odd count. returns 1: Invalid argument
diotest4    4  FAIL  :  write allows odd count.returns 1: Invalid argument
diotest4    5  FAIL  :  Odd count of read and write
diotest4    6  PASS  :  Read beyond the file size
diotest4    7  PASS  :  Invalid file descriptor
diotest4    8  PASS  :  Out of range file descriptor
diotest4    9  PASS  :  Closed file descriptor
diotest4   10  PASS  :  removed
diotest4   11  CONF  :  Direct I/O on /dev/null is not supported
diotest4   12  PASS  :  read, write to a mmaped file
diotest4   13  PASS  :  read, write to an unmapped file
diotest4   14  PASS  :  read from file not open for reading
diotest4   15  PASS  :  write to file not open for writing
diotest4   16  FAIL  :  allows read nonaligned buf. returns 4096: Bad file descriptor
diotest4   17  FAIL  :  allows write nonaligned buf. returns 4096: Bad file descriptor
diotest4   18  FAIL  :  read, write with non-aligned buffer
Segmentation fault

-- 
Catalin

