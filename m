Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758545Ab1CCUE5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 15:04:57 -0500
Message-ID: <4D6FF466.2070004@RedHat.com>
Date: Thu, 03 Mar 2011 15:04:54 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Karel Zak <kzak@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 3/2] mount: Allow 'port=0' to be a valid port value.
References: <1299159822-25190-1-git-send-email-kzak@redhat.com>
In-Reply-To: <1299159822-25190-1-git-send-email-kzak@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

With the new util-linux, /etc/mtab is now is symbolically linked
to /proc/mounts. In /proc/mounts, the 'port=0' exits which causes
the umount.nfs to error out with the following error:
   umount.nfs: invalid value for 'port=' option

Setting port=0 is a valid value. It just means go out and query
remote rpcbind to get the correct port.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 8049c1a..88ab222 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1346,7 +1346,7 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
 	case PO_NOT_FOUND:
 		break;
 	case PO_FOUND:
-		if (tmp >= 1 && tmp <= 65535) {
+		if (tmp >= 0 && tmp <= 65535) {
 			*port = tmp;
 			return 1;
 		}
