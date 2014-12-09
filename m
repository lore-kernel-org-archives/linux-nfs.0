Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51274 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756831AbaLIFlf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:41:35 -0500
Subject: [PATCH 09/19] nfs-utils: gssd - remove "close me" code
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:41:25 +0100
Message-ID: <20141209054125.24756.79432.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This code is mostly just confusing. Close the fds immediately
instead of doing so later.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd.c |   26 ++++++++------------------
 utils/gssd/gssd.h |    2 --
 2 files changed, 8 insertions(+), 20 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 632d1a1..2187562 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -366,7 +366,10 @@ gssd_clnt_gssd_cb(int UNUSED(fd), short which, void *data)
 	struct clnt_info *clp = data;
 
 	if (which != EV_READ) {
-		clp->gssd_close_me = true;
+		printerr(2, "Closing 'gssd' pipe for %s\n", clp->dirname);
+		close(clp->gssd_fd);
+		clp->gssd_fd = -1;
+		event_del(&clp->gssd_ev);
 		gssd_update_clients();
 		return;
 	}
@@ -380,7 +383,10 @@ gssd_clnt_krb5_cb(int UNUSED(fd), short which, void *data)
 	struct clnt_info *clp = data;
 
 	if (which != EV_READ) {
-		clp->krb5_close_me = true;
+		printerr(2, "Closing 'krb5' pipe for %s\n", clp->dirname);
+		close(clp->krb5_fd);
+		clp->krb5_fd = -1;
+		event_del(&clp->krb5_ev);
 		gssd_update_clients();
 		return;
 	}
@@ -396,22 +402,6 @@ process_clnt_dir_files(struct clnt_info * clp)
 	bool gssd_was_closed;
 	bool krb5_was_closed;
 
-	if (clp->gssd_close_me) {
-		printerr(2, "Closing 'gssd' pipe for %s\n", clp->dirname);
-		close(clp->gssd_fd);
-		event_del(&clp->gssd_ev);
-		clp->gssd_fd = -1;
-		clp->gssd_close_me = false;
-	}
-
-	if (clp->krb5_close_me) {
-		printerr(2, "Closing 'krb5' pipe for %s\n", clp->dirname);
-		close(clp->krb5_fd);
-		event_del(&clp->krb5_ev);
-		clp->krb5_fd = -1;
-		clp->krb5_close_me = false;
-	}
-
 	gssd_was_closed = clp->gssd_fd < 0 ? true : false;
 	krb5_was_closed = clp->krb5_fd < 0 ? true : false;
 
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 2417579..cea2b92 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -74,10 +74,8 @@ struct clnt_info {
 	char			*protocol;
 	int			krb5_fd;
 	struct event		krb5_ev;
-	bool			krb5_close_me;
 	int			gssd_fd;
 	struct event		gssd_ev;
-	bool			gssd_close_me;
 	struct			sockaddr_storage addr;
 };
 

