Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:35788 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932161Ab1IMSOm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 14:14:42 -0400
Subject: [PATCH v3 08/11] NFSd: force creation of rpcbind clients during
	service creation
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Tue, 13 Sep 2011 22:14:22 +0400
Message-ID: <20110913181421.3961.81050.stgit@localhost6.localdomain6>
In-Reply-To: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
References: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFSd sends requests to portmapper and thus requires rpcbind clients.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/nfssvc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index dc5a1bf..88faab8 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -332,7 +332,7 @@ int nfsd_create_serv(void)
 	nfsd_reset_versions();
 
 	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
-				      nfsd_last_thread, nfsd, THIS_MODULE);
+				      1, nfsd_last_thread, nfsd, THIS_MODULE);
 	if (nfsd_serv == NULL)
 		return -ENOMEM;
 

