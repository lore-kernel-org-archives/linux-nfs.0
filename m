Return-Path: <SRS0=ZX+r=P2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BA85C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Jan 2019 03:03:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0D01220873
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Jan 2019 03:03:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726821AbfARDDh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 17 Jan 2019 22:03:37 -0500
Received: from szxga07-in.huawei.com ([45.249.212.35]:53684 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726818AbfARDDh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Jan 2019 22:03:37 -0500
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.58])
        by Forcepoint Email with ESMTP id 734322572CD53C6EF25F;
        Fri, 18 Jan 2019 11:03:34 +0800 (CST)
Received: from localhost (10.177.31.96) by DGGEMS401-HUB.china.huawei.com
 (10.3.19.201) with Microsoft SMTP Server id 14.3.408.0; Fri, 18 Jan 2019
 11:03:28 +0800
From:   YueHaibing <yuehaibing@huawei.com>
To:     <trond.myklebust@hammerspace.com>, <anna.schumaker@netapp.com>
CC:     <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        YueHaibing <yuehaibing@huawei.com>
Subject: [PATCH -next] nfs: remove unneeded semicolon
Date:   Fri, 18 Jan 2019 11:03:22 +0800
Message-ID: <20190118030322.15464-1-yuehaibing@huawei.com>
X-Mailer: git-send-email 2.10.2.windows.1
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.177.31.96]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

remove unneeded semicolon

Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 fs/nfs/nfs4proc.c  | 4 ++--
 fs/nfs/nfs4state.c | 2 +-
 fs/nfs/super.c     | 6 +++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 557a5d6..54da1bf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6670,7 +6670,7 @@ static void nfs4_handle_setlk_error(struct nfs_server *server, struct nfs4_lock_
 	case -NFS4ERR_STALE_STATEID:
 		lsp->ls_seqid.flags &= ~NFS_SEQID_CONFIRMED;
 		nfs4_schedule_lease_recovery(server->nfs_client);
-	};
+	}
 }
 
 static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *fl, int recovery_type)
@@ -8414,7 +8414,7 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
 	case -EACCES:
 	case -EAGAIN:
 		goto out;
-	};
+	}
 
 	clp->cl_seqid++;
 	if (!status) {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 02488b5..2f8774d 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1131,7 +1131,7 @@ static void nfs_increment_seqid(int status, struct nfs_seqid *seqid)
 		case -NFS4ERR_MOVED:
 			/* Non-seqid mutating errors */
 			return;
-	};
+	}
 	/*
 	 * Note: no locking needed as we are guaranteed to be first
 	 * on the sequence list
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 22ce3c8..6dbc810 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1561,7 +1561,7 @@ static int nfs_parse_mount_options(char *raw,
 					dfprintk(MOUNT, "NFS:   invalid "
 							"lookupcache argument\n");
 					return 0;
-			};
+			}
 			break;
 		case Opt_fscache_uniq:
 			if (nfs_get_option_str(args, &mnt->fscache_uniq))
@@ -1594,7 +1594,7 @@ static int nfs_parse_mount_options(char *raw,
 				dfprintk(MOUNT, "NFS:	invalid	"
 						"local_lock argument\n");
 				return 0;
-			};
+			}
 			break;
 
 		/*
@@ -2512,7 +2512,7 @@ static void nfs_get_cache_cookie(struct super_block *sb,
 		if (mnt_s->fscache_key) {
 			uniq = mnt_s->fscache_key->key.uniquifier;
 			ulen = mnt_s->fscache_key->key.uniq_len;
-		};
+		}
 	} else
 		return;
 
-- 
2.7.0


