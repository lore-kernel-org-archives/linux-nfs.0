Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:18251 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205Ab1EUIIJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 04:08:09 -0400
Message-ID: <4DD772E4.2030505@panasas.com>
Date: Sat, 21 May 2011 11:08:04 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs-submit for objects: BUGs Please help
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Benny, people hi!

After long debugging of the "pnfs-submit for objects" and after some bugs found.
Please see next-mail patch: [RFC] pnfs: pnfs-core BUGs fixing

I'm at a situation that the lseg reference count is unbalanced short, and the
segment gets freed after layout_commit stage, and never survives to see
a layout_return. (So layout_commit is the last operation I see)

What is nice is that there is a BUG_ON that caches this, (I've converted it to WARN_ON
for debbuging but just the same)

Please see below:

------------[ cut here ]------------
WARNING: at /usr0/export/dev/bharrosh/git/pub/linux-pnfs/fs/nfs/pnfs.c:258 put_lseg_common+0x29/0x7f [nfs]()
Modules linked in: md5 objlayoutdriver exofs nfsd nfs lockd auth_rpcgss nfs_acl sunrpc osd libosd cryptomgr aead crc32c crypto_hash crypto_algapi ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi scsi_mod binfmt_misc dm_mirror dm_region_hash dm_log dm_multipath dm_mod [last unloaded: scsi_wait_scan]
Call Trace: 
76a5bb98:  [<60030b0a>] warn_slowpath_common+0x5e/0x75
76a5bbd8:  [<60030b36>] warn_slowpath_null+0x15/0x17
76a5bbe8:  [<7b7c97df>] put_lseg_common+0x29/0x7f [nfs]
76a5bc08:  [<7b7ca685>] put_lseg+0x6d/0x9b [nfs]
76a5bc48:  [<7b7b8c0a>] nfs4_layoutcommit_release+0x27/0x3f [nfs]
76a5bc68:  [<7a8a3e06>] rpc_release_calldata+0x12/0x14 [sunrpc]
76a5bc78:  [<7a8a3ec8>] rpc_free_task+0x57/0x5f [sunrpc]
76a5bca8:  [<7a8a3f1d>] rpc_final_put_task+0x4d/0x4f [sunrpc]
76a5bcb8:  [<7a8a3f49>] rpc_do_put_task+0x2a/0x31 [sunrpc]
76a5bce8:  [<7a8a3f6a>] rpc_put_task+0xb/0xd [sunrpc]
76a5bcf8:  [<7b7b4d7f>] nfs4_proc_layoutcommit+0x10b/0x119 [nfs]
76a5bd88:  [<7b7c8e71>] pnfs_layoutcommit_inode+0x1d5/0x207 [nfs]
76a5bde8:  [<7b79f293>] nfs_file_fsync+0xa2/0xab [nfs]
76a5be18:  [<600aa80e>] vfs_fsync_range+0x4d/0x75
76a5be48:  [<600aa88b>] vfs_fsync+0x17/0x19
76a5be58:  [<7b79ee2c>] nfs_file_flush+0x5c/0x61 [nfs]
76a5be78:  [<60087638>] filp_close+0x3f/0x76
76a5bea8:  [<6008771a>] sys_close+0xab/0xe7
76a5bee8:  [<60016fd4>] handle_syscall+0x58/0x70
76a5bf08:  [<600264d7>] userspace+0x2dd/0x38a
76a5bfc8:  [<600145e8>] fork_handler+0x7d/0x84

---[ end trace 00e42804444a3cac ]---

So you can see that put_lseg() in nfs4_layoutcommit_release decides that this is the
last ref and frees lseg. (See pnfs.c:258)

I'm not sure where is the missing ref? Please help!!

I'll send the fixes needed to get to this stage as reply. Current tree will crash much
earlier.

Benny I've done all the work needed on the pnfs-objects I'll send that next look for
the:
[PATCHSET 00/11] SQUASHME pnfs-obj: Lots of changes addressing comments by Trond and Benny

Thanks
Boaz

