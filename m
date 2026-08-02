Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D66B3C1D57
	for <linux-nfs@vger.kernel.org>; Sun,  2 Aug 2026 17:04:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785690287; cv=none; b=uXPIOsqYZ4p/NMdIGZlc6MPXviq2kqJp5VaDWSDa8R0Q52dcZreBGx5xvtk8tcGbTnV4HZBD+jagOhvz0c7ihjaCONsKDfy6NQcFfvvarmimZ4lt97iGpzaLqqiX70zHCZwQi1NpwTYnNOw1CAUgtEWP9kCjkxNo+Px69SVQ+9I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785690287; c=relaxed/simple;
	bh=kkBTd2wqDJy4LD3UrKNDfnH5OL0gG9v5FNI1aj6Kr9Y=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=kwp9T4yvlAoRfnmIp5zZw8HcCgOPh96AIvpGn3/7OVq+SYHTFy+kPanlmSMnhZ3wf+jjZ7DzwmR6odbWlR2Vl419aJGfxzMAWAJZ0y03JBeW+hlyVBnlmrsdciL3shYmosj3HdDsw7npHhpS9ywfxP6OCpfTxBnmSRILBouga5c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RstbETWX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RstbETWX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A77391F00A3D;
	Sun,  2 Aug 2026 17:04:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785690284;
	bh=rWb69+sJESIICZKejwnu6N934r5M2AOtw4yRtXUK5TI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RstbETWX86DUXxKYABJVWIOg/oTZMN0JmBFLWevAGvpSe3dXPN8tTV2va43E65cTE
	 cWMbSgA+7mI4BcisnxNaImFSdU6qMUsg0FGaOwBJYWhlSc0Kbz8eibpXnOfhcrFXBx
	 vH5sOefeE22L1eIPN84QAPGHiNcKQtZQ6M6jvqgSM2ILL6iP65EpkuGx4GYNDgh1Jy
	 lNA+QBVr7o4kwl6b6W1ChXGMkWDvzoex3HJ7c9LU/v388T3ApB/61hIOAE5ASfQkb3
	 vD5t121+I2ocKSSjeZ2OM9pMepcnfju1MTbVkaZOCxmC8pAsqlaXTHBln6u5U44/Hm
	 w03mcXwsYyzKg==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 02 Aug 2026 13:04:28 -0400
Subject: [PATCH 1/9] NFSD: Budget the CB_SEQUENCE opcode and referring call
 array count
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260802-nfsd-deleg-destroy-badhandle-v1-1-323aa7196055@kernel.org>
References: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
In-Reply-To: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1864; i=cel@kernel.org;
 h=from:subject:message-id; bh=kkBTd2wqDJy4LD3UrKNDfnH5OL0gG9v5FNI1aj6Kr9Y=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqb3ipMa2w7mJGxm6dTX1pQBSVNjRPEo2zhGwJG
 3Zc0yApWZuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCam94qQAKCRAzarMzb2Z/
 lxxKEACgbxpmLb5kzDtF8OF3ShgQZGQkI5G4mPDO9Jfm+7Teq2O9H5xUiUJVkzbKA291ZTF5kKG
 gJ40Z6itv6FITz8kPFPpDgZGsegohs4bmz5ADzqjw27xF6rzA6uBDm7JafuzEEVsKp6zLX4HnH4
 bv5hvy/PAl+ddECRNkSS8pyIXb9HHrxfJjkgk8ycpOPdh22VpYWoplOikvXzkrpuq6a7iMVjTZG
 qzqV6gHAirbxhyGBfVWHU4jiW97/CDML/P6hMx/Z1/n8ARF6AmbIGf2Gc55NFTOhaIpk5VVtFNY
 ZBNTvr52A4aTmDiKmxqxWAjzi1Mc4lDCUDwK1IrB1xDzkz7efHRwTY8C7lO+FaXp6hFleeNjwUL
 569mNp8NsdC9hhBwQ0E4tED2QX+YJwVlIeJ3KbfyL2m8LP6SP8QMlkSziMGhFRRJUjlDq4Y4oRh
 EMCrLwXwtYjmWBlsoXEsGyIPEVw5nvjcim/d4iCpJGwfa1Fc2iV7zow6d0k9FmT2JC2eyA28vn6
 +WOcSFc0lm7UJwL+U+JLwuJMXxAZDBucwFnIryaLPc6GY8ENr1uajTGqw1CaZJRZa+yFfi2uQfz
 Cfk0NlKjKt4NY2/fPUrOHdeIxS4gXMzsEhAuznH8G9VwqvpBuvrAWAK45jWLqal4+LdKphBmqjr
 rg7a2+uqHoj51Lg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

cb_sequence_enc_sz counts the session ID, the four scalar fields, and
one referring call list. encode_cb_sequence4args() also emits the
CB_SEQUENCE opcode and the csa_referring_call_lists array count, so
the macro falls two XDR words short. Every NFS4_enc_cb_*_sz built on
it is short by the same two words.

NFSD_CB_MAX_REQ_SZ derives from NFS4_enc_cb_recall_sz, so the two
missing CB_SEQUENCE words shrink the ca_maxrequestsize that
check_backchannel_attrs() accepts by eight bytes. Count both words.
The minimum a client must advertise rises by those eight bytes.

The short count cannot overrun the send buffer. The macro sizes
p_arglen, and rq_callsize adds two credential slacks on top of that.
The only client affected is one whose ca_maxrequestsize falls inside
those eight bytes. No backport is needed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/xdr4cb.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/xdr4cb.h b/fs/nfsd/xdr4cb.h
index b06d0170d7c4..04d3e321a972 100644
--- a/fs/nfsd/xdr4cb.h
+++ b/fs/nfsd/xdr4cb.h
@@ -6,14 +6,14 @@
 #define cb_compound_enc_hdr_sz		4
 #define cb_compound_dec_hdr_sz		(3 + (NFS4_MAXTAGLEN >> 2))
 #define sessionid_sz			(NFS4_MAX_SESSIONID_LEN >> 2)
+#define op_enc_sz			1
 #define enc_referring_call4_sz		(1 + 1)
 #define enc_referring_call_list4_sz	(sessionid_sz + 1 + \
 					enc_referring_call4_sz)
-#define cb_sequence_enc_sz		(sessionid_sz + 4 +             \
-					enc_referring_call_list4_sz)
+#define cb_sequence_enc_sz		(op_enc_sz + sessionid_sz + 4 + \
+					1 + enc_referring_call_list4_sz)
 #define cb_sequence_dec_sz		(op_dec_sz + sessionid_sz + 4)
 
-#define op_enc_sz			1
 #define op_dec_sz			2
 #define enc_nfs4_fh_sz			(1 + (NFS4_FHSIZE >> 2))
 #define enc_stateid_sz			(NFS4_STATEID_SIZE >> 2)

-- 
2.54.0

