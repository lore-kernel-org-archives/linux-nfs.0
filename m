Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8951B3C870E
	for <linux-nfs@vger.kernel.org>; Sun,  2 Aug 2026 17:04:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785690293; cv=none; b=PiGqVy2XMt0jZMtU2I38ZLXvOdijF8UO9UXqxyQFd5ydkXHCJXHH7zRD3c7+eAfUH2pezkbEX6HMyCz2gwRF4WQKt24gVRz6TEWmW+s/nBiVmuOSHYOuGfuIVM2Y3fHauCst+bNEmSAjQypVzrWKXNMEmXpY83oFed2iKp1+XFA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785690293; c=relaxed/simple;
	bh=2Vk8+wW3cIc38PuGGVuSQSuWoYIKPsLL7NKBiuuBT+E=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=LGqfAIlzrFqcsw5zGEfjCoOo+A3X0JC1UD0WmeCGFg6Gh6rKU6+St1gWC7iscnvb9dbSD7k91RLJpa9Zwp7SbTGskyK2KGkYni9THdkCB2/e7fldvlR7be0YcLma/bwc4FB3qrHBSehbRWLauCpHWbUJY2PDwdc/3KJKRXyVIx8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=X7ECr4eV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="X7ECr4eV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9133E1F00ACF;
	Sun,  2 Aug 2026 17:04:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785690287;
	bh=WKLbM3wZE/XD3rG8zYtvqeNgz+G3YZYE2i8EbaX5T70=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=X7ECr4eVEZxzzaXnurWMJZtZBhF/QT001kUVyQJfSxMfUZU4zK+xbU54YcfNLXDbR
	 z9NctSnyeSBQawVmyxIvGMOQUx95E6gAMeouhsuwryA/RB/mwVbTV8ZzmHxbXRi2Xu
	 De/sfEimE2VqJ4CBoFiOdzW8pp5A9EpA37cncD1lJUolPqhnWJeu6izjSAoFEgTvY9
	 hFYQDNkd5bYHNmxfc8SyZnNgblB7/6eBhKB/BTRaj5gy7pp/tXScULP9ZfQcMWSg/L
	 EMB0KJZ7EBEZeR3ln2CEImKqYapOHcxwzQlB22b20/yffZpF1M7VNEsCvgVswoTZkr
	 JzE2Wo8Cdr/7g==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 02 Aug 2026 13:04:32 -0400
Subject: [PATCH 5/9] NFSD: Budget the CB_NOTIFY_LOCK opcode
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260802-nfsd-deleg-destroy-badhandle-v1-5-323aa7196055@kernel.org>
References: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
In-Reply-To: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=953; i=cel@kernel.org;
 h=from:subject:message-id; bh=2Vk8+wW3cIc38PuGGVuSQSuWoYIKPsLL7NKBiuuBT+E=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqb3iqeDdajVTOCXb40P6bdZyb7b+tHla5ayi7j
 xx2lsGUqe6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCam94qgAKCRAzarMzb2Z/
 l9dFD/9ps202ROkLW//Fb4pbMT66qM2AEpPQ/pygNdDKQ07AOgZAQLCUfAJQ+o2Sk+7dUGvB2vV
 88rKIis8nO/+L5YA28/GbPDJ67c8g9BYqC2wzZV2PTnY00UY3K09zlt4itjkdxf30+R94LZEkO0
 ogLL0zrUimc40T13Rdg33I6TVlHfWc/scvZdX1sIdfQS4h4c3p7RTRVmkMpZIq0ThAOOW9IJe4M
 cq35qT+Y0K03Ohl05Vq1abxe9/nDRxTxp5gPZ0yuhyYD2QCcGIX7s/w2hjQrMRJEbQ7Mwg541yp
 GvTsJcq13cBfbIvaieJeHnTLSRjcVtX58niZsIID0jRz3nVVpDpM5rpOLrlA0TJe6vcij4aIeEz
 Z6D0bb58Ds37tT6I3iYMCuiwOpP4jdtOxKNawoq/2V3Afgj6bWiJ7zGqXMZoZ5PPl42ypSEhb/K
 kbQyyishHhLRbG15Po6Ts2EeW9hxH13WB2t81r8uPs1E3czfyDTCzv8EPfnuLte2GzMOquqsKP8
 rKGcMIoJirJoRSBezrB7mjIHCYCtWZW7dlHQjnQ69lpipAmdyfs/KBwn4KiqWwV3kklFOJ6X3iJ
 wO3qHJGu/2eAsUYRljfNcsFDX9qKiuE5Ifi+81EZndN/83YCcrezfS1W5F+8iVtkMnL6kiaxHIn
 mmQ4RK8DV8p6ZWQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFS4_enc_cb_notify_lock_sz counts the lock owner and the file
handle. nfs4_xdr_enc_cb_notify_lock() emits an opcode ahead of both,
so the macro falls one XDR word short.

This macro sizes p_arglen and nothing else. rq_callsize pads that
with two credential slacks, so the shortfall has never reached
the send buffer. No backport is needed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/xdr4cb.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/xdr4cb.h b/fs/nfsd/xdr4cb.h
index 21d8280edead..01bb54f03d25 100644
--- a/fs/nfsd/xdr4cb.h
+++ b/fs/nfsd/xdr4cb.h
@@ -48,7 +48,7 @@
 
 #define NFS4_enc_cb_notify_lock_sz	(cb_compound_enc_hdr_sz +        \
 					cb_sequence_enc_sz +             \
-					2 + 1 +				 \
+					op_enc_sz + 2 + 1 +		 \
 					XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
 					enc_nfs4_fh_sz)
 #define NFS4_dec_cb_notify_lock_sz	(cb_compound_dec_hdr_sz  +      \

-- 
2.54.0

