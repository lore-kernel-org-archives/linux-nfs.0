Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:39040 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078Ab3IZSlA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:00 -0400
Received: by mail-qc0-f181.google.com with SMTP id q4so1026439qcx.40
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:40:59 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 16/49] pnfsd: accept all ds stateids
Date: Thu, 26 Sep 2013 14:40:57 -0400
Message-Id: <1380220857-13416-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Until a stateid protocol is implemented, remove all checking on
file layout data server stateids.

These are idetified by the current fh type.

Signed-off-by: Andy Adamson <andros@netapp.com>
[remove #ifdef around pnfs_fh_is_ds]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2c973e6..b80807c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3648,6 +3648,9 @@ static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
 	if (grace_disallows_io(net, ino))
 		return nfserr_grace;
 
+	if (pnfs_fh_is_ds(&current_fh->fh_handle))
+		return 0;
+
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return check_special_stateids(net, current_fh, stateid, flags);
 
-- 
1.8.3.1

