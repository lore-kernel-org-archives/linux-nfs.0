From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] mount.nfs: don't use IPv6 unless IPV6_SUPPORTED is set
Date: Mon,  4 Jan 2010 14:47:34 -0500
Message-ID: <1262634454-2330-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750770Ab0ADTri (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Jan 2010 14:47:38 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 1f3fae1fb25168aac187ff1881738c8ad53a8763 made mount.nfs start
looking up and trying to use IPv6 addresses when mount.nfs was built
against libtirpc (even when --enable-ipv6 wasn't specified).

The problem seems to be that nfs_nfs_proto_family() is basing the family
on HAVE_LIBTIRPC. I think it should be basing it on IPV6_SUPPORTED
instead.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/mount/network.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index e3ad5c2..906e20c 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1344,7 +1344,7 @@ int nfs_nfs_proto_family(struct mount_options *options,
 	unsigned long protocol;
 	char *option;
 
-#ifdef HAVE_LIBTIRPC
+#ifdef IPV6_SUPPORTED
 	*family = AF_UNSPEC;
 #else
 	*family = AF_INET;
-- 
1.6.5.2

