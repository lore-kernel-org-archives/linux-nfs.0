Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33539 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbbCTH4y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Mar 2015 03:56:54 -0400
Received: by pabxg6 with SMTP id xg6so88666352pab.0
        for <linux-nfs@vger.kernel.org>; Fri, 20 Mar 2015 00:56:54 -0700 (PDT)
Message-ID: <550BD2B8.6070900@gmail.com>
Date: Fri, 20 Mar 2015 15:56:40 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>
CC: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@sandeen.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>, xfs@oss.sgi.com
Subject: [PATCH] NFSD: Fix infinite loop in nfsd4_cb_layout_fail()
References: <20150304020826.GD19439@fieldses.org> <20150304155421.GE1627@fieldses.org> <20150304220900.GX18360@dastard> <20150304222709.GI1627@fieldses.org> <20150304224557.GY4251@dastard> <54F78BE5.1020608@sandeen.net> <20150304225623.GZ4251@dastard> <20150305040849.GJ1627@fieldses.org> <20150305131731.GA16235@lst.de> <CAB6yy341fvF8Bsg0_hViQm+zRLVdJ2WOE9duDwdU+S0CkOEpbg@mail.gmail.com> <20150320065010.GC626@lst.de>
In-Reply-To: <20150320065010.GC626@lst.de>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix commit 31ef83dc05 (nfsd: add trace events)'s typo 
causing a infinite loop when callback layout fail.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4layouts.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 3c1bfa1..0a616b5 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -587,7 +587,7 @@ nfsd4_cb_layout_fail(struct nfs4_layout_stateid *ls)
 
 	rpc_ntop((struct sockaddr *)&clp->cl_addr, addr_str, sizeof(addr_str));
 
-	nfsd4_cb_layout_fail(ls);
+	trace_layout_recall_fail(&ls->ls_stid.sc_stateid);
 
 	printk(KERN_WARNING
 		"nfsd: client %s failed to respond to layout recall. "
-- 
2.3.3

