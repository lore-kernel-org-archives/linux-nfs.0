Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE7EC391842;
	Thu, 11 Jun 2026 20:01:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781208075; cv=none; b=oI47nd/Ec2pcCD33OI7gjSxD0gruX4hOGSpwWGqwxRGVkFQKkr343IicJIVyFuYCHxfzV7GOjjsF1Rsw8Ax3zpTi8dbJWfKm7U8M3/TKxEIu2YdslB/j6HsPdI9D1IMlQJfoAjOCvGuMeTugpYOyW1lHuuFXi2ySBLpqd6VN6KA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781208075; c=relaxed/simple;
	bh=KVrLhX9lsnQb1vW4B3vqrncGKobnyg/dgPHZxa0IyTk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=H3dp35Z9a4wcKG6bUk5d0+CWfHYjA3q706Q103OupbzlP7I/fXhrWB4hiBSeEKqZD4LH2xcp8JO8pUyY4REL2c0DlZp40AfZBW9MY2c+7hX0NoKcJVG8Vb+oqQ3qqbvv75VwBemZOPy0486SN2oxnI7JJKo8vNUyH4DF6d6M4w8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=URcSr7Ov; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="URcSr7Ov"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E1EBB1F000E9;
	Thu, 11 Jun 2026 20:01:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781208074;
	bh=VGQgLYYOesAWY4AaR21R8wLs+Xwa63VsdpGz6sz3/hs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=URcSr7Ov0mEtXhKyMmUFAvjFJR5DhY7Csyx6C6HOQm7ZCrK7Hsdo+CUMe2Dh7ZxvP
	 YzkfqjxKXVPVREllKykzQHQ5cWcOgLclGsmS8lOAHnSZOLaUiA/XeGM0M02YG2Xn+H
	 he32kjq20M+S/xL9IKP5UdWEgG/2WmQqR3SDt/i/satxJMJtuvAqTr/NJNmJMwLe9x
	 gJioOxfef2IpI7bkm5U8kcYtbVx8mebAEi1T6EviX1UvEc+lgwD83gV0a8itY0jl8o
	 6lIrOLMZUMATXeWPW+XchlqwukZlZE/BZhcY5bnOpQ1515Fp0QHW3N9bpTBoDBc1ok
	 3jiac8TZ1a2kw==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 11 Jun 2026 16:00:51 -0400
Subject: [PATCH v2 08/21] nfsd: remove premature NFS4_OO_CONFIRMED in
 CLAIM_PREVIOUS path
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260611-nfsd-testing-v2-8-5b90e276f2d9@kernel.org>
References: <20260611-nfsd-testing-v2-0-5b90e276f2d9@kernel.org>
In-Reply-To: <20260611-nfsd-testing-v2-0-5b90e276f2d9@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1050; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=KVrLhX9lsnQb1vW4B3vqrncGKobnyg/dgPHZxa0IyTk=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKxP+ijHh3wMXBwdRhhmNb14rDf5Mw5AEJPITM
 Fr6R4QfsKuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaisT/gAKCRAADmhBGVaC
 FdK4D/wNLWtsFiiqsMKyaeHO6eWnjEkVTwCozJZbLEB0KwI1Vv3P1THBELBKC+Jj2t8//gEC1EL
 kAnsb4eb2rTZ7O41z99UUamujTaaXRy3lK0i7E/7qYdun2tl0QeusVzsPTA8wvzNsHYqoN1pAYp
 SZ8JbjognOoybPwwVtGSo2djYr7tdIweLkTu2SCvRZKGyHoxiEUj328wJyeMR9IhMAwq4K4XwO5
 IkiN6P4Qwi+h9avmLfUN0nG4CmgcddBDoFkEgi0+vJAoH1X4mfFkuhWgiINFqDlPbHTvQh9+OPC
 JhpO3mQkCJPht94ygtVaFzW6XAs1aqBApSCdD6ilUIBj4VvFObq1SgG7jmXPSfMsdwoBycB9TcN
 1vHOrn734wLpzaOLnVsvL+LAM9U+BHJYLmuS3opRXb2zS0gnF0OrzXfkCHZq49Ph3/i2fWlqvso
 LeDvSNH4hvA2s7/hlaPIC/C9S+EhhPc6RiI/Hf9iQMvTsxxoE9VBoucXHAck/zkWCT9S9Z9jlJz
 uV2D+KZ5QoXU8uheGXDXc1bsLNj2sxE3jt8ZJZUOxY6X1+mbAaSegKT3WMCWjZGgPnasaDzrF2C
 o36hleurxJA7T2YHd8cZn5sYiC7Srttr5ZCQTJeGlQ5Q2/7wV0xyKAb1YvsB78T9W55qEbcMY6A
 cgf328qITpsYFfw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_open() sets NFS4_OO_CONFIRMED on the openowner before calling
do_open_fhandle(), which can fail. If it fails, the openowner stays
permanently confirmed despite the OPEN failing. The correct
success-path setter already exists in init_open_stateid().

Remove the premature setter. NFSv4.1+ is unaffected as sessions
always confirm at creation time.

Fixes: a525825df152 ("[PATCH] nfsd4: handle replays of failed open reclaims")
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 69fee481581d..4fe46996c8ed 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -643,7 +643,6 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfs4_check_open_reclaim(cstate->clp);
 		if (status)
 			goto out;
-		open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
 		reclaim = true;
 		fallthrough;
 	case NFS4_OPEN_CLAIM_FH:

-- 
2.54.0

