Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:23988 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751336Ab2AZLLy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 06:11:54 -0500
Subject: [PATCH 1/5] NFS: pass proper net rpc_pton() in nfs_dns_resolve_name()
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Thu, 26 Jan 2012 15:11:33 +0400
Message-ID: <20120126111133.8386.34195.stgit@localhost6.localdomain6>
In-Reply-To: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
References: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/dns_resolve.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
index be9a530..fcd8f1d 100644
--- a/fs/nfs/dns_resolve.c
+++ b/fs/nfs/dns_resolve.c
@@ -20,7 +20,7 @@ ssize_t nfs_dns_resolve_name(struct net *net, char *name, size_t namelen,
 
 	ip_len = dns_query(NULL, name, namelen, NULL, &ip_addr, NULL);
 	if (ip_len > 0)
-		ret = rpc_pton(&init_net, ip_addr, ip_len, sa, salen);
+		ret = rpc_pton(net, ip_addr, ip_len, sa, salen);
 	else
 		ret = -ESRCH;
 	kfree(ip_addr);

