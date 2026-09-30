Received: from mail-pj2-f39.google.com (mail-pj2-f39.google.com [74.125.227.167])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57BCA30C147
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 05:40:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.167
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790746847; cv=none; b=g3NxSbfCSn+Wf5MEJ2iIeDUn7/LL2vNmBigPcSW8li2lfgTijf+OvKu35UtXbI/IN+4zmXz+/t15PuvGMtdExXsGZzely6tq3q4uAfo+b5aQy2pJjtVa91Ptm5zyZ6OAInNpN2x3YYKVnaMWZPJHAxliiV9Hle/WSGr3D0+1Ksg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790746847; c=relaxed/simple;
	bh=w0vkE58pygpZnQ6xhvwFA25OV6aNlPCuw3mRKVBbpuU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=f1sWuu/w4FuQYB13opumK/v6x4loZU9yxYuaV5xUD1FYm7Z+iBAyWHjcySdY7VL7181CSbaehfRtwZYOlp4zm1E1YEhAut2i92dfrueBygwob+DExE50Up9as+KJzKKH59fSGnkBbfPMc3kDWw+y/s0sTlGmA942h9VxeadKOFE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=SRmpNHxU; arc=none smtp.client-ip=74.125.227.167
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SRmpNHxU"
Received: by mail-pj2-f39.google.com with SMTP id d9443c01a7336-2e2d42b972bso7218645ad.3
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 22:40:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790746846; x=1791351646; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=bKiK48LqhkdDPcjT2xrb41xymi0pBOhKQ7z3uPdbq1Q=;
        b=SRmpNHxUpDa1F3O9nyETT0tOzDWnC0P6OPclYk0LCJRRtVDuU00eP+EIB/LJodkbLd
         RDZVtSj0WdFMnnm0FyU/lP19gznM4n4yutogxoy1hDho1Ccj7urb/mNWC6gvYMLvFsVL
         z6kzOLEOjNpw3VvZfO0s0QHOXCXzWepwhc4y4Eq2sbkAM1H+D4Q6oeCUgy/Pc04juc58
         SrqFoXQhirp4uvu0BNGhkdtGF1GGHewKWvAlqhA4VuHfXH9WB7m9JJGQqqDcnQdlsa9m
         uBPZDA2SNLdo47bY9gIBdzpBvxMOLJeri3RYZCNOvks6JRhmegFJKLAhcfu4Wr6p1XfD
         sS/A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790746846; x=1791351646;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=bKiK48LqhkdDPcjT2xrb41xymi0pBOhKQ7z3uPdbq1Q=;
        b=tUO4GKiQuhBdfVzZ57+gQqfQqgEwCtpdKNr/nUY7hRwX3RCH9HrKsFvszkI7e+QHa6
         GD3NLId15HFj3lNaQMXKCpPUsYxaXWXgPM8/6HUMLiBBcVDb98sl++o95o9+1mVoCKIO
         mz7gMtGlKycACuT0dcWlU4jFFDyBYW38N0azJ6fBveArfZgPOKz4z0pLyhBcWgo5bd1A
         IK4BfExO7RD6Ip1FwDcE/ZYnOj274xJyX0NHQQy7aTB8SuwqJ32nPn5jsyBn3ATx+b3p
         VYy3eOU2s/Vb5i57Gz3hjg69zmVcLQ2RgWaondjR79eujDteZOr+SO5XRmOjnI2rhJfM
         0cNA==
X-Gm-Message-State: AFq9FYLwWIzW8g1a35LbTzG/vv/NWZpPRkjXoIlC3wCaCY0k+uBDMbui
	V8iEL3qW+oAXtVloZXSSyzNmVu51t15UxHs05q2g3C90lYHM2CtSH5ecKGQDEDPvKwA=
