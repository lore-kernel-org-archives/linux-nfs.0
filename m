Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51230 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273Ab1AUDFV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Jan 2011 22:05:21 -0500
Received: by mail-vw0-f46.google.com with SMTP id 16so612009vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 Jan 2011 19:05:21 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] NFS: Fix "kernel BUG at fs/nfs/nfs3xdr.c:1338!"
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 20 Jan 2011 22:05:18 -0500
Message-ID: <20110121030518.1056.86423.stgit@matisse.1015granger.net>
In-Reply-To: <20110121030314.1056.96774.stgit@matisse.1015granger.net>
References: <20110121030314.1056.96774.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Milan Broz <mbroz@redhat.com> reports:

> on today Linus' tree I get OOps if using nfs.
>
> server (2.6.36) exports dir:
> /dir   172.16.1.0/24(rw,async,all_squash,no_subtree_check,anonuid=500,anongid=500)
>
> on client it is mounted  in fstab
> server:/dir  /mnt/tst  nfs  rw,soft 0 0
>
> and these commands OOpses it (simplified from a configure script):
>
> cd /dir
> touch x
> install x y
>
> [  105.327701] ------------[ cut here ]------------
> [  105.327979] kernel BUG at fs/nfs/nfs3xdr.c:1338!
> [  105.328075] invalid opcode: 0000 [#1] PREEMPT SMP
> [  105.328223] last sysfs file: /sys/devices/virtual/bdi/0:16/uevent
> [  105.328349] Modules linked in: usbcore dm_mod
> [  105.328553]
> [  105.328678] Pid: 3710, comm: install Not tainted 2.6.37+ #423 440BX Desktop Reference Platform/VMware Virtual Platform
> [  105.328853] EIP: 0060:[<c116c06c>] EFLAGS: 00010282 CPU: 0
> [  105.329152] EIP is at nfs3_xdr_enc_setacl3args+0x61/0x98
> [  105.329249] EAX: ffffffea EBX: ce941d98 ECX: 00000000 EDX: 00000004
> [  105.329340] ESI: ce941cd0 EDI: 000000a4 EBP: ce941cc0 ESP: ce941cb4
> [  105.329431]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> [  105.329525] Process install (pid: 3710, ti=ce940000 task=ced36f20 task.ti=ce940000)
> [  105.336600] Stack:
> [  105.336693]  ce941cd0 ce9dc000 00000000 ce941cf8 c12ecd02 c12f43e0 c116c00b cf754158
> [  105.336982]  ce9dc004 cf754284 ce9dc004 cf7ffee8 ceff9978 ce9dc000 cf7ffee8 ce9dc000
> [  105.337182]  ce9dc000 ce941d14 c12e698d cf75412c ce941d98 cf7ffee8 cf7fff20 00000000
> [  105.337405] Call Trace:
> [  105.337695]  [<c12ecd02>] rpcauth_wrap_req+0x75/0x7f
> [  105.337806]  [<c12f43e0>] ? xdr_encode_opaque+0x12/0x15
> [  105.337898]  [<c116c00b>] ? nfs3_xdr_enc_setacl3args+0x0/0x98
> [  105.337988]  [<c12e698d>] call_transmit+0x17e/0x1e8
> [  105.338072]  [<c12ec307>] __rpc_execute+0x6d/0x1a6
> [  105.338155]  [<c12ec474>] rpc_execute+0x34/0x37
> [  105.338235]  [<c12e738d>] rpc_run_task+0xb5/0xbd
> [  105.338316]  [<c12e7474>] rpc_call_sync+0x3d/0x58
> [  105.338402]  [<c116d0c6>] nfs3_proc_setacls+0x18e/0x24f
> [  105.338493]  [<c10b3f76>] ? __kmalloc+0x148/0x1c4
> [  105.338579]  [<c10ecd01>] ? posix_acl_alloc+0x12/0x22
> [  105.338665]  [<c116d5c8>] nfs3_proc_setacl+0xa0/0xca
> [  105.338748]  [<c116d69c>] nfs3_setxattr+0x62/0x88
> [  105.338834]  [<c1317042>] ? sub_preempt_count+0x7c/0x89
> [  105.338926]  [<c116d63a>] ? nfs3_setxattr+0x0/0x88
> [  105.339026]  [<c10cfa79>] __vfs_setxattr_noperm+0x26/0x95
> [  105.339114]  [<c10cfb43>] vfs_setxattr+0x5b/0x76
> [  105.339211]  [<c10cfbfb>] setxattr+0x9d/0xc3
> [  105.339298]  [<c10a2ea8>] ? handle_pte_fault+0x258/0x5cb
> [  105.339428]  [<c1091ff6>] ? __free_pages+0x1a/0x23
> [  105.339517]  [<c10498ea>] ? up_read+0x16/0x2c
> [  105.339599]  [<c10b8365>] ? fget+0x0/0xa3
> [  105.339677]  [<c10b8365>] ? fget+0x0/0xa3
> [  105.339760]  [<c1025d23>] ? get_parent_ip+0xb/0x31
> [  105.339843]  [<c1317042>] ? sub_preempt_count+0x7c/0x89
> [  105.339931]  [<c10cfc72>] sys_fsetxattr+0x51/0x79
> [  105.340014]  [<c1002853>] sysenter_do_call+0x12/0x32
> [  105.340133] Code: 2e 76 18 00 58 31 d2 8b 7f 28 f6 43 04 01 74 03 8b 53 08 6a 00 8b 46 04 6a 01 8b 0b 52 89 fa e8 85 10 f8 ff 83 c4 0c 85 c0 79 04 <0f> 0b eb fe 31 c9 f6 43 04 04 74 03 8b 4b 0c 68 00 10 00 00 8d
> [  105.350321] EIP: [<c116c06c>] nfs3_xdr_enc_setacl3args+0x61/0x98 SS:ESP 0068:ce941cb4
> [  105.364385] ---[ end trace 01fcfe7f0f7f6e4a ]---

nfs3_xdr_enc_setacl3args() is not properly setting up the target
buffer before nfsacl_encode() attempts to encode the ACL.

Introduced by commit d9c407b1 "NFS: Introduce new-style XDR encoding
functions for NFSv3."

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs3xdr.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 01c5e8b..183c6b1 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1328,10 +1328,13 @@ static void nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
 
 	encode_nfs_fh3(xdr, NFS_FH(args->inode));
 	encode_uint32(xdr, args->mask);
+
+	base = req->rq_slen;
 	if (args->npages != 0)
 		xdr_write_pages(xdr, args->pages, 0, args->len);
+	else
+		xdr_reserve_space(xdr, NFS_ACL_INLINE_BUFSIZE);
 
-	base = req->rq_slen;
 	error = nfsacl_encode(xdr->buf, base, args->inode,
 			    (args->mask & NFS_ACL) ?
 			    args->acl_access : NULL, 1, 0);

