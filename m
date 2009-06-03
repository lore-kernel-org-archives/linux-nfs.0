From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 02/10] nfs-utils: clean up option parsing in nfsd.c
Date: Wed,  3 Jun 2009 15:52:35 -0400
Message-ID: <1244058763-10352-3-git-send-email-jlayton@redhat.com>
References: <1244058763-10352-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51436 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754179AbZFCTwr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 15:52:47 -0400
In-Reply-To: <1244058763-10352-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Minor formatting nits.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsd/nfsd.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index e3c0094..c7bd003 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -97,11 +97,11 @@ main(int argc, char **argv)
 			}
 			break;
 		case 'T':
-				NFSCTL_TCPUNSET(protobits);
-				break;
+			NFSCTL_TCPUNSET(protobits);
+			break;
 		case 'U':
-				NFSCTL_UDPUNSET(protobits);
-				break;
+			NFSCTL_UDPUNSET(protobits);
+			break;
 		default:
 			fprintf(stderr, "Invalid argument: '%c'\n", c);
 		case 'h':
-- 
1.6.2.2

