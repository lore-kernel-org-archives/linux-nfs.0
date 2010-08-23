Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:60451 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294Ab0HWRLP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Aug 2010 13:11:15 -0400
Received: by pvg2 with SMTP id 2so2351827pvg.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Aug 2010 10:11:15 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] statd: statd fails to monitor if no reverse mapping of
	mon_name exists
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Aug 2010 13:11:12 -0400
Message-ID: <20100823171112.2123.24635.stgit@matisse.1015granger.net>
In-Reply-To: <20100823170552.2123.43124.stgit@matisse.1015granger.net>
References: <20100823170552.2123.43124.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Commit 8ce130c4 switched in the new statd_canonical_name() function
that constructs a "unique" name statd can use to uniquely identify a
monitor record.

The legacy statd would monitor a client that sent an IP address with
no reverse map as its caller_name.  To remain bug-for-bug compatible,
allow this case in the new statd.

This shouldn't be a problem: statd_canonical_name() needs to create
a unique name for the monitored host so it can keep track of monitor
requests from the same remote.  The IP address itself should work as
well as the host's canonical name, in case there is no reverse
mapping.

We still enforce the requirement that a mon_name that is a DNS name
must have a forward map to an IP address.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/hostname.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
index 7d704cc..38f2265 100644
--- a/utils/statd/hostname.c
+++ b/utils/statd/hostname.c
@@ -212,7 +212,9 @@ statd_canonical_name(const char *hostname)
 					buf, (socklen_t)sizeof(buf));
 		freeaddrinfo(ai);
 		if (!result)
-			return NULL;
+			/* OK to use presentation address,
+			 * if no reverse map exists */
+			return strdup(hostname);
 		return strdup(buf);
 	}
 

