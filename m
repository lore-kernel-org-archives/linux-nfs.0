Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49754 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007Ab1EQExS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2011 00:53:18 -0400
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Tue, 17 May 2011 14:52:17 +1000
Subject: [PATCH 2/2] supress socket error when address family is not supported
Cc: linux-nfs@vger.kernel.org, Suresh Jayaraman <sjayaraman@suse.de>,
        Neil Brown <neilb@suse.de>
Message-ID: <20110517045217.29020.46681.stgit@notabene.brown>
In-Reply-To: <20110517045125.29020.14596.stgit@notabene.brown>
References: <20110517045125.29020.14596.stgit@notabene.brown>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Suresh Jayaraman <sjayaraman@suse.de>

It was observed that when ipv6 module was not loaded and cannot be auto-loaded,
when starting NFS server, the following error occurs:
	"rpc.nfsd: unable to create inet6 TCP socket: errno 97 (Address
	family not supported by protocol)"

This is obviously a true message, but does not represent an "error" when ipv6
is not enabled.  Rather, it is an expected condition.  As such, it can be
confusing / misleading / distracting to display it in this scenario.

This patch instead of throwing error when a socket call fails with
EAFNOSUPPORT, makes it as a NOTICE.

Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Neil Brown <neilb@suse.de>
---

 utils/nfsd/nfssvc.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index ea36399..f607214 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -174,8 +174,13 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
 		sockfd = socket(addr->ai_family, addr->ai_socktype,
 				addr->ai_protocol);
 		if (sockfd < 0) {
-			xlog(L_ERROR, "unable to create %s %s socket: "
-				"errno %d (%m)", family, proto, errno);
+			if (errno == EAFNOSUPPORT)
+				xlog(L_NOTICE, "address family %s not "
+						"supported by protocol %s",
+						family, proto);
+			else
+				xlog(L_ERROR, "unable to create %s %s socket: "
+				     "errno %d (%m)", family, proto, errno);
 			rc = errno;
 			goto error;
 		}


