From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 02/11] nfs-utils: clean up option parsing in nfsd.c
Date: Mon,  8 Jun 2009 14:00:35 -0400
Message-ID: <1244484044-21355-3-git-send-email-jlayton@redhat.com>
References: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48166 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565AbZFHSA7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:00:59 -0400
In-Reply-To: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Minor formatting nits.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsd/nfsd.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 8563c5c..183681b 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -98,11 +98,11 @@ main(int argc, char **argv)
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
1.6.0.6

