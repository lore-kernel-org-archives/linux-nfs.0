Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f42.google.com ([209.85.210.42]:57084 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896Ab1JSAwN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2011 20:52:13 -0400
Received: by pzk36 with SMTP id 36so2963913pzk.1
        for <linux-nfs@vger.kernel.org>; Tue, 18 Oct 2011 17:52:12 -0700 (PDT)
Message-ID: <4E9E1F3A.2090709@tonian.com>
Date: Tue, 18 Oct 2011 17:52:10 -0700
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Olga Kornievskaia <aglo@citi.umich.edu>,
        Michael Groshans <groshans@umich.edu>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] pnfsd: dlm: fix bug in DS tcp/tcp6 address string
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

squash into "pnfsd: Correctly set netid to tcp or tcp6 for non-local exports"

Currently, the code looks for ':' using strcspn that requires a null terminated string
while the address buffer isn't null terminated.

Instead, just use strnchr to look for a ':' and if not found assume
it's an IPv4 address, otherwise it's IPv6

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsdlm.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
index abc4d83..d07a6037 100644
--- a/fs/nfsd/nfs4pnfsdlm.c
+++ b/fs/nfsd/nfs4pnfsdlm.c
@@ -328,13 +328,8 @@ static int nfsd4_pnfs_dlm_getdevinfo(struct super_block *sb,
 		memcpy(daddr->r_addr.data + len, ".8.1", 4);
 		daddr->r_addr.len = len + 4;

-		if (strcspn(daddr->r_addr.data, ":") - 1 == daddr->r_addr.len) {
-			daddr->r_netid.data = "tcp";
-			daddr->r_netid.len = 3;
-		} else {
-			daddr->r_netid.data = "tcp6";
-			daddr->r_netid.len = 4;
-		}
+		daddr->r_netid.data = "tcp6";
+		daddr->r_netid.len = strnchr(daddr->r_addr.data, len, ':') ? 4 : 3;

 		fdev.fl_device_list[i].fl_multipath_length = 1;
 		fdev.fl_device_list[i].fl_multipath_list = daddr;
-- 
1.7.6

