Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.3]:50880 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750951AbeAMTkc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 13 Jan 2018 14:40:32 -0500
To: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jeff Layton <jlayton@kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] sunrpc: Use seq_putc() in unix_gid_show()
Message-ID: <5b9ca3b8-b801-a658-ae76-2b6bc43826ea@users.sourceforge.net>
Date: Sat, 13 Jan 2018 20:40:11 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 13 Jan 2018 20:33:05 +0100

A single character (line break) should be put into a sequence.
Thus use the corresponding function "seq_putc".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/sunrpc/svcauth_unix.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index af7f28fb8102..df1327c0dd1c 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -566,7 +566,7 @@ static int unix_gid_show(struct seq_file *m,
 	seq_printf(m, "%u %d:", from_kuid_munged(user_ns, ug->uid), glen);
 	for (i = 0; i < glen; i++)
 		seq_printf(m, " %d", from_kgid_munged(user_ns, ug->gi->gid[i]));
-	seq_printf(m, "\n");
+	seq_putc(m, '\n');
 	return 0;
 }
 
-- 
2.15.1

