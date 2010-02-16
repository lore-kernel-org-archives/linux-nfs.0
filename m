Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:50360 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933409Ab0BPWKm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Feb 2010 17:10:42 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] mount: Set protocol family properly for "udp" and "tcp"
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 16 Feb 2010 17:10:10 -0500
Message-ID: <20100216221010.2977.6043.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In nfs_nfs_proto_family(), *family is never set if the legacy
"udp" or "tcp" mount options are specified.  The result is an error
message at umount time, for example:

umount.nfs: DNS resolution failed for
  2001:5c0:1101:2f00:250:8dff:fe95:5c61: ai_family not supported

even if mount was built with IPv6 support.

The man page says that "udp" is a synonym for "proto=udp", and
likewise for "tcp".  Thus, we don't look at config_default_family
here, but always use AF_INET explicitly, to be consistent with the
meaning of proto=.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---

 utils/mount/network.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index f020933..8dc183a 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1373,8 +1373,9 @@ int nfs_nfs_proto_family(struct mount_options *options,
 
 	switch (po_rightmost(options, nfs_transport_opttbl)) {
 	case 0:	/* udp */
-		return 1;
 	case 1: /* tcp */
+		/* for compatibility; these are always AF_INET */
+		*family = AF_INET;
 		return 1;
 	case 2: /* proto */
 		option = po_get(options, "proto");

