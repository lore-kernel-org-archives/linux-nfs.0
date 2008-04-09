From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfs: call nfs4_try_open_cached only if opendata->state is not
	NULL
Date: Wed,  9 Apr 2008 19:20:52 +0300
Message-ID: <1207758052-12825-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org, nfsv4@linux-nfs.org
To: trond.myklebust@fys.uio.no
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes the following oops that happened after breaking from a pending
open with ^C.

(traces below apply to the nfs41 development tree, not mainline kernel)

Apr  9 19:00:19 bh-testlin1 kernel: BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
Apr  9 19:00:19 bh-testlin1 kernel: IP: [<ffffffff8820732b>] :nfs:nfs4_opendata_to_nfs4_state+0x27/0x240
...
Apr  9 19:00:19 bh-testlin1 kernel: Call Trace:
Apr  9 19:00:19 bh-testlin1 kernel:  [<ffffffff88207833>] :nfs:nfs4_do_open+0x14e/0x238
Apr  9 19:00:19 bh-testlin1 kernel:  [<ffffffff8820be3a>] :nfs:nfs4_atomic_open+0xd7/0x19d
Apr  9 19:00:19 bh-testlin1 kernel:  [<ffffffff8108e0a1>] init_object+0x27/0x6b
Apr  9 19:00:19 bh-testlin1 kernel:  [<ffffffff8108faf3>] __slab_alloc+0x3c5/0x44a
Apr  9 19:00:19 bh-testlin1 kernel:  [<ffffffff810a579a>] d_alloc+0x24/0x1af
Apr  9 19:00:19 bh-testlin1 kernel:  [<ffffffff881f3e3e>] :nfs:nfs_atomic_lookup+0xb5/0x109
Apr  9 19:00:19 bh-testlin1 kernel:  [<ffffffff8109c624>] __lookup_hash+0xe9/0x10d
Apr  9 19:00:19 bh-testlin1 kernel:  [<ffffffff8109f8c6>] open_namei+0xfe/0x675
Apr  9 19:00:19 bh-testlin1 kernel:  [<ffffffff8108e399>] check_bytes_and_report+0x37/0xc9
Apr  9 19:00:19 bh-testlin1 kernel:  [<ffffffff81093f5d>] do_filp_open+0x1c/0x38
Apr  9 19:00:19 bh-testlin1 kernel:  [<ffffffff8109d6f2>] getname+0x25/0x1a6
Apr  9 19:00:19 bh-testlin1 kernel:  [<ffffffff81093d3e>] get_unused_fd_flags+0x111/0x11f
Apr  9 19:00:19 bh-testlin1 kernel:  [<ffffffff81093fbf>] do_sys_open+0x46/0xc3
Apr  9 19:00:19 bh-testlin1 kernel:  [<ffffffff8100c0bd>] tracesys+0xdc/0xe1

(gdb) list *(nfs4_opendata_to_nfs4_state+0x27)
0x1832b is in nfs4_opendata_to_nfs4_state (fs/nfs/nfs4proc.c:806).
801     }
802
803     static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
804     {
805             struct nfs4_state *state = opendata->state;
806             struct nfs_inode *nfsi = NFS_I(state->inode);
807             struct nfs_delegation *delegation;
808             int open_mode = opendata->o_arg.open_flags & (FMODE_READ|FMODE_WRITE|O_EXCL);
809             nfs4_stateid stateid;
810             int ret = -EAGAIN;

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7ce0786..d6a530f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -483,7 +483,7 @@ static struct nfs4_state *nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data
 	nfs4_stateid *deleg_stateid = NULL;
 	int ret;
 
-	if (!data->rpc_done) {
+	if (!data->rpc_done && data->state) {
 		state = nfs4_try_open_cached(data);
 		goto out;
 	}
-- 
1.5.3.3
