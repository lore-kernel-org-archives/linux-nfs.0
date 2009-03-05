From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] mount.nfs: squelch compiler warning for TI-RPC builds
Date: Wed, 04 Mar 2009 19:02:55 -0500
Message-ID: <20090305000254.28749.54076.stgit@ingres.1015granger.net>
References: <20090304234711.28749.7018.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:26915 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbZCEADT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Mar 2009 19:03:19 -0500
In-Reply-To: <20090304234711.28749.7018.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The printf format string in nfs_pp_debug() assumes the @program and
@version arguments are unsigned long, because the legacy RPC headers
define both rpcprog_t and rpcvers_t as unsigned long types.

However, the TI-RPC headers define both types as uint32_t, which
requires a different printf format type.  If we replace the legacy
headers with TI-RPC headers, this type mismatch generates compiler
warnings that are nothing but noise.

We are about to provide a switch at ./configure time to allow the use
of either the legacy RPC headers or the TI-RPC headers, so we need
a printf format that works in both cases.

To squelch the compiler warnings that occur when using the TI-RPC
headers, cast both arguments in the fprintf statement to the widest of
the two types ("unsigned long" or "uint32_t").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index b41388e..bcd0c0f 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -546,8 +546,9 @@ static void nfs_pp_debug(const struct sockaddr *sap, const socklen_t salen,
 		strcat(buf, "unknown host");
 	}
 
-	fprintf(stderr, _("%s: trying %s prog %ld vers %ld prot %s port %d\n"),
-			progname, buf, program, version,
+	fprintf(stderr, _("%s: trying %s prog %lu vers %lu prot %s port %d\n"),
+			progname, buf, (unsigned long)program,
+			(unsigned long)version,
 			(protocol == IPPROTO_UDP ? _("UDP") : _("TCP")),
 			port);
 }

