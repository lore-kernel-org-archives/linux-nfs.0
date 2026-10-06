Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE12F3D3CED
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 20:44:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791319477; cv=none; b=ffYPwyu7FFBcn6BeWUw5rrsrApu2UpM3Rrwrit+OqZva9x3YDdB6OgWU6lS3PRVVfQXXYQVDouQH9PNBVyFXDfoSKDiLnhr57ZJorB7X8goSRuPQ1+27MGrTNJUEGv/T4kQlyK+UDa019XD0Am/cO7yrDBHWwkd/3h8EvuK/V6c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791319477; c=relaxed/simple;
	bh=RuACCjrfLmBxK+3Lidlazg6dFzmbl4ABQn0Hrw8IHRo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=o4kCTupkthXVzKd6uAbeFaguuRktMinM9EzUSs2QLCPP3DkaWVZvMwTeNY4lpSNAucf/2ffyzciUIIYjoKG8ij3cUgd+JD9URQ2dna5Qyt6J6Z+MV1qsvgWqTZrx5SOf/eWqL7slJdT1rJD1xUw+K45JV3J6yPEuUk7R9eLnmEk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RUKmTqP6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RUKmTqP6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2C3081F008A1;
	Tue,  6 Oct 2026 20:44:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791319475;
	bh=2FMCdRbj5of7ebvVjGoyk5nw99TvIFWKVhLeds3CauU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RUKmTqP6uFMa3ik32ZTP+D3s2kXCacgtaOlp0S2QZ5H6v75fPrAVGOmzAVy/oK7wn
	 i6sAzye/P1Ai0YuiuWQ0S4+KYHG1BTNy0GDWPDKX9sFg9abCSrmehrtNZL/UzQwxeT
	 6GAMunuBwIRjgzdc69nNPidYN2T2EVgrvB5ASYL2yW81agtd9pOyKeaXY812j/qLQ/
	 libdDq6Q9w158PqI04tWP09sCa5f48p3IDhs0N5Qv8Z6nQtFqD17Yi/+PZEC9dYwJX
	 pPbL1OCYJNtRU9RC8dt2ZoYcwnOvrbRixaHXJW8sJ9+qmk0rWqk0yFIhNjN9pHwAND
	 9q3HQ5qsUsKbg==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 06 Oct 2026 16:44:15 -0400
Subject: [PATCH 2/2] NFSD: Save the stateowner reply when a seqid-mutating
 operation fails
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261006-open-replay-fixes-v1-2-0c668a3e7216@kernel.org>
References: <20261006-open-replay-fixes-v1-0-0c668a3e7216@kernel.org>
In-Reply-To: <20261006-open-replay-fixes-v1-0-0c668a3e7216@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3766; i=cel@kernel.org;
 h=from:subject:message-id; bh=RuACCjrfLmBxK+3Lidlazg6dFzmbl4ABQn0Hrw8IHRo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqxV2xZq18btsQdRjjXALeobo5HPp0iteRpdLQm
 PzS46eQB5mJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasVdsQAKCRAzarMzb2Z/
 l41cEACYohwrtWT5QDcLyHQaGFltu5W3MMcBP6ZBGah2rOQZ1cVUFKGznwBj3iZS0FQKxwkp/n4
 +XikW2jKgUpEoXyv1WtnZTjd7T5JhhjkaB3gr06vVDYyCOXYZGIokCvIt+mHg1Vjp3zcQwgoXCD
 ACfIJ1mOmSwg0bb8OwEfmFcTCkqMdUZOyDSsdcZbyEjeM4dYJi7hT15VDrE3eVuWzBVkUU1k4vZ
 bnu8SGRE79SyVJdO4hxGIkgJkkbQ1NqcQuTbkooaMedPhJl2dLfOpHUy2ajUx3YZv+jYgHj4qQE
 eRMmBSD6ElW9gR3oEbDY4k5R3+tH52g9OSsYpiHG/oFOi3U+TJg6kljOEfdXorKH5mLdeRUTwuU
 KXpb6RMe6VMuBL2/ncwY7CF+zVdGGXWtj3TRdGDz5GO2hJOsLjQ5WUFQb8WUUXEGSeye4h7gDiE
 xLFQHK4QrhdNthEV2DlbzV/LJDPZZxQ0GQCQIaDhUHEfSQsVrmJ0uODOlb1dIjisCKQqGS/1rE3
 paQ9gs15oSiaeXiomNkzq6QRcG+GIpPwwVQqCs5wsBqYTrrLwTMXE2bnXXBXgKtcWycJtATiwNf
 LSFnvYI6CZehUgOEkNC19Nwa3YtHyD2BiAefj8A8DLuAp4oO+nSFryU7YLpRO0yCQbNHeMKBu6y
 a26sPOSP26xxGrA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

