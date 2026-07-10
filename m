Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 225E536A360
	for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2026 20:47:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783716438; cv=none; b=Orq7zctbkZ9rUkQtVdIQgtXYfinhNeH76SNvpH/3xvfyjjESnzdKPKfSxLbIzAWHfSeAgvP/uhprVOQ25Tqs18qdYpDWcjN966A2AkbjFo/pXMCIXAgBam94YYzY7e8BVHkbHUqi9SNFv9mhb/DZKQGq92byS0vXcN+dDZgl0M0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783716438; c=relaxed/simple;
	bh=AsJMliBe5ejbNkbQ/Epyf2kYMWUQ406FRpVK4OlZ8Uk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=gqbsqTVpciYbylZoE3JB8I1d+Si7LStZMpegKiUSj9N+x9bbKUK3brieZwp7/ZxIfUsxIgBkUw2Wwvstypyrpdh4tVUQyYuDoGdHJw5JWldWzaMpZDg8WpEXcdh6iqBon+IpiM7pHNXd+kggQOF+E6At9S5+2tb8Yn9JWZVa1HE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZKozJR5R; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZKozJR5R"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6C60A1F000E9;
	Fri, 10 Jul 2026 20:47:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783716436;
	bh=RRrkpeB/p82Oip5WxW622/k9Mf9MO+9qTyJdLa7QNTY=;
	h=From:To:Cc:Subject:Date;
	b=ZKozJR5R/6Rc/Az5m7xSXea7WaRQITLRuwEClAy+RVH6Iaqv+BSD4FMJ4z+d3DkF1
	 YiXNjhCy+SXrqkm9hhKINguViJhcQjOh090ulhOVMdfLgX2dtqFpalwpaemTsg6+bs
	 WGREomZscsNwoucVcUUtITtZp5byqdAGRa+e/NbkjZ7+FNThxRvYduLKrQ5I1sJeYY
	 jKlpjdTeTMQwEcuc5gbTgCELHYw+KKmJEMafpEry+fjSPQJFZorCliPo3gq88VWxLK
	 7HWNLL7xiqlUYZi0g1VY1gqJjgJz1m9pKkcqtpHWVZum1+O+01XHm9zrFkQLtJTK9v
	 Hk6hKL647BwtA==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH 1/2] NFS: Pin the 'struct nfs_server' during a FREE_STATEID call
Date: Fri, 10 Jul 2026 16:47:14 -0400
Message-ID: <20260710204715.621189-1-anna@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@hammerspace.com>

Dan Aloni reports that he was able to hit a use-after-free bug if a
FREE_STATEID operation gets delayed for whatever reason. Fix this by
bumping the refcount of the 'struct nfs_server' object for the duration
of the FREE_STATEID so it doesn't get cleaned up from underneath us
while operations are still in flight.

Reported-by: Dan Aloni <dan.aloni@vastdata.com>
Fixes: 7c1d5fae4a87 ("NFSv4: Convert nfs41_free_stateid to use an asynchronous RPC call")
Tested-by: Dan Aloni <dan.aloni@vastdata.com>
Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a3415082d610..3ad5ef52a2e8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -10364,6 +10364,7 @@ static void nfs41_free_stateid_release(void *calldata)
 	struct nfs_free_stateid_data *data = calldata;
 	struct nfs_client *clp = data->server->nfs_client;
 
+	nfs_sb_deactive(data->server->super);
 	nfs_put_client(clp);
 	kfree(calldata);
 }
@@ -10405,6 +10406,10 @@ static int nfs41_free_stateid(struct nfs_server *server,
 
 	if (!refcount_inc_not_zero(&clp->cl_count))
 		return -EIO;
+	if (!nfs_sb_active(server->super)) {
+		nfs_put_client(clp);
+		return -EIO;
+	}
 
 	nfs4_state_protect(clp, NFS_SP4_MACH_CRED_STATEID,
 		&task_setup.rpc_client, &msg);
-- 
2.55.0

