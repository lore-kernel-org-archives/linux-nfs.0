Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9460D1B2EF6;
	Wed, 21 Aug 2024 14:56:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724252211; cv=none; b=enILXpt5p30ZCrf0nZxfzaPm+W2vbcf0i3iv3LiWKVp7wU/If6WSgtP+3jpg9sUTsy3QWCpk2sDH9NGSOGqW/Bdulu9O2YoJ3wLW9+nTX+3Ns9rNSLadi/RWnhcs1fFohxYjgpMM/hx88i0cEPGRelqGwgtrpHoBDSxTyMuuVnw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724252211; c=relaxed/simple;
	bh=DFrpZZ2NPQLLVDIJ8ns+Q2FkuW2fBXVGphkUeZbgVzc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CetAlk/faUWLEhTeEQpkEaQOOMNfwEVodHkP9g99a9iTXICRr0SHeGOUEJoZkZnvynR86D/q6V6N329k1YjU4mLoYLdbLYZWDJsZ4avGr/RzxDJfsslb9+gw+8cuACQiFcJGhrDfiugNXw/92970+my/XC2/i1duEWjax8dVc1k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=tYduwhyk; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="tYduwhyk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B8168C32786;
	Wed, 21 Aug 2024 14:56:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1724252211;
	bh=DFrpZZ2NPQLLVDIJ8ns+Q2FkuW2fBXVGphkUeZbgVzc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=tYduwhykrJamOsbq4FF7Tm9jXm/YK5ejCSYB/A5AkR5IeuIzjTVAApUByHCfWVLDO
	 e3ctC5fTTDQHBSZanwuLKCLTJilS87nYoXMCyH8f/M7+BLwAGeZQ6WtRVx9T9s6YRg
	 r0K9/XpzllY1PqHOpz1NyGsa4lALX17KrfoiZv/SktZt2t8Sk9xJqqB/6oB2jPL08c
	 dI6GF9SvsXw5tVBQm1QTyi4KCVQmkMyfE1vAbf1r3805mCxXGdsoKY7y7IyEM7O2L8
	 mTzmYtDR6EgvUazg962Y+1Yj6RU1WmF92Crl6RG+i5e29knwj7ijassfUzBf15Z5Xr
	 gTTi8k9NCPCNQ==
From: cel@kernel.org
To: <stable@vger.kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	pvorel@suse.cz,
	sherry.yang@oracle.com,
	calum.mackay@oracle.com,
	kernel-team@fb.com,
	Josef Bacik <josef@toxicpanda.com>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 5.15.y 13/18] sunrpc: use the struct net as the svc proc private
Date: Wed, 21 Aug 2024 10:55:43 -0400
Message-ID: <20240821145548.25700-14-cel@kernel.org>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20240821145548.25700-1-cel@kernel.org>
References: <20240821145548.25700-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Josef Bacik <josef@toxicpanda.com>

[ Upstream commit 418b9687dece5bd763c09b5c27a801a7e3387be9 ]

nfsd is the only thing using this helper, and it doesn't use the private
currently.  When we switch to per-network namespace stats we will need
the struct net * in order to get to the nfsd_net.  Use the net as the
proc private so we can utilize this when we make the switch over.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/stats.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index c964b48eaaba..a004c3ef35c0 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -309,7 +309,7 @@ EXPORT_SYMBOL_GPL(rpc_proc_unregister);
 struct proc_dir_entry *
 svc_proc_register(struct net *net, struct svc_stat *statp, const struct proc_ops *proc_ops)
 {
-	return do_register(net, statp->program->pg_name, statp, proc_ops);
+	return do_register(net, statp->program->pg_name, net, proc_ops);
 }
 EXPORT_SYMBOL_GPL(svc_proc_register);
 
-- 
2.45.2

