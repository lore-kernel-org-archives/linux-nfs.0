Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 958BF379C23;
	Thu, 15 Oct 2026 04:15:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792037744; cv=none; b=KTRm/2/OuBBoBleGqtFxJG4gGJ0zFmOLuZxsjDNW544/aM+TiZDopMxYQpp8n0WVzZkJ6HhPCVXV9b4/sArEVmd813fA0WGvpgfiEk2T3FcGPzwHh+wn4UKlHEg/FARVqo8R6STEI9l9HtZq+XOyXkqGKNrYGA2OgRdujmomjhA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792037744; c=relaxed/simple;
	bh=GJpwNjhTaY3AtuQAN3gF3+j/lhrAkAA5NemuQfT1MNE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=rGdKc8b8sxB8zBuV281Fdn8qXHg1c+BQMY2Z3Cx3NcyPVf6fd1ELjWqqqQo+r+1lV8Xm7nHKIbf35CxGiQ9IQc35zKAUP95vNEY/lUdyVDyp/PZ4DJIKrzdgQLJtZqFQj6ZyZSHoVfRkIrhiFy3jHUL+R+hqTtKL91SvEx92t4g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dhaQj5vF; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dhaQj5vF"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 68AFDC2BCC7;
	Thu, 15 Oct 2026 04:15:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1792037744;
	bh=GJpwNjhTaY3AtuQAN3gF3+j/lhrAkAA5NemuQfT1MNE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=dhaQj5vFWbhWWY/0WkSxSTJasE3oUZdlsOnXoDPVzl33Xixq6Lrm7pfd5rFmjdCCR
	 b2tKbqhtvPFwebriAsvKuzU/5JHl9qdQdg0nzq/PrWABn45eYkJ6Q3Ux0PtqAnWiRa
	 kjb5TUnTijpXmCzu8/oaUoQXor+nLO8KEwdIt6dxcMic8EPWf+rsriNvsbYafwFZVK
	 Jou9uxtZZGJMCE/S+8jZDrjXTjbof089LwSUhHtLZIsRM6MEBLYi7xGZtiXwUnPJzm
	 KSAhGDkaJjnAwy8QyLhKZsm/J4eJNYwCmkwQtLOEIr2LB39kGiaxUa/2YsMo/ChBbx
	 XUnONBWrwKgHg==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55B79CC6B2F;
	Thu, 15 Oct 2026 04:15:44 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Thu, 15 Oct 2026 13:15:48 +0900
Subject: [PATCH v3 7/7] nfsd: do not fence a client for a layout recall
 with no layouts left
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261015-nfsd-layout-recall-v3-7-ba3269f8ca22@samsung.com>
References: <20261015-nfsd-layout-recall-v3-0-ba3269f8ca22@samsung.com>
In-Reply-To: <20261015-nfsd-layout-recall-v3-0-ba3269f8ca22@samsung.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <bcodding@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1792037741; l=1899;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=6GiEVewxuMZ81xHHgGV1yJUzVmA4yZmiSrM8AvX15L4=;
 b=quInCAPucFSkzXgvcKHjmuHkMVGE21JPo5cPtiXOujhHQNkGfkrWU/RLywj3PWbjNPZgSJd+R
 qlBbYzdA4RwAZBIfW3oXQrpEuyfQtCgduaJoEhJCDHUHzzDLPvcUSue
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com

From: Daejun Park <daejun7.park@samsung.com>

nfsd4_cb_layout_done() fences the client for any answer to a
CB_LAYOUTRECALL that it does not handle, without looking at whether the
layout stateid still has layouts. A LAYOUTRETURN can return the last
layout while the recall is still out. The Linux client answers
NFS4ERR_NOMATCHING_LAYOUT then, which RFC 8881 section 20.3.3 allows
for a client that holds no layouts for the file. A client that answers
NFS4ERR_BAD_STATEID is right too, since section 12.5.3 makes a layout
stateid invalid once the client has no layouts for the file, but it is
fenced for nothing.

Check for layouts before fencing, as the polls already do before their
time limit, and end the recall when none are left. This does not depend
on the earlier patches in this series.

A pynfs client that returns its layout on the recall and then answers
it NFS4ERR_BAD_STATEID: without this patch, nfsd logged "failed to
respond to layout recall" and ran the fence for it; with it, the recall
ended without either.

Fixes: c5c707f96fc9 ("nfsd: implement pNFS layout recalls")
Signed-off-by: Daejun Park <daejun7.park@samsung.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4layouts.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index a6934fc21a..e0eb668ca9 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -977,6 +977,15 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
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


