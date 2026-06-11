Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DEAD43A875F;
	Thu, 11 Jun 2026 20:01:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781208088; cv=none; b=obI4vbofs0GQ4P5zpf5988FT1dHiVGF0ke6aRW6KJJTqXoLc1EdNVtNoAHwlqgtmWMQSRQAoszSJosotD6cPgYmQutna/8CjC/ltVaJCxxvWmEdmlQoDbfJ+IuczBDKcdrlKix7SKkV4Q+57cAxkkdiWAhQw7ZdBnt9kU8OlWJE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781208088; c=relaxed/simple;
	bh=HjdcV2o8ncJG3aQMZRNiAtDXRSSo4VAEwbbEo7SDSMI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=iZbwm5M2XgZOtgc4H2VULcyWM/WlbZf2rjZgYgbNdh4xyYFOXYdoNC4Z29FgzbF2S2w5IxrMBn0eFSuvX8FqAYckkc0IJPEXLYCy/tf71WDFBJTCfYSLjGTho29AwhjnCuQdyLbAq+zgTEoEDXuHF8mkrRRK0AnzWdkxWyUPw5k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kuA+02bY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kuA+02bY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0E2151F00A3D;
	Thu, 11 Jun 2026 20:01:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781208086;
	bh=6debSdEaXxrI+zgXvMpC3Fp4bAhHn2+KFSNNHUmoMHI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kuA+02bYuSEN5pSNiE2O6qRasijJAFLpMl9J50MKAMpNVIgKzd6B9DpL9WX6XCaP8
	 FY9opNG78lquXl6xlInz1HSg1MxqQvDzyE9RZAGd5kFXiMLNy/bot8xATaL8L3mwMB
	 Nry8PQJW9qo1/fDZRPgGGlum23R1qPVxheS7v/0u7OblNlqQ8B6Nt9kxFgcmQmjBBp
	 sKqqiAktvdispwNthdrJ+A1vWZfIGOGD5Q9/b9+1dHLPD0JgTkrVlXDnAAe9Wbn6vc
	 nnYkW0IKbu5GEw8YpUpuw0kz60e/ya5jI8A7Nkqw7CtnG+B2kzG84BIWwiimqWBN7G
	 0yjMeQZmU2IHg==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 11 Jun 2026 16:01:03 -0400
Subject: [PATCH v2 20/21] nfsd: reset thread skip index when advancing
 pools in rpc_status dumpit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260611-nfsd-testing-v2-20-5b90e276f2d9@kernel.org>
References: <20260611-nfsd-testing-v2-0-5b90e276f2d9@kernel.org>
In-Reply-To: <20260611-nfsd-testing-v2-0-5b90e276f2d9@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2084; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=HjdcV2o8ncJG3aQMZRNiAtDXRSSo4VAEwbbEo7SDSMI=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKxQBjOn8XRRNJmd+dEPmbrKLRhziQGET1QP+f
 GnsKJgecvWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaisUAQAKCRAADmhBGVaC
 FVUXD/4tWMbmztr+AuhtQgQvTjLGNk0bEHO+jg5KgxTBCSBzl1Nd2/anC47gQb0IgO+BafMn2BQ
 N6hU+R4zCYYocDkiOHvY4BOhIVWoZqEXPTQlWWBvfFb9haV4798HE/kLNiuvgk9aULZqsmCXz+q
 isr4LPloTQoX38fqii6PKXz+QEiyzSlE0z+MTeG/cao3LYfkzzLfha6NA0zPCOj5V6zLqnScZzx
 zJffiThjR0Pj+6E3qA/871ZXx0qWj4NVfS6LSzG8VCfdMtpBc87prZ2K0gGVAIFR73iejceQUuE
 MaJVe7OfXxA4PbO5X805r7AUtXm6kPIoCSx2/7FM3t17H42bJjhnGPcOeuJQJ4wEe/LZT6uw8KL
 tHT4CcwJzvlRD5PutniFUHwLdfS1ukOhFRLJP0NL3J0XAwM2QDjI0y1EmAsbvTL5l/UPn17nluL
 zoPWEEu9E97ZkTkXSZNnu+cPdSvjkWJwn9zSzJSPKcN3k8u+ztyFYt0HorUn8AB+NygXU2BFFfI
 gkdYqz0T39zXvQmdinJSpR8cn89avUkHc7MTDhKWrssbZrJHWVRMFhO/wYqh+/Nzfx6UPJW6Q7Y
 x1eOxxP4LYTQhUDZAyXTnskLyofOCJuQ8tEXm5YYQ5bsL1H9FKa2TJ3W8k2rxhgro1boznCA2Xb
 ha71Q5WcK025VfA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

When a netlink dump of rpc_status fills the reply buffer, the iterator
saves the pool index in cb->args[0] and the thread index within that pool
in cb->args[1], so the next invocation can resume where it left off.

On resume the thread skip count was applied to every pool, not just the
pool the dump was suspended in. Once the resumed pool was exhausted and the
loop advanced to the next pool, the first cb->args[1] threads of that pool
(and of every pool after it) were still skipped, silently omitting their
rpc_status entries from the dump.

Apply the saved thread index only to the pool matching cb->args[0], and
start every subsequent pool from thread 0.

Fixes: bd9d6a3efa97 ("NFSD: add rpc_status netlink support")
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 720b481bb7ad..a5e328b14e45 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1527,10 +1527,20 @@ int nfsd_nl_rpc_status_get_dumpit(struct sk_buff *skb,
 
 	for (i = 0; i < nn->nfsd_serv->sv_nrpools; i++) {
 		struct svc_rqst *rqstp;
+		long thread_skip = 0;
 
 		if (i < cb->args[0]) /* already consumed */
 			continue;
 
+		/*
+		 * The saved thread index only applies to the pool the dump
+		 * was resumed in. Subsequent pools must start from thread 0,
+		 * otherwise their first cb->args[1] threads are silently
+		 * skipped.
+		 */
+		if (i == cb->args[0])
+			thread_skip = cb->args[1];
+
 		rqstp_index = 0;
 		list_for_each_entry_rcu(rqstp,
 				&nn->nfsd_serv->sv_pools[i].sp_all_threads,
@@ -1538,7 +1548,7 @@ int nfsd_nl_rpc_status_get_dumpit(struct sk_buff *skb,
 			struct nfsd_genl_rqstp genl_rqstp = {};
 			unsigned int status_counter;
 
-			if (rqstp_index++ < cb->args[1]) /* already consumed */
+			if (rqstp_index++ < thread_skip) /* already consumed */
 				continue;
 			/*
 			 * Acquire rq_status_counter before parsing the rqst

-- 
2.54.0