An NFSv4.0 stateowner caches its last reply in so_replay. When a
seqid-mutating operation fails with a status that advances the seqid,
nfsd4_bump_seqid() advances so_seqid, but commit b7571e4cd39a ("nfsd4:
skip encoder in trivial error cases") sends the failure past the save
in nfsd4_encode_operation(). so_replay keeps the previous reply, which
NFSD then sends to a request that reuses the failed seqid. When pynfs
resent an OPEN that drew NFS4ERR_DELAY, NFSD replied with NFS4_OK and
an OPEN_CONFIRM body.

Move the save below the status label so that every operation with a
replay owner stores its final status and body.

Save the status that goes on the wire. The save currently runs before
nfsd4_map_status(), so a replay of a failed symlink OPEN would carry
nfserr_symlink_not_dir in place of NFS4ERR_SYMLINK.

Skip the filehandle restore in nfsd4_open() when the cached reply is
an error. rp_openfh names a file only if the OPEN got far enough to
record one, and fh_verify() on a stale handle would replace the cached
error with NFS4ERR_STALE.

After the change, a client that reuses a seqid after an error that
advances the seqid receives the cached error until it stops
resending. The Linux NFS client, FreeBSD, and illumos do not reuse a
seqid after NFS4ERR_DELAY. illumos does reuse the seqid after
NFS4ERR_OLD_STATEID, which NFSD treats as seqid-advancing. Whether
illumos then repeats the request was not determined.

Fixes: b7571e4cd39a ("nfsd4: skip encoder in trivial error cases")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c |  4 ++++
 fs/nfsd/nfs4xdr.c  | 15 +++++++++------
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index db683af11bd8..eb3a3095ea9e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -702,6 +702,10 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfsd4_process_open1(cstate, open, nn);
 	if (status == nfserr_replay_me) {
 		struct nfs4_replay *rp = &open->op_openowner->oo_owner.so_replay;
+
+		/* A cached error does not guarantee rp_openfh was set. */
+		if (rp->rp_status)
+			goto out;
 		fh_put(&cstate->current_fh);
 		fh_copy_shallow(&cstate->current_fh.fh_handle,
 				&rp->rp_openfh);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 7062c84f96dd..56805283f90f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -6771,7 +6771,13 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 		 */
 		warn_on_nonidempotent_op(op);
 		xdr_truncate_encode(xdr, op_status_offset + XDR_UNIT);
-	} else if (so) {
+		/* Keep a truncated reply out of so_replay. */
+		so = NULL;
+	}
+status:
+	op->status = nfsd4_map_status(op->status,
+				      resp->cstate.minorversion);
+	if (so) {
 		int len = xdr->buf->len - (op_status_offset + XDR_UNIT);
 
 		so->so_replay.rp_status = op->status;
@@ -6782,8 +6788,8 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 			if (buf) {
 				so->so_replay.rp_buf = buf;
 			} else {
-				/* rp_buflen already zeroed; skip caching */
-				goto status;
+				/* A body this long would overrun rp_ibuf. */
+				len = 0;
 			}
 		} else if (so->so_replay.rp_buf != so->so_replay.rp_ibuf) {
 			nfs4_replay_free_cache(&so->so_replay);
@@ -6793,9 +6799,6 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 					op_status_offset + XDR_UNIT,
 					so->so_replay.rp_buf, len);
 	}
-status:
-	op->status = nfsd4_map_status(op->status,
-				      resp->cstate.minorversion);
 	write_bytes_to_xdr_buf(xdr->buf, op_status_offset,
 			       &op->status, XDR_UNIT);
 release:

-- 
2.55.0

