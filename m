Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:1440 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752775Ab2AZLMS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 06:12:18 -0500
Subject: [PATCH 4/5] NFS: pass current net to rpc_pton() while parsing mount
 options
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Thu, 26 Jan 2012 15:11:57 +0400
Message-ID: <20120126111157.8386.76201.stgit@localhost6.localdomain6>
In-Reply-To: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
References: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/super.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b79f2a1..5ed6071 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1408,7 +1408,7 @@ static int nfs_parse_mount_options(char *raw,
 			if (string == NULL)
 				goto out_nomem;
 			mnt->nfs_server.addrlen =
-				rpc_pton(&init_net, string, strlen(string),
+				rpc_pton(mnt->net, string, strlen(string),
 					(struct sockaddr *)
 					&mnt->nfs_server.address,
 					sizeof(mnt->nfs_server.address));
@@ -1430,7 +1430,7 @@ static int nfs_parse_mount_options(char *raw,
 			if (string == NULL)
 				goto out_nomem;
 			mnt->mount_server.addrlen =
-				rpc_pton(&init_net, string, strlen(string),
+				rpc_pton(mnt->net, string, strlen(string),
 					(struct sockaddr *)
 					&mnt->mount_server.address,
 					sizeof(mnt->mount_server.address));

