Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:15445 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754863Ab3ANEA0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jan 2013 23:00:26 -0500
Message-ID: <50F382EF.2070309@cn.fujitsu.com>
Date: Mon, 14 Jan 2013 12:00:47 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH] it maybe can't disable migration when mount with nomigration
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

when mount with nomigration it maybe can't disable migration.

notice commit 896526174ce2b6a773e187ebe5a047b68230e2c
'Introduce "migration" mount option'

Signed-off-by: Fan Chaoting <fanchaoting@cn.fujitsu.com>
---
 fs/nfs/super.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2e7e8c8..e72efc8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1304,7 +1304,7 @@ static int nfs_parse_mount_options(char *raw,
                        mnt->options |= NFS_OPTION_MIGRATION;
                        break;
                case Opt_nomigration:
-                       mnt->options &= NFS_OPTION_MIGRATION;
+                       mnt->options &= ~NFS_OPTION_MIGRATION;
                        break;

                /*
--
1.7.10.1

