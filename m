Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36674 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbcHGSxK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Aug 2016 14:53:10 -0400
Received: by mail-io0-f193.google.com with SMTP id y34so27520036ioi.3
        for <linux-nfs@vger.kernel.org>; Sun, 07 Aug 2016 11:53:10 -0700 (PDT)
Received: from klimt.1015granger.net ([2604:8800:100:81fc:ec4:7aff:fe6c:6aa0])
        by smtp.gmail.com with ESMTPSA id y194sm12692052iod.17.2016.08.07.11.53.08
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Aug 2016 11:53:09 -0700 (PDT)
Subject: [PATCH v2] nfsd: Fix race between FREE_STATEID and LOCK
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Sun, 07 Aug 2016 14:53:07 -0400
Message-ID: <20160807185024.11705.10864.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When running LTP's nfslock01 test, the Linux client can send a LOCK
and a FREE_STATEID request at the same time. The LOCK uses the same
lockowner as the stateid sent in the FREE_STATEID request.

The outcome is:

Frame 115025 C FREE_STATEID stateid 2/A
Frame 115026 C LOCK offset 672128 len 64
Frame 115029 R FREE_STATEID NFS4_OK
Frame 115030 R LOCK stateid 3/A
Frame 115034 C WRITE stateid 0/A offset 672128 len 64
Frame 115038 R WRITE NFS4ERR_BAD_STATEID

In other words, the server returns stateid A in a successful LOCK
reply, but it has already released it. Subsequent uses of the
stateid fail.

To address this, protect the generation check in nfsd4_free_stateid
with the st_mutex. This should guarantee that only one of two
outcomes occurs: either LOCK returns a fresh valid stateid, or
FREE_STATEID returns NFS4ERR_LOCKS_HELD.

Reported-by: Alexey Kodanev <alexey.kodanev@oracle.com>
Fix-suggested-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4state.c |   19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b921123..07dc1aa 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4911,19 +4911,20 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		ret = nfserr_locks_held;
 		break;
 	case NFS4_LOCK_STID:
+		atomic_inc(&s->sc_count);
+		spin_unlock(&cl->cl_lock);
+		stp = openlockstateid(s);
+		mutex_lock(&stp->st_mutex);
 		ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
 		if (ret)
-			break;
-		stp = openlockstateid(s);
+			goto out_mutex_unlock;
 		ret = nfserr_locks_held;
 		if (check_for_locks(stp->st_stid.sc_file,
 				    lockowner(stp->st_stateowner)))
-			break;
-		WARN_ON(!unhash_lock_stateid(stp));
-		spin_unlock(&cl->cl_lock);
-		nfs4_put_stid(s);
+			goto out_mutex_unlock;
+		release_lock_stateid(stp);
 		ret = nfs_ok;
-		goto out;
+		goto out_mutex_unlock;
 	case NFS4_REVOKED_DELEG_STID:
 		dp = delegstateid(s);
 		list_del_init(&dp->dl_recall_lru);
@@ -4937,6 +4938,10 @@ out_unlock:
 	spin_unlock(&cl->cl_lock);
 out:
 	return ret;
+out_mutex_unlock:
+	mutex_unlock(&stp->st_mutex);
+	nfs4_put_stid(s);
+	goto out;
 }
 
 static inline int

