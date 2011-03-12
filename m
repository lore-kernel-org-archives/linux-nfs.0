Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:59302 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324Ab1CLN1l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Mar 2011 08:27:41 -0500
Message-ID: <4D7B74C7.7060506@gmail.com>
Date: Sat, 12 Mar 2011 14:27:35 +0100
From: roel <roel.kluin@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH] SUNRPC: svc_register error overwritten in next iteration
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The break is in the inner loop, the svc_register() error is overwritten
in the next iteration. Only the error in the last iteration is returned.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 net/sunrpc/svc.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

Is this needed?

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 08e05a8..5fd08c0 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -889,6 +889,8 @@ int svc_register(const struct svc_serv *serv, const int family,
 			if (error < 0)
 				break;
 		}
+		if (error < 0)
+			break;
 	}
 
 	return error;
