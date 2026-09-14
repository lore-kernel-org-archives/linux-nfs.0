Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7BA0636829D
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 16:00:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789401658; cv=none; b=Ylrgy7rPKlZ1LBBlMNcsNAFTHZA1SUe0kEyWE2g+UXQLLJk5Xqq1wAIy1oBx1Ov93ophkhxnVrodjq87M6gcIekjF+e7PhbEpOha2l7G2SmjlyX3zmPBtWZSSdS/yQnJdKV886ly/MNYNwNRf2b0KHtc/O1Jkdzqu50epj0ariM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789401658; c=relaxed/simple;
	bh=gcnBxGsIKGaLB1CLqqvGB1r7EdH7RqS4aB8ByEQPR8k=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=pNOnoCdRvRfVROqhJ/Y38LqZZ3XV0xMJemIlszpe28Bu6vBpXD4sldk3icoam78hAzq7+0y/M+LwyPRPlxSgjnDbQtxj6XupMuWZKzEKtPMoH/qgO+YhM5tDb/4HmeVm9kD4I06ng547sYJbL8hUdabVdACuQ3+vBL6sBzqf4+I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NmjFy+Yh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NmjFy+Yh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A2F711F00898;
	Mon, 14 Sep 2026 16:00:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789401657;
	bh=64Nod3xtqyegr2ytc6zordiq1DU5xUqpkBWFiK0OPwo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NmjFy+Yh4SSi4JVZnHb1Nprht6wND+OzLZFA6m3DASr+aIvTIJjBUs0nX7RQ23Jy1
	 oHzjVcoZCMCcRZ+rBK8tKCOb2hEGsOA684fOEn3S5ynw8zfRHlKWx2fs6DYvCutNXr
	 AtysVlrVlya3QuJpPQdXA1I5qc6CntHPi/nOcj8rG/zplnfFsbBnJcoe2pUURUA04T
	 Dp6NbZ41Vi+7MgllQDbRS4D6zd9+2ESzETzHD62/E+ysDaiZ85L7Hjx8ErChDEthF4
	 Xp6wJTi9wB63VfCvWF95wWwr7Nwq4qDHWSZQFkLNtARDkBAqojlLjvUr7qjB4i/kZs
	 vLPG8q2wpAYmQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 12:00:34 -0400
Subject: [PATCH RFC nfs-utils v2 06/10] nfsdctl: clear rpcbind entries when
 the serv is torn down
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nfsdctl-rpcb-v2-6-b2c679ac0107@kernel.org>
References: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
In-Reply-To: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3595; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=gcnBxGsIKGaLB1CLqqvGB1r7EdH7RqS4aB8ByEQPR8k=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqBox6kEEfpxdvdJKh8myoxfF1mHK6Ck1+z9ua
 BHHvrAt9C+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqgaMQAKCRAADmhBGVaC
 FbMzD/9RnGXsgQgGYIqeGNLs0Fm/0kYSs95OWN6rMo1vU+XQAXLKwjni8BsYFhClwwlIyh5hopr
 RVDUgF91W0geW4bI6GAZ1qoXuL8r3U2T4Z7HDJ8/rlPpoTXCoQEsCFFc7REZTfyZjsnC9+LpvTC
 7IyqQapuwYhW7f2IV2Jqy5B6udx86gn97K2meH66VVlf+Z9GUan1lvD2okkAhsdHYeHgXHd0Fkj
 eqb8IWl4n8cGVBTxZxLPEupVWudhXFcVmjJfHkvPWidejxVmTQMRdfMLEKcOGTj8X98OnRqQ3JU
 e3WOxF+aOBf3rC68o1PkDfnBz9EKtLbwSnPKccLquZcbBqlSxmsOz1/lp2WwXp+iqIZD8jvpVlV
 lBMeEItzkMIGXinERoQJvWmExkwbae3xz3vdzturDvmrH7ePrw99Bcf6k/yUp8GZTkOUoxVZSK3
 POXRcNeuO5izemXwyqvRMQdt15nZTgsP8WA9myknyCEpwiLDcfVZrhUlh795Yaxi7G50A+6Bs5W
 Q2QNR1GrJYHIPTTyjqtXpObw9dsQX8jkudL9Q27b96EvCCFXo4F8/LSclXBLcvI25JFr2xpzg3C
 iNUwTjDySzVtI/IEc+K2rmfafTrbrrSlYYC8HR2sz5ojnNKEpqKvlbCYdgdIjBybdpQhHbEZLtF
 96AcxnT5TdRPXXQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd destroys the serv when the last thread stops. The kernel used to
