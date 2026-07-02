Received: from mailgw.kylinos.cn (mailgw.kylinos.cn [124.126.103.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B4E529B79B;
	Thu,  2 Jul 2026 01:50:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=124.126.103.232
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782957026; cv=none; b=USWmWg28IRHiM7O04fWLi6drrkKr2CBRdMC2CoiRS5HkzxX5Ga/SoOdRcBC79C+InMtuBNwUdhUrfJOdZo+GAoe3OzLi2HIeF5fvZIMmwqs9LNn/BeF4h8442ZKJeH2FxAsNf+zKh4dm50gbI3izkB0AIj/UFdO0mUZa9LWOsxE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782957026; c=relaxed/simple;
	bh=EYK5gGhf2WCP8XECD+MQ+3RLd6xkWWgez07E0AmpYHk=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=I5U2NFisgQecYhAdumbzQtxnXHvQG2qgMNLZqpWi94oY3Q/B6WICsB9IWridjImK8hIuUsGE7lOxvOpKid6NBHbIYT/nxPb2Ou7rUIDVsTSZ7hLqgS4eVJqjb1+zYe04TFDSm5hgRYXDPFy2NAn4ftNqG0IVit8u9pmxZZHIoSQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn; spf=pass smtp.mailfrom=kylinos.cn; arc=none smtp.client-ip=124.126.103.232
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kylinos.cn
X-UUID: 610a885475b811f1aa26b74ffac11d73-20260702
X-CID-P-RULE: Release_Ham
X-CID-O-INFO: VERSION:1.3.12,REQID:0130af7c-4e88-4dcc-9800-a4894c0a2bf4,IP:0,U
	RL:0,TC:0,Content:0,EDM:25,RT:0,SF:0,FILE:0,BULK:0,RULE:Release_Ham,ACTION
	:release,TS:25
X-CID-META: VersionHash:e7bac3a,CLOUDID:04db85e218a4687316c40f98d044e792,BulkI
	D:nil,BulkQuantity:0,Recheck:0,SF:102|136|850|865|898,TC:nil,Content:0|15|
	50,EDM:5,IP:nil,URL:0,File:nil,RT:nil,Bulk:nil,QS:nil,BEC:nil,COL:0,OSI:0,
	OSA:0,AV:0,LES:1,SPR:NO,DKR:0,DKP:0,BRR:0,BRE:0,ARC:0
X-CID-BVR: 2,SSN|SDN
X-CID-BAS: 2,SSN|SDN,0,_
X-CID-FACTOR: TF_CID_SPAM_SNR
X-CID-RHF: D41D8CD98F00B204E9800998ECF8427E
X-UUID: 610a885475b811f1aa26b74ffac11d73-20260702
X-User: yijiangshan@kylinos.cn
Received: from localhost.localdomain [(10.44.16.150)] by mailgw.kylinos.cn
	(envelope-from <yijiangshan@kylinos.cn>)
	(Generic MTA with TLSv1.3 TLS_AES_256_GCM_SHA384 256/256)
	with ESMTP id 1213473515; Thu, 02 Jul 2026 09:50:18 +0800
From: Jiangshan Yi <yijiangshan@kylinos.cn>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: gregkh@linuxfoundation.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	13667453960@163.com,
	Jiangshan Yi <yijiangshan@kylinos.cn>
Subject: [PATCH] NFS: fix folio dereference before NULL check in nfs_inode_remove_request()
Date: Thu,  2 Jul 2026 09:50:14 +0800
Message-Id: <20260702015014.192357-1-yijiangshan@kylinos.cn>
X-Mailer: git-send-email 2.25.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfs_inode_remove_request() obtains the folio for the head request via
nfs_page_to_folio(), which returns NULL when the PG_FOLIO flag is not
set on req->wb_head.

The presence of the "if (likely(folio))" check shows the code already
assumes folio can be NULL. However, folio was dereferenced before that
check:

        folio = nfs_page_to_folio(req->wb_head);
        mapping = folio->mapping;                       /* deref */

        spin_lock(&mapping->i_private_lock);
        if (likely(folio)) {                            /* too late */

folio->mapping is read (and mapping->i_private_lock is taken, and
folio_end_dropbehind(folio) is called outside the check) before folio
is validated, so a NULL folio would crash before the guard is ever
reached, rendering the check useless.

Move the folio->mapping read, the i_private_lock section and the
folio_end_dropbehind() call inside the "if (likely(folio))" block so
the folio is only dereferenced after it has been confirmed non-NULL.
The behaviour is unchanged when folio is non-NULL.

Signed-off-by: Jiangshan Yi <yijiangshan@kylinos.cn>
---
 fs/nfs/write.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index fcffb8c9e9df..33d51eb9a3a4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -739,17 +739,18 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 	nfs_page_group_lock(req);
 	if (nfs_page_group_sync_on_bit_locked(req, PG_REMOVE)) {
 		struct folio *folio = nfs_page_to_folio(req->wb_head);
-		struct address_space *mapping = folio->mapping;
 
-		spin_lock(&mapping->i_private_lock);
 		if (likely(folio)) {
+			struct address_space *mapping = folio->mapping;
+
+			spin_lock(&mapping->i_private_lock);
 			folio->private = NULL;
 			folio_clear_private(folio);
 			clear_bit(PG_MAPPED, &req->wb_head->wb_flags);
-		}
-		spin_unlock(&mapping->i_private_lock);
+			spin_unlock(&mapping->i_private_lock);
 
-		folio_end_dropbehind(folio);
+			folio_end_dropbehind(folio);
+		}
 	}
 	nfs_page_group_unlock(req);
 
-- 
2.25.1

