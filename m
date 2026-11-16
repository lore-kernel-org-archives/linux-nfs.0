Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794872659;
	b=3h4dLsjzBFBw5hJx+lnNdrHyxGwfAt2vcnSAB/48XTMwt7Lv0py5c1h+aTwguIDrbn4J
	 TbApNN4TL8H3K45T590DWe6cZJL5os95+ZkTfDHyTCpqCs6a478/oZXfwF3D+ExioRZjc
	 Qr5cVIhomixFB8SfPm/0B58Fla0+tqlqs49DzmuBYZ5jeQQGK2OENPmKvlfmByP81Jife
	 9H6NaS7Pe60/i43s6Bt0ahHr8C9oR/08j/U2ZMee2oO1M9K6ItAeWdryOMJP/Q5OG7s72
	 9VGmX4pNchcqDPoN1dvvIqMtG44IgkYfqtMZ3pYtuTaxmrzC4KQ7iLU7umkJ+KgVr+Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794872659;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=X6teNmQXDZuYdy1Y2DJUfA/p26dPkkMm9pc11A1PS1s=;
	b=hiROM/of4JZeUn7xyS0Z+A2voPQi801/3vdyRE21rHbrKq/eBfmXxq4n8f8chjnRzWHL
	 rVtcSJEQfr0zPXw1xgW4ZZ68XyZTYFDaPYSQwIsYk3bZTtcjlqr4b24wd7Eo2W1Of4v39
	 NO6rKouuKgg5VFdBD2ZpHkx/QHlmZMaG9buLjCmWCZLy7lOuSAEkMzl4gzdYzR4/vaUG6
	 3vh/f1ppjipM33m2M7ge949ojBBt1niqqs8/+mRfAijsuMADdORXu3T8lVobxe44tBicS
	 749iZJh9893fQ2JOLgJp/DH75AaAaRTKhn20VMhx/A4JlQR8jye51jj+SrXUmAUMzSQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Q8UsPOV+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 11F59606A338
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 23:44:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Q8UsPOV+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C52341F000C5;
	Mon, 16 Nov 2026 23:44:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794872658;
	bh=X6teNmQXDZuYdy1Y2DJUfA/p26dPkkMm9pc11A1PS1s=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Q8UsPOV+FTEKwFtArhIhF0sbAd6rs5cqJtMYhAgXpomkwQ1ip3GNWojz0+wzqRykc
	 BlpbqZ/8Q3agK3ihrQU1GU4mK/grPQiiUVFXveLtV8u/X2Q0eeI1D8K3jeZF1ubcac
	 Q5rtHwsGTQpTkfmbYmk/rVQ0d+1AR3xmfbAhZFYIoT5A6PokxdRGfyWg29+4vCLHKL
	 g4rIafFpdu6uhd1vY7CRChXI0LgnicvmV+ct7RRk0b34MkK3G/RPuFO8/f5VdSvzHr
	 smblqpr/hBp7b0T3rl2icOrwELo+Gb3ygd3YV7HMV3uLBttb7pWnNsvtmXUOWPmy+u
	 tcxNmLXxL7PNQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 16 Nov 2026 18:44:12 -0500
