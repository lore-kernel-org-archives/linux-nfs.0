Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41360 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752263AbcKOU7y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Nov 2016 15:59:54 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] nfs: only show mountproto in /proc/mounts if set
Date: Tue, 15 Nov 2016 15:59:52 -0500
Message-Id: <1479243592-38858-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs_server->mountd_protocol field doesn't get set when a v3 submount
is created, causing /proc/mounts to show 'mountproto=' without a netid.
This in turn causes umount.nfs to emit the error message "Failed to find
'' protocol" if you manually unmount the submount.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/super.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 001796b..b60946d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -532,7 +532,8 @@ static void nfs_show_mountd_netid(struct seq_file *m, struct nfs_server *nfss,
 {
 	struct sockaddr *sap = (struct sockaddr *) &nfss->mountd_address;
 
-	seq_printf(m, ",mountproto=");
+	if (nfss->mountd_protocol || showdefaults)
+		seq_printf(m, ",mountproto=");
 	switch (sap->sa_family) {
 	case AF_INET:
 		switch (nfss->mountd_protocol) {
-- 
2.4.11

