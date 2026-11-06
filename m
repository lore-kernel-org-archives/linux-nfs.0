Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793998089;
	b=1KbsDSeYCG+sZJCm1GlbgIFmmsmGQ+iSaJdNuCtYtNp3Z/7QABI+sOAa5jwsx2hNpNwa
	 FuUJHudY9CTD1ecv8aljlSBSSveErLew08FNzfY2ING3Y1htMB9VEBwDvyg8BxMByO4vu
	 kFSTfwGBDzlFpQtv1ahyxfLH3VTz0GCWLLIQAexYhkwWfFBOsk+CXm+xT6yhUfQIJiuge
	 cIR6JUDlWTmIWoiLl0syRVS7zC5GeW3PuX5KN4peq61JnRyIo8LtQn41fU1NQCkwOLaor
	 Xz5eaeZ/SMoIC8sprkKErSA86TdhmYTJPobCqi7Ai0R15Ac/4WWaiqD+IOKZ/yPibAw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793998089;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=fthAK85SvL0xU/hKyJUQbG81L5iQSuqOeLIi93h2BFc=;
	b=LxRPFdfbSwN0/DJCmx9g1LyDI0Xd4a24e4y8yjQaClFlIkLLgv8eTk/p68V08FMUoGfP
	 WIMuqRrubJ+DDAcGLnb/pLg0GrYIcEHfFPV1Qn2DqNbjVIho4El+unWOvoZO9vj5nREbg
	 wZt183cdw9pyHlXsZZx5q1kLN0BZVdMKP1YsAEQ6MHd56vG8iQd/e1bWvhEUjihzXKdBh
	 JUxD4aV+t6x8AjTFVfmPionT04c1TuEkBKBRPmpbGFUAN82w1ij3RBhUWMqyHVPJCQsEV
	 sKe/m0HLmfJ+7lHlX+V73BKMzb0zZdb58ZHlrVMNHDy8yI3/hoFxbVBqPRKF9m17f+w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ItxQwA8k;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A61DF606A32E;
	Fri,  6 Nov 2026 20:48:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ItxQwA8k
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B00751F0089F;
	Fri,  6 Nov 2026 20:48:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793998089;
	bh=fthAK85SvL0xU/hKyJUQbG81L5iQSuqOeLIi93h2BFc=;
	h=From:Subject:Date:To:Cc;
	b=ItxQwA8kldXdBCRHzSQXD+fayqGIB03vA1BrRRgOLizoZDpC60M1h8GYd0x+tbNPJ
	 h5DUPE917XmU92IPtci0h43BNzrYb3yEYVKpIsHTjEfJpllw90aOOLq97QL6WZsAIe
	 BVLGPRoBbwhErFNpk7My3HFzudRhX6wbZG5dDEMKRFyYovpYqwxqqC+DkT0fErndNf
	 V5Yx9DN5SLHLmE7fSuzWS4TBDlslN8kf1xZym83cWn/8o8oqp51pdonIGNcDpS/X0w
	 miFp97D2MXmyLBRVgA99jI4pE9H+5MXheVi6Lw6aVS6WRcDFtTozlUwpNPu891zIcY
	 gcdBEvmnvp2lQ==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 0/3] NFS: fixes for delegated timestamps
Date: Fri, 06 Nov 2026 15:48:03 -0500
Message-Id: <20261106-delegts-nfs-v1-0-1d5c5e364a07@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzNDQwMz3ZTUnNT0kmLdvLRiXSPTlMS0VBPzJBNjEyWgjoKi1LTMCrBp0bG
 1tQDyXlNzXQAAAA==
X-Change-ID: 20261106-delegts-nfs-25dafe47b434
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Lance Shelton <lance.shelton@hammerspace.com>, 
 Olga Kornievskaia <okorniev@redhat.com>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=837; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=iqI3b4jVM4hkAG3pcJ1Tqy+6Vwoqqe4x7r6ponXmaNc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq7j0HfJGu7KJ7P4bXHAzrxeF7VW72wTrc/8DMQ
 ObrFEEgxoeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCau49BwAKCRAADmhBGVaC
 FaCLD/9iPUqvtzuDwKE4hmjkxSCLoM3gWMu2kFgRQy5eFwcnfFNrLXw68wqrNWFm6q8Sz93Zhvr
 8Yld976dACIf9jswZxJAatwTPLsX6tpGFvX3HrEX/x55d/Z0Rr4qVvM+2qO/YHZFh/WM0qg/4pn
 BzQLVDsDUKK2X3kpRF3lhUDgHkTWpzH/zahtArcynZlHieZ1kTQe4noapD6u6UurnYat7wk0I4d
 Pib+rr4aXUwepuKCbQumDk2ml9ETgKKz3G8Na+5EHv/2QieqSiG7obn7moIo+zHen7QwstPXtFG
 i8M2Xo16TlJGJUZTHx9r2czdXYlSbQMfKM2NiAmHxjwJDNZJmCd2vsRJ8UmLkzf8Y53Ju2Y85QE
 VEsvMHEzKZ6E0MBi4N+BMHdu364RPrlorUiVqOs4ks1CYyPLCdXF4f0q29J6OHDE7xwijE6ZFLz
 H9vGAMGjL/WB/dgrOfmwB2q2WkxM9ycfh5jDTEKiH65mdbsvjhYFu+vlleEnDauZCETqMO4uQVV
 gE4sJ4O6B/Wcpy8uTc6jDknVMp9t1fBNeM8s5thg3DWeWwrf4AcGtwzrqK1CzQL5mG6xUpQrCNy
 7bk0B3PYi6iY44Fi1xn79CNWiX42ilbk8UklRGu/0yupaSMYjHDLV4EYt7m5fWypxYgOwfbZm+O
 /JWn/FTA7I499oA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

These are some client-side fixes for problems that I was seeing with
delegated timestamps. Mostly this was evident in the git regression
testsuite (which is particularly sensitive to timestamp issues).

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (3):
      NFS: don't let delegated c/mtime stamps go backward
      NFS: stamp after the server's ctime when truncating under delegated times
      NFS: stamp after the server's ctime following a CLONE

 fs/nfs/delegation.h |  2 ++
 fs/nfs/inode.c      | 43 ++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs42proc.c  | 12 +++++++++---
 3 files changed, 53 insertions(+), 4 deletions(-)
---
base-commit: d692f252c52b8d1b4bc7481554f314df31ed8249
change-id: 20261106-delegts-nfs-25dafe47b434

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

