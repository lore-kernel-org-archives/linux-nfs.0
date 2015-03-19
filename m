Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36290 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbbCSLEZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Mar 2015 07:04:25 -0400
Received: by padcy3 with SMTP id cy3so72532370pad.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Mar 2015 04:04:24 -0700 (PDT)
Message-ID: <550AAD2E.6040607@gmail.com>
Date: Thu, 19 Mar 2015 19:04:14 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: [PATCH] NFSD: Check layout type when returning client layouts
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to RFC5661:
" When lr_returntype is LAYOUTRETURN4_FSID, the current filehandle is used
   to identify the file system and all layouts matching the client ID,
   the fsid of the file system, lora_layout_type, and lora_iomode are
   returned.  When lr_returntype is LAYOUTRETURN4_ALL, all layouts
   matching the client ID, lora_layout_type, and lora_iomode are
   returned and the current filehandle is not used. "

When returning client layouts, always check layout type.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4layouts.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 3c1bfa1..44341d6 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -513,6 +513,9 @@ nfsd4_return_client_layouts(struct svc_rqst *rqstp,
 
 	spin_lock(&clp->cl_lock);
 	list_for_each_entry_safe(ls, n, &clp->cl_lo_states, ls_perclnt) {
+		if (ls->ls_layout_type != lrp->lr_layout_type)
+			continue;
+
 		if (lrp->lr_return_type == RETURN_FSID &&
 		    !fh_fsid_match(&ls->ls_stid.sc_file->fi_fhandle,
 				   &cstate->current_fh.fh_handle))
-- 
2.3.3

