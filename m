Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:44565 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756058Ab3BAMz1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Feb 2013 07:55:27 -0500
Subject: [PATCH 3/4] nfsd: disable usermode helper client tracker in container
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Fri, 01 Feb 2013 15:56:22 +0300
Message-ID: <20130201125622.3257.22985.stgit@localhost.localdomain>
In-Reply-To: <20130201125210.3257.46454.stgit@localhost.localdomain>
References: <20130201125210.3257.46454.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This tracker uses khelper kthread to execute binaries.
Execution itself is done from kthread context - i.e. global root is used.
This is not suitable for containers with own root.
So, disable this tracker for a while.

Note: one of possible solutions can be pass "init" callback to khelper, which
will swap root to desired one.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4recover.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index ba6fdd4..e0ae1cf 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1185,6 +1185,12 @@ bin_to_hex_dup(const unsigned char *src, int srclen)
 static int
 nfsd4_umh_cltrack_init(struct net __attribute__((unused)) *net)
 {
+	/* XXX: The usermode helper s not working in container yet. */
+	if (net != &init_net) {
+		WARN(1, KERN_ERR "NFSD: attempt to initialize umh client "
+			"tracking in a container!\n");
+		return -EINVAL;
+	}
 	return nfsd4_umh_cltrack_upcall("init", NULL, NULL);
 }
 

