Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C086122F388
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 22:45:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791499553; cv=none; b=VUmwZ7lmiWx6+hJiALjsHQicBYlTjp+8LpILj4lk77/7+D/eizxBV0kXx+137D9ASVyyC0l8YgUxaoJH5VHBPweD/PvPoh8B/3Au1x7mxS1EzB6YXXwofylZAdxakq9SONEZvSCCZldHJlSkfDXzokAitISd1Xzfrq7xJaMNJ3Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791499553; c=relaxed/simple;
	bh=0d35gT4RrZiugAo+jk8OP3H/Z6Z+k3mCbF5WkR7nang=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=pqZw2Zas0N/iOqia4wIb+96mDZFxmp2jTKZ1kYPLmVRwd1QNQ1aULhl66j53VVBKyvGPVfin5IpNCaYafIUqrEFr547cQxoMySPfQygDpUHOmkmjb4mZOiIlLe/PTeVhEbGgsHHk6W0vGG9JOS2F4kUrZmqqzuDpq+W3MUcbYiE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Received: from kunlun.suse.cz (unknown [IPv6:2a07:de40:b306:2000::2])
	by smtp-out1.suse.de (Postfix) with ESMTP id AFAEA21BB3;
	Thu,  8 Oct 2026 22:45:49 +0000 (UTC)
Authentication-Results: smtp-out1.suse.de;
	none
From: Anthony Iliopoulos <ailiop@suse.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4/flexfiles: fix infinite retry loop on data server version mismatch
Date: Fri,  9 Oct 2026 00:45:44 +0200
Message-ID: <20261008224544.79469-1-ailiop@suse.com>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Rspamd-Pre-Result: action=no action;
	module=Unknown lua;
	unknown reason
X-Spam-Flag: NO
X-Spamd-Bar: /
X-Rspamd-Queue-Id: AFAEA21BB3
X-Rspamd-Pre-Result: action=no action;
	module=Unknown lua;
	unknown reason
X-Rspamd-Action: no action
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Spam-Level: 
X-Spamd-Result: default: False [0.00 / 50.00]
X-Spam-Score: 0.00

When a flexfiles layout disallows fallback to the MDS via
FF_FLAGS_NO_IO_THRU_MDS and sets the ffdv_version in GETDEVINFO response
to NFSv3, it can cause an infinite retry loop in the client when the
server is not configured to handle NFSv3 protocol connections.

Specifically, the server will return a PROG_MISMATCH RPC along with the
minimum protocol version supported, and the client will keep retrying as
the EPROTONOSUPPORT error is not currently handled as a fatal error.  At
the same time the client is not allowed to fallback to the MDS where it
could proceed with NFSv4.

Given that a DS version mismatch is usually a permanent error, it makes
little sense to keep retrying. Fix this by explicitly checking for the
specific error, return immediately when the MDS fallback is disabled,
and allow an error to be propagated back to user space.

Signed-off-by: Anthony Iliopoulos <ailiop@suse.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7fe8b91fa47c..52018039c9a4 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1060,6 +1060,11 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	if (IS_ERR(ds)) {
 		if (!ff_layout_no_fallback_to_mds(pgio->pg_lseg))
 			goto out_mds;
+		if (PTR_ERR(ds) == -EPROTONOSUPPORT) {
+			pgio->pg_error = -EIO;
+			pnfs_generic_pg_cleanup(pgio);
+			return;
+		}
 		pnfs_generic_pg_cleanup(pgio);
 		/* Sleep for 1 second before retrying */
 		ssleep(1);
@@ -1139,6 +1144,11 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 		if (IS_ERR(ds)) {
 			if (!ff_layout_no_fallback_to_mds(pgio->pg_lseg))
 				goto out_mds;
+			if (PTR_ERR(ds) == -EPROTONOSUPPORT) {
+				pgio->pg_error = -EIO;
+				pnfs_generic_pg_cleanup(pgio);
+				return;
+			}
 			pnfs_generic_pg_cleanup(pgio);
 			/* Sleep for 1 second before retrying */
 			ssleep(1);
-- 
2.55.0

