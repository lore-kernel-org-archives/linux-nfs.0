Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:39597 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269Ab3LMKDq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Dec 2013 05:03:46 -0500
Received: by mail-ee0-f46.google.com with SMTP id d49so757698eek.19
        for <linux-nfs@vger.kernel.org>; Fri, 13 Dec 2013 02:03:45 -0800 (PST)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH 1/2] nfsd4: break from inner lookup loop in nfsd4_release_lockowner on first match
Date: Fri, 13 Dec 2013 12:03:40 +0200
Message-Id: <1386929020-12578-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52AADAF6.40700@primarydata.com>
References: <52AADAF6.40700@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise the lockowner may by added to "matches" more than once.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0874998..84007b6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4660,6 +4660,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 			if (check_for_locks(stp->st_file, lo))
 				goto out;
 			list_add(&lo->lo_list, &matches);
+			break;
 		}
 	}
 	/* Clients probably won't expect us to return with some (but not all)
-- 
1.8.3.1

