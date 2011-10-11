Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:62534 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753886Ab1JKJor (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Oct 2011 05:44:47 -0400
MIME-Version: 1.0
From: Hamo <hamo.by@gmail.com>
Date: Tue, 11 Oct 2011 17:44:27 +0800
Message-ID: <CAO_0yfPgXJJSZNDYXHBSt45J0WQsh5EQVUs0nBN4wb+NoT6hAQ@mail.gmail.com>
Subject: [PATCH] nfs-utils: mount: really return from errno test
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should only try next address family if we meet ECONNREFUSED or EHOSTUNREACH
for v4 or ECONNREFUSED or EOPNOTSUPP or EHOSTUNREACH for v3v2.
Before, only a break in swich can not make the program out of for loop.

Signed-off-by: Yang Bai <hamo.by@gmail.com>
---
 utils/mount/stropts.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 314a806..4032bf3 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -665,9 +665,10 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
 		case EHOSTUNREACH:
 			continue;
 		default:
-			break;
+			goto out;
 		}
 	}
+out:
 	return ret;
 }

@@ -751,9 +752,10 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
 		case EHOSTUNREACH:
 			continue;
 		default:
-			break;
+			goto out;
 		}
 	}
+out:
 	return ret;
 }

-- 
1.7.1
