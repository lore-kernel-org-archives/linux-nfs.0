Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 197F02DF138;
	Fri, 10 Jul 2026 14:00:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783692026; cv=none; b=FJR4+dDmuJ4P0QaKzjEpwQlNYwId9oBmQVjgd2MviTOYyJRgJy1RgP5oJa9Ny3LioLM4Fz2eB8/rLCXKeabCDI8ZZiYN1k1ab8cdzUBmipLsjUnBLo65t5ucQq8SCw6wAXx949B6/JKxA/9FSF+iVNb5is52SF7JAuc2oaDUsA8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783692026; c=relaxed/simple;
	bh=OBAcAmuNHGNAjJb8SGj1X19JOVR/ECBYLZECYdgYJnA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=F97/7drzDO1NwuAIKqfpKVxFbWHVqvXFkV0ZNlnTywpqDNJ3sW1avVKO8gynraDi0IYMd9dG1GiUAYoS8FPWwWOiOdmTW1tls+I8vsJHbP6l1lnHdZfZnS0lLanoPoEvBAbQ/e1JXEMoFHIKRCyiNPR61R7Hu5oqjxX6eeaAxWQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jzhaUJiJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jzhaUJiJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3E12F1F00A3A;
	Fri, 10 Jul 2026 14:00:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783692024;
	bh=S87tTAzj5+/H96YlSzkJ+WeP5cl5B6o4PXUTBsQyehI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jzhaUJiJVR7yNPOm3qFxGiAqoboC+RYemKSQT3O1mCVmykFZt2r/nm9ynY5OGjjpO
	 jS14DaSVC5adEGrdHrAMZPnnEACNGy++X+whCRywhMXVPP4KfMMAobsQxCX4WSDdnS
	 Jg3hLYX/korcdRo0RAN3f81iqzAboySDvJeRhdNIKMV7lY5aGvhjebxuh9rPMn0/Jf
	 oArZlS52iStxdjCyi/EzESXsRqKw6Pf1imSX9e1mgPE9iMnd7286BvgirJfS/VaMWn
	 Wf26whxtbOvD0jsTYpCKXWrH5NGmbvJ/hvgBgFygrViHROQ9ejnew0KBCbDFaa6oaw
	 +L5VtMuOmjYmA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 10 Jul 2026 10:00:07 -0400
Subject: [PATCH v3 03/10] nfsd: fix stale s2s_cp_stateids IDR entry for
 async COPY
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260710-nfsd-testing-v3-3-a0ff7db6aa3e@kernel.org>
References: <20260710-nfsd-testing-v3-0-a0ff7db6aa3e@kernel.org>
In-Reply-To: <20260710-nfsd-testing-v3-0-a0ff7db6aa3e@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1869; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=OBAcAmuNHGNAjJb8SGj1X19JOVR/ECBYLZECYdgYJnA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqUPrzZlzBO4nE8kSVBlHXJMgeaOT+lSj+stUOY
 QzV9LbZjzCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCalD68wAKCRAADmhBGVaC
 FYUpD/4+B0zJSL+QQuoCcEC7WhEstMtnUXMnRyq5WYy88OkQOq2cDRcdpKxgHChtSHkd4oHsDbH
 FHVhl+fVQ+FoOxGjVjP+8B+/CYUoJFxE2TfKGdD1hMku9a6rTDLQGyUFCjWggr4lYAwPKAg70oh
 uakzlImNDn2pO3oBWmrQRNj2qQnG+n6pZRM48kKviMQGRweLbcM/7n4LVvhwaRSQwAyR5L3d/sj
 4V3Sz1ha9M6hF5bXMTrzGNnF8m2if3K08vGIxYczHsNGW2tLDTXj5rLvO2W8riYez5yskWuWgOv
 ud6bPOE9M6m2KDxuGgDSDLY5urrHUjJhIqnhrwAzndEAzu1BSs0T14Lp0nFcEzw6Cce/tmZwpvz
 ++jbznv/JTXU0mA8KBXzjDgQr9mD2HB54cKNdN6fgkSkBZ8eT47DjUf2lTtd+5XgE6vBPWtA8R7
 HyL7wI1lphLEQKO5WB05nI/dY29dg6nainkulZkKJzSZGXjxy1eMDAtQtFlX8Lk2rUPT5khN+7O
 YCzmdZ3SDNBkGs95VFmRKc6uxgxDJRAYbUyX84HoliA65vBxYiErcitUeo/IjFGfvpFzTTfd3ZH
 Ee2vHcNiMKdOTfrvZVjWfw6YKzoHh04z8L1+950qd9PtqbSu6Yd7Zn83tRyOekZ//aMN9M/WGqh
 Gf5tFujgmw1rwMg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

For an async COPY, nfsd4_copy() called nfs4_init_copy_state() before
dup_copy_fields(), so the s2s_cp_stateids IDR was pointed at
&u->copy->cp_stateid -- memory in the per-rqstp COMPOUND buffer that is
reused by the next request. dup_copy_fields() copies only the value into
async_copy, so the IDR slot dangled at the transient buffer for the whole
background copy. Any IDR walker then dereferences reused request memory:
the laundromat reads cs_type from it and, if the bytes look like an
expired NFS4_COPYNOTIFY_STID, follows into
refcount_dec()/idr_remove()/kfree() on garbage; manage_cpntf_state() has
the same exposure via idr_find().

Duplicate the fields first, then register the stateid on the stable
async_copy. result->cb_stateid is unchanged.

Fixes: e0639dc5805a ("NFSD introduce async copy feature")
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b2f1a9bc9202..b9049a3d7c07 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2237,11 +2237,12 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		async_copy->cp_src = kmalloc_obj(*async_copy->cp_src);
 		if (!async_copy->cp_src)
 			goto out_dec_async_copy_err;
-		if (!nfs4_init_copy_state(nn, copy))
+		dup_copy_fields(copy, async_copy);
+
+		if (!nfs4_init_copy_state(nn, async_copy))
 			goto out_dec_async_copy_err;
-		memcpy(&result->cb_stateid, &copy->cp_stateid.cs_stid,
+		memcpy(&result->cb_stateid, &async_copy->cp_stateid.cs_stid,
 			sizeof(result->cb_stateid));
-		dup_copy_fields(copy, async_copy);
 		if ((READ_ONCE(copy->nf_dst->nf_file->f_mode) &
 			       FMODE_NOCMTIME) != 0)
 			async_copy->attr_update = true;

-- 
2.55.0

