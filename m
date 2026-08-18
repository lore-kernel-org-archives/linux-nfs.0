Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2784721CC5C
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 01:08:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787015328; cv=none; b=q9JCYEkRus1tX0nzcNihMs2o2jT6oqtuLW8jbUQy1lWMdGB7Ee5MRYw/gRAA6/eFNE8DOpPbxJubd3x2DKVG+wm6/GQQx1O8f4++5ZtmEsZI1QofJQFROydmzE3IaeaLjc41QV9T6H9bW4DKKt2Biz3r4ExABvHqZAS/sxf+E6w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787015328; c=relaxed/simple;
	bh=iPCK4/YTsV0TsVhCmS38MPizZH63LFGZrrCi7j3/Vkc=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=RG2AgVUIRUl5wlVoe+CI3xpPMzswO5QaQE1EOEtSs861RK8Yu55xQbzbl+zCFfU/qdlGAJlFqjlca12cGh0Oldo47U+s9GeVA/1u/D7D+7uw9AERDk7Z9vDyPp+gZm1fE2bLk5Qrtwrm72SR3O7pws9qaEcwpIfSI3uCip8cepM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SEN678yq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SEN678yq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 335D31F000E9;
	Tue, 18 Aug 2026 01:08:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787015326;
	bh=c9RdbR45Vr+B2+MSIt8tX0MuCG2ZoqM+kDztQicrcZM=;
	h=From:Subject:Date:To:Cc;
	b=SEN678yqRXqA1cGlAM+mx0mxnAPbJQ8ySDmd+13BduLS9+L1qrl78rcBlEZ7vhoDc
	 TnxGJkfq0k3YhwQ3DosV1PIdE0xGrXd0OWJb83JeXsdgzMpX+56u/1gjj+sud1nxRf
	 yEW2YZwUFReq/Y8xjuWhNjm5omFLp97MnGq+J26876O1rzj61+G/eDXm27MGdh5Umt
	 U3LPdgkav4BOJTNm2+h2z86PPOdk3p2HYt/hVKu050pJpDXlXc3GlaP00NM7nW/0Ub
	 8ps8fnD0f91gTxQSb2eTIaw/NVrzosL89vNTHlRB1yaeKqdbh/UyU9ihPQgVCNcB1E
	 LCnpZPvsZYM5Q==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v5 0/8] NFSD: CB_RECALL_ANY fixes and a meaningful keep
 count
Date: Mon, 17 Aug 2026 21:08:35 -0400
Message-Id: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3XOTW7DIBAF4KtErEvLnx07q96j6gKGwaaxcATEa
 hT57oVUlVxFXr7Rm0/vThJGj4mcDncScfHJz6GE5uVAYNRhQOptyUQw0bKOMxoR9DRRHW70jHi
 hMF9Dpq5hIDRyc+wFKb+XiM5/P9yPz9+cruYLIVesNoxOSE3UAcZ6ApzegkuWZkzZh6FWRp/yH
 G+PbQuv1N8MvjNj4ZRRiz1oxlQvzfH9jDHg9DrHgdQdi9gyYo8RhdGdcAq0kKX3xMgtI/cYWZm
 +tUJJYIbLJ0ZtmWaPUYUxzjSmk7YFw/8x67r+AGilN5LFAQAA
