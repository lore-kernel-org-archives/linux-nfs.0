Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2146939DBCB
	for <linux-nfs@vger.kernel.org>; Sun,  4 Oct 2026 19:40:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791142836; cv=none; b=VwHLN4WR7+y51jvB3h0QQy1o6Sup1VJ5K2G3IgFPWGPYY5vbqKpiGzf4GaRLLJcDhgccZFW+8cYIn/h99EVhjXWeT5rPitgh2J/4aFmB+82uZyBRSJ21doCD3P82CvWDy5cUlV63aSZn7d2TuLWQZFGEYofR90kGzWNCluQpguA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791142836; c=relaxed/simple;
	bh=i0TuHmqAiB6AtdIDv5yoZjmxKRhFhYMhvZVY7DHDEcY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=TAqjQAgNMvSiP4cwaKNUd9oJu7qNKYCyV1FmSzCYXpgeHZUBElvgVnNxql37c0qVblWyLUqcHe15ZCGAZr04QqF38G7cofYryGJd/TDyZuoQ6gunzNithAFq6s3Km4iwv/25OiaTeCmBOnEuuLcbniQF++Qf6Pj9ttO6ISyv3sw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DvdGlK1i; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DvdGlK1i"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 840E21F00893;
	Sun,  4 Oct 2026 19:40:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791142835;
	bh=vj3mcdioR5GWHTlMtUcyWeF84ac/ca0zaiOMZWhVglI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=DvdGlK1ietjV5z9gix3+Vk5GcIA+pf/rSgRerEaA4TyQoGQAuKddPjVvuCYEuUcWF
	 lmQILcA5jdPfFNCzQ7ClmXogEpWr9iCewNPvSVSjr6qVYMXRpdMF3Wg/iVvvere80j
	 veMcNBELVJcojLen6H1iZcnV60wWTNnTBR6aofXoj0ykyAhvZf+vNohSWgDJTuQDeg
	 4aOz9k0fyU2MFIBiC9nIzvU5AlXiFQxckp2xgiAbLYP8eZjMEMWm8Z3Ic12Ibbaouc
	 3DEQETuGaiyYnlJClgVbaF0JCWjZJBX4H1/eiFd/6h7CUoveLqgOWPuVbQW1PbDd/J
	 bc8ZH3eAy/tSA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 5/7] nfsd: remove unreachable cancel of the layout fence work
Date: Sun,  4 Oct 2026 15:40:27 -0400
Message-ID: <20261004194029.10714-6-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261004194029.10714-1-cel@kernel.org>
References: <20261004194029.10714-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Clean up: Queued fence work holds a reference on its layout stateid.
nfsd4_layout_lm_breaker_timedout() takes the reference under ls_lock
before it queues the work, and the fence worker still holds it when
it queues a retry. nfsd4_free_layout_stateid() runs only after the
last reference is dropped, so its delayed_work_pending() check is
never true. The check reads as though sc_free cancels fence work,
but nfsd4_stop_layout_fence() is the only teardown path that does.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4layouts.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 7ac379fd5868..898776c9d72f 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -169,13 +169,6 @@ nfsd4_free_layout_stateid(struct nfs4_stid *stid)
 
 	trace_nfsd_layoutstate_free(&ls->ls_stid.sc_stateid);
 
-	spin_lock(&ls->ls_lock);
-	if (delayed_work_pending(&ls->ls_fence_work)) {
-		spin_unlock(&ls->ls_lock);
-		cancel_delayed_work_sync(&ls->ls_fence_work);
-	} else
-		spin_unlock(&ls->ls_lock);
-
 	spin_lock(&clp->cl_lock);
 	list_del_init(&ls->ls_perclnt);
 	spin_unlock(&clp->cl_lock);
-- 
2.55.0