X-Gm-Gg: AYBFou2nofIRS7ql51yk3RJwCkfHP/s3FFWKTNcNwejWynpLqmxAQC5C/o0vbt/q9xj
	ywgIPL1t4dYaRYHsityk4l6K7KhxJmcOVqVWQtNlcrDOhstM4upSKNwqvzBaEr0Z4On3KjYRPe5
	Qjw6l/qjudNLAg25DfCv6y1/5v1LeHpw4aza0Lq4SVYStm/dhiJq5h17hWzJEjf0LSSd/90Mxoi
	cc1cpShXLLjJGSWU8wjvPcvlmUA43oYV5vwgpWdnmAZI+XtrcR+NV+szYtYOqC/jTkMtepiY72e
	PYSjgTxvoQE24MDgwuxJJIkFn0w1yVUw8Xwgx+nxhPZOICY2vzODeNFNtKJEMqkPMPix6Qfylik
	E9R7HHPY+nDMAtKl/+Tx4xdIHHR2yYIxt+XlRrr8uX9uUJg33NMlq5bC8em1fp4xVmPjxUZSYxu
	56BUpRF+r2JmqoH0muBb3H2pAN8KH9pqUDPF4EkK+cJZq2PhPbEFF3iGI/IQcTPoRvf5h3X4eZi
	SZ4LcV60eUYzhoRSJ4VD5oOil96B6uU5kOd6ZyeZ5gcdw8MQ7hQ/dl+y1L+xxc=
X-Received: by 2002:a17:903:8c6:b0:2db:2376:6e8a with SMTP id d9443c01a7336-2e2e49f74d2mr3566885ad.9.1790746845561;
        Tue, 29 Sep 2026 22:40:45 -0700 (PDT)
Received: from muumthf.localdomain ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2e2e5b8a026sm1189175ad.29.2026.09.29.22.40.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 22:40:45 -0700 (PDT)
From: Hyunsol Mun <muumthf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	bobtobabz@gmail.com,
	Hyunsol Mun <muumthf@gmail.com>
Subject: [PATCH v2] nfsd: update reclaim client pointer under hash lock
Date: Wed, 30 Sep 2026 14:40:32 +0900
Message-ID: <20260930054032.299499-1-muumthf@gmail.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

__nfsd4_create_reclaim_record_grace() assigns cr_clp after
nfs4_client_to_reclaim() has released reclaim_str_hashtbl_lock.
Concurrent reclaim-record removal can free the returned record before
that assignment.

Pass the client into nfs4_client_to_reclaim() and install cr_clp while
its write lock is held, both for an existing record and for a newly
allocated record.

The vulnerable path requires the default-off legacy client-tracking backend
and startup grace. For deterministic validation, a timing-only kretprobe
module delayed the helper return while the administrator ended grace. The
module did not allocate, free, or modify the reclaim record.
It only widened the post-unlock interval; it is not a remote capability.

Validation used the Torvalds mainline base recorded below. On the
unmodified KASAN kernel, the legacy backend and a real startup grace period
were active, the validator hit the post-unlock boundary, and
RECLAIM_COMPLETE returned NFS4_OK. Generic KASAN then reported an
eight-byte slab-use-after-free write in nfsd4_create_clid_dir(), with
allocation in nfs4_client_to_reclaim() and freeing in
nfs4_release_reclaim().

