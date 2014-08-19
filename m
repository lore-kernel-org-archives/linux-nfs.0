Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f43.google.com ([209.85.220.43]:51932 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbaHSPQ4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2014 11:16:56 -0400
Message-ID: <53F36A4C.60301@gmail.com>
Date: Tue, 19 Aug 2014 23:16:28 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Jeff Layton <jeff.layton@primarydata.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org, kinglongmee@gmail.com
Subject: [PATCH 1/6 v4] NFSD: Remove the duplicate initialize of file_lock
References: <53BAAAC5.9000106@gmail.com>	<53E22EA5.70708@gmail.com> <20140809065112.700e0ecc@tlielax.poochiereds.net> <53E791F1.40802@gmail.com> <53ED5093.6000308@gmail.com>
In-Reply-To: <53ED5093.6000308@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

locks_alloc_lock() has initialize the struct file_lock,
so, don't need re-initialize it by locks_init_lock().

v4: same as v3, only cleanup

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
Reviewed-by: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2e80a59..98edf97 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3759,7 +3759,6 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int flag)
 	fl = locks_alloc_lock();
 	if (!fl)
 		return NULL;
-	locks_init_lock(fl);
 	fl->fl_lmops = &nfsd_lease_mng_ops;
 	fl->fl_flags = FL_DELEG;
 	fl->fl_type = flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK;
@@ -5210,7 +5209,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 
 	fp = lock_stp->st_stid.sc_file;
-	locks_init_lock(file_lock);
 	switch (lock->lk_type) {
 		case NFS4_READ_LT:
 		case NFS4_READW_LT:
@@ -5354,7 +5352,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_jukebox;
 		goto out;
 	}
-	locks_init_lock(file_lock);
+
 	switch (lockt->lt_type) {
 		case NFS4_READ_LT:
 		case NFS4_READW_LT:
@@ -5432,7 +5430,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_jukebox;
 		goto fput;
 	}
-	locks_init_lock(file_lock);
+
 	file_lock->fl_type = F_UNLCK;
 	file_lock->fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
 	file_lock->fl_pid = current->tgid;
-- 
1.9.3

