Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3A1E84570FC;
	Tue,  4 Aug 2026 10:55:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785840928; cv=none; b=qVW4t9dV1b5QZ6tSbNPo61eNl6JNaw7GojlUgJIHFOqwuHGaBjJEyQljx+Dmz0Ca7wgtuxRzxxBsPKd+YpkscJfodjPeH8RpvEpnhCSEyUMZ4yhabFAEfzfWWsqyenYXOLRI1PHiCn9+Worefd4qeDLKgZ8VHdLJ9MIUdL5zFEs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785840928; c=relaxed/simple;
	bh=F5f9S39Wy5yR44QpT3JsOfQLfBe7Y4KOQV1Mv0uzWcc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=lYosmiWHKgf2zlEyKJ9+jWBxf5Gay+K4wG5slD4ecC1xdRXNm/R2rToG2QePwWkvmg0BmUywaJPJE9e1OjCZiUkMcNMFAdRjoQJ4X81bO/ng+N/cCrCMTC1xfQjWlFRKdJ9pLnsrkD9Ycz1SMDdfzDqJwZqqc89OtdGB9lDmrv0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Pxj1O5m4; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Pxj1O5m4"
Received: by smtp.kernel.org (Postfix) with ESMTPS id B7347C2BCF7;
	Tue,  4 Aug 2026 10:55:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1785840926;
	bh=F5f9S39Wy5yR44QpT3JsOfQLfBe7Y4KOQV1Mv0uzWcc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=Pxj1O5m4o+B+CZ8KocW19ZBCc9n2vT0kdfG+JX65kafkEJc526R7zM5XPVgySQldy
	 7j5YT/eGufVNM2yrW3/jW5cCZv8bZn/cUoYd6p+No/pmrUvFva71C3hb8wpTLZ8oE0
	 3NLxILT0h0H+CF8/d6ny/R6PDS5TfmCbSmfWjicYXghV5y9nD/Z1t7qOhkqwgLTvHp
	 JbcEV9wenRx+tEcHBfvBRV52MXRUozNjjjR5LJWnGgV4CHEpQk3DLG/ivGdhiG9IM4
	 7NgoJ38R0qaPTxbc8ihP1cEdb2rUnZ5s+XFy6IQMJAoVAy069eMg5YQtifR81FDu3J
	 Mv2rxc+nGCuaQ==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96AC1C5518F;
	Tue,  4 Aug 2026 10:55:26 +0000 (UTC)
From: Junrui Luo via B4 Relay <devnull+moonafterrain.outlook.com@kernel.org>
Date: Tue, 04 Aug 2026 18:55:02 +0800
Subject: [PATCH 2/5] NFSv4/flexfiles: fix da_netid leak in
 nfs4_ff_alloc_deviceid_node()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260804-nfs-fixes-v1-2-1544df970e7c@outlook.com>
References: <20260804-nfs-fixes-v1-0-1544df970e7c@outlook.com>
In-Reply-To: <20260804-nfs-fixes-v1-0-1544df970e7c@outlook.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jonathan Curley <jcurley@purestorage.com>, 
 Michael Bommarito <michael.bommarito@gmail.com>, 
 Junrui Luo <moonafterrain@outlook.com>, Yuhao Jiang <danisjiang@gmail.com>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1642;
 i=moonafterrain@outlook.com; h=from:subject:message-id;
 bh=Js0koCYPuEad0TbgAqXuAe69HQlQTlIjrIH4OepFPu4=;
 b=owJ4nJvAy8zAJVb4wiKgu++DA+NptSSGrMKjMoU1QradKx7FHXlzc98DHi5PE/8DPLd2b5I5u
 EvuYavDy+cdpSwMYlwMsmKKLMcLLn2z8N2iu8VnSzLMHFYmkCEMXJwCMBHPRQz/Yy69X7nKIUnY
 1NOx8lB74sJl29VirrOmOjo8K3FIq/L9wMhw7NK72JU+4Y+nFXX7807bvO3EGYdp0978vyrlezt
 ZSJeTBwBJH0zC
X-Developer-Key: i=moonafterrain@outlook.com; a=openpgp;
 fpr=C770D2F6384DB42DB44CB46371E838508B8EF040
X-Endpoint-Received: by B4 Relay for moonafterrain@outlook.com/default with
 auth_id=909
X-Original-From: Junrui Luo <moonafterrain@outlook.com>
Reply-To: moonafterrain@outlook.com

From: Junrui Luo <moonafterrain@outlook.com>

nfs4_decode_mp_ds_addr() allocates the r_netid string and hands ownership
to the nfs4_pnfs_ds_addr it returns. Both loops in
nfs4_ff_alloc_deviceid_node() that drain the local dsaddrs list free only
da_remotestr and the da itself, so the netid is leaked.

The success-path loop runs when nfs4_pnfs_ds_add() finds an equivalent
data server already cached and leaves the caller's list intact; the
out_err_drain_dsaddrs loop runs on every late failure in the function.

da_remotestr and da_netid are the only heap pointers in the structure, so
free both, as nfs4_pnfs_ds_addr_free() does.

Fixes: 4be78d26810b ("NFSv4/pNFS: Store the transport type in struct nfs4_pnfs_ds_addr")
Reported-by: Yuhao Jiang <danisjiang@gmail.com>
Assisted-by: Claude:claude-opus-5
Signed-off-by: Junrui Luo <moonafterrain@outlook.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 659a2bf7b502..98d464f402d5 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -169,6 +169,7 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 				      da_node);
 		list_del_init(&da->da_node);
 		kfree(da->da_remotestr);
+		kfree(da->da_netid);
 		kfree(da);
 	}
 
@@ -181,6 +182,7 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 				      da_node);
 		list_del_init(&da->da_node);
 		kfree(da->da_remotestr);
+		kfree(da->da_netid);
 		kfree(da);
 	}
 

-- 
2.51.2


