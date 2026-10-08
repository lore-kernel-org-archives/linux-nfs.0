Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5EE5A34D4C9
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 18:18:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791483522; cv=none; b=PnIVJC022HnB8KQdWvqbMvuJNhTgIhpEyLncZl/X35lic8kR4ml/Uk55jRiTYX6QvGZamhRMVNErvlLxiyosL/XghERpkLqGRMWAMZ9/+UO0Sm82DU4qck75BNCMmygib+HrszhXC9oBmQ7QUlJrfurpk0OQig/1pdr3CufduD4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791483522; c=relaxed/simple;
	bh=UHQEc1KnkRjTCIh1Gi8r9AfwGIzNYbbNE8+rK1lnt3c=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Q0/lyOJrHmFO1/zZiJ/actFpDaTvJ7nCoTadsV0GzlJYxacmj5VeJjxzAjJthy485+qLYrxeog23FAUWuIGPxU3Sn9rnfFUPS0EKuVA4ZCEJABrbEzmPWNHpZt4P6TR+oW8mFuVJhIz6KNLfMlJju5aKM15W7+Qs3TUQjb19Sv4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KQLazAIS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KQLazAIS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 87AC11F00893;
	Thu,  8 Oct 2026 18:18:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791483521;
	bh=dKsXR9Vg01The6xwSPQS0UzobRyO67mTU+Uhao/vhcU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=KQLazAISKs+Vu0M5M6i3Z8oTViLDxOL9ennq48h2IVrIzJN2mMiJoHA6TMA3w7ZJR
	 8hjUGGC5E5hRKn1HJImxPi2NCsj4E1OCiEE9QRt8YH9yNufMB35VwtcNyseNdJF8vW
	 UmiA1XA8nIeSKSjAs9kDplKmQl2diU9br7d1WiCvZaUNdHquL60Udaoj80onmtZzWx
	 sQxfEzQx/dI7H5lAuSi/vOu7DqRJN7AW+VmAiYwOHILupSX0sj9wzk4p+1Y27EvY7q
	 oBYHc177mhbjiYuxr+pzGYz5ekdurTH9F7Fz00sIy/de8PXE1frcxhXQvJVRdt5tOl
	 h/APtnoJO9SRA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 08 Oct 2026 14:18:27 -0400
Subject: [PATCH 1/5] NFSD: Report WND4_CANCELLED for an OPEN with
 WANT_CANCEL
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261008-want-read-v1-1-e372262857c8@kernel.org>
References: <20261008-want-read-v1-0-e372262857c8@kernel.org>
In-Reply-To: <20261008-want-read-v1-0-e372262857c8@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1981; i=cel@kernel.org;
 h=from:subject:message-id; bh=UHQEc1KnkRjTCIh1Gi8r9AfwGIzNYbbNE8+rK1lnt3c=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqx95/TWdCR5dgpZjgEVP29mXkTMozNhiiUaDyt
 0q8htLaqjmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasfefwAKCRAzarMzb2Z/
 l93UEACn2FJiYg9EOWziAbdhQc5o7IMtV8gUA4hG//dZdQD9e+YdUC7nBVu0lXWNi2FZuPJw362
 RJBcEhSHYJKIOjvU8A7T+QAuxjDeCYgG+GbufvscPaPb5hb6+4CXeuBhqcp9oz29f7OBmlwlvxy
 +OlTsKp1vkmXYux2nd5x1AzblNXzLMrunAShHNux82s0WumyZSSkQTfcjw+v7Nrmq5qJRXypBCY
 dafgfamNOpzjkk4YWb/JHg5qsySTANLSpPag49X+l5cCJXiHX1hEyVZ+axmnbiHkZGZw8DiJiKK
 UikC+y54W8sGqPtzR4d+E7Nt50ajBUi8SWuM+ltpLavVik4KOGO1dDHAR2qse2os3yCa9HDvviE
 fq4ABYjkwWMNz1DHuhQG9nh4fXEeBUGGaCPFsJeo+MlKDLrt6SIWoEiSbhvf0IBhBG3+ZyeeRyD
 wp84iQcimioicQkiSBR5iBYS0eS9T+BkWiWDwLvpUOeR1kNuPIM4P05PaOBmzcc3tRanruJU8tt
 bFnS5KmVFndbkMQ8TqUM57Li0bA3ZsKw/rT9l2WXcnjzkYoGdkOqe0VcL1UZamDdAkgiQp2LRcz
 PkASj4TJvwIKLwZYlMgt3UAYHJuewkJO3XoXqgBcRe3CqDIXMXFAWm8NZg+Mh1cKwaf1TD7Ys5d
 TjJKdKA6vpnS8rg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

An NFSv4.1 OPEN that sets OPEN4_SHARE_ACCESS_WANT_CANCEL gets
OPEN_DELEGATE_NONE_EXT with ond_why set to WND4_NOT_WANTED. RFC 8881
Section 18.16.3 defines WND4_CANCELLED for that request.
nfsd4_process_open2() tests op_deleg_want with a bitwise AND against
OPEN4_SHARE_ACCESS_WANT_NO_DELEG (0x0400), and
OPEN4_SHARE_ACCESS_WANT_CANCEL (0x0500) has that bit set.

Compare the want type by value and report each reason for its own
request. An OPEN with either want type never reaches
nfsd4_open_deleg_none_ext(), so move the WANT_CANCEL case there
under the existing WARN_ON_ONCE().

Fixes: d24433cdc91c ("nfsd41: implement NFS4_SHARE_WANT_NO_DELEG, NFS4_OPEN_DELEGATE_NONE_EXT, why_no_deleg")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9d00a58a334d..5075baac7586 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7170,8 +7170,6 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
 		case OPEN4_SHARE_ACCESS_WANT_ANY_DELEG:
 			break;
 		case OPEN4_SHARE_ACCESS_WANT_CANCEL:
-			open->op_why_no_deleg = WND4_CANCELLED;
-			break;
 		case OPEN4_SHARE_ACCESS_WANT_NO_DELEG:
 			WARN_ON_ONCE(1);
 		}
@@ -7474,10 +7472,15 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	mutex_unlock(&stp->st_mutex);
 
 	if (nfsd4_has_session(&resp->cstate)) {
-		if (open->op_deleg_want & OPEN4_SHARE_ACCESS_WANT_NO_DELEG) {
+		switch (open->op_deleg_want & NFS4_SHARE_WANT_TYPE_MASK) {
+		case OPEN4_SHARE_ACCESS_WANT_NO_DELEG:
 			open->op_delegate_type = OPEN_DELEGATE_NONE_EXT;
 			open->op_why_no_deleg = WND4_NOT_WANTED;
 			goto nodeleg;
+		case OPEN4_SHARE_ACCESS_WANT_CANCEL:
+			open->op_delegate_type = OPEN_DELEGATE_NONE_EXT;
+			open->op_why_no_deleg = WND4_CANCELLED;
+			goto nodeleg;
 		}
 	}
 

-- 
2.55.0

