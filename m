From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 6/8] NFSv4: Don't allow posix locking against servers that
 don't support it
Date: Mon, 25 Jan 2010 16:57:35 -0500
Message-ID: <20100125215735.14716.35281.stgit@localhost.localdomain>
References: <20100125215734.14716.19614.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8049 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752248Ab0AYWEK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:04:10 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0PM4AM2014291
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2010 14:04:10 -0800 (PST)
In-Reply-To: <20100125215734.14716.19614.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@kernel.org
---

 fs/nfs/nfs4_fs.h  |    1 +
 fs/nfs/nfs4proc.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 865265b..ea2f41b 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -146,6 +146,7 @@ enum {
 	NFS_O_RDWR_STATE,		/* OPEN stateid has read/write state */
 	NFS_STATE_RECLAIM_REBOOT,	/* OPEN stateid server rebooted */
 	NFS_STATE_RECLAIM_NOGRACE,	/* OPEN stateid needs to recover state */
+	NFS_STATE_POSIX_LOCKS,		/* Posix locks are supported */
 };
 
 struct nfs4_state {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0b68238..be044b5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1658,6 +1658,8 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, in
 	status = PTR_ERR(state);
 	if (IS_ERR(state))
 		goto err_opendata_put;
+	if ((opendata->o_res.rflags & NFS4_OPEN_RESULT_LOCKTYPE_POSIX) != 0)
+		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
 	nfs4_opendata_put(opendata);
 	nfs4_put_state_owner(sp);
 	*res = state;
@@ -4200,8 +4202,11 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 {
 	struct nfs_inode *nfsi = NFS_I(state->inode);
 	unsigned char fl_flags = request->fl_flags;
-	int status;
+	int status = -ENOLCK;
 
+	if ((fl_flags & FL_POSIX) &&
+			!test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
+		goto out;
 	/* Is this a delegated open? */
 	status = nfs4_set_lock_state(state, request);
 	if (status != 0)

