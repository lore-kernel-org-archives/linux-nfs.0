Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297187;
	b=dr/5ImbIu66gujg58HAADF/YaGdmeO426cZ5MWQ38Om1Rqwj1Lr28RHlBJpZlTFMd4SA
	 3s+Grf9MVcZnSwRpt5JsV1lJb5u1cTXZoNhvBNbAV1xjTEdH8I30dcOAz9KDPgqEBiWAT
	 IBhTcQ4RGVk64HeRGW1WFfd2q8QG8bO/1z6iBsjs2pAUhhZ63UoVtAWiLsJ2ctXzjWByt
	 q7uipaSFw5Wp9afHG8dTCp5xdN5g4ERrGBfPBbrYHWSW/p6VKymr14BQjmfzFkkTuFuA8
	 5ZsxVuEIFUmakFz4MTJvDf3FdWD97ddnwiMz9EsM1SVUpororUcPBMWQeoewKmXBddA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297187;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=wcRWeoTnxmMz2yFxz5ziwMIAik5LTWFJFt8oxHzTDXQ=;
	b=bX+Js58JNXSTJj7HgXpvQ+tOB5KDLEWRdXVY1iiIyY5XkdVi/h4CY2zm17fh9JAMqMRp
	 DV+fFTmPl/YOCmpuKezMsA8SgHfchhyCu3FIRBGbBC+eHIazoVCbrmmAZ21NTMKHyh/CA
	 xmwEhjCP7Mg+RLGYmlVTxyQkEckukE+NObeGiZ6QKMrGBKCs9Tg5LbqP5lq1q8F5lBsD8
	 0EvjeII06T+WtYWpwAkfLHyeskyd9b0RB/LfJsXCYL5DToaeiA0njeCgCIhVhx2mxOP28
	 PiO3dmG/h1tvo3UKwtOL3jNC2+W2Z5ITRLCRg8an3cZmbmNvg7ItqUQ3rOeLpu/52Yw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dy4GpW3l;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C1E6D606A330
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:06:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dy4GpW3l
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E330E1F031E4;
	Thu, 29 Oct 2026 18:06:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793297186;
	bh=wcRWeoTnxmMz2yFxz5ziwMIAik5LTWFJFt8oxHzTDXQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=dy4GpW3lH8pSOtWQtyN+93UJw4740LOH9QKHXZAvsJqS92tpT/FQ4l/vCpqq33pLn
	 ZUNQ31q/hHAeWxBYr/QDUNxnOX/Rl7+dua30z4nnC8mtm5hFOawPrzrCxbRoURzIrZ
	 V1pOZ1kNztvucKEJPzbRVe3JWCsu5Uc587rE6wHgk2R4DmQS6JYSHSmkvRKUk/4o0W
	 w/t6IyRUp29lvxEagt3AzUHZqeExiU7IjNEtPvfNP/muDMZSAiQapmnTOcRDd2ADA5
	 uu06bK5sp9TfMRIx+rMIXEHuoRwvJ12XkI8KYNnkligx9J3TON+hnlkvNaCDsziCue
	 +NqsaddBJlgLg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 14:06:11 -0400
Subject: [PATCH v7 05/13] NFSD: Prepare bucket pruning for additional
 eviction reasons
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261029-duplicate-reply-cache-v7-5-f3b0f3cf5bc7@kernel.org>
References: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
In-Reply-To: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1473; i=cel@kernel.org;
 h=from:subject:message-id; bh=JEijht0z9yZxjifkfaggMNGj39+F+JsRc20qVhemrfU=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq44scH+dns1AsprsXHu0IqH687IswwfW/eGcxu
 cv3edp/paaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauOLHAAKCRAzarMzb2Z/
 lw53D/0fGhlqMEOEt0SlWNxORivVrDf48LszL60egLZD8vCWbzZrpYTIbBILnZgkD4YgtDD1zss
 rRE8rjpBp+VWRlMAu97YzFCYC/cdFCPWSE9yYRLAP+u9ZocgQebXO/IUj+2qI9VNzPhJpVHlW8u
 7UcVVOLNgysCRufZEeOBtnVaXJuEXyGdIA07moXakDI+esXzOHiLUYEIxszMXsqZUw3QEtVpY9X
 A6r+2ZDOTE5PoRsZtODwILfOI2SlkxpuAsaszLH36YItqJwsnEuBbHsUJ9qrHrL3OhsWdr2JZzy
 2GLUDgrkHKOVkfei9nEtt0+ZBFTvEyt3vZzyF5c/pvL4Y+hgrcRQy0tqF/LdsFs9fJd8t2N/IIK
 CHWVcJyCyJDAFpJrmEqMtCjWbWMd+eMd9Uw1fuTER/if2IThfpv6L6MeV/gSgBBNCpBmfS42D2o
 SEmvTFhUHzVH0zyF3XnfVAvJJnV2+NJvKFOyNqJTU6Yb03BFteeWTUyQEI6bC2xeX3Mc4XLedPM
 NBXwV7fxPPjyjTi6Y4lPWMju0abAXeXC+BaH3TFo9c1dxxgbj//f/JFv+kFO1Is+ou40sLy1id5
 Xue30qB6CtjONWcfAdNCFnskbotQAlbLZZ3nYYJKBpIwaXORDIMedlpOxgCIqlUF9iqwXh2+/ka
 LiW7foOajWLuJwQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_prune_bucket_locked() combines its two eviction reasons,
memory pressure and RC_EXPIRE, in a single test and stops the walk
at the first entry the test does not evict. A reason that needs
its own handling, a tracepoint per reason or a test that must run
ahead of the stop, has nowhere to go.

Test each reason on its own and jump to a shared eviction label.
The walk still stops at the first entry no reason applies to.

Assisted-by: LLM
Reviewed-by: NeilBrown <neil@brown.name>
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-5-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 01ad6a9ebe1f..988b955590cc 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -274,10 +274,13 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 
 	/* The bucket LRU is ordered oldest-first. */
 	list_for_each_entry_safe(rp, tmp, &b->lru_head, c_lru) {
-		if (atomic_read(&nn->num_drc_entries) <= nn->max_drc_entries &&
-		    time_before(expiry, rp->c_timestamp))
-			break;
+		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries)
+			goto evict;
+		if (time_before_eq(rp->c_timestamp, expiry))
+			goto evict;
+		break;
 
+evict:
 		nfsd_cacherep_unlink_locked(nn, b, rp);
 		list_add(&rp->c_lru, dispose);
 

-- 
2.56.0

