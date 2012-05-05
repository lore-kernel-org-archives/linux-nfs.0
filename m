Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:7404 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757706Ab2EERYM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 May 2012 13:24:12 -0400
Subject: [PATCH RFC 06/13] Lockd: add more debug to host shutdown functions
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Sat, 05 May 2012 21:22:15 +0400
Message-ID: <20120505172215.11559.11430.stgit@localhost.localdomain>
In-Reply-To: <20120505170722.11559.74503.stgit@localhost.localdomain>
References: <20120505170722.11559.74503.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/lockd/host.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 8cbf53d..0084ab8 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -608,11 +608,10 @@ nlm_shutdown_hosts_net(struct net *net)
 	struct hlist_node *pos;
 	struct nlm_host	*host;
 
-	dprintk("lockd: shutting down host module\n");
 	mutex_lock(&nlm_host_mutex);
 
 	/* First, make all hosts eligible for gc */
-	dprintk("lockd: nuking all hosts...\n");
+	dprintk("lockd: nuking all hosts in net %p...\n", net);
 	for_each_host(host, pos, chain, nlm_server_hosts) {
 		if (net && host->net != net)
 			continue;
@@ -637,6 +636,7 @@ nlm_shutdown_hosts_net(struct net *net)
 void
 nlm_shutdown_hosts(void)
 {
+	dprintk("lockd: shutting down host module\n");
 	nlm_shutdown_hosts_net(NULL);
 }
 

