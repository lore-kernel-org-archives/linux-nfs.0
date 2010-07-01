Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:56369 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847Ab0GAPJp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 11:09:45 -0400
From: Artem Bityutskiy <dedekind1@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] sunrpc: make the cache cleaner workqueue deferrable
Date: Thu,  1 Jul 2010 18:05:56 +0300
Message-Id: <1277996756-8415-1-git-send-email-dedekind1@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>

This patch makes the cache_cleaner workqueue deferrable, to prevent
unnecessary system wake-ups, which is very important for embedded
battery-powered devices.

do_cache_clean() is called every 30 seconds at the moment, and often
makes the system wake up from its power-save sleep state. With this
change, when the workqueue uses a deferrable timer, the
do_cache_clean() invocation will be delayed and combined with the
closest "real" wake-up. This improves the power consumption situation.

Note, I tried to create a DECLARE_DELAYED_WORK_DEFERRABLE() helper
macro, similar to DECLARE_DELAYED_WORK(), but failed because of the
way the timer wheel core stores the deferrable flag (it is the
LSBit in the time->base pointer). My attempt to define a static
variable with this bit set ended up with the "initializer element is
not constant" error.

Thus, I have to use run-time initialization, so I created a new
cache_initialize() function which is called once when sunrpc is
being initialized.

Signed-off-by: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
---
 include/linux/sunrpc/cache.h |    1 +
 net/sunrpc/cache.c           |    7 ++++++-
 net/sunrpc/sunrpc_syms.c     |    1 +
 3 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 6f52b4d..7bf3e84 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -192,6 +192,7 @@ extern int cache_check(struct cache_detail *detail,
 extern void cache_flush(void);
 extern void cache_purge(struct cache_detail *detail);
 #define NEVER (0x7FFFFFFF)
+extern void __init cache_initialize(void);
 extern int cache_register(struct cache_detail *cd);
 extern void cache_unregister(struct cache_detail *cd);
 
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 58de76c..939d048 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -320,7 +320,7 @@ static struct cache_detail *current_detail;
 static int current_index;
 
 static void do_cache_clean(struct work_struct *work);
-static DECLARE_DELAYED_WORK(cache_cleaner, do_cache_clean);
+static struct delayed_work cache_cleaner;
 
 static void sunrpc_init_cache_detail(struct cache_detail *cd)
 {
@@ -1504,6 +1504,11 @@ static int create_cache_proc_entries(struct cache_detail *cd)
 }
 #endif
 
+void __init cache_initialize(void)
+{
+	INIT_DELAYED_WORK_DEFERRABLE(&cache_cleaner, do_cache_clean);
+}
+
 int cache_register(struct cache_detail *cd)
 {
 	int ret;
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index f438347..c52b184 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -43,6 +43,7 @@ init_sunrpc(void)
 #ifdef CONFIG_PROC_FS
 	rpc_proc_init();
 #endif
+	cache_initialize();
 	cache_register(&ip_map_cache);
 	cache_register(&unix_gid_cache);
 	svc_init_xprt_sock();	/* svc sock transport */
-- 
1.7.0.1

