Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 04A0F5803BC
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 18:22:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789064537; cv=none; b=Y6+XIjYMP2ILddyHu9QIkEB11VFeC6fhWOMljt0CKEYPg4iyfTvbIXMQiehQx2L+qfX/JGhdG91Aava18AEjs2EGlu2yLu9n6/z/6jAfqVXHabuJI489xvig6vJ32a23w132l9naJpibYSxURlfz5MQlPJQxpeD+Q9BKtuSPVdc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789064537; c=relaxed/simple;
	bh=rd0hmUEGxOiUjwuRcrEKLe+9gvXFjybpRrRk6I9wG6g=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=DAKjDsxYgJNPrup2K6b6ngSYlpsu+VmitTTMKWIZ4evnD7SGKjgqCGKJ6bM/twRgVu7aYpis2t7vDDp7BDKAwsmhtv22mNmFSuXXVGDRXjRW27Zo/gaswAB/x9sggmep/yMks4O9tUrofrFB3L6ephNP4l2XeOIk5y+rp50e9tU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aRF4ayQC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aRF4ayQC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2C68E1F00898;
	Thu, 10 Sep 2026 18:22:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789064535;
	bh=+AfY6E99Zu/Lo3LxNgnd5plP0ChQVQIH9Fq4bsGwmuo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=aRF4ayQCv5VAE2BTJFBXsPvQFBR4GPeEDiXrymtb5oVNTqgG1tQsWL5iCi2FabHLF
	 6C8qB7L2NjiMQHe1L3gxqvHQl5ZJiN3LNzsBVEGd7RqnPB3/oN0GSbwLImgRdGWhTr
	 RBQbBq5S/BaXqIabqB4lVHiEWjaLyfjeXPLF8IWan0ytw0nM75R1nXolzRwyxnV+eG
	 y2hYDT1iBasCnnegOawj/fgxrxXcDi/cD76HqFHWVUtI+i71daGNLGxr5pBgqCErMs
	 VKhe9gWLuVAdztePXyTG4plNHh/pxgF1fcS6HAvK6kS2NYqPD9v6Rg7n7EEIf5T87f
	 YDls83f8a4N4Q==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 10 Sep 2026 14:22:07 -0400
Subject: [PATCH RFC nfs-utils 6/7] nfsdctl: clear rpcbind entries when the
 last thread stops
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-nfsdctl-rpcb-v1-6-4bba1e7a3a43@kernel.org>
References: <20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org>
In-Reply-To: <20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3005; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=rd0hmUEGxOiUjwuRcrEKLe+9gvXFjybpRrRk6I9wG6g=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqovVQWg1Qmv/G5FXA1RWjOrkqC4uObAesHlmWB
 A9vT3kTRjWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqL1UAAKCRAADmhBGVaC
 FViyD/953JX0yjgT1jdB7mFzYKjndRfhorcX9SA9wWJyJDO2LlQhte9LAszYQSOd2wq3IwLVQSO
 J8LQOw/Bb8D1C6eu9XFKxQuQV30K+6XPG49d9JK9kPymdp8HhM1nQHkCc4hj4k/NvjXYuuAhJpP
 4M8LrZKMtTUupl3eDuPz/rRxgRwJWlP8K5PRxsT6Q5rrttRsEXRyqR+1goXug5sVDYLfK0vg17O
 ydEPiJOLVfUE4aEbf37h2IIsaNNPQOW+GasOYDrRRuFLs+PbAnSXhCnPbHZ1bXqJX41KMGrzRfg
 S/te6mXd2Dwx+3IPdHqy0LkDsybarX2LrNNtNhIdDR6Enw5WTzjRmDR5c0OENFjuvuEVWh3Kj9d
 B+hTbc4ctzm4wduDak8MQjkNl+RJtfwDTw2N/urEjETTg0wTpxWvYLYdR0nvTeb1P5MG3TuQSfr
 cGezOpw/1SB3KLhB2TZlQ5OLktjunEfwPq2mLtmkVuFqS9gkCA+fu+3YoMCIjrBkc66PNtqujGF
 iSKQIV3PlV3F1H4rL2YxY+LJhiM2IaANemqjjf1IgPGFaQr9Mnrk82ZC67aapFV/46xC7DSJMK4
 SpiXr2xSFMWf74k0L+rWZ52DIJDqJcpsgET/bVT50Y92vIfjG5chDTZ8FldqSc+aqGsCXIuLABQ
 utEbHnwaR7w6lfw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd destroys the serv when the last thread stops. The kernel used to
clear the rpcbind entries on that path, through svc_rpcb_cleanup(). A
serv that let this program own rpcbind does not clear them. The entries
would then outlive the server and name a port that nothing listens on.

Clear them from "nfsdctl threads 0". nfs-server.service runs that command
to stop the server.

zero_threads was true when any one pool argument was zero. That is the
wrong test to hang the sweep off: "nfsdctl threads 8 0" empties pool 1,
keeps the serv, and would have cleared every entry under a running
server. Sum the pool counts instead.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 utils/nfsdctl/nfsdctl.c | 26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index 370784e8fe8c..a96faee6cbea 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -832,7 +832,7 @@ static int threads_func(struct nl_sock *sock, int argc, char **argv)
 	uint8_t cmd = NFSD_CMD_THREADS_GET;
 	int *pool_threads = NULL;
 	int minthreads = -1;
-	int opt, pools = 0;
+	int opt, pools = 0, ret;
 	uuid_t fh_key;
 	bool zero_threads = false;
 
@@ -873,7 +873,7 @@ static int threads_func(struct nl_sock *sock, int argc, char **argv)
 
 	if (optind < argc) {
 		char **targv = &argv[optind];
-		int i;
+		int i, total = 0;
 
 		pools = argc - optind;
 		pool_threads = alloca(pools * sizeof(*pool_threads));
@@ -889,13 +889,18 @@ static int threads_func(struct nl_sock *sock, int argc, char **argv)
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
@@ -908,14 +913,25 @@ static int threads_func(struct nl_sock *sock, int argc, char **argv)
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

-- 
2.55.0

