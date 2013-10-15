Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f173.google.com ([74.125.82.173]:58255 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206Ab3JOG6B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Oct 2013 02:58:01 -0400
Received: by mail-we0-f173.google.com with SMTP id u57so7943318wes.18
        for <linux-nfs@vger.kernel.org>; Mon, 14 Oct 2013 23:57:59 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH 1/2] nfsd: nfs4_open_delegation needs to remove_stid rather than unhash_stid
Date: Tue, 15 Oct 2013 09:57:55 +0300
Message-Id: <1381820275-14078-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <525CE711.1040107@primarydata.com>
References: <525CE711.1040107@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the out_free: path, the newly allocated stid must be removed rather
than unhashed so it can never be found.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 64c167f..b8f3c7e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3157,7 +3157,7 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_READ;
 	return;
 out_free:
-	unhash_stid(&dp->dl_stid);
+	remove_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 out_no_deleg:
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
-- 
1.8.3.1

