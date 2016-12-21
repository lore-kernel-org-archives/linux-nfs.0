Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44882 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752273AbcLUAUQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Dec 2016 19:20:16 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 21 Dec 2016 11:19:14 +1100
Subject: [PATCH 3/4] nfs-server-generator: avoid using syslog
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Message-ID: <148227955410.31345.7715529128389692817.stgit@noble>
In-Reply-To: <148227940052.31345.1974080582264239934.stgit@noble>
References: <148227940052.31345.1974080582264239934.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs-server-generator is run very early when a lot of services
are not yet started, so it mustn't depend on them.
It already avoids using DNS, but it should avoid syslog too.

If it tries to log error to syslog, it can deadlock.  So just let
messages go to stderr.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 systemd/nfs-server-generator.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/systemd/nfs-server-generator.c b/systemd/nfs-server-generator.c
index 7c40b3f29b99..cc99969e9922 100644
--- a/systemd/nfs-server-generator.c
+++ b/systemd/nfs-server-generator.c
@@ -95,6 +95,9 @@ int main(int argc, char *argv[])
 	FILE		*f, *fstab;
 	struct mntent	*mnt;
 
+	/* Avoid using any external services */
+	xlog_syslog(0);
+
 	if (argc != 4 || argv[1][0] != '/') {
 		fprintf(stderr, "nfs-server-generator: create systemd dependencies for nfs-server\n");
 		fprintf(stderr, "Usage: normal-dir early-dir late-dir\n");


