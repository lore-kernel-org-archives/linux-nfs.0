Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 624424A2A53
	for <linux-nfs@vger.kernel.org>; Tue,  1 Sep 2026 20:20:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788294005; cv=none; b=nirzMj8PdSxt54Q5PNGGWh+yMYKDAJKHvBF9ipjCk4ydL11XF3MZTokDuuxrCGZeB+1+UZX35HgTYUkqhLVC1tdiUkC8FQSNcNFeGdQ338fWy2u4m5sTSNI3KfNZxblU/kropn+8CbjF7GhSU6ASuTX2H0HnkGpLqxrocAbgjCI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788294005; c=relaxed/simple;
	bh=1J/yEFDOJSnWQdWiIJadpqrb7x+k8ceZ7KLT25XkDII=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=lKQwI+7Jfv3gp8LvswZ8XJ7r5DBOSkilz1pZGDX+BpW8ZOA8jUqrPJF9ugTUnwbVv9sFT0cLaeLxagwp7JT8W8nZ7gGUBagsptCs/3s6obaUu20lQjRfMJt0neRLimW6oKcBbQtegiDzyrfmfLDyf0xjzZ6OvLNRQ6ZjDh/6Mm4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lQfmIuf9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lQfmIuf9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 800B41F000E9;
	Tue,  1 Sep 2026 20:20:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788294004;
	bh=9h33GUTUQfg476ZzFrGiXPZahl7rJAktyEfkxvZryRk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=lQfmIuf9mA+D3LVRhFjQIeUapyxw51M/SXFnjdKJU/ClzxqJmcYTCfoPxTLmISavD
	 d20HIt4JPVjCFM6jFs+UMvRkAX/xWDXSidn3TgWB4+XCRnX/v5I6r36mhAfhiCLeBq
	 SGVfSKjFZPFsLN5Ls5flxKt8zImudYMzHY1Wq1O3AaRsk5cTZmfPiX0gjDe1Le7+iZ
	 tmuidsBOuQ0X48nPSEFeCJt3VdXJU+jA0qja8M23mcaQ2iC7RK6d7PpbjgKSSIyd6u
	 dYV81HCHeuOfEv6QKAje2wI1kTdmK5OAIv4UVwDeaJTp7LcP/Z3Udr2ksanJ3napgj
	 abF1vuFzevACQ==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 01 Sep 2026 16:19:47 -0400
Subject: [PATCH v2 7/8] NFSD: Complete a cld upcall when the daemon closes
 the pipe
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-alemi-v2-7-e163f94a3a6e@kernel.org>
References: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
In-Reply-To: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Scott Mayhew <smayhew@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2492; i=cel@kernel.org;
 h=from:subject:message-id; bh=1J/yEFDOJSnWQdWiIJadpqrb7x+k8ceZ7KLT25XkDII=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlzNrQrKkUnJWN15PoOwGoKJz4m3rdOnomDQa4
 oRCBR95B6aJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapczawAKCRAzarMzb2Z/
 lzwSEACni+jvwvlwvYkIOj1jyBlgaaYocV7j7p/EWqhG0VjZYSroBFiBxqUjwOYpEWAPhzhtaQI
 k1+Ct+4831Pd5dreKAcK1IrIhv6y+4JfKIKwJswVdVU8LR16bYAbQtjwivgI29fy8/ZOysOWJQE
 tHyn7x5J3j9+219kce7/Kijlsg+lGOWEw4wfnUJpVcNV+z/aAghBYX7g3KxuxTDXb5QPZQ5Z5u6
 u1JY57WYWVXBxVATS1gOq9R8KkEO5FTdr3mswLg/QaQBoxO3+wULJzMpODQ1/a5ZhxaZ/UX+eah
 xAH6lJliWl95LPRVGL/eRcZ2u1NzgxKcgcQurM+lecg7s69h0kXxgTAE1JkFIE7tDLrErHnioZ7
 rka20oCWH1cNmWY6pge49Uc2eDKWd727H6rEJXyvI8Y4phG21A1ITl1pCQJvuNry3gte1xJ5I0j
 tVCNPVYyo8m6xmKJXq7l2bp6BoO3FGt4xjPntAP+uco5DohAJM/kD5hzg/6Mz2VKuobzC7YPSLv
 ms7dF/rEkdvUhNR+hkNwOCKAnLYqTs2UE15ynzz8nUKk9Pxbhn4r+4ZJL8dySWco65Cr7QHi67B
 MtLnET0GzJTIsorWCbDk02Jg8akkm/uE3fwL4t1w2djHCc6JX1XGtGd2egTzTyXkpFWgBX+jXF7
 ZQcZ91SR55zBRcA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Once nfsdcld has read a whole upcall, rpc_pipe_read() unlinks the
message from every pipe list, so the purges in rpc_pipe_release()
and rpc_close_pipes() no longer reach it. cld_upcall_ops supplies no
.release_pipe callback, and cld_pipe_destroy_msg() returns without
completing the upcall because a downcall is expected to follow. A
daemon that exits between the read and the write therefore strands
its waiter: the nfsd thread sleeps in TASK_UNINTERRUPTIBLE in
__cld_pipe_upcall() and never returns, hung task warnings follow,
and the server cannot be shut down.

Add a .release_pipe that completes every upcall the daemon has
consumed. cu_inflight distinguishes those from upcalls still queued
on the pipe, which the framework purges before it calls this
callback; cld_pipe_downcall() removes an upcall it accepts from
cn_list under the same lock. Neither can be completed twice.

Fail the stranded upcall with -EPIPE rather than the -EAGAIN that
makes cld_pipe_upcall() retry. The daemon consumed the request, so
whether it acted on it before exiting is unknown.

Fixes: f3f8014862d8 ("nfsd: add the infrastructure to handle the cld upcall")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4recover.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 1a9ea6393740..5e7788e3fb79 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -871,10 +871,34 @@ cld_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 	complete(&cup->cu_done);
 }
 
+/*
+ * An upcall the daemon has consumed is off every pipe list, so the
+ * purge in rpc_pipe_release() and rpc_close_pipes() cannot reach it.
+ * Release its waiter here instead; no downcall can arrive now.
+ */
+static void
+cld_release_pipe(struct inode *inode)
+{
+	struct nfsd_net *nn = net_generic(inode->i_sb->s_fs_info, nfsd_net_id);
+	struct cld_net *cn = nn->cld_net;
+	struct cld_upcall *cup;
+
+	spin_lock(&cn->cn_lock);
+	list_for_each_entry(cup, &cn->cn_list, cu_list) {
+		if (!cup->cu_inflight)
+			continue;
+		cup->cu_inflight = false;
+		cup->cu_pipe_msg.errno = -EPIPE;
+		complete(&cup->cu_done);
+	}
+	spin_unlock(&cn->cn_lock);
+}
+
 static const struct rpc_pipe_ops cld_upcall_ops = {
 	.upcall		= rpc_pipe_generic_upcall,
 	.downcall	= cld_pipe_downcall,
 	.destroy_msg	= cld_pipe_destroy_msg,
+	.release_pipe	= cld_release_pipe,
 };
 
 static int

-- 
2.54.0

