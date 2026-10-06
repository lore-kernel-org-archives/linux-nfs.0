Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56087356747;
	Tue,  6 Oct 2026 04:29:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791260984; cv=none; b=JMpCWDvQRhMyHWw+brdA8vuqWCuHyb9Y85+vtUJHeIvW4EMNeI+A3GSMAPpeQK60NeNlA99rvD32GLpCOoq7JhBRRzvxxOKUsg9yFzFA5v9H+p0tKpFhAT1r3yuPqNvPrZW4Xm/bqvBlfS2m7jHBUR+131keisgA0LegtrazXMs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791260984; c=relaxed/simple;
	bh=cR/D2haPwwjo171jB+/EuVU3PIdnppipC88D3htU2BU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=XqN5X9H/jGJydjhAvv41t2zZ1C0TWok5ilReyzR3Z8/PM4lVOxzWpcBcnzplWVF5XdQREEv1Uuy9Xrn9eQzpHzXCLCJWrpoPp1xLs2+EvEtqL0nKCvUwQrRvuIIZi8/M4HU1NTuvabt1436r5Tkcr3cQGRSDLmaigUb880bjexY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IKM5bErH; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IKM5bErH"
Received: by smtp.kernel.org (Postfix) with ESMTPS id BD282C4AF67;
	Tue,  6 Oct 2026 04:29:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1791260983;
	bh=cR/D2haPwwjo171jB+/EuVU3PIdnppipC88D3htU2BU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=IKM5bErHlLIcfCFDFCjkn6v/o4JKaUS75lIIzZKF1W7enecZfgLxox8YE6kgysfv2
	 45wouSdHiGIkjRvYnlaBJ0GJVTc+TEpU/NUFADVkqlR+BO0zf+fXRyXSq5uf1TUkoQ
	 nTUtsMZOtqQOhsYaSBV5Qqy6XJUY1jfxjEJtK/uYJRHruWBunOpT0bOvJdGS1WcGH+
	 F2XXPgplV2+st5pBRa2O65EsQMSc67quLsEVuPnEszAFJbV65pzBDO3nUOzmbc0MUO
	 b8hXfmTciPJeEbmU294xl9jFee0yT7q2k1XWxBbawtHLbC2sBidme6fBaWmFkijbwY
	 rrKFAsLu+68Xw==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAC48CA6001;
	Tue,  6 Oct 2026 04:29:43 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Tue, 06 Oct 2026 13:29:48 +0900
Subject: [PATCH 6/6] nfsd: do not fence a client for a layout recall with
 no layouts left
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261006-nfsd-layout-recall-v1-6-b59b31caf342@samsung.com>
References: <20261006-nfsd-layout-recall-v1-0-b59b31caf342@samsung.com>
In-Reply-To: <20261006-nfsd-layout-recall-v1-0-b59b31caf342@samsung.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <bcodding@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1791260982; l=1856;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=COYpZ3SqMO2IRKw0SwEL7gpRX3/8u/hD6UzC74CWKOs=;
 b=5qcBM6K6w6wFM+qZQy3un3Voxb9MQBkUbamzRFy4ehI1RHFL4dcFr9uFQT58EEVfBTjQnu124
 xdekVhZ1y9KBtvbdIr5x1V32yzB4Kd13FRMU1toi7AyY2BpsK8P3H6z
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com

From: Daejun Park <daejun7.park@samsung.com>

nfsd4_cb_layout_done() fences the client for any answer to a
CB_LAYOUTRECALL that it does not handle, without looking at whether the
layout stateid still has layouts.  A LAYOUTRETURN can return the last
layout while the recall is still out.  The Linux client answers
NFS4ERR_NOMATCHING_LAYOUT then, which RFC 8881 section 20.3.3 allows
for a client that holds no layouts for the file.  A client that answers
NFS4ERR_BAD_STATEID is right too, since section 12.5.3 makes a layout
stateid invalid once the client has no layouts for the file, but it is
fenced for nothing.

Check for layouts before fencing, as the polls already do before their
time limit, and end the recall when none are left.  This does not depend
on the earlier patches in this series.

A pynfs client that returns its layout on the recall and then answers
it NFS4ERR_BAD_STATEID: without this patch, nfsd logged "failed to
respond to layout recall" and ran the fence for it; with it, the recall
ended without either.

Fixes: c5c707f96fc9 ("nfsd: implement pNFS layout recalls")

Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
 fs/nfsd/nfs4layouts.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index c140c9bde..345890add 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -803,6 +803,15 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
 		}
 		fallthrough;
 	default:
+		/*
+		 * Nothing to fence for once the layouts are gone: a
+		 * LAYOUTRETURN can return the last one while the recall is
+		 * still out.
+		 */
+		if (list_empty(&ls->ls_layouts)) {
+			trace_nfsd_layout_recall_done(&ls->ls_stid.sc_stateid);
+			return 1;
+		}
 		/*
 		 * Unknown error or non-responding client, we'll need to fence.
 		 */

-- 
2.43.0


