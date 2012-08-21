Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46797 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753607Ab2HUU5f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 06/14] nfsd: allow configuring nfsd to listen on 5-digit ports
Date: Tue, 21 Aug 2012 16:57:24 -0400
Message-Id: <1345582652-18476-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1345582652-18476-1-git-send-email-bfields@redhat.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Note a 16-bit value can require up to 5 digits.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 89be13c..e41a08ff 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -712,7 +712,7 @@ static ssize_t __write_ports_addxprt(char *buf)
 	int port, err;
 	struct net *net = &init_net;
 
-	if (sscanf(buf, "%15s %4u", transport, &port) != 2)
+	if (sscanf(buf, "%15s %5u", transport, &port) != 2)
 		return -EINVAL;
 
 	if (port < 1 || port > USHRT_MAX)
-- 
1.7.9.5

