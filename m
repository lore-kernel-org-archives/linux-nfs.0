From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 1/2] mount.nfs: silently fails with bad version arguments
Date: Wed,  2 Jun 2010 09:41:23 -0400
Message-ID: <1275486084-23899-2-git-send-email-steved@redhat.com>
References: <1275486084-23899-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:46013 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754585Ab0FBOyp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jun 2010 10:54:45 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1OJoCC-0002bc-Jg
	for linux-nfs@vger.kernel.org; Wed, 02 Jun 2010 09:41:24 -0400
In-Reply-To: <1275486084-23899-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mount.nfs should not only fail when an invalid protocol
option is used (as it does), it should also print a
diagnostic identifying the problem.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index c541257..de1014d 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1254,6 +1254,8 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 			nfs_error(_("%s: option parsing error\n"),
 					progname);
 		case PO_BAD_VALUE:
+			nfs_error(_("%s: invalid value for 'vers=' option"),
+					progname);
 			return 0;
 		}
 	case 4: /* nfsvers */
@@ -1268,6 +1270,8 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 			nfs_error(_("%s: option parsing error\n"),
 					progname);
 		case PO_BAD_VALUE:
+			nfs_error(_("%s: invalid value for 'nfsvers=' option"),
+					progname);
 			return 0;
 		}
 	}
-- 
1.6.6.1

