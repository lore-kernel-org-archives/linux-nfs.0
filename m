Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793548282;
	b=eKTDuvmK8MQ+gQTS5SS4Cv1IuDB+aLMFP8FeZD+805fKkTC6FwHt0WDGtFMoL1dIOkPD
	 J4X1LHj0nJEx7jz5c/lSzpiKeZdPwoYLfS0ZOLzPCD5Gq14WBZWP05rLgFDN7NyH4X7lD
	 s1YypsDoB2TXVALrvpptWHexvKT5iLON6Un7Mp16Jmg4XoFfIdb8syl/1ABdXBnDmj7RE
	 p8PwBQpf7GvmSxEfFKt1eq4kxr9LCcK8qxFfq1V/zFcZ8jkqZQPBNC2JBF1/77bmZuYkt
	 OBJzMM688JMyCt7yNXEz225W8Raty+Mw43e1ChgimgQ7z9pdKsrnoU/t2+KOu/PGJAw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793548282;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=WegNEmpKRRWSzxLhvfvUhla5z4ld8cstexY8Ei6KrLI=;
	b=lzN0hfMdBc2i9A8GChpwtnP4hC+RKYtekReXYY8KBFJ7u4G79grU9BYIKr9NMkywx5Ht
	 9yn9JHRJ2XBbCNb/CuxQFP4HABXi+bvGKVhMtP6CzxjpExL7Th8RLbXKsRGjygbiREbEZ
	 8y4/NhGSQJ9qeJ/7ngjeC+YKbpQ9yFF3A5kEJyP03mlQJ5r0RvxFeXkwKlEElzIAovrWC
	 f/4rA9t5ub+0HF4YkUOtdWwEaOO789mJEsIpf8rRNivu8ycZmuh1M3omtGXQ2f3KqoHU6
	 UyGOvvfCy61HyuoOgjZZ1j7osbyPwyILYKVje9Vz9wuPPKLUqblqJAtF1XxlMGwQ2qw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YWh2JKV+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 70FD4606A331
	for <linux-nfs@vger.kernel.org>; Sun,  1 Nov 2026 15:51:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YWh2JKV+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 705D01F00A17;
	Sun,  1 Nov 2026 15:51:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793548282;
	bh=WegNEmpKRRWSzxLhvfvUhla5z4ld8cstexY8Ei6KrLI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=YWh2JKV+tIDSCuGyu+bKjRaQSf6k5rnDZsJfujBT0pDOqx3I838yQRwezbVuF0C3y
	 k2ZG29sLSBG1UEXMyLVWULfQcWIc3OPi0X8PRL5Qfxutt+bafXinukPwL2dIBvhzsZ
	 C6gcaCCbXBFC/aDBh17JIR9LTkKulXkAn2cQfPP1P/z6zknUQoXd0fziAXUFViX1rS
	 BqAWe0SOF6maCVGpP49pI23FumyWcViNNMcD44H6CEHzkEmopEuLpVk6Y4PLxuphN7
	 Gz8U270kuLKUNtLdGVK8JeFStIsQP6Gkf3oCqMDDAhwvmhGZhlYFrih6ss5Lc10j3b
	 L+fv+vqfhar6w==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 01 Nov 2026 10:51:11 -0500
Subject: [PATCH v6 2/3] NFSD: Check export security on the COPY and CLONE
 source
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
Message-Id: <20261101-verofess-v6-2-4d70097db7d3@kernel.org>
References: <20261101-verofess-v6-0-4d70097db7d3@kernel.org>
In-Reply-To: <20261101-verofess-v6-0-4d70097db7d3@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1665; i=cel@kernel.org;
 h=from:subject:message-id; bh=/MA2K/qSMxYhyaDV8bIgIo1is7pBkgoZl6gCVy67SGY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq51/2+xVPfPCDQph+qv+WDCxTBgLOJ4R5pj/aO
 XH5OF4pc3GJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaudf9gAKCRAzarMzb2Z/
 l+LVD/9Z/lpTesB1htPO5mqeC/daJuheTNWh1mA3SNO0dtSOZZhFRWJOBhK8asdpe299ZjXEKdq
 3pb9sSIYw6NkRyplSxgx/AQ2ITycl+uQFWw/22kQhtg7g04O6lgQ6PFLnO7w5ApLdPOCVgJzVlV
 GxsFpsuZgQCTN6nFh5YhFFSpv97rlpTffbCYqHhRJuRjGEdJMvQdivrgO8Iqkbz39M7oofeZebw
 uRRFHxB4Unhalk0WvUPRDB7kdu/liWljMIYTRYw96EpU31gebm7RhY5O53rJM2F3Y8mF6ct5w84
 lvZpC4yK/3iMG4ewWHEKY/wxVP8734Rf6dJk5kSZMZykZcxdtBMb2jhpG/cXTOWBz48QOikQ24b
 ruE54rLWl8yruGZP5nIiXaPWXRO8V+tzsj7/PYyPYrA6yrJ8s+8BGPAeC83DHQQBjDDuNjlXMq8
 alAH0GMQj5gElFfF07fOPuWK8eyeg0MqTmcX3Mw7BYkxtgWNNeUIGtZ7wQ4BgZrYGZ3vMajZqeB
 SL+7hXwDhVa9ZH7y/MAmDMUXjXhJBQXe0rnSteIhjwDxzoR7znFWGJ3LqxgQRWQP84xCTumJnFK
 yJBEgdiBxchhvclfcU2t2FM0TzTg4j9lrdpeTALsVRzFQCGMjqGhPwEcnjII97cBe88nryV+kgv
 LTfLGdjZyjTZI+w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: VeroFess <coderzeng@gmail.com>

RFC 8881 Section 2.6.3.1.1 forbids PUTFH from returning
NFS4ERR_WRONGSEC when another PUTFH follows, so in PUTFH; SAVEFH;
PUTFH; COPY the source handle reaches nfsd4_verify_copy() with its
export's security flavor unchecked. The source stateid then finds a
cached nfsd_file and the copy proceeds.

On a kernel with only the need_wrongsec_check() fix, an AUTH_SYS
READ of a sec=krb5p source returned NFS4ERR_WRONGSEC, but PUTFH;
SAVEFH; PUTFH; COPY of the same file completed and wrote the source
bytes to the destination.

Check the saved export with check_nfsd_access() before using the
source stateid. Map NFS4ERR_WRONGSEC to NFS4ERR_ACCESS, since
neither COPY nor CLONE permits NFS4ERR_WRONGSEC.

Fixes: 29ae7f9dc21a ("NFSD: Implement the COPY call")
Signed-off-by: VeroFess <coderzeng@gmail.com>
Tested-by: VeroFess <coderzeng@gmail.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 50f38d6e147b..b6dcb889b5eb 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1491,6 +1491,11 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (!cstate->save_fh.fh_dentry)
 		return nfserr_nofilehandle;
 
+	/* A cached open stateid does not authorize the saved source export. */
+	status = check_nfsd_access(cstate->save_fh.fh_export, rqstp);
+	if (status)
+		return status == nfserr_wrongsec ? nfserr_acces : status;
+
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
 					    src_stateid, RD_STATE, src, NULL);
 	if (status)

-- 
2.56.0

