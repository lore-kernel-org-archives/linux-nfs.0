Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52570 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754180AbdGSUx7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Jul 2017 16:53:59 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id EA1CA80467
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 20:53:58 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-122-174.rdu2.redhat.com [10.10.122.174])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 9E53117C14
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 20:53:58 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 05/11] nfsd.c: removed a few warnings
Date: Wed, 19 Jul 2017 16:53:48 -0400
Message-Id: <20170719205354.10006-6-steved@redhat.com>
In-Reply-To: <20170719205354.10006-1-steved@redhat.com>
References: <20170719205354.10006-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd.c:187:8: warning: this statement may fall through [-Wimplicit-fallthrough=]
nfsd.c:213:8: warning: this statement may fall through [-Wimplicit-fallthrough=]nfsd.c:263:4: warning: this statement may fall through [-Wimplicit-fallthrough=]

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsd/nfsd.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 2b38249..1d35658 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -198,6 +198,7 @@ main(int argc, char **argv)
 					minorvers = 0;
 					minorversset = minormask;
 				}
+				break;
 			case 3:
 			case 2:
 				NFSCTL_VERUNSET(versbits, c);
@@ -220,6 +221,7 @@ main(int argc, char **argv)
 					NFSCTL_MINORSET(minorvers, i);
 				} else
 					minorvers = minorversset = minormask;
+				break;
 			case 3:
 			case 2:
 				NFSCTL_VERSET(versbits, c);
@@ -261,8 +263,9 @@ main(int argc, char **argv)
 			break;
 		default:
 			fprintf(stderr, "Invalid argument: '%c'\n", c);
+			/* FALLTHRU */
 		case 'h':
-			usage(progname);
+			usage(progname); /* usage does not return */
 		}
 	}
 
-- 
2.13.3

