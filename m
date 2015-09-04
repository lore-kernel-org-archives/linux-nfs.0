Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:2138 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932892AbbIDRaG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 13:30:06 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Olga Kornievskaia <kolga@netapp.com>
Subject: [PATCH Version 2 14/16] NFS in copy use stateid returned by copy_notify
Date: Fri, 4 Sep 2015 13:29:36 -0400
Message-ID: <1441387778-16465-15-git-send-email-andros@netapp.com>
In-Reply-To: <1441387778-16465-1-git-send-email-andros@netapp.com>
References: <1441387778-16465-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <kolga@netapp.com>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 42cab7e..e33734d 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -191,15 +191,17 @@ static ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 			args.cp_src[0].u.nl4_addr.na_netid,
 			args.cp_src[0].u.nl4_addr.na_uaddr_len,
 			args.cp_src[0].u.nl4_addr.na_uaddr);
+
+		nfs4_stateid_copy(&args.src_stateid, &cn_res->cnr_stateid);
+	} else {
+		status = nfs42_set_rw_stateid(&args.src_stateid, src, FMODE_READ);
+		if (status)
+			return status;
 	}
 
 	if (!(server->caps & NFS_CAP_COPY))
 		return -ENOTSUPP;
 
-	status = nfs42_set_rw_stateid(&args.src_stateid, src, FMODE_READ);
-	if (status)
-		return status;
-
 	status = nfs42_set_rw_stateid(&args.dst_stateid, dst, FMODE_WRITE);
 	if (status)
 		return status;
-- 
1.8.3.1