X-Change-ID: 20260810-recall-any-keep-count-f50c2ae1b792
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3234; i=cel@kernel.org;
 h=from:subject:message-id; bh=iPCK4/YTsV0TsVhCmS38MPizZH63LFGZrrCi7j3/Vkc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqg7CWd3EHjYVLAuP6eOx3rqn/VoMGu+Poklv1o
 ZjvLWcWoQ+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoOwlgAKCRAzarMzb2Z/
 lx2vD/98l3GGPk1/A5frR8pzvksqPP9Q+1v2PcMlRQsG7SdT0J43k1La1LzF3PR21qXuHACck9H
 xlQdzgPxso/TQi1Zva9xdtQK+RjNuZ2i8s9C8nAabHwe3WkHK8M7+4kSfd3latgLHFdLBBId+p+
 oNJIcQ+crqosevxKdqYH5Ta1OIatSDAPPzuPOZ8hghHSaEHSv5nm7PegcVMPuv6PnldWv/KD3vQ
 s3yBGa4ZCK11RWRN2Cm3MCjm6RjlqBI6hNTobEp28QQQAJczB3SPY1+EImXutfYZWkp5hVyFM8j
 eoCvt8jYZfBiEARz92xN+TudAfOUqPbVRrK9kg0ozZ2Vk8bHkwSazJCxID8w98qVloIPQEgxadS
 S2kWixRuuhNOQUWG1aGBJI8MHZJfNzi0WBODcAFW+rqdfPRrUxXQRmOzbcgK0A89OW93A6gk4Ed
 YUW8IazgXt83SN0cb79/8nNmKjssQUkNEQ6QNkNJCl7oVI0yfNJExihO2d+wENTLS6I+ZGYIAjv
 EHDm4Pipg0IsDbpGv+7rtqFs4TJKC9cCjFSq1texy05qU88PZenSkNOF6Ic2iogOEqaakbd+Q2c
 tooTVuf4Qht2bEL/mi96AikfHAnHNAtPjSVurs+tilOVc+TxjZbCQiprgoM8QjaDbleCSUuDVjC
 mGTOM4vLEMNNaDQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFSD currently sends every CB_RECALL_ANY with craa_objects_to_keep
set to zero, as RFC 8881 Section 20.6.3 does not mandate any
particular way for a client to choose which delegations to return,
if any.

NFSD intends CB_RECALL_ANY only as a signal to return currently
unused delegations. To date, only the Linux NFS client has been
deeply tested against it. That implementation ignores the
craa_objects_to_keep value and returns only one unused delegation
of the named types. Therefore the fixed zero craa_objects_to_keep
value never produced visible misbehavior during our testing.

However, a zero value can result in non-Linux clients giving back
more delegations than is necessary to relieve temporary memory
pressure on the server, which needlessly punctures the clients'
delegation working set.

Change NFSD so that each CB_RECALL_ANY asks a client to give up a
sensible number of delegations instead of all of them at once. To
handle the accounting correctly, it is necessary for this series to
split the current state shrinker mechanism. The patch descriptions
have those details.

---
Changes in v5:
- Exclude clients the sweep skips from the apportionment's divisor.
- Skip clients whose CB_RECALL_ANY callback is still running.
- Discount the delegation shrinker's count by its pending requests.
- Link to v4: https://patch.msgid.link/20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org

Changes in v4:
- Avoid a divide by zero when max_delegations is zero.
- Collect Jeff's Reviewed-by on 5-8, given on the v3 posting.
- Link to v3: https://patch.msgid.link/20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org

Changes in v3:
- Count delegations per namespace so each shrinker reports its own.
- Give courtesy clients and delegations separate state shrinkers.
- Record the shrinker's scan requests and discount the count by them.
- Scale each client's CB_RECALL_ANY by its share of the scan request.
- Reword the keep-count rationale in the commit message and comment.
- Link to v2: https://patch.msgid.link/20260812-recall-any-keep-count-v2-0-a82f4ca23812@kernel.org

Changes in v2:
- Drop the gate that skipped clients holding a single delegation.
- Cover letter rewritten to give performance rationale.
- Link to v1: https://patch.msgid.link/20260811-recall-any-keep-count-v1-0-de9ca00493b7@kernel.org

---
Chuck Lever (8):
      NFSD: Do not send CB_RECALL_ANY to NFSv4.0 clients
      NFSD: Count the delegations held by each client
      NFSD: Name directory delegations in the CB_RECALL_ANY type mask
      NFSD: Send a meaningful CB_RECALL_ANY keep count
      NFSD: Count delegations per network namespace
      NFSD: Give delegations their own state shrinker
      NFSD: Pace the state shrinker's scan requests
      NFSD: Apportion CB_RECALL_ANY recalls among clients

 fs/nfsd/netns.h     |  17 +++-
 fs/nfsd/nfs4state.c | 285 +++++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/state.h     |   2 +
 3 files changed, 267 insertions(+), 37 deletions(-)
---
base-commit: de7051270554f99559f9b6bcf3c4fb695c7c223d
change-id: 20260810-recall-any-keep-count-f50c2ae1b792

Best regards,
--  
Chuck Lever <cel@kernel.org>

