Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62861 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886Ab1ABUVB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Jan 2011 15:21:01 -0500
Date: Sun, 2 Jan 2011 23:20:42 +0300
From: Dan Carpenter <error27@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch -next] lockd: double unlock in next_host_state()
Message-ID: <20110102202042.GN1886@bicker>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We unlock again after we goto out.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index c106d6a..5f1bcb2 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -532,7 +532,6 @@ static struct nlm_host *next_host_state(struct hlist_head *cache,
 			host->h_state++;
 
 			nlm_get_host(host);
-			mutex_unlock(&nlm_host_mutex);
 			goto out;
 		}
 	}
