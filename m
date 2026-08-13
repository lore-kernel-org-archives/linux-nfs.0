Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 39AF140DB5B
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 18:40:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786646452; cv=none; b=luISLpcO1ui9f0O/ZDzvnfQwozhb6+8oNXOX8DdYSbycXxueGczI0vIYAxZnCYh/60h4NqiGVn6Xkbeew3MWzWY8RYg1vUZAn5tB9gZN4x2AboCcCqjQwo4CzKfMUbqAspwFfwYbNwORYIqYsM0C01c1oeNLsVCH/zvIeTcim7A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786646452; c=relaxed/simple;
	bh=dUoCF6QFbiWGBqWLpbL/dhA5Cz/oJD/+5MJvveopjVM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=aNN5xEfMJIM0RsL8GhjiBsE0KC0CveBQ7Q88OlE0Xg8DApnRP8SZr9CR7Re0qJvE4HB4xKq9rThxQiOnWxI1J/r1UTu8/vePP1MIQK/WRRm/tStkThCwzqgBkdcJBvU7n3DQnUTJQfBQcLexJhis8TCNRqzuXH+8mONnDiFSOC8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kFG2UeF7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kFG2UeF7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4B2D41F00A3D;
	Thu, 13 Aug 2026 18:40:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786646450;
	bh=TFsCLUIxfdIQT6U3Fs6mvmCAZ8VJ42aTjTPEALmTx/A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kFG2UeF7EaYn7xNPL8/Q/jlapb4+JH1Xq51iQUf3YcFlGANteCqmdSha510cxA4BL
	 3QyTKe++8zyTfbYPnHaAtCsA3rLyJYRtOs0eCltpDzkculnU/cDnhCm7RmnLVC4AOT
	 gY0RmbF4XDaNCNNFdCaglQU/yR0JLxAs3g4FmYqinxAmE2f+Tt6gaM4EYHXgLKrrYY
	 1WYzQqUhu/tDFM3QEUWRhkVvsvtV+2RXY7yXRf49Svg4PaNh29GUcnanoqiqS4+GQY
	 CZXQ2nk8vbrdvEOd0zhzwrblMgtfBeKDoiJmM6A65wQn7nql6hQOAdOjdX5lSEtspQ
	 YsU4H0YxGD6Uw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 13 Aug 2026 14:40:30 -0400
Subject: [PATCH v3 1/8] NFSD: Do not send CB_RECALL_ANY to NFSv4.0 clients
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260813-recall-any-keep-count-v3-1-a96d243c0b13@kernel.org>
References: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
In-Reply-To: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1620; i=cel@kernel.org;
 h=from:subject:message-id; bh=dUoCF6QFbiWGBqWLpbL/dhA5Cz/oJD/+5MJvveopjVM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqfg+wLGJpGAb68OAkZcZjtsxZm5Y7fVQRrfnK3
 qScaCcnNhiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCan4PsAAKCRAzarMzb2Z/
 lxe8D/9L6FFGR/AvuRgcEWhV+jAZOzt4YSKiZD1k+Rjr7tcgbPj+dfwldJCdBgGtY8WG9PAnolF
 OWTjp8Ync9dn5v2vaebTmXc2NcsZRRvtoTz51Y+nrpySVbejw11Z6iHqj644K4VN74RAT9fYtef
 PwL4rZyyZP3bhaM0wRzTMOZCuRfTovvqw+fvWPJgWtR2Vh58KONFW/4RLQEjTNtHXWI15BImbIB
 LXqvV68fo+owy9cxFTWc4EZ7Si9iyi3FCm6memPo2+4gD0MFlA8eOk30EgCnMzeULA7Td3LNTNK
 W72yMEx0V6jU2G7JUDKqOK7ZUckvkVqkJuQ0pVj1hBe5rJKfBYaTAbrV4mCn28WV/TQu6EjDbRN
 1U9crs7WNWlo0fBtZ1EiX+s6eEMYxbYL4+r1C4/J0016gPdL7BR5DzkPhrCa5k2fRN2Ib+EvfHN
 azq2gOQRleCPnexQh6wzJQLPFeXLCMehJCjYwgjb164U4pjyqknTJ607EXFmwGhL7Vw3pnnbnvD
 F5zOv1fllZ8AVQxvGHOxhe5uw4zd/NItfNIEjAdFEc9pRJLTu33P+MHo/d7umR5/FVKf2r1tJJp
 AgmOrvdiaruU1BjsKBpTY+eBWq3qa8SA39HJurV245SXFYNazGPFpeiCLtBwBFDKRAz2/cwt1OF
 LKvYQNrx0EPtVww==
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
index 510380b6aa7a..09b1aa2914bc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7947,6 +7947,8 @@ deleg_reaper(struct nfsd_net *nn)
 	list_for_each_safe(pos, next, &nn->client_lru) {
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 
+		if (clp->cl_minorversion == 0)
+			continue;
 		if (clp->cl_state != NFSD4_ACTIVE)
 			continue;
 		if (list_empty(&clp->cl_delegations))

-- 
2.54.0

