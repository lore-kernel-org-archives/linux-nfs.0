Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44887 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752508AbcLUAUW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Dec 2016 19:20:22 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 21 Dec 2016 11:19:14 +1100
Subject: [PATCH 4/4] mountd: delay reading etab until first request arrives.
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Message-ID: <148227955423.31345.17642862410755193193.stgit@noble>
In-Reply-To: <148227940052.31345.1974080582264239934.stgit@noble>
References: <148227940052.31345.1974080582264239934.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reading etab may require hostname lookup, so it is not reliable
until the network is active.
But we want mountd to start before that so that it is ready
when the very first NFS request arrives.
So delay reading etab until that request arrives, by which time
the network must be online so hopefully hostname look will be reliable.

An alternate would be to delay starting mountd and nfsd until the
network is on-line, but that will often be an unnecessary delay.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mountd/mountd.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 5d9466f5c651..61699e62a6f0 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -852,8 +852,6 @@ main(int argc, char **argv)
 	sa.sa_handler = sig_hup;
 	sigaction(SIGHUP, &sa, NULL);
 
-	auth_init();
-
 	if (!foreground) {
 		/* We first fork off a child. */
 		if ((c = fork()) > 0)


