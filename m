Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57144 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865AbcGNC2S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2016 22:28:18 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 14 Jul 2016 12:26:43 +1000
Subject: [PATCH 8/8] mount: use a public address for IPv6 callback.
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <20160714022643.5874.51563.stgit@noble>
In-Reply-To: <20160714021310.5874.22953.stgit@noble>
References: <20160714021310.5874.22953.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If IPv6 address privacy is active, the "clientaddr" given to the server
will likely be a temporary address which will eventually expire, thus
breaking callback.
So ask for a public address to ensure continued service.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mount/network.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 0d12613e86a4..6529b6ee6b01 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -38,6 +38,7 @@
 #include <sys/socket.h>
 #include <sys/wait.h>
 #include <sys/stat.h>
+#include <linux/in6.h>
 #include <netinet/in.h>
 #include <rpc/rpc.h>
 #include <rpc/pmap_prot.h>
@@ -1113,6 +1114,7 @@ static int nfs_ca_sockname(const struct sockaddr *sap, const socklen_t salen,
 		.sin6_addr		= IN6ADDR_ANY_INIT,
 	};
 	int sock, result = 0;
+	int val;
 
 	sock = socket(sap->sa_family, SOCK_DGRAM, IPPROTO_UDP);
 	if (sock < 0)
@@ -1124,6 +1126,9 @@ static int nfs_ca_sockname(const struct sockaddr *sap, const socklen_t salen,
 			goto out;
 		break;
 	case AF_INET6:
+		/* Make sure the call-back address is public */
+		val = IPV6_PREFER_SRC_PUBLIC;
+		setsockopt(sock, SOL_IPV6, IPV6_ADDR_PREFERENCES, &val, sizeof(val));
 		if (bind(sock, SAFE_SOCKADDR(&sin6), sizeof(sin6)) < 0)
 			goto out;
 		break;


