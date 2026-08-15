Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8108329C48
	for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 16:38:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786811940; cv=none; b=JCzLJNEyeLOOwv28hqwGruvQSnDgayJxKkSBl94eQtH8LltWamboUlKS5vyJOUraRb3+sTog4olU0mJCZdCkZGmSES1izE5XxwgxRA9KjHE2dAstfQNeUJnj87Tw2PaUAhkcVjtTT69pUycUMWdy2tYNXLyMOtYwPD2lFNlmZkk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786811940; c=relaxed/simple;
	bh=8rNrab61OcKe/19c+EgT/hNxyukaSIW5Dcvp4TLryAs=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=tKU+Sux/v7VbGntQvLUy0D30kNnKmJIBbvQSBKIGVw5bKkt9EFE+lhy7hgYFwOa9Gg8LXBgaNCNOC741oGeeSFbmD3Ka6ZTt/hEQh2GcsJiLeqZkZvCHQraHstxS1AUHFo5nRZFS2rlAQUfA5kydSbrgE57erwdOG7b2qnYMzF0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LkIzGiFR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LkIzGiFR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 30DFC1F00A3E;
	Sat, 15 Aug 2026 16:38:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786811939;
	bh=wvoHmAz0SBYKsTksVO8Bo13VC8Jbmuk/s+6G9y6Npqc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LkIzGiFRch0kxOGFLFwiLQuFDYGdKynG0/+7u1XGKEpo9BGn/0TNtllCTzigXqeb2
	 C9nxl2leQGmkFP6CLpXbjvznpHw/IwqfJ68UQwHKEds48U8DPxizqVkeW81F2VLZvN
	 ggtgSd5shCNEEo1Dr6lvIInT1M42VWamlmaq2Qz+0v9sBd6E41kQITl5EGCxzTMsn3
	 jQG8U2WJN8rl4gU9oEmU1MSckqYrRY7DIeZTyTxJDOBMRalWHVF+I2XkJn+ddJEZ3c
	 9zeq/arw1kUyz4LqTCWcB8DaSSWvUNPLkH79YRo1fKxeoqD77+PX5fCkamZaPRKUQK
	 qvDm3kdkh7soQ==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 15 Aug 2026 12:38:49 -0400
Subject: [PATCH v4 1/8] NFSD: Do not send CB_RECALL_ANY to NFSv4.0 clients
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260815-recall-any-keep-count-v4-1-bfb5b83d6cb1@kernel.org>
References: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
In-Reply-To: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1620; i=cel@kernel.org;
 h=from:subject:message-id; bh=8rNrab61OcKe/19c+EgT/hNxyukaSIW5Dcvp4TLryAs=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqgJYhB1WXRc+eoZSo6RjEKHaD4vzs9+z6aYBAp
 onQ4Av5FoGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoCWIQAKCRAzarMzb2Z/
 l1E0EACwwIkzlEnpWecdEUYdoVzfgghXkPq2AOlurgFjOgG7z1zMzbkYrMsOGR4kaBini6nCzQk
 MYDPKoIL8IR0GsaipT80twQrs9AaSIkLVDhp+p63U7y5PVRHnIWpuscS0J/Tfk9XMv2LW5ecmMP
 hZem5eonLBH8gky6GeBL+nSTm7ljfF4CX0rRQdf1MUfQ2F6Nadbhw81qg5owALIOHSkLwDvhZdP
 nvcpb34nFRLjdzm0yUOcfkQi8x5kkqGwErSdbZwhRibk9uLHAcvHKWeQfd9qk/sZsxAkTKMtEYX
 7PrYIDTLTT1XkPK20c8bCQGUSvtDVjofFneqb1bPJu3KBXqzpoQ3IR+vwrEYLpWx0u5b+biu2UL
 F65Lk6yjcBBJSZtOiPnJzK6yQ5hONeC33V3cHMrM4OvpG+DdtomoBD2T5vY/coHqkfL45NcIKwc
 IfwHVdka6FOzh9JmDVpbvA9Ql161LbZPTqaEbM/MBDGe+xAtjU/4Dp9RO31beQOrfBZRlzbwVgy
 o0MkgiFRxbu762DYz1gHbNFY5NAqXWFvQGdvCkK8LlZi4HWxNC5dYOyppuWKsqi57FDRJnI8ro1
 z3vrgyU7t7mfxf+oaK/N4zLCo2CIbqoPSjhHykWOYUXZKWs2BsWyxP9KIRdqvEo7wzUYvJoSxtw
 fSuu9bYvZlkzUuw==
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

