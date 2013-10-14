Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga02-in.huawei.com ([119.145.14.65]:64608 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121Ab3JNM2a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 08:28:30 -0400
From: Kefeng Wang <wangkefeng.wang@huawei.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
CC: John McCutchan <john@johnmccutchan.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Eric Paris <eparis@redhat.com>, Robert Love <rlove@rlove.org>,
        <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] fs: notify: use path_equal() to simply code
Date: Mon, 14 Oct 2013 20:26:02 +0800
Message-ID: <1381753562-47884-4-git-send-email-wangkefeng.wang@huawei.com>
In-Reply-To: <1381753562-47884-1-git-send-email-wangkefeng.wang@huawei.com>
References: <1381753562-47884-1-git-send-email-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 fs/notify/fanotify/fanotify.c        | 3 +--
 fs/notify/inotify/inotify_fsnotify.c | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/notify/fanotify/fanotify.c b/fs/notify/fanotify/fanotify.c
index 0c2f912..777af06 100644
--- a/fs/notify/fanotify/fanotify.c
+++ b/fs/notify/fanotify/fanotify.c
@@ -24,8 +24,7 @@ static bool should_merge(struct fsnotify_event *old, struct fsnotify_event *new)
 			    (new->mask & FAN_ALL_PERM_EVENTS))
 				return false;
 #endif
-			if ((old->path.mnt == new->path.mnt) &&
-			    (old->path.dentry == new->path.dentry))
+			if (path_equal(&old->path, &new->path))
 				return true;
 			break;
 		case (FSNOTIFY_EVENT_NONE):
diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
index 4216308..58b638d 100644
--- a/fs/notify/inotify/inotify_fsnotify.c
+++ b/fs/notify/inotify/inotify_fsnotify.c
@@ -53,8 +53,7 @@ static bool event_compare(struct fsnotify_event *old, struct fsnotify_event *new
 				return true;
 			break;
 		case (FSNOTIFY_EVENT_PATH):
-			if ((old->path.mnt == new->path.mnt) &&
-			    (old->path.dentry == new->path.dentry))
+			if (path_equal(&old->path, &new->path))
 				return true;
 			break;
 		case (FSNOTIFY_EVENT_NONE):
-- 
1.8.2.1


