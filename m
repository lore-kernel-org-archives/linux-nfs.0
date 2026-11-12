Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794516201;
	b=5M0uuKh72Cl3j7nsys64R73pF+BXwx6z6aEefepRWyGXpB6S0y94n7rUFi3kDR1NYQ2o
	 0orspJde+lnz+J6WWewlwGDcpMRflQlZ3jt2Ow1upExr+YgUwNkQgGNpXa56QYAx5O1wL
	 elqbBlU9ZEQbLTa/3kw+DtGR3oVzOSJmCq/4sClhqu9RPpPj5HBFNYa1hsh3UNlLAgyY4
	 1jzlpAHzufyuxgGkXqaca++EXEsQ47Nps4+5206WaHwSm77nQ8YyYSREz+X1s1pdp+eI2
	 ik1CHBLVlQ4dauLQ5+BsMG8hzUCSm2PJ1iTB5TfXbDcAx7TJ2haqPQMmXE5cD6c33bw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794516201;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=DC/qP9LjAFeKtw7OZ6NgwF5JMeyJn9r895+QBQXZW2Y=;
	b=OYebpf5NtZMNBLallfWJhc1NznNM6ZZg5x/3htbh1jaRp+kg1QiESvlJcVaMDutmGGTB
	 4xKgz9qHd5JsrksgteDWUi/l73M9qJgzxWUWkwLU00BjASBstaGDXcccpnfanH3ZRedx9
	 FY2sz/GhX04Yovg7S06+zVu0lbiLZqGUjUOrEX7VCJoZ9j2t2WRg/aaO7sr01CFWZmkGP
	 V0snbCDlBGJiWx8Du6ae0JJ2/l/qZW/yMbf5xh5p+aJopD07VBvv++Xut3eoqtQmM02d/
	 SDY6u3/8ZUKYz9CIVljD/92mAGzN7CqQ0RQ/DgalLYjXJb73qQlK+AENcBU2adW4wNw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HkjdEttO;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8513606A321
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 20:43:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HkjdEttO
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 93DC41F000C4;
	Thu, 12 Nov 2026 20:43:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794516201;
	bh=DC/qP9LjAFeKtw7OZ6NgwF5JMeyJn9r895+QBQXZW2Y=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=HkjdEttOHElKzS8XW3wQD5C3gAwawpqFL2hPKJZ9ruNEJYEPjU2MCfvlfn0ZkA4wJ
	 +4EIASL+Gh82WwnnV3HwkwiYA7DbHwTP8J0lWqP3N/yyBUAgYfcC1MZhfPI5I1Kck9
	 ydiQ/pPV+9aaU63O41ATq4xsqX/l1cJG6iNN0H5gdoeJnyY7RXpQvrTf2bUekDxeFG
	 QJE0DJzX5IrLJYH1TO9VPugVasrby8XJNaYqLfQ67J3Vd0DQeODUb/mLtw8KQBXPK1
	 LQHxsuec8+V3++0x677D9Qqt2t9Y6z4z3Z4e544iDkC6wof9L/OSAofp4ZvOQrykdV
	 uUpTBk+qh0u6g==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 15:43:07 -0500
Subject: [PATCH v3 7/7] NFSD: Verify the target directory last in
 nfsd_link()
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
Message-Id: <20261112-verofess-2-v3-7-487532e4d7ca@kernel.org>
References: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
In-Reply-To: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, sashiko-bot <sashiko-bot@kernel.org>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2153; i=cel@kernel.org;
 h=from:subject:message-id; bh=tQmV/yDHMVeHQfYD5uMAYogJsbItIBaRRwuTPz8w8n0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9iTe+LDzzuNuj9tdy9dWvSNMzEw5kvfLFGPp0
 OTxDRSdZGmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavYk3gAKCRAzarMzb2Z/
 lyH7D/9+09zUmcfASaGtodlgGUhn8zcN+eK3mnEAqtH7N0PPbm/HmNDsDqmcVlsK7Ga6R63Hi8D
 xj43hboynUKjCmMc/A9jub6i/HNYXVC5frmiq77jQNYI5/Ydn8P6+m7qmdc77UHAwJ7hcPqltSI
 LHuXKhejWIdR4MT5mORLqG63Y6sqilV4QHjjhVKid2TrolwagyE7cdVUHiNoVnMScCFMmkRgqPF
 4tZixcCxm2IBT3j02kMlEAWx5ChUbhnBv+UMp7me2pgaaQsscY/lKZAo3x/f5QfL8D/IKLXKAm9
 +lT4TvoBN9UEQSq34Vg+Yfe2g7WiKyz+OOlXBDPakgIQwiyDQvaZy1M6ISM9ykBImdgn4bVALqG
 sIJa7yJ+oVNy1GBknFcTHmfMWtjFgQ1/Gdjs27crkizVEJCz1x09vaeEgLmaHt4fosjl0MNAi/k
 A/fC9mgDmni4V2KoR/n25SXF/A+eptwTHeEkQHyJbWLrBH+Ux+DuHpKgT5K14yXXojG759EK4p3
 XO6fBycipcpHIWwLg1iZMTBzPU5eZmhv9RYb6nIuNrM2+pmocjmEGG/Hay7BmvYyfHbn67t6fdP
 Br97N1k5H2JCkH+vcCY/RsCW3XOJZbpQqSEXJwgLKEZeVXR2vRJU2P86r4pAvSCL2F+sxx5UVtr
 u7uEpXozVGb21Kw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_link() verifies the target directory first and the source file
last, and fh_verify() installs the credentials of the export it
verifies. When the two filehandles are in different exports of one
file system, vfs_link() checks and modifies the target directory with
the source export's squash mapping, and a LINK that the target export
permits can fail with EACCES. After an NFSv4 LINK, the source export's
credentials also stay installed while the current filehandle stays in
the target export. Operations that follow in the same compound without
calling fh_verify(), such as READ with an OPEN stateid, then run on
the target export with the source export's squash mapping. RENAME
verifies its target directory last, so it is not affected.

Verify the source file first and the target directory last. After the
change, the target export's credentials are in effect for vfs_link()
and for the rest of an NFSv4 compound. When neither filehandle passes
fh_verify(), nfsd_link() now returns the source file's error.

Reported-by: sashiko-bot <sashiko-bot@kernel.org>
Closes: https://sashiko.dev/#/patchset/20261103-verofess-2-v1-0-9e6568221beb@kernel.org?part=4
Closes: https://sashiko.dev/#/patchset/20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org?part=7
Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/vfs.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c227a3d3a805..77ca88618b13 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -2297,10 +2297,14 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 
 	trace_nfsd_vfs_link(rqstp, ffhp, tfhp, name, len);
 
-	err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_CREATE);
+	/*
+	 * Verify @ffhp last so that the credentials of its export are in
+	 * effect for vfs_link() and after return.
+	 */
+	err = fh_verify(rqstp, tfhp, 0, NFSD_MAY_NOP);
 	if (err)
 		goto out;
-	err = fh_verify(rqstp, tfhp, 0, NFSD_MAY_NOP);
+	err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_CREATE);
 	if (err)
 		goto out;
 	err = nfserr_isdir;

-- 
2.56.0

