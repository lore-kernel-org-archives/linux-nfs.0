Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA7A63438AF
	for <linux-nfs@vger.kernel.org>; Tue, 11 Aug 2026 19:52:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786477936; cv=none; b=bjjGLOIIqK5JKg8m//s9S7zWLuR1Ep5LBg6HmhD01yg/QLVQbA9uKNdDz6tRfD9uxtGT6vmlP8PgHEX3BjK1yIn4qHkUQcdo5nwDNFBfmgq7KRKj96pnOfrrk314XIrPl6svHvNgHCTJnj9vfUys3gd5ytuaTlAkLIszhret7fA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786477936; c=relaxed/simple;
	bh=VUjHI6PchYG7x/QRhXZGQzAHxFL9hkUIsXWxXPoNHtQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=uO6iwRSViEqiofCU0vDZrl7d3Rt2ge5GH4EDQlEi/15iZadWz4aCC9kjNJHwjPuD0DnWBOkUllsmO92R9rBKem2LTTGo8qsuPhyh4OAowDqXaVbKNGO9gmOOO9MRk5FZaXlYMOihskDQAtsskwYxtrhBmjmyRrzgSJIW5moAz5U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NVJMTVzM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NVJMTVzM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 379B91F00A3A;
	Tue, 11 Aug 2026 19:52:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786477934;
	bh=puZnyjClaEToaZ/1aK2I1QuHnYOC/NEpG3CTNGRBQv8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NVJMTVzMOjZBAPCGp4ZqWIsDTrNb8LWEwq4x41ARECACZuh5tSPKyHR7olB/rKjAE
	 /wjv7rFB5Po2bOQfegE2ZJXORwbgRBiew2nDyF3MvdnU08Bg1mZXyZjCby/XDVvHjY
	 W6xhwFWXN2jEQek26ECgKCgg8bijIDvOufs/bNs3pByxQxsTikep+q/0WVRRfi+nrr
	 HlE3rQykHD2nCI6LF1XcA2WFS4dc94tpRiFekEirKosf+7BabjSWlOWWM/Jk5dElw5
	 EKdRCXKv+YMau0FB8IgyOYSn3+f69GM7aujJptXOwZEq1ZUbzrBIuwMAqWNh953oCQ
	 HycazKYfXEjCg==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 11 Aug 2026 15:52:02 -0400
Subject: [PATCH 1/4] NFSD: Do not send CB_RECALL_ANY to NFSv4.0 clients
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260811-recall-any-keep-count-v1-1-de9ca00493b7@kernel.org>
References: <20260811-recall-any-keep-count-v1-0-de9ca00493b7@kernel.org>
In-Reply-To: <20260811-recall-any-keep-count-v1-0-de9ca00493b7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1573; i=cel@kernel.org;
 h=from:subject:message-id; bh=VUjHI6PchYG7x/QRhXZGQzAHxFL9hkUIsXWxXPoNHtQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqe31si7wV/FpBq9n8Du0KIiJgh0ChULxHEr+ph
 2t9MYreScOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCant9bAAKCRAzarMzb2Z/
 l9Z/D/99kBLdILJdFpU6hgl07TKjdBt8CL9uV0s2j9KOQ/itfoxyQJ4nCed4adCnC8m2+AoyrXk
 BT1fHhOUUMhjIjtklsTrxOMAXZXMtIHwz8KhH40XTuX9n/zsKu9lpQyUyXVP1edBD/ImnZcLJ30
 hytnP9NRo+6ZEJuKGjPvbnS08lLZnseItIVgfscIIifvxUvcursL87YPl0gt6TE3vzb7URfUPsD
 WfEQqenXkVKTackcLS1BKWJytS1oocQL5hVAz7FrWpfpQNmiLnzhINOQr5KvRjjjghT3QSLWdl1
 vhyuDHXqot6oDlCjxWE8Rvs8vCtjsv/nbsRM1sD9O85BHsREr5IBib5ImYneNevw+5Yeps8M5l+
 N10gAzs7GvpUyVxtJ8JhUU3XV78aipwB1VTOO1CPHPDnnE45aM3ZwXvr8+UvACX60ZB/HTHBGK8
 Up/wWGv1sEXs8TZo9/WKc/v2bdki9J0nlpaCMLdk4G6HLymtf0QTE54g8yC3wQgHMWl+24usGbC
 tcfM3d10LhrYxuTMD7i092nAd0y9iRYdsqt280KRhsWgBa4W7A18z4fSuyR3DnV9heG5TVuQEVN
 Cdl3O7f7c7M3D0zWeMFBGxXqNDHsCF6pbfDx6jjJ5YOlLPCurWvL7V/Rdy2pM/6zWp0xivGwnIh
 fv4M4+wUiY8AZCw==
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

