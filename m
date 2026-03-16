Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03C8E3A257E;
	Mon, 16 Mar 2026 18:28:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773685728; cv=none; b=XvznvbDtGqRmQuTvaColwz+CcvVXjTCl7whW43L1HQaOryiVffJu55XZcGL7yRiqnjedSU6psmDWaTPyC4WejqLajJ23wMp4rm0AEDNKTBKMUTx6mbHSS1bWzYhuYTRR/4NhFnZP1zmeluyBbXuW0GqhSR3W8JTFzwSxQleLTeQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773685728; c=relaxed/simple;
	bh=2JGaOQ+/5MbtItPoxYx8/+miveKJkF/K7tVtM+JJsnY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=S+eUfqzWpKkkH8gDxEUe5Z9mhOibZ1INnkudE5uu+zMB7f5FoRkFn860ZeIiTxiuIKoonhLVfdlCYl43Navrd829V7W+iO2nmR5jonW8RM13XrSbHCYjORu+aQq8QsickIh3gAONOCDgv4m5tqTAG2G7FfX6cIjHYu95CFLoSfE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 10D75C19421;
	Mon, 16 Mar 2026 18:28:47 +0000 (UTC)
From: Joseph Salisbury <joseph.salisbury@oracle.com>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] nfsd: fix comment typo in nfsxdr
Date: Mon, 16 Mar 2026 14:28:45 -0400
Message-ID: <20260316182845.155269-1-joseph.salisbury@oracle.com>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The file contains a spelling error in a source comment (occured).

Typos in comments reduce readability and make text searches less reliable
for developers and maintainers.

Replace 'occured' with 'occurred' in the affected comment. This is a
comment-only cleanup and does not change behavior.

Fixes: f5dcccd647da ("NFSD: Update the NFSv2 READDIR entry encoder to use struct xdr_stream")
Cc: stable@vger.kernel.org
Signed-off-by: Joseph Salisbury <joseph.salisbury@oracle.com>
---
 fs/nfsd/nfsxdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index fc262ceafca9..ae71e0621317 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -605,7 +605,7 @@ svcxdr_encode_entry_common(struct nfsd_readdirres *resp, const char *name,
  *
  * Return values:
  *   %0: Entry was successfully encoded.
- *   %-EINVAL: An encoding problem occured, secondary status code in resp->common.err
+ *   %-EINVAL: An encoding problem occurred, secondary status code in resp->common.err
  *
  * On exit, the following fields are updated:
  *   - resp->xdr
-- 
2.47.3

