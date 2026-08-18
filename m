Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD95123E35F
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 01:08:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787015328; cv=none; b=ke9SEQOoibOtpE5ReUiAZI11cpES5BJ4glw8/HEVoHru3ozAbSjXdKp/d9l1ZpvpOrErvNXtyt47BPmn4NUDO8sy7+UEFAVsVKdTjf+di6gpdSiZbgovc92mRSWcOgqBro+gofuvYJGqTt++gwfmOIXlvFzewpK5JLhicMWxjeg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787015328; c=relaxed/simple;
	bh=8rNrab61OcKe/19c+EgT/hNxyukaSIW5Dcvp4TLryAs=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=NrbXCopfoXyyKuaiY8iYsHOoiuSWR/gKH7JNIMYdgU0i0/APAbZWZZLVGLJano6U0TofXGxUsBnbGzgiu22+qR+BKmZaloQ6wkueIAXwzJp1mm7txGQ+AEasHLyF4rDy88SnpJcxWAx+CtSHFsnHGIdNN3DBL6/qab6Dd/D3/U0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aprQgSj+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aprQgSj+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F1F261F00A3E;
	Tue, 18 Aug 2026 01:08:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787015327;
	bh=wvoHmAz0SBYKsTksVO8Bo13VC8Jbmuk/s+6G9y6Npqc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=aprQgSj+zBtTWOTuVCyzRydfKfKp2F+ocgLXOcDylk2njMDzGu1Kl4O2PXlI8GAov
	 SIe8gYFVrdj27equYYZImFc3k1tfbfRzY+JFDX4Bc5fCu/DOYtEcKLbKk28JD7Whn7
	 2Pb762DXNwqUAD0HOx0JHLin9SYWJ+qkjGily+7CeX6mBUKIJLgFDkbkovXtf1+D7g
	 DSOTz0+5nwWZ3FkCujXrozL74Lfnd1jDCkEQ4plnwNNcyR6HROM6TetQ4RVNz1upZD
	 KGhikMM6B1rnFCXBU2tBg6TaADmzLIKG8X62aVx3TOxlI9pgI1eHyh+QLZ3PNqTFno
	 QGakwOt8gmT1w==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 17 Aug 2026 21:08:36 -0400
Subject: [PATCH v5 1/8] NFSD: Do not send CB_RECALL_ANY to NFSv4.0 clients
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260817-recall-any-keep-count-v5-1-3b2cffce701e@kernel.org>
References: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
In-Reply-To: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1620; i=cel@kernel.org;
 h=from:subject:message-id; bh=8rNrab61OcKe/19c+EgT/hNxyukaSIW5Dcvp4TLryAs=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqg7CdY45gqBZhqVUkATK9w09tX9LR8Q1+z5tge
 olEsacT3jmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoOwnQAKCRAzarMzb2Z/
 l3kMEADCWVcaeBIy8Qm9HIHT2mjJND9/+K3sHnkSZdgsd9n+22RmZdVySsJlmV2J9WUDB3UNJT0
 yqR69fpsV6sxoH+9/aeSji+98mwBos9D8lddy0safzyg1QaFNuMrK1J5Qz2pA9lwgtROB5fjmxt
 ovioA51/XJPgPLw9qrp4Vgd+K8xTBIgndHQwgWPNXJGqXtVvY+aO2VrOKyasdh43NzZOCyYuOH4
 ZZitsKe6Rl59qBYMPXOUb5HSJ+ASbLSfxSn+HflOYppzbuqGuVi5juP9SkcOXTbzmWSvmD0NsEF
 qMeXsvI69fwtcAixAGTGqZO7NIBDhDoJrB0pviUWLOmrxL50Dc2UX4sWgR23b0NRioHxQ5cLUqT
 ICtSb5Uelg2uG/zJWdXDdXnKJOjOILVPYrdXVQdqjHCgi5kuwszMC4tINMAA1hvWMbqZlvmVbMh
 HhRt0NCvqBUqZ7CcKPdgJ6BV6kRVPIklS/Umba6W+nWiDZs1IuBJKMQLQ4phi2sArmvS2PxPDE6
 m/gGa8w4v6b/NMaoO4agpDtDge8VrnaOYx0apSpOU9N8BknZQ8Pjm3lFRMKLTdh2SQYb84sBVgX
 lekw39zBnXIfHjzHqQPQ73yRUdVFyxH8fry1tc12ExbueZ4pskv/6j5ONU1AgS0z7nNW1rKhtqJ
 dUgwL00w3BZ2Tbg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

deleg_reaper() sends CB_RECALL_ANY to every ACTIVE client holding
delegations, but CB_RECALL_ANY is an NFSv4.1 operation. An NFSv4.0
client's callback service accepts only CB_GETATTR and CB_RECALL, so it
replies OP_ILLEGAL. The decoder maps the unexpected opnum to -EIO, and
nfsd4_cb_done() marks the client's callback channel down.

Nothing brings the channel back. nfsd4_run_cb_work() sets NFSD4_CB_UP
only for a minor version above zero, and the only nfsd4_probe_callback()
call site an NFSv4.0 client reaches is nfsd4_setclientid_confirm(). One
visit from the reaper therefore leaves the channel marked down until the
client re-establishes its clientid. RENEW then returns
NFS4ERR_CB_PATH_DOWN for as long as the client holds delegations.
nfsd4_cb_channel_good() stops returning true, so the client is granted
no further delegations.

Skip clients at minor version zero.

Fixes: 44df6f439a17 ("NFSD: add delegation reaper to react to low memory condition")
Signed-off-by: Chuck Lever <cel@kernel.org>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1ba97e3f65eb..9a3574b853ad 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7945,6 +7945,8 @@ deleg_reaper(struct nfsd_net *nn)
 	list_for_each_safe(pos, next, &nn->client_lru) {
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 
+		if (clp->cl_minorversion == 0)
+			continue;
 		if (clp->cl_state != NFSD4_ACTIVE)
 			continue;
 		if (list_empty(&clp->cl_delegations))

-- 
2.54.0

