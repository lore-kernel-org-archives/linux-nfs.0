From: Benny Halevy <bhalevy@panasas.com>
Subject: writeable file with no mnt_want_write()
Date: Thu, 03 Jul 2008 15:21:58 +0300
Message-ID: <486CC466.6060504@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:11934 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758671AbYGCMWX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2008 08:22:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

I'm seeing this warning on the open_downgrade path
when running the newpynfs tests:

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

I'm not sure what would be the right fix for that...

The following could be unrelated, and maybe I'm just confused
but there seems to be something funky about the way we convert
from bmap to access bits.
(unrelated note: for nfsv4.1 we'll need to mask the share access with
~OPEN4_SHARE_ACCESS_WANT_DELEG_MASK)

If I understand this correctly, we set a bit in 
st_access_bmap corresponding to the share_access,
so for read-only bit #1 will be, write-only #2,
and for read-write (only) bits 1-3 should be set.
otherwise this wouldn't work:
	if (!test_bit(od->od_share_access, &stp->st_access_bmap)) {
		dprintk("NFSD:access not a subset current bitmap: 0x%lx, input access=%08x\n",
			stp->st_access_bmap, od->od_share_access);
		goto out;
	}

but init_stateid sets only one bit:
	__set_bit(open->op_share_access, &stp->st_access_bmap);

only if we went through nfs4_upgrade_open another bit may be set.

Benny
