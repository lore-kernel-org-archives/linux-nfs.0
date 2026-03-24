Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 92A283750A2;
	Tue, 24 Mar 2026 17:32:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774373537; cv=none; b=anWSCAUQqZRKbY+aW1rlAsJhS+wRlBrbZ9wqy3txEgMAWEHkgWAKz3hzo+B+LiGOMYdU85Vs3Aw24E5id3b6chh4DQxsksmC8WFfGyYqb93YAct0cSIwxoIapmmdD0WePWrHO4X/7XX8nG0DuWCxSvVcmwImwbQgkHqPOJ5QxCM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774373537; c=relaxed/simple;
	bh=fufUQlEvyvQqQs6zE/Je2VGFJWTmcMJGn4+UxsNiNPg=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=WdPJVqP1AUnJguvi4uofPjkxIebpWj13BApKN+YOqg3nbvXnF5weKGQrXvWGMEhFfm3qvC12gE16y2uGd5E8JDEBx2LIyhRsrAGJv9caNvOr6amCTNGouhbil8aYufXaj1VkuCoaVY8k1Z5O2B6WVnmPSyEAkF3/NYFdNueB5jA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ngBRIGFk; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ngBRIGFk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E03B2C19424;
	Tue, 24 Mar 2026 17:32:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1774373537;
	bh=fufUQlEvyvQqQs6zE/Je2VGFJWTmcMJGn4+UxsNiNPg=;
	h=From:Subject:Date:To:Cc:From;
	b=ngBRIGFksw3RPUMCKU1HGKaQtdJN4c5EqPHnEr9eq8kk9TxEBmGyeyPhbCRJLLqaJ
	 IReKitwYAN4L11fc1UmVEFmKeYI+V4rN0zYc4ouV/lhhJkthxQ1Fs5y0iEjR3o8Pki
	 J0IVMdso8w8OJOMbGQWwcT8Pto3gjObbk5z5RliEB5KH/9xs+dxmwj1p6W3L8rHFXS
	 jiBzS9ofE0upazxvf3kohpyjmBgfCQ5rXRMJZEfYjPvimfG8VfcrjKXnLYW1Dr6ZuQ
	 PLSIk0VbcVfQ/incZzT4vINwrtg4b95ns3JXad/WObjk8HQxqJohQruuw4rBLAikfh
	 s4V/DCdy+vO7A==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 0/2] nfs: delegated attribute fixes
Date: Tue, 24 Mar 2026 13:32:10 -0400
Message-Id: <20260324-nfs-7-1-v2-0-d110da3c0036@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/2XMQQrCMBCF4auUWTsySU1rXXkP6ULTSTsoiSQSl
 JK7G7t1+T8e3wqJo3CCU7NC5CxJgq+hdw3Y5epnRplqgybdUUsGvUvYo8LB9epmJzZHa6C+n5G
 dvDfpMtZeJL1C/GxwVr/138gKCVlrItcNbA7t+c7R82Mf4gxjKeULz33rPZ8AAAA=
X-Change-ID: 20260305-nfs-7-1-9f71bcde58c5
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: Olga Kornievskaia <aglo@umich.edu>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.2
X-Developer-Signature: v=1; a=openpgp-sha256; l=776; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=fufUQlEvyvQqQs6zE/Je2VGFJWTmcMJGn4+UxsNiNPg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBpwsqgD93ClFbyPzxwIQ2Nn1N65LKO35UHKctKX
 zGGwkM6Vq2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCacLKoAAKCRAADmhBGVaC
 Fcw1D/wJZOg0R5Pin0goaCcFkYCoY/wQ725eqsjv/Ow3X8o07E7P2/RDnEt7CRBs+fpOieyus+M
 Hnb/mLCQ0yWwps72OzTJ8DK2KxVe/cRgd66JH7AD6xvskx5HF2B+yYUmistLigkHUiEUADjxt/b
 61ZOnUSYe3rr4q1pKT9sW4lGy7g8NkzC1SiPojRJkjVbpoDzLB637SW2latm2dwvESwoRHGaKTr
 DT18/MnGo0+6yvmTIi8XLZe+qftTCaopkMhrSK85R5UJuNR4Pn+naon4RjggoGBnQrJ1+y1CMUB
 lHi2kJMrEsrX0K+5PTdV1F8ouMfolXmHQfK06E7rkaMAg8fQyijI3+Wfgu71xpK1/FLIBmXGN7v
 bq5rZImn9lDeR1wDej+ptPYTq8Yv5o3ysuhHnDzXhO63xmYMCaOtq0D1imunB0ad+3uyKyoIv2T
 Hjh6lWss+hEMaHAvcJx9RXq7lnEFXDkqsQ26mfc2DHF2DNCacemUHLGoooHjQmYU75t6OHYdeOD
 R0LD2/iFRXrNaDEl520HfqWLBVdfHabuZ522Enp26beP0K2fUFdRcJoq5yoSXwPsIgWwLREIcub
 LcstaMY0LrBvq7cAWwvjYRa4ajYezd4voC/5Sk1CA6eCRKtCwgQuaG9hOsfQnc3fFiCcFAx8XyQ
 cMjhqiExPAmDZzA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This is the same set I sent a few weeks ago, with Fixes: tags added.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v2:
- Add fixes tags
- Link to v1: https://lore.kernel.org/r/20260305-nfs-7-1-v1-0-e2200f69e543@kernel.org

---
Jeff Layton (2):
      nfs: fix utimensat() for atime with delegated timestamps
      nfs: update inode ctime after removexattr operation

 fs/nfs/inode.c          |  9 +--------
 fs/nfs/nfs42proc.c      | 18 ++++++++++++++++--
 fs/nfs/nfs42xdr.c       | 10 ++++++++--
 include/linux/nfs_xdr.h |  3 +++
 4 files changed, 28 insertions(+), 12 deletions(-)
---
base-commit: c107785c7e8dbabd1c18301a1c362544b5786282
change-id: 20260305-nfs-7-1-9f71bcde58c5

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