clear the rpcbind entries on that path, through svc_rpcb_cleanup(). A
serv that let this program own rpcbind does not clear them. The entries
would then outlive the server and name a port that nothing listens on.

Clear them from "nfsdctl threads 0". nfs-server.service runs that command
to stop the server. autostart_func() tears the serv back down the same
way when a listener fails to start, so sweep there too.

zero_threads was true when any one pool argument was zero. That is the
wrong test to hang the sweep off: "nfsdctl threads 8 0" empties pool 1,
keeps the serv, and would have cleared every entry under a running
server. Sum the pool counts instead.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 utils/nfsdctl/nfsdctl.c | 33 ++++++++++++++++++++++++++++-----
 1 file changed, 28 insertions(+), 5 deletions(-)

diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index 699947e4507f..4cc33672a41f 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -836,7 +836,7 @@ static int threads_func(struct nl_sock *sock, int argc, char **argv)
 	uint8_t cmd = NFSD_CMD_THREADS_GET;
 	int *pool_threads = NULL;
 	int minthreads = -1;
-	int opt, pools = 0;
+	int opt, pools = 0, ret;
 	uuid_t fh_key;
 	bool zero_threads = false;
 
@@ -877,7 +877,7 @@ static int threads_func(struct nl_sock *sock, int argc, char **argv)
 
 	if (optind < argc) {
 		char **targv = &argv[optind];
-		int i;
+		int i, total = 0;
 
 		pools = argc - optind;
 		pool_threads = alloca(pools * sizeof(*pool_threads));
@@ -893,13 +893,18 @@ static int threads_func(struct nl_sock *sock, int argc, char **argv)
 			}
 
 			pool_threads[i] = strtol(targv[i], &endptr, 0);
-			if (!pool_threads[i])
-				zero_threads = true;
+			total += pool_threads[i];
 			if (!endptr || *endptr != '\0') {
 				xlog(L_ERROR, "Invalid threads value %s.", argv[1]);
 				return 1;
 			}
 		}
+
+		/*
+		 * The serv only goes away when no pool has a thread left.
+		 * "threads 8 0" empties one pool and keeps the server up.
+		 */
+		zero_threads = (total == 0);
 	}
 	/* check if there are active listeners added */
 	if (fetch_current_listeners(sock)) {
@@ -912,14 +917,25 @@ static int threads_func(struct nl_sock *sock, int argc, char **argv)
 			 * listener. If we ever add functionality to remove
 			 * listeners on an active server, we need to revisit this.
 			 */
+			if (userspace_rpcbind_supported())
+				nfsd_rpcb_unset_all();
 			return 0;
 		}
 		xlog(L_ERROR, "No active listeners added, not starting threads");
 		return 1;
 	}
 
-	return threads_doit(sock, cmd, 0, 0, pools, pool_threads, NULL,
+	ret = threads_doit(sock, cmd, 0, 0, pools, pool_threads, NULL,
 				minthreads, fh_key);
+
+	/*
+	 * The last thread destroys the serv, and a serv that never called
+	 * rpcb_create_local() leaves its entries behind.
+	 */
+	if (!ret && zero_threads && userspace_rpcbind_supported())
+		nfsd_rpcb_unset_all();
+
+	return ret;
 }
 
 /*
@@ -2041,6 +2057,13 @@ static int autostart_func(struct nl_sock *sock, int argc, char ** argv)
 
 	ret = threads_doit(sock, NFSD_CMD_THREADS_SET, grace, lease, pools,
 			   threads, scope, minthreads, fh_key);
+
+	/*
+	 * That teardown destroys the serv, and a serv that never called
+	 * rpcb_create_local() leaves its entries behind.
+	 */
+	if (!ret && !pools && userspace_rpcbind_supported())
+		nfsd_rpcb_unset_all();
 out:
 	free(threads);
 	return ret;

-- 
2.55.0

