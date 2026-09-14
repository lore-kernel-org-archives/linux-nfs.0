Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 82239369D40
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 16:00:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789401661; cv=none; b=ADByWzkLiiGBd2c4/RU1M00Oq/sKtW/OINXmrAN++9AjI/jHHolpy9tj3FQcjTKSAG5bJl/e7EkIztXMj3PgFKK6KJqVujUxyn6C5qCt5hzxD30md5IC9bM/sCV8qGumC5DCIAfh25YwFlxLTPGvt4JDDoxYDME/395JKDyhw5I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789401661; c=relaxed/simple;
	bh=qsAdQSbD4HUquE1mes1YstLmAgVJJc/YbGGR4fT3mpI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=grp+vLhkZbxlcxpH5vlr9Qtcg8m/WRaECrGecK/qpswC70ByeGrgXQ6C54TMx422VMRDKeIdgJLP/R6GO7ZpjR5seLumJBKdzOOkjxxK2/u9jZYB48DmMi9D5nKMMAsRdn/nvLr9Juz7+Eg/FRtUbW1z5hOrMPwWFYxOBmPsibU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iJPqgpGD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iJPqgpGD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 94E461F00899;
	Mon, 14 Sep 2026 16:00:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789401659;
	bh=MRHusf2lu3KLhzs78NlOFtRaoSTCaiFWC3t2pp23nQY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=iJPqgpGDDsVQRhBwgtkinbF6Nduiev/mYMbQFFu2BOYJIU2df8/PxIPFaylymLYBW
	 K+4CypWU+kjGD9h3AfSsPIkrfU3WfsYSpfGl7uumQMjXiLtXfayawz55+no8T18Noy
	 BeEsU06yOkn5noxqmBY7Zounmdlrc3JFpv76WfkLifNQECrF+jvLSYTrCjMDVntbxM
	 MAz8Gma9eqNAExTUXt6prPPKg4RGCbgaH1YlZ9sRtJsIBWwCcPj1Nh5t+/TW61Run6
	 l8vQA0i+IVoWapSZbT0AK9wKmFvTVa8UyfgPkRjqxt2Fgm8z1+l9i+GhBKFjNOlKbR
	 w9v3fwiRaOl9w==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 12:00:36 -0400
Subject: [PATCH RFC nfs-utils v2 08/10] nfsdctl: fix heap overflow in
 autostart_func() listener cleanup
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nfsdctl-rpcb-v2-8-b2c679ac0107@kernel.org>
References: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
In-Reply-To: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2271; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=qsAdQSbD4HUquE1mes1YstLmAgVJJc/YbGGR4fT3mpI=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqBoygNMZAGOrdW5L8HvoEmJqcM9TwUg/h6M/g
 hw2WbreddiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqgaMgAKCRAADmhBGVaC
 FcaED/9dWRFH46IKj9SUsdiu8wxY9GXOb0LXxZfRkWX1lla/0df0AXniAWFn6qPPwM0zfOJ2gtF
 WWZgAJBQqhhNr+8/fAx2I+1JeqCo4E06dEfuvCvNc2Roq4eqozRdt70Ye/DBpfgzQWUthES6dBX
 dNrf04/tweRhW03FAQOVsRsPzYWvvbCcPep+tE2d2n/+X0mRCXXfiXkJVYKUrkUIbNOyoaK9sv2
 vbD4JcVzfydJM/kJeZ+QxpnnjRLAfxqMaYf6S6046oTMEAiOoG1n+4/AFzdtRZ9CwGPku5ssxl0
 Leo5kImO5JQ4+HRCFBRJfbOMK4570/GFGeqvr1Y2O6Y/fXneThozpPKCl5rkurX7tsxZ+rgMEOK
 YOF87WO70IIXYzEzm53mC+LAxTSddoYmMHF7lKhz6mkXQcGiVS4u9EG+OGUGSNMCQpkGWwPI1EY
 N/qIKjXPu+tMCBbABe49cGCBKWAwngX29RR+fetQJ5wjgGDYZwFjerUwdSO4708pQpbNF9+adzv
 blyFgyqn4ZCRbpYexQW7FNC7INb2sl2PNmuB4bN7oxT4vOARvBONuvwOE32DV+pmJ2wZLeN1l/7
 TxX3zHp4XKikcgHT68z+2qMlzMTtstNp/oeD695UTWoaLCW58mWOL3oHi15S9yF+6RwqbEeKWjN
 FzjW2yFMyD+Mjtw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The listener-failure cleanup forced pools to 0 before sizing the array:

	pools = thread_str ? thread_str->cnt : 1;
	if (failed_listeners)
		pools = 0;
	threads = calloc(pools, sizeof(int));
	...
	if (thread_str)
		TAILQ_FOREACH(n, &(thread_str->fields), link)
			threads[idx++] = strtol(n->field, &endptr, 0);

The TAILQ walk is driven by thread_str, not by pools, so it writes
thread_str->cnt ints into a calloc(0) allocation. Any /etc/nfs.conf with
a [nfsd] threads setting overflows the heap once a listener fails to
come up.

Size the array from the list and clamp pools to 0 just before
threads_doit(), which is the only consumer. The netlink message is
unchanged.

Also switch the hash_fh_key_file() failure to goto out; it returned
directly and leaked threads.

Fixes: 8b02f0d5590e ("nfsdctl: cleanup listeners if some failed")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 utils/nfsdctl/nfsdctl.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index ce4da2769e5a..a2b5dea75dac 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -2014,12 +2014,6 @@ static int autostart_func(struct nl_sock *sock, int argc, char ** argv)
 	thread_str = conf_get_list("nfsd", "threads");
 	pools = thread_str ? thread_str->cnt : 1;
 
-	/* if we fail to start one or more listeners, then cleanup by
-	 * starting 0 knfsd threads
-	 */
-	if (failed_listeners)
-		pools = 0;
-
 	threads = calloc(pools, sizeof(int));
 	if (!threads)
 		return -ENOMEM;
@@ -2045,7 +2039,7 @@ static int autostart_func(struct nl_sock *sock, int argc, char ** argv)
 	if (fh_key_file) {
 		ret = hash_fh_key_file(fh_key_file, fh_key);
 		if (ret)
-			return ret;
+			goto out;
 	}
 
 	lease = conf_get_num("nfsd", "lease-time", 0);
@@ -2057,6 +2051,12 @@ static int autostart_func(struct nl_sock *sock, int argc, char ** argv)
 		minthreads = -1;
 	}
 
+	/* if we fail to start one or more listeners, then cleanup by
+	 * starting 0 knfsd threads
+	 */
+	if (failed_listeners)
+		pools = 0;
+
 	ret = threads_doit(sock, NFSD_CMD_THREADS_SET, grace, lease, pools,
 			   threads, scope, minthreads, fh_key);
 

-- 
2.55.0

