Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34459 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbcHFXeY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2016 19:34:24 -0400
Received: by mail-io0-f196.google.com with SMTP id i199so4357989ioi.1
        for <linux-nfs@vger.kernel.org>; Sat, 06 Aug 2016 16:34:24 -0700 (PDT)
Received: from klimt.1015granger.net ([2604:8800:100:81fc:ec4:7aff:fe6c:6aa0])
        by smtp.gmail.com with ESMTPSA id h63sm5125763ita.12.2016.08.05.19.26.35
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 19:26:36 -0700 (PDT)
Subject: [PATCH v1] nfsd: Fix race between FREE_STATEID and LOCK
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Fri, 05 Aug 2016 22:26:35 -0400
Message-ID: <20160806022349.3381.8042.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using LTP's nfslock01 test, one of our internal testers found that
the Linux client can send a LOCK and a FREE_STATEID request at the
same time. The LOCK uses the same lockowner as the stateid sent in
the FREE_STATEID request.

The outcome is:

Frame 115025 C FREE_STATEID stateid 2/A
Frame 115026 C LOCK offset 672128 len 64
Frame 115029 R FREE_STATEID NFS4_OK
Frame 115030 R LOCK stateid 3/A
Frame 115034 C WRITE stateid 0/A offset 672128 len 64
Frame 115038 R WRITE NFS4ERR_BAD_STATEID

In other words, the server returns stateid A in the LOCK reply, but
it has already released it. Subsequent uses of the stateid fail.

To address this, protect the logic in nfsd4_free_stateid with the
st_mutex. This should guarantee that only one of two outcomes
occurs: either LOCK returns a fresh valid stateid, or FREE_STATEID
returns NFS4ERR_LOCKS_HELD.

Reported-by: Alexey Kodanev <alexey.kodanev@oracle.com>
Fix-suggested-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Before I pass this along to Alexey for testing, I'd appreciate some
review of the proposed fix.


 fs/nfsd/nfs4state.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b921123..a9e0606 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4911,16 +4911,24 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		ret = nfserr_locks_held;
 		break;
 	case NFS4_LOCK_STID:
-		ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
-		if (ret)
-			break;
+		spin_unlock(&cl->cl_lock);
 		stp = openlockstateid(s);
+		mutex_lock(&stp->st_mutex);
+		ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
+		if (ret) {
+			mutex_unlock(&stp->st_mutex);
+			goto out;
+		}
 		ret = nfserr_locks_held;
 		if (check_for_locks(stp->st_stid.sc_file,
-				    lockowner(stp->st_stateowner)))
-			break;
+				    lockowner(stp->st_stateowner))) {
+			mutex_unlock(&stp->st_mutex);
+			goto out;
+		}
+		spin_lock(&cl->cl_lock);
 		WARN_ON(!unhash_lock_stateid(stp));
 		spin_unlock(&cl->cl_lock);
+		mutex_unlock(&stp->st_mutex);
 		nfs4_put_stid(s);
 		ret = nfs_ok;
 		goto out;

