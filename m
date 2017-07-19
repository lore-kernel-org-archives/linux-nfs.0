Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36400 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752811AbdGSUyA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Jul 2017 16:54:00 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4EA9261E4C
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 20:54:00 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-122-174.rdu2.redhat.com [10.10.122.174])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 01E1A17C66
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 20:53:59 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 08/11] network.c: removed some warnings
Date: Wed, 19 Jul 2017 16:53:51 -0400
Message-Id: <20170719205354.10006-9-steved@redhat.com>
In-Reply-To: <20170719205354.10006-1-steved@redhat.com>
References: <20170719205354.10006-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

network.c:1234:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
network.c:1382:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
network.c:1477:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
network.c:1508:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
network.c:1574:6: warning: this statement may fall through [-Wimplicit-fallthrough=]
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 281e935..19f14e5 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1235,6 +1235,7 @@ nfs_nfs_program(struct mount_options *options, unsigned long *program)
 			*program = tmp;
 			return 1;
 		}
+		break;
 	case PO_BAD_VALUE:
 		nfs_error(_("%s: invalid value for 'nfsprog=' option"),
 				progname);
@@ -1383,6 +1384,7 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
 			*port = tmp;
 			return 1;
 		}
+		break;
 	case PO_BAD_VALUE:
 		nfs_error(_("%s: invalid value for 'port=' option"),
 				progname);
@@ -1478,6 +1480,7 @@ nfs_mount_program(struct mount_options *options, unsigned long *program)
 			*program = tmp;
 			return 1;
 		}
+		break;
 	case PO_BAD_VALUE:
 		nfs_error(_("%s: invalid value for 'mountprog=' option"),
 				progname);
@@ -1509,6 +1512,7 @@ nfs_mount_version(struct mount_options *options, unsigned long *version)
 			*version = tmp;
 			return 1;
 		}
+		break;
 	case PO_BAD_VALUE:
 		nfs_error(_("%s: invalid value for 'mountvers=' option"),
 				progname);
@@ -1575,6 +1579,7 @@ nfs_mount_port(struct mount_options *options, unsigned long *port)
 			*port = tmp;
 			return 1;
 		}
+		break;
 	case PO_BAD_VALUE:
 		nfs_error(_("%s: invalid value for 'mountport=' option"),
 				progname);
-- 
2.13.3

