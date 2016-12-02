Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36544 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752480AbcLBD7y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 22:59:54 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:58:29 +1100
Subject: [PATCH 11/15] conffile: ignore setting of empty string
Cc: linux-nfs@vger.kernel.org
Message-ID: <148065110977.28046.4258233430833825030.stgit@noble>
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A value setting like

   foo =

is now equivalent to not setting "foo" at all.
This is likely to be least confusing.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 support/nfs/conffile.c |    2 ++
 systemd/nfs.conf.man   |    3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 947bf9bad1e7..eaff5f5c35ea 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -748,6 +748,8 @@ conf_set(int transaction, char *section, char *arg,
 {
 	struct conf_trans *node;
 
+	if (!value || !*value)
+		return 0;
 	node = conf_trans_node(transaction, CONF_SET);
 	if (!node)
 		return 1;
diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 8e2f034d0b9b..8cf55668b664 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -36,7 +36,8 @@ in the current section to
 Leading and trailing spaces and tab
 are ignored, as are spaces and tabs surrounding the equals sign.
 Single and double quotes surrounding the assigned value are also
-removed.
+removed.  If the resulting string is empty, the whole assignment
+is ignored.
 .PP
 Any line starting with
 .RB \*(lq # \*(rq


