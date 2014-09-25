Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27962 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752759AbaIYNfB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2014 09:35:01 -0400
Subject: [PATCH] NFS: Fabricate fscache server index key correctly
From: David Howells <dhowells@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Steve Dickson <steved@redhat.com>,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-cachefs@redhat.com, james-p@moving-picture.com
Date: Thu, 25 Sep 2014 14:34:41 +0100
Message-ID: <20140925133441.2142.25916.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When fabricating a server index key for fscache, we should clear the index key
buffer before starting to fill it in, not in the middle.

Reported-by: James Pearson <james-p@moving-picture.com>
Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Steve Dickson <steved@redhat.com>
---

 fs/nfs/fscache-index.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/fscache-index.c b/fs/nfs/fscache-index.c
index 7cf2c4699b08..777b055063f6 100644
--- a/fs/nfs/fscache-index.c
+++ b/fs/nfs/fscache-index.c
@@ -74,11 +74,10 @@ static uint16_t nfs_server_get_key(const void *cookie_netfs_data,
 	struct nfs_server_key *key = buffer;
 	uint16_t len = sizeof(struct nfs_server_key);
 
+	memset(key, 0, len);
 	key->nfsversion = clp->rpc_ops->version;
 	key->family = clp->cl_addr.ss_family;
 
-	memset(key, 0, len);
-
 	switch (clp->cl_addr.ss_family) {
 	case AF_INET:
 		key->port = sin->sin_port;

