Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:37886 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296AbaFMJdQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jun 2014 05:33:16 -0400
Received: by mail-pb0-f46.google.com with SMTP id md12so1163257pbc.19
        for <linux-nfs@vger.kernel.org>; Fri, 13 Jun 2014 02:33:15 -0700 (PDT)
Message-ID: <539AC53A.9070600@gmail.com>
Date: Fri, 13 Jun 2014 17:32:42 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH] NFSD: fix bug for readdir of pseudofs
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 561f0ed498ca (nfsd4: allow large readdirs) introduces a bug
about readdir the root of pseudofs.

Call xdr_truncate_encode() revert encoded name when skipping.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 53ca43c..30913c8 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2687,6 +2687,7 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
 		nfserr = nfserr_toosmall;
 		goto fail;
 	case nfserr_noent:
+		xdr_truncate_encode(xdr, start_offset);
 		goto skip_entry;
 	default:
 		/*
-- 
1.9.3

