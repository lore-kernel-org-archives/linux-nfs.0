Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795029412;
	b=lqwP7M+7Xu+6YrASPwNWY6a+CI2/cU4CgI+poGtkL5rJ9H3d/eQcny/DMIaN0RkCG9at
	 geAuOrSRp9z8ltQDoIOycNpXlq2vw4C2nsB/I2YRddh89+qgFoWjqOsOCLfbObxcC90gy
	 UPYZOxIizBazTvfsT0SKjBqyreaaufcKbWQ8hIpnUbOeBkhrWYJhLFFz9JmPGY2eCudSP
	 M+UF/a6TspBh8YjooB50d3TSA8Weyof2YeHLxFllA+suLndwRPzlyycYpiAKhSXqOPiYr
	 dhp3EsQysx/X2zhat65THluZ5NxW9RJ2I9hc1nTEO8BzuKmrn+gldkyBFORIaPmlWyw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795029412;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=pkPBMe95/PXi46FAIguOseukLd/DFOb4folnaagAQTg=;
	b=1J/old38TfCdYUzNwYRLtBVJCQ5us9uTtV4UMosH59JjYj/9fbN4KWo/2x6//kBmI0wj
	 Yuk0bYrnqdmQd2IvP2aTu9/gWyIe1OE23xRgvtYSMGoSWIzViPsZpmZMP0iDgA876UbU1
	 KOXXP3eVRaS7h1g83JJoNprTuAxT4efNkOt/1VaKxjpbABJh7ap+4RyfyWCGz75I+etPV
	 8lxuvqhb3sBKC4WWcU4Y1CIqTbUnFiFXkrsVbQ1vulwrG4tpi0V4TfMIVCPnWI0SqZr/Q
	 lhjTnoccxwwGGdTN5W5WEQcumJY7HgsuaUASdXb0S3GFjQaevRshwQngaX1tPJ+TdRQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NM8NK1pt;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE27C60A260F
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 19:16:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NM8NK1pt
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7FCAC1F000CD;
	Wed, 18 Nov 2026 19:16:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795029412;
	bh=pkPBMe95/PXi46FAIguOseukLd/DFOb4folnaagAQTg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NM8NK1ptqM50z76qk9qGrLPNknN/oG5Lck6SV5duqieqt6WDsBjK76g0L315S1w4f
	 rLJkhntr61XN3PEKS0pyiUwHNnGKFDWG1xdwglGRTy9nTNim0sFAhsBZ0wjd4ApUsi
	 O3JKxHFC4gTbgEFSJnOnl3zWgkRPp50ckkMM/DA6fdG0XZ2WR+3jhbJ0nTAKzfU9gk
	 RwWml/ixN0M02cIHTaMV97lXV6om+IHyd+RJrWDpjdWLytahPLNi9Y2l+aZDmTUw02
	 pNxvQgN/x/9jA44+MdaXgWNzIKbOQbmKmNi7FzVbOGIgvSSBlNE5jJHAmwth5N6EIz
	 vfEXPclX08b9w==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 18 Nov 2026 11:16:44 -0800
Subject: [PATCH pynfs 5/6] server41tests: check CB_GETATTR times that
 predate the server's WRITE
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
Message-Id: <20261118-delegts-v1-5-9bd252eea637@kernel.org>
References: <20261118-delegts-v1-0-9bd252eea637@kernel.org>
In-Reply-To: <20261118-delegts-v1-0-9bd252eea637@kernel.org>
To: Calum Mackay <calum.mackay@cdmnet.org>, 
 Jeff Layton <jlayton@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1212; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=/DZ+YY7EJWZnf+gObhYaK9sYbTT26PzAAFiOmmkxSuw=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq/fmiAiYTme1ffTe0kS5z+eUlrAB2RiOTVaV51
 V4z15HCIIGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCav35ogAKCRAADmhBGVaC
 FUQXD/97oGCUkScqdXfEO0lBwDKzKsAnMBFmzp0xcBpB7Sl8zE7Ul78xGpSIg5z2uOVjv+xpum0
 RkfdRGTIIkNekVNh/SkS8S/pkBIwRVR0Fqkz1XTmeYIka4r6VM70yuUPhmMWnMDlHSECOS4m5/v
 IeUxHza5qpZSlWPIGZDCnXlYzFoRpR/TlaOnlgJTAnxIn9n0X8fa/bKhooJwtDdZ4UQWtuMe+Zq
 sFORxZfFCQvmsVcqswjIsi6zLS8CEmseOzvzEexJVStQmWM53l92hiBLBW0ZxqphEWOFA2laej+
 ivPkIiENSbROsnXn0hZ6Mc1KTF+TJv6xNLgZ1leiOyC7R3xseDXfF3Cj1gRhifJSFzBYSuqv45U
 c64/9xjSq2DwIlFprtGFKaSLquRQ7rvoOTZz01xP21dsARVC9q2L7aKdOO2NmL6xOwFaCJOuDHe
 juzrYm6xOp/zOH2sriZ4Dc7iDPo9xLxpZLYE8k7AKBTrSenHdwurVuvgaYxgyCkjkj60OZPrF7v
 uVjMKlEOhXSgxZtH9atK9wVCcukA0S9a5EdKHFCaeaGOWx9MQW0QfYnbBHF5EUh0r0zRN6u3k8x
 /iRxZZf54wT/q9/PFuUKmdFglbMIWV+xmiTrCRWyKiLtOdyA0RWHZ+66nkhv5tsZb2dg+Mcrt/H
 IIitSwPdSSAw6Wg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Combine DELEG29 and DELEG30: the mtime the holder reports in
CB_GETATTR and later SETATTRs is older than the server's WRITE stamp.
A server that sets ctime to "now" when it applies an mtime older than
ctime moves the ctime the second client already saw.

Add DELEG31.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/server41tests/st_delegation.py | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index 8ab60929a1eb..bf165a17cd29 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -815,3 +815,15 @@ def testDelegTimesCbGetattr(t, env):
     CODE: DELEG30
     """
     _testDelegTimesStable(t, env, observe=True)
+
+def testDelegTimesCbGetattrEarlyStamp(t, env):
+    """Attributes seen through CB_GETATTR survive the holder's return
+
+    As DELEG30, but the time_modify the holder reports predates the
+    server's WRITE stamp, as when a client stamps on write(2) and flushes
+    later.
+
+    FLAGS: deleg all
+    CODE: DELEG31
+    """
+    _testDelegTimesStable(t, env, early_stamp=True, observe=True)

-- 
2.56.1

