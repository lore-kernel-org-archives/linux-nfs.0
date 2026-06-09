Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1B854D8DAE;
	Tue,  9 Jun 2026 17:47:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781027267; cv=none; b=MrAkcosHc5vSNGfApRGbyF58Q/MHBnXVLP4+nHoOuhq8RwH9MNU2hhJXJw+ixOeocaITQI0uETYgO+Yu0HD6Cw6umAb+2Yisnvlch4uP2cImye9GKVGtdYHmsV5s/bfrmrYy8U4jUszgy33nQSLpxNEyB5zZtVCvy3dn6a5Cn3g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781027267; c=relaxed/simple;
	bh=4+8eovD7Yp5c79xV/YngVLXcs1F1tWnrdqFY3m7RtXw=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ZM1fSHDuzIupb521K9pqsyJa1p+aBwQRo+OTnv/sRu41VnAV9VwYsTM5y4Ynd6ygIFojPLM4wb6qohyzXPbK8taj1LkNQA7MkZdWaiJntEhPA+RdDCxWOGstPQEb5TTwseKvK4g79O/BMrj95399n9LgD47Oc0oylWPb/vhMNK0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fGWooAa8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fGWooAa8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6C9B21F0089B;
	Tue,  9 Jun 2026 17:47:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781027266;
	bh=jGpOL1fRJDAgSHqvuwsusdCfPJYd9WiQJNs/7d7KNTI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=fGWooAa8DQif0er/NguGO+GwTyO3bip/DItfVtXt+dMiegIGXWMc1VXqE9iLu9Toc
	 sygozAxWiu3BKaHy2G4SBw+QLYYRjxJsXec6hgo5LFW3qYtafpqLe7LeFoXBBwl/td
	 Qerp+I2NMW8jwCRQ/qGlD3GO1BgJgJEIfp++SFJY9VQeuRthlOQ3xXTDMmDBTMXgnj
	 NiJsICGXC2+0jZifEICdio9+hGPS6/ugDQGS0NjqWtSDobpvHltN8Z/SLhyZdcK5Mt
	 0jXLN4mDsjxOHIpl7K2aAZ6ooRG+aLsGr2SGZwbQvsO5Xy694ObqaqM7hhb/Xk062p
	 1Wvon7jxOwd3A==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 09 Jun 2026 13:47:22 -0400
Subject: [PATCH 01/19] nfs/localio: fix nfsd_file ref leak on
 nfs_local_doio() init failure
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260609-nfsd-testing-v1-1-e83acead2ae8@kernel.org>
References: <20260609-nfsd-testing-v1-0-e83acead2ae8@kernel.org>
In-Reply-To: <20260609-nfsd-testing-v1-0-e83acead2ae8@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Christian Brauner <brauner@kernel.org>, 
 Benjamin Coddington <bcodding@redhat.com>, 
 Donald Hunter <donald.hunter@gmail.com>, 
 Lorenzo Bianconi <lorenzo@kernel.org>, Qi Zheng <qi.zheng@linux.dev>, 
 Andrew Morton <akpm@linux-foundation.org>, 
 Muchun Song <muchun.song@linux.dev>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 netdev@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2127; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=4+8eovD7Yp5c79xV/YngVLXcs1F1tWnrdqFY3m7RtXw=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKFG5SJo+h1KnkcReqhgLOB/oCODXnc74iyWRi
 Gl3LWdbukSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaihRuQAKCRAADmhBGVaC
 FUyGEACb3J8w9yzZyIOwJKaYor2IU8FkNScf8F1Fia9n5kCDOLR9Lx8G9OtTbRJ7qQvds+Ksmu6
 4lGXhOx+AdvGc4bpg+H0DFYnYZzza14QqMipKvPNO03Cz0pa8U9iRroPhOsEU0RmrbTCF+K2DsZ
 RlDK+fLJs8ZrxQOeLE+gibpbP258yFbwA7Ak1eotWcReJpc9imWheZLRJf1CD6gNwlF9lhQ17KJ
 KZ2gObPsYCN/RUCrMDzihx7F9qyVb2vP/x9rIQLVvem6RNBBuDcoWlUnZHK/HaYOp/eU8UF5iQN
 2zwZ4nNMiEQbTHlRJeSuVopL1LRiUCC58YpAD7G8DjE3Fs5r8tVTWRyJqKNagmd6wKnOicWxatr
 GcG06urB/IVo31Dke5n0boiO5hCbqQIS6c/6KYjg7MO9jCZ69jJ2du7E9rg0zpjEsK8x2eA33vF
 TKKShfdoNYwaUjKTSrmrsexVujQDg2vaLqOqwv0XkOlApV8NN5BT3+swYI2j+SpGgfSN0CXEVT6
 wCPOm/HYdEjAoN/U80fnnSjeaxwoyuJgou5vh3FIfR3yuqxcPozzTs2wikboxSgVIejH3v429o9
 lyJb0dEWIm0F7lUyQYEMDiMTViquVKatBP22Udn5o4f/ap8fzL6Fzzt1oBFbmytZdqhTj+zaZCm
 2LrKB3c5tjHA8QQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Two early return paths in nfs_local_doio() fail to release the localio
(nfsd_file) reference passed in by the caller:

- When hdr->args.count is zero, the function returns 0 without calling
  nfs_local_file_put().

- When nfs_local_iocb_init() fails (e.g. -ENOMEM from allocation or
  -EOPNOTSUPP if the file lacks read_iter/write_iter), the function
  returns the error without releasing localio or completing the hdr
  lifecycle.

A leaked nfsd_file pins the associated net namespace reference,
blocking network namespace teardown, and holds a reference on the
exported filesystem, preventing unmount.

Fix the zero-count path by adding the missing nfs_local_file_put()
call. Fix the iocb init failure path by jumping to a new cleanup label
that releases localio, sets hdr->task.tk_status, and calls
nfs_local_hdr_release() -- matching the existing error handling pattern
for the post-iocb error path.

Fixes: e77c464c31b3 ("nfs/nfsd: add "local io" support")
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/localio.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
index e55c5977fcc3..63cf6e2cc745 100644
--- a/fs/nfs/localio.c
+++ b/fs/nfs/localio.c
@@ -970,12 +970,16 @@ int nfs_local_doio(struct nfs_client *clp, struct nfsd_file *localio,
 	struct nfs_local_kiocb *iocb;
 	int status = 0;
 
-	if (!hdr->args.count)
+	if (!hdr->args.count) {
+		nfs_local_file_put(localio);
 		return 0;
+	}
 
 	iocb = nfs_local_iocb_init(hdr, localio);
-	if (IS_ERR(iocb))
-		return PTR_ERR(iocb);
+	if (IS_ERR(iocb)) {
+		status = PTR_ERR(iocb);
+		goto out_put_localio;
+	}
 
 	switch (hdr->rw_mode) {
 	case FMODE_READ:
@@ -996,6 +1000,12 @@ int nfs_local_doio(struct nfs_client *clp, struct nfsd_file *localio,
 		nfs_local_hdr_release(hdr, call_ops);
 	}
 	return status;
+
+out_put_localio:
+	nfs_local_file_put(localio);
+	hdr->task.tk_status = status;
+	nfs_local_hdr_release(hdr, call_ops);
+	return status;
 }
 
 static void

-- 
2.54.0

