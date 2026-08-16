Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB7E238DC65;
	Sun, 16 Aug 2026 08:01:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786867293; cv=none; b=YCNgJrQsW3x+HiNfD/3Au92zYvakr8BLIXHT9fnZK63DocdbT8OMAr2qciBR8jlaw7Q4TGu5xzo94ygtBS8gs/gUcbWbbGs/kScKqHCX9UE+2/G/kWBRyg883wWT1Fhr6wnKeLIV/9gLx9VSLG/w+Ahh5OZMdsSjX1s/ISDVXW0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786867293; c=relaxed/simple;
	bh=V08XHTzDmd0zndE2k1uFguiKVcMiev5gvp2O0PzV+2k=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=n7kHaOoHaXHJyM7+AYAdykn6y4ma76xBhrE9KVL+QwXmvDLBf667g26+Xr92dfuywWGNGl6BAlwg2//k8G0HazHVTbrAPEEsgkaytwCPTof1sbDhmCZmX7cjrJ7Sp8en04N1i0Cs80SPyF1jitshcVaQr/rOdQlMS2SiJgMgJwc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Fd0J6vm+; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Fd0J6vm+"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 86C03C2BCFD;
	Sun, 16 Aug 2026 08:01:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1786867293;
	bh=V08XHTzDmd0zndE2k1uFguiKVcMiev5gvp2O0PzV+2k=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=Fd0J6vm+ujC8N5O5tZcPkJgrYq7jPAG6+tFOPw2R0JkZzBAxhIsNkK+kzEDIjh1o0
	 zgDoKtwjJirab5p9f3yQwdXKcDFH/J/ND+JaRy/e39aAOh+9e0+lQwSSCYAR0du559
	 B1RFO/K0Zl6AooU2ilxIiwZt7Gzs+HwkeAx3RJTZvh68nj/4HdWxX51G56yiURcM/v
	 9qXXV9f1jc+X+rZDgMPYOz2mfMgt/aPqhWNRLIF/Kio5zmDDxux7cufcZWDx1xaN/F
	 xOKE7CZFnAfO4NOYw8TKqTOgaq7FKgB/pWYhbdgnQqEO2LsJq5kvJwUJrqFi7yeJ3/
	 FEjrpATPhjLkw==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 739ABC5DF76;
	Sun, 16 Aug 2026 08:01:33 +0000 (UTC)
From: Junrui Luo via B4 Relay <devnull+moonafterrain.outlook.com@kernel.org>
Date: Sun, 16 Aug 2026 16:01:29 +0800
Subject: [PATCH 3/3] NFSv4.1: fix layout segment leak on the
 pnfs_layout_process() forget path
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260816-nfs4-fixes-v1-3-a810f21729ab@outlook.com>
References: <20260816-nfs4-fixes-v1-0-a810f21729ab@outlook.com>
In-Reply-To: <20260816-nfs4-fixes-v1-0-a810f21729ab@outlook.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Peng Tao <tao.peng@primarydata.com>, 
 Jeff Layton <jeff.layton@primarydata.com>, 
 Tao Peng <bergwolf@primarydata.com>, 
 Weston Andros Adamson <dros@primarydata.com>, 
 Tom Haynes <loghyr@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Trond Myklebust <trond.myklebust@hammerspace.com>, 
 Junrui Luo <moonafterrain@outlook.com>, Yuhao Jiang <danisjiang@gmail.com>, 
 stable@vger.kernel.org
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1716;
 i=moonafterrain@outlook.com; h=from:subject:message-id;
 bh=D7n3g4lGtcu9wd31yKYC70rrbF3Z2OQe2hWQ9E6cyoE=;
 b=owJ4nJvAy8zAJVb4wiKgu++DA+NptSSGrMa8aCsPPc09OY/XHnCMW8+2K/SJ5kWFCefeN3Dfe
 GT7r/uC2NSOUhYGMS4GWTFFluMFl75Z+G7R3eKzJRlmDisTyBAGLk4BmMidbIb/CQrbXQ4lT5Jm
 3/R91rknK8vSd72ZvWHFlX0zPC9v2SF0fjcjw6Wt1x9c9agWLMj8Vbr8AM+kaWn5LOwFl+TdNq/
 suLCPgxEApqFPaA==
X-Developer-Key: i=moonafterrain@outlook.com; a=openpgp;
 fpr=C770D2F6384DB42DB44CB46371E838508B8EF040
X-Endpoint-Received: by B4 Relay for moonafterrain@outlook.com/default with
 auth_id=909
X-Original-From: Junrui Luo <moonafterrain@outlook.com>
Reply-To: moonafterrain@outlook.com

From: Junrui Luo <moonafterrain@outlook.com>

When the server returns a new layout stateid while a valid one is still
held, pnfs_layout_process() calls pnfs_mark_matching_lsegs_return() on
the on-stack free_me list and jumps to out_forget. Segments whose
reference count drops to zero are unlinked from lo->plh_segs and moved
to free_me by mark_lseg_invalid(); for an idle cached segment the layout
header holds the only reference, so this happens on the first decrement.

out_forget never drains free_me -- only the success path calls
pnfs_free_lseg_list().

Commit 814b84971388 ("pNFS/NFSv4: Fix a layout segment leak in
pnfs_layout_process()") added the drain; commit 08bd8dbe8882
("pNFS/NFSv4: Try to return invalid layout in pnfs_layout_process()")
removed it while switching the destination to lo->plh_return_segs, which
is drained elsewhere. Commit fb700ef02676 ("NFSv4.1: Simplify layout
return in pnfs_layout_process()") switched the destination back to
free_me without restoring the drain.

Restore the pnfs_free_lseg_list() call.

Fixes: fb700ef02676 ("NFSv4.1: Simplify layout return in pnfs_layout_process()")
Reported-by: Yuhao Jiang <danisjiang@gmail.com>
Assisted-by: Claude:claude-opus-5
Cc: stable@vger.kernel.org
Signed-off-by: Junrui Luo <moonafterrain@outlook.com>
---
 fs/nfs/pnfs.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7715e2bd5871..a3d2ffc9daa5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2643,6 +2643,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	spin_unlock(&ino->i_lock);
 	lseg->pls_layout = lo;
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
+	pnfs_free_lseg_list(&free_me);
 	return ERR_PTR(-EAGAIN);
 }
 

-- 
2.51.2


