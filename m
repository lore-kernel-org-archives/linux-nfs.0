From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: nfs_sillyrename -> lookup_one_len warning
Date: Wed, 10 Jun 2009 14:38:50 -0400
Message-ID: <200906101838.n5AIco0n013973@agora.fsl.cs.sunysb.edu>
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2]:50477 "EHLO
	filer.fsl.cs.sunysb.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758379AbZFJS4f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Jun 2009 14:56:35 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, in testing unionfs on top of nfs4 in 2.6.30, I get this warning.  I
think you need to lock the underlying inode sem around the call to
lookup_one_len.

[ 2173.937471] WARNING: at fs/namei.c:1252 lookup_one_len+0x33/0x74()
[ 2173.937954] Hardware name: VMware Virtual Platform
[ 2173.938332] Modules linked in: unionfs md5 ext4 jbd2 crc16 nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc [last unloaded: unionfs]
[ 2173.938345] Pid: 10640, comm: rm Not tainted 2.6.30-unionfs2 #326
[ 2173.938347] Call Trace:
[ 2173.938362]  [<c021df7e>] warn_slowpath_common+0x60/0x77
[ 2173.938367]  [<c021dfa2>] warn_slowpath_null+0xd/0x10
[ 2173.938370]  [<c026ed93>] lookup_one_len+0x33/0x74
[ 2173.938404]  [<f8964506>] ? nfs_sillyrename+0xd5/0x205 [nfs]
[ 2173.938419]  [<f8964538>] nfs_sillyrename+0x107/0x205 [nfs]
[ 2173.938434]  [<f89656dd>] nfs_unlink+0x74/0x1d0 [nfs]
[ 2173.938437]  [<c026e3a6>] vfs_unlink+0x5d/0xab
[ 2173.938454]  [<f894f9e2>] do_delete_whiteouts+0x12b/0x1b4 [unionfs]
[ 2173.938463]  [<f894fd3d>] delete_whiteouts+0x9b/0xc5 [unionfs]
[ 2173.938470]  [<c0238811>] ? trace_hardirqs_on_caller+0xff/0x120
[ 2173.938474]  [<c023883d>] ? trace_hardirqs_on+0xb/0xd
[ 2173.938482]  [<f894b128>] ? check_empty+0x222/0x23a [unionfs]
[ 2173.938490]  [<f894bf43>] unionfs_rmdir+0xdf/0x415 [unionfs]
[ 2173.938505]  [<c03bd700>] ? _spin_unlock+0x27/0x3c
[ 2173.938509]  [<c026e815>] vfs_rmdir+0x67/0xa8
[ 2173.938512]  [<c026ff6b>] do_rmdir+0x84/0xc3
[ 2173.938516]  [<c020289b>] ? sysenter_exit+0xf/0x18
[ 2173.938520]  [<c0238811>] ? trace_hardirqs_on_caller+0xff/0x120
[ 2173.938523]  [<c026ffe9>] sys_rmdir+0x10/0x12
[ 2173.938526]  [<c0202868>] sysenter_do_call+0x12/0x36
[ 2173.938529] ---[ end trace 7364f4a6081197e6 ]---
[ 2177.416172] Completed unionfs module unload

Cheers,
Erez.