Subject: [PATCH 4/7] NFS: Return NFS4ERR_REP_TOO_BIG for an oversized
 NFSv4.1 callback reply
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
Message-Id: <20261116-quinn-v1-4-f05258cab8e4@kernel.org>
References: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
In-Reply-To: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2353; i=cel@kernel.org;
 h=from:subject:message-id; bh=qLUSEG4qbGPma4QgqwlJQO490lCZhQJpslVsdCd68qI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq+5VR5vq2RWFLK7Kg568GA2gjWks/aCe9PrDgZ
 Lf4NkL29vKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavuVUQAKCRAzarMzb2Z/
 l/rGEACPo//M1QZF5XlW2GAnegtm4dpiUOd8jwA760IgLrzFfcsLUU2xYH2ilZKFkMRi8S7DMFr
 RFqowH7OhLe6FZQDG3h2qJheAe/AiP913WlcyvpWBRLp9Es5YIQfApBITTpk2SjQY41HTrmzPAv
 D/q0cjchKWlAoNZSZ4UlxUPY3C8iBtUfUzlYZpkhtDK6DF4cS0pWvPpPX/4k9xfJ+sE9HcZeey+
 ORpiTQjqpUdc+kT+n+rxe2yLsCZabZPg29cHdBLeLHXDdzzFDkOanckQCgRMRnBAFe0q/dyQ7en
 cD+ZDq9nJG6WPjkDp4df9B3hgKGLnPHjxiYEissL1LjwkVJGo0VFCaxmLH4UECnF2T/zQqdO7OZ
 q4RU3PxAtFG8hCwnHFULzJgGSVxFhkBVckomxiDsriwABnNMaswXTk2a12Zwo+svu1mlCiH9rvI
 ubjwcl9TyJ2qLP8AGge2xdSpVq6Ea748lQwFlJkXBIp9FRjyBfnZZ/ZUShdK9guR9ww7r/+eDqQ
 0B0dSe95tGzd7wp4cq+IH/qhJSgc3UpxAG4Re+lcQNPdTATHuj7Sus58jMJsyY3TSNBNjzdOCpZ
 miegBOjzy3o7h+1J9NrlOeoUdgwaBGXbopndnK+OZPLL2Jl+HIAfJJFMdtsYYN4wBI7uxbJYXgS
 a4ADZmqsR6mzrPw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

When a callback reply runs out of buffer space, the NFS client puts
NFS4ERR_RESOURCE in the CB_COMPOUND status, whatever the minor version.
NFSv4.1 does not define NFS4ERR_RESOURCE. RFC 8881 Section 15.1.3.6
defines NFS4ERR_REP_TOO_BIG for a reply that would exceed the channel's
negotiated maximum response size, and Section 15.3 lists it as a valid
error for every callback operation except CB_ILLEGAL.

Report NFS4ERR_REP_TOO_BIG instead when the minor version is 1 or
later, at each place process_op() and nfs4_callback_compound() find the
reply out of space. NFSv4.0 callbacks keep NFS4ERR_RESOURCE.

Fixes: 34bc47c941a0 ("nfs41: consider minorversion in callback_xdr:process_op")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/callback_xdr.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 3dd2181e51f6..5a77487f9481 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -885,6 +885,14 @@ preprocess_nfs4_op(unsigned int op_nr, struct callback_op **op)
 	return htonl(NFS_OK);
 }
 
+static __be32 cb_reply_too_big(const struct cb_process_state *cps)
+{
+	/* RFC 8881 does not define NFS4ERR_RESOURCE */
+	if (cps->minorversion)
+		return htonl(NFS4ERR_REP_TOO_BIG);
+	return htonl(NFS4ERR_RESOURCE);
+}
+
 static __be32 process_op(int nop, struct svc_rqst *rqstp,
 			 struct cb_process_state *cps)
 {
@@ -931,14 +939,17 @@ static __be32 process_op(int nop, struct svc_rqst *rqstp,
 			status = op->process_op(rqstp->rq_argp, rqstp->rq_resp,
 						cps);
 	} else
-		status = htonl(NFS4ERR_RESOURCE);
+		status = cb_reply_too_big(cps);
 
 encode_hdr:
 	res = encode_op_hdr(xdr_out, op_nr, status);
 	if (unlikely(res))
 		return res;
-	if (op->encode_res != NULL && status == 0)
+	if (op->encode_res != NULL && status == 0) {
 		status = op->encode_res(rqstp, xdr_out, rqstp->rq_resp);
+		if (unlikely(status))
+			status = cb_reply_too_big(cps);
+	}
 	return status;
 }
 
@@ -993,7 +1004,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp)
 		status = htonl(NFS4ERR_BADXDR);
 		nops--;
 	} else if (unlikely(status == htonl(NFS4ERR_RESOURCE_HDR))) {
-		status = htonl(NFS4ERR_RESOURCE);
+		status = cb_reply_too_big(&cps);
 		nops--;
 	}
 

-- 
2.56.0

