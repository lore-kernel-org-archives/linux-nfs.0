Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B566C190664;
	Sun,  1 Mar 2026 02:04:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772330693; cv=none; b=c3CkmM3sP4Xe7K68kkJUr+lkv0cZEmMJPtHhfN1TOEGCUzcSmdi2QtA+NSsF6Ff3X794u5+40raymC+WXO9NFprAaUW4gh5P5+SD+/tfiWb2dsvjBoBZ0ZjytzYQTBkorvS6UMdbhkmVq0/6ud5wm4PlpjSptUaBb88W7Lj75J8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772330693; c=relaxed/simple;
	bh=caKWZYL5O7q0hLqaeYoNM0JGfpq/Z1+OaVwX/7/f1/Q=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ZjcNJkTAW1qIfPx54xjhFbrOBObDROSGtczw3y6UB1zpc60agXxAUCRX2qsUaNgqqb0cDxOh4qBbNKn327E7wDorfQItQCSDk5btRJ/0oaj3NBJV5b+zNawzo/5R7B2k9EeQhI0NAQ0gjIww2B+C326we1ceSt4lzdnUiN3LUAI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RxCnuj3o; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RxCnuj3o"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0C4A4C19421;
	Sun,  1 Mar 2026 02:04:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772330693;
	bh=caKWZYL5O7q0hLqaeYoNM0JGfpq/Z1+OaVwX/7/f1/Q=;
	h=From:To:Cc:Subject:Date:From;
	b=RxCnuj3o/u7dDvxrwRSotkRJQe5BXMag7jBIfCMi7VOUo+x7qnI/1B0LLLJsh8Bbr
	 ANPx3FGDdp0BdB72yqPIsTy7F6IcP1slV6RIqH4U3wQJ2kxYG7STCJaw8isBWKZgFD
	 n1ss4AKmCNf1f4sT8G+Pcpk4sw4z3GzO1iP0SkiziEeuXIPh2RQBfXycdqQmc6otQE
	 7FGzmb/h5XXMlVQLfyITL42R+T828QVlx978H4rO5d9WXH5dWyoM7+OXQM+d2V9Z+O
	 T/NC5UdA6Se9JJm/q/oAuAaYBoNUSZeompcIh9hTcRiQledftDsTC9Sv3MC41YLQHx
	 ZTzvjgl3HHAFg==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org,
	git@danielhodges.dev
Cc: Anna Schumaker <anna.schumaker@oracle.com>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Subject: FAILED: Patch "SUNRPC: fix gss_auth kref leak in gss_alloc_msg error path" failed to apply to 5.10-stable tree
Date: Sat, 28 Feb 2026 21:04:51 -0500
Message-ID: <20260301020451.1733398-1-sashal@kernel.org>
X-Mailer: git-send-email 2.51.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: ignore
X-stable: review
Content-Transfer-Encoding: 8bit

The patch below does not apply to the 5.10-stable tree.
If someone wants it applied there, or to any other stable or longterm
tree, then please email the backport, including the original git commit
id to <stable@vger.kernel.org>.

Thanks,
Sasha

------------------ original commit in Linus's tree ------------------

From dd2fdc3504592d85e549c523b054898a036a6afe Mon Sep 17 00:00:00 2001
From: Daniel Hodges <git@danielhodges.dev>
Date: Fri, 6 Feb 2026 15:41:46 -0500
Subject: [PATCH] SUNRPC: fix gss_auth kref leak in gss_alloc_msg error path

Commit 5940d1cf9f42 ("SUNRPC: Rebalance a kref in auth_gss.c") added
a kref_get(&gss_auth->kref) call to balance the gss_put_auth() done
in gss_release_msg(), but forgot to add a corresponding kref_put()
on the error path when kstrdup_const() fails.

If service_name is non-NULL and kstrdup_const() fails, the function
jumps to err_put_pipe_version which calls put_pipe_version() and
kfree(gss_msg), but never releases the gss_auth reference. This leads
to a kref leak where the gss_auth structure is never freed.

Add a forward declaration for gss_free_callback() and call kref_put()
in the err_put_pipe_version error path to properly release the
reference taken earlier.

Fixes: 5940d1cf9f42 ("SUNRPC: Rebalance a kref in auth_gss.c")
Cc: stable@vger.kernel.org
Signed-off-by: Daniel Hodges <git@danielhodges.dev>
Signed-off-by: Anna Schumaker <anna.schumaker@oracle.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 5c095cb8cb201..bb3c3db2713b1 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -39,6 +39,8 @@ static const struct rpc_authops authgss_ops;
 static const struct rpc_credops gss_credops;
 static const struct rpc_credops gss_nullops;
 
+static void gss_free_callback(struct kref *kref);
+
 #define GSS_RETRY_EXPIRED 5
 static unsigned int gss_expired_cred_retry_delay = GSS_RETRY_EXPIRED;
 
@@ -551,6 +553,7 @@ gss_alloc_msg(struct gss_auth *gss_auth,
 	}
 	return gss_msg;
 err_put_pipe_version:
+	kref_put(&gss_auth->kref, gss_free_callback);
 	put_pipe_version(gss_auth->net);
 err_free_msg:
 	kfree(gss_msg);
-- 
2.51.0