With this patch alone applied to the same source, five identical runs each
hit the validator boundary and returned NFS4_OK without a KASAN report.
Basic NFSv4.2 and NFSv3 read/write/unmount smoke tests also passed. The
unmodified and patched full kernels were built with GCC 12.2 and
CONFIG_WERROR without a compiler warning. A source reproducer and timing
module source, together with the complete KASAN logs, are available
privately on request.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: 7e4f015d815d ("nfsd: release the legacy reclaimable clients list in grace_done")
Assisted-by: LLM
Signed-off-by: Hyunsol Mun <muumthf@gmail.com>
---
Changes in v2:
- Revalidate against current Torvalds mainline.
- Expand the lifetime-race and runtime-validation details.
- No code changes.

 fs/nfsd/nfs4recover.c | 8 +++-----
 fs/nfsd/nfs4state.c   | 6 ++++--
 fs/nfsd/state.h       | 3 ++-
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index d513971fb119..357b53a5b7c7 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -113,10 +113,8 @@ __nfsd4_create_reclaim_record_grace(struct nfs4_client *clp,
 {
 	struct xdr_netobj name = { .len = strlen(dname), .data = dname };
 	struct xdr_netobj princhash = { .len = 0, .data = NULL };
-	struct nfs4_client_reclaim *crp;
 
-	crp = nfs4_client_to_reclaim(name, princhash, nn);
-	crp->cr_clp = clp;
+	nfs4_client_to_reclaim(name, princhash, clp, nn);
 }
 
 static void
@@ -404,7 +402,7 @@ load_recdir(struct dentry *parent, char *cname, struct nfsd_net *nn)
 		/* Keep trying; maybe the others are OK: */
 		return 0;
 	}
-	nfs4_client_to_reclaim(name, princhash, nn);
+	nfs4_client_to_reclaim(name, princhash, NULL, nn);
 	return 0;
 }
 
@@ -761,7 +759,7 @@ __cld_pipe_inprogress_downcall(const struct cld_msg_v2 __user *cmsg,
 			cn->cn_has_legacy = true;
 		}
 #endif
-		if (!nfs4_client_to_reclaim(name, princhash, nn))
+		if (!nfs4_client_to_reclaim(name, princhash, NULL, nn))
 			return -EFAULT;
 		return nn->client_tracking_ops->msglen;
 	}
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9c4adf3110ae..fd947208cd78 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -9577,7 +9577,7 @@ nfs4_has_reclaimed_state(struct xdr_netobj name, struct nfsd_net *nn)
  */
 struct nfs4_client_reclaim *
 nfs4_client_to_reclaim(struct xdr_netobj name, struct xdr_netobj princhash,
-		struct nfsd_net *nn)
+		struct nfs4_client *clp, struct nfsd_net *nn)
 {
 	unsigned int strhashval;
 	struct nfs4_client_reclaim *crp;
@@ -9606,6 +9606,8 @@ nfs4_client_to_reclaim(struct xdr_netobj name, struct xdr_netobj princhash,
 				crp = NULL;
 			}
 		}
+		if (crp && clp)
+			crp->cr_clp = clp;
 		up_write(&nn->reclaim_str_hashtbl_lock);
 		return crp;
 	}
@@ -9637,7 +9639,7 @@ nfs4_client_to_reclaim(struct xdr_netobj name, struct xdr_netobj princhash,
 		crp->cr_name.len = name.len;
 		crp->cr_princhash.data = princhash.data;
 		crp->cr_princhash.len = princhash.len;
-		crp->cr_clp = NULL;
+		crp->cr_clp = clp;
 		nn->reclaim_str_hashtbl_size++;
 	} else {
 		kfree(name.data);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 2d00a411c663..45324734e38c 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -921,7 +921,8 @@ void nfsd4_async_copy_reaper(struct nfsd_net *nn);
 bool nfsd4_has_active_async_copies(struct nfs4_client *clp);
 void nfsd_update_cmtime_attr(struct file *f, unsigned int flags);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(struct xdr_netobj name,
-				struct xdr_netobj princhash, struct nfsd_net *nn);
+				struct xdr_netobj princhash,
+				struct nfs4_client *clp, struct nfsd_net *nn);
 extern bool nfs4_has_reclaimed_state(struct xdr_netobj name, struct nfsd_net *nn);
 int nfsd_handle_dir_event(u32 mask, const struct inode *dir, const void *data,
 			  int data_type, const struct qstr *name);

base-commit: fd179f8a05be3ccae366b9b96e176b51fbe54aab
-- 
2.39.5
