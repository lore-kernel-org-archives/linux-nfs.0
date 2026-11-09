Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794257093;
	b=RUBpjuTsi/k9WVppdZDnhWwCevSOM52v+JMbRxX31ouRc8ELu3ojcP3X2zrkDmk+fs1F
	 ct0Yxeb8ELWLNOOAUZC68X8ZKJkfQe8hOFdQkXB7GqFsNeDEk3Aydgp/XtPQnrnwZbSzK
	 qvHhjWxSHAIVFTKAyIpdmb0SHUiSKKubDFBE2y8DR5T3JJnLRug9Rtg77b3+jboSLGuAf
	 pGFWCqBI4KP7q0CteFe9O84iX9/lPhaIbcsiuM5ocp87omuHD0eD9hF5YjThlxjM83GXh
	 /KpvbQjgFzNOGi1a+Mpg5fipUBMmAyUTY8xtB0x7mI8x6gfSdiw5+0Wr7I2P/AcfmNw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794257093;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=FL5B+ZobyMcavVUt7atRUnc2Wr0kOuMry15Yk9u4RYs=;
	b=y4Y+yeYX57BNzJBu5AO984mx4OMHGuiojeeTWRyctMwZBd2TqpLokO8Rv7mPfsXaeTKX
	 j49GuFs6j2VXCvQmm/GlJAxAh9CLSJU1psobTLTWbYWBjXAlTDOScKzm/CkQXHROGkaDk
	 6TTfPMIy5/guE/5C9rdXJQEOfD2N75YthRj3Ko5MSR2zZAnwch/AKUWuw4YA7+TuqVeDH
	 mL/ZcoGzYavB1ev2wfqVt2hmqvNW1gnk1lsiGTzXjez9Rh6RieBR4FeKXxALJ7JPUyVkK
	 nynx1yFKXo1trkDNMDw20B0MTBSQHrUYz47b79RB1UGdUFWIH5hiA/mJCM+sfgsl6nA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HCUh66uJ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4DB57606A325;
	Mon,  9 Nov 2026 20:44:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HCUh66uJ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3A5FB1F0089F;
	Mon,  9 Nov 2026 20:44:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794257092;
	bh=FL5B+ZobyMcavVUt7atRUnc2Wr0kOuMry15Yk9u4RYs=;
	h=From:Subject:Date:To:Cc;
	b=HCUh66uJD+7y76ZPRX7KJdrupTMF1HYS1etOg2QhxsOp7qYXdnFTsvP2L+zyjY6LW
	 bCSCoQfdNJT9Cy/rwRKxXcWgRfQ4t/P68xfjRnbcv3WJEqFCh9gocryYZOtnbYZE3i
	 dvFRp4VPKAJj6nEDpMRY4i/eRic94f7fvwdu302PvRH14gKsRxA+yiYYsCbBfb09Iu
	 bXS8JuxrV7O+MkEC5lLbjTvVfpODQHLaTZwNV2r4cUxRK1d6H3cO/hV1f89udSK1dx
	 hvxy2GQJ7z0YriI12Juqmg+njEo9MKNaoWLjykGRd9Cz0zZloRGZ0SJ/+eziSOOmWK
	 6Qi5Ecy5TOoyw==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 0/3] NFS: fixes for delegated timestamps
Date: Mon, 09 Nov 2026 15:44:46 -0500
Message-Id: <20261109-delegts-nfs-v2-0-9d1e926cc3d5@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/23MQQrDIBCF4auEWXeKGjXQVe8RsrBxNNJgigZpC
 d69Nusu/wfvOyBTCpTh1h2QqIQctthCXDqYFxM9YbCtQTChOWcaLa3k94zRZRTKGkdyeMheQnu
 8ErnwPrVxar2EvG/pc+KF/9b/TuHIkFs1K+q1NGy4PylFWq9b8jDVWr8J4+3tpwAAAA==
X-Change-ID: 20261106-delegts-nfs-25dafe47b434
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Lance Shelton <lance.shelton@hammerspace.com>, 
 Olga Kornievskaia <okorniev@redhat.com>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1485; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=zhrPj/mSUknYvQp+Q3SXYYKqnBrNegs6RQkz2xBo3+Q=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq8jDDw3hCHj2FIJC6UNmA901DIJ0N3TB0RrZhU
 zOM6T78wQSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCavIwwwAKCRAADmhBGVaC
 FeeoD/41Qcr8SmDCGkqzQ1fUG1xealXyK/Fp0tnipGNZkqLgApJbSho4lVxixo6A78/AeGweSm2
 Zh2Xft18ZIKIRCAJpCOzWpOrN6e3j+sAjRXFLCW8KJu3LhOLnXMslgxRBoflmPCVSKEZFiFYoI7
 Z7hA64JWuud/5YaKfmyNpbaUGDIlWRaOWdnan7ogS23m+7tfkcNxXr4wK40ZHJcuZ3xa3ExpwbJ
 cizeZmeSRquttjCpz9XRSAH4hjqDdn9e1cr3I1rSB6jLFY+bryXRynSG85zO4ftCc63/oDPUCeX
 HamcudcWlr9HDX6HX1y+QbZtC8eBrtfkUhQhzqiAXyh8tehX3VTf/ZsydRts7Vy2RzeFjrnE4DN
 ujlmScyDtNu8rF0/3nqOCskAUJrjdzbbZgc8kb+cuXmwcHCCjMSGddOwoiY07G6SmbmcMjDVWs0
 aPAAtvFwqN0sQqM8eMkY9Z9LUzJ6peYzaruY0Fbjz/o0EQFMtQgvMLWHqDs+/Ix1rzm0oju2eE/
 syySgnUWdeR2W9WdHMnxdn61qnbu46NiP0kO89NzCLypn5ZjsjxisY1E2Y56aS5fJzbCp0c7XY8
 dYI2dbJozV9XJE12I/bG5Y2o0rx0myiy95MtpDfeVpdssGccsLJQd3ccB2Bi+ttbu0LdfXP7VKp
 DwBm7oQt6ST8fRA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This version fixes some issues that Sashiko pointed out.

These are some client-side fixes for problems that I was seeing with
delegated timestamps. Mostly this was evident in the git regression
testsuite (which is particularly sensitive to timestamp issues).

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v2:
- "don't let delegated c/mtime stamps go backward": compute the stamp
  before storing it, so lockless readers never see the coarse time
- "stamp after the server's ctime when truncating under delegated times":
  stamp before nfs_vmtruncate() drops i_lock
- "stamp after the server's ctime following a CLONE":
  - stamp under i_lock
  - apply the reply with nfs_refresh_inode() under delegated times, so
    its ctime doesn't overwrite the stamp
- Link to v1: https://lore.kernel.org/r/20261106-delegts-nfs-v1-0-1d5c5e364a07@kernel.org

---
Jeff Layton (3):
      NFS: don't let delegated c/mtime stamps go backward
      NFS: stamp after the server's ctime when truncating under delegated times
      NFS: stamp after the server's ctime following a CLONE

 fs/nfs/delegation.h |  2 ++
 fs/nfs/inode.c      | 65 ++++++++++++++++++++++++++++++++++++++++-------------
 fs/nfs/nfs42proc.c  | 25 ++++++++++++++++-----
 3 files changed, 72 insertions(+), 20 deletions(-)
---
base-commit: 5e810a57a1cf2fc785d89e711ff40f1112f6404c
change-id: 20261106-delegts-nfs-25dafe47b434

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

