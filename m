Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35548 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbbGIJie (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 05:38:34 -0400
Received: by pactm7 with SMTP id tm7so147894966pac.2
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jul 2015 02:38:34 -0700 (PDT)
Message-ID: <559E4112.3070902@gmail.com>
Date: Thu, 09 Jul 2015 17:38:26 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH v2] nfsd: Fix a file leak of ls_file if nfsd4_layout_setlease
 fail
References: <559672B7.4010802@gmail.com> <20150708213015.GG19084@fieldses.org> <20150709081239.GB19291@infradead.org> <559E3F68.6090205@gmail.com>
In-Reply-To: <559E3F68.6090205@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If nfsd4_layout_setlease fail, nfsd will not put ls->ls_file.

Fix commit c5c707f96f "nfsd: implement pNFS layout recalls".

v2, just put file using fput

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4layouts.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 6904213..ebf90e4 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -212,6 +212,7 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
 	BUG_ON(!ls->ls_file);
 
 	if (nfsd4_layout_setlease(ls)) {
+		fput(ls->ls_file);
 		put_nfs4_file(fp);
 		kmem_cache_free(nfs4_layout_stateid_cache, ls);
 		return NULL;
-- 
2.4.3

