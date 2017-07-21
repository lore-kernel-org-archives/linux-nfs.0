Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57568 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754548AbdGUQiK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Jul 2017 12:38:10 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E8B3646213
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:09 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-121-35.rdu2.redhat.com [10.10.121.35])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 9DE6360C14
        for <linux-nfs@vger.kernel.org>; Fri, 21 Jul 2017 16:38:09 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 05/11] nfsd.c: removed a few warnings
Date: Fri, 21 Jul 2017 12:38:00 -0400
Message-Id: <20170721163806.15803-6-steved@redhat.com>
In-Reply-To: <20170721163806.15803-1-steved@redhat.com>
References: <20170721163806.15803-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd.c:187:8: warning: this statement may fall through [-Wimplicit-fallthrough=]
nfsd.c:213:8: warning: this statement may fall through [-Wimplicit-fallthrough=]nfsd.c:263:4: warning: this statement may fall through [-Wimplicit-fallthrough=]

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsd/nfsd.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 2b38249..f973203 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -198,6 +198,7 @@ main(int argc, char **argv)
 					minorvers = 0;
 					minorversset = minormask;
 				}
+				/* FALLTHRU */
 			case 3:
 			case 2:
 				NFSCTL_VERUNSET(versbits, c);
@@ -220,6 +221,7 @@ main(int argc, char **argv)
 					NFSCTL_MINORSET(minorvers, i);
 				} else
 					minorvers = minorversset = minormask;
+				/* FALLTHRU */
 			case 3:
 			case 2:
 				NFSCTL_VERSET(versbits, c);
@@ -261,6 +263,7 @@ main(int argc, char **argv)
 			break;
 		default:
 			fprintf(stderr, "Invalid argument: '%c'\n", c);
+			/* FALLTHRU */
 		case 'h':
 			usage(progname);
 		}
-- 
2.13.3

