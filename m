From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfsd: take file and mnt write in nfs4_upgrade_open
Date: Fri,  4 Jul 2008 15:38:41 +0300
Message-ID: <1215175121-18665-1-git-send-email-bhalevy@panasas.com>
References: <486E18C3.1040703@panasas.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:33578 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753258AbYGDMiy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jul 2008 08:38:54 -0400
In-Reply-To: <486E18C3.1040703@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

testing with newpynfs revealed this warning:
Jul  3 07:32:50 buml kernel: writeable file with no mnt_want_write()
Jul  3 07:32:50 buml kernel: ------------[ cut here ]------------
Jul  3 07:32:50 buml kernel: WARNING: at /usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/include/linux/fs.h:855 drop_file_write_access+0x6b/0x7e()
Jul  3 07:32:50 buml kernel: Modules linked in: nfsd auth_rpcgss exportfs nfs lockd nfs_acl sunrpc
Jul  3 07:32:50 buml kernel: Call Trace:
Jul  3 07:32:50 buml kernel: 6eaadc88:  [<6002f471>] warn_on_slowpath+0x54/0x8e
Jul  3 07:32:50 buml kernel: 6eaadcc8:  [<601b790d>] printk+0xa0/0x793
Jul  3 07:32:50 buml kernel: 6eaadd38:  [<601b6205>] __mutex_lock_slowpath+0x1db/0x1ea
Jul  3 07:32:50 buml kernel: 6eaadd68:  [<7107d4d5>] nfs4_preprocess_seqid_op+0x2a6/0x31c [nfsd]
Jul  3 07:32:50 buml kernel: 6eaadda8:  [<60078dc9>] drop_file_write_access+0x6b/0x7e
Jul  3 07:32:50 buml kernel: 6eaaddc8:  [<710804e4>] nfsd4_open_downgrade+0x114/0x1de [nfsd]
Jul  3 07:32:50 buml kernel: 6eaade08:  [<71076215>] nfsd4_proc_compound+0x1ba/0x2dc [nfsd]
Jul  3 07:32:50 buml kernel: 6eaade48:  [<71068221>] nfsd_dispatch+0xe5/0x1c2 [nfsd]
Jul  3 07:32:50 buml kernel: 6eaade88:  [<71312f81>] svc_process+0x3fd/0x714 [sunrpc]
Jul  3 07:32:50 buml kernel: 6eaadea8:  [<60039a81>] kernel_sigprocmask+0xf3/0x100
Jul  3 07:32:50 buml kernel: 6eaadee8:  [<7106874b>] nfsd+0x182/0x29b [nfsd]
Jul  3 07:32:50 buml kernel: 6eaadf48:  [<60021cc9>] run_kernel_thread+0x41/0x4a
Jul  3 07:32:50 buml kernel: 6eaadf58:  [<710685c9>] nfsd+0x0/0x29b [nfsd]
Jul  3 07:32:50 buml kernel: 6eaadf98:  [<60021cb0>] run_kernel_thread+0x28/0x4a
Jul  3 07:32:50 buml kernel: 6eaadfc8:  [<60013829>] new_thread_handler+0x72/0x9c
Jul  3 07:32:50 buml kernel:
Jul  3 07:32:50 buml kernel: ---[ end trace 2426dd7cb2fba3bf ]---

Bruce Fields suggested this (Thanks!):
maybe we need to be doing a mnt_want_write on open_upgrade and mnt_put_write on downgrade?

This patch adds a call to mnt_want_write and file_take_write (which is
doing the actual work).

The counter-calls mnt_drop_write a file_release_write are now being properly
called by drop_file_write_access in the exact path printed by the warning
above.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0d1760f..4263445 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1570,6 +1570,10 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct svc_fh *cur_fh, struct nfs4_sta
 		int err = get_write_access(inode);
 		if (err)
 			return nfserrno(err);
+		err = mnt_want_write(cur_fh->fh_export->ex_path.mnt);
+		if (err)
+			return nfserrno(err);
+		file_take_write(filp);
 	}
 	status = nfsd4_truncate(rqstp, cur_fh, open);
 	if (status) {
-- 
1.5.6.GIT

