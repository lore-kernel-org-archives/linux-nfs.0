Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.14.82]:56134 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757485Ab0FQTx0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 15:53:26 -0400
Subject: [PATCH] pnfsd: Add ability to clear pnfs dlm device ds list
From: Eric Anderle <eanderle@umich.edu>
Reply-To: eanderle@umich.edu
To: bhalevy@panasas.com
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Jun 2010 15:53:20 -0400
Message-ID: <1276804400.1796.8.camel@Berlin>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Added the ability to clear the pnfs dlm device ds list. Before, we
checked to make sure the list wasn't empty; this is accomplished by
examining the character after the ':' in the passed-in string. By
modifying this check, an empty list is considered valid, and everything
just works.

---
 fs/nfsd/nfs4pnfsdlm.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index 40f9b84..befec4f 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -160,17 +160,15 @@ nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device,
int len)
 
        err = -EINVAL;
        bufp += len + 1;
-       if (bufp >= endp)
+       if (bufp > endp)
                goto out_free;
 
        /* data server list */
-       /* FIXME: need to check for comma separated valid ip format */
        len = strcspn(bufp, ":");
        if (len > NFSD_DLM_DS_LIST_MAX)
                goto out_free;
        memcpy(new->ds_list, bufp, len);
 
-
        /*  validate the ips */
        if (!nfsd4_validate_pnfs_dlm_device(new->ds_list,
&(new->num_ds)))
                goto out_free;
-- 
1.7.0.4

