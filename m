Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from wp221.webpack.hosteurope.de ([80.237.132.228]:47678 "EHLO
	wp221.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752665AbbJaKsI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Oct 2015 06:48:08 -0400
Received: from [192.168.0.17] (helo=jue.netz)
	by tor.netz with esmtp (Exim 4.86)
	(envelope-from <juergen@jue.netz>)
	id 1ZsTPF-0006kR-5S
	for linux-nfs@vger.kernel.org; Sat, 31 Oct 2015 11:29:05 +0100
Received: from juergen by jue.netz with local (Exim 4.86)
	(envelope-from <juergen@jue.netz>)
	id 1ZsTPF-0000X3-4a
	for linux-nfs@vger.kernel.org; Sat, 31 Oct 2015 11:29:05 +0100
Date: Sat, 31 Oct 2015 11:29:05 +0100
From: Juergen Daubert <jue@jue.li>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: Fix message when creating NFSD listener sockets
Message-ID: <20151031102905.GA2010@jue.netz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the kernel's IPv6 module isn't loaded:

#:~> /usr/sbin/rpc.nfsd --debug 8
rpc.nfsd: knfsd is currently down
rpc.nfsd: Writing version string to kernel: -2 +3 +4
rpc.nfsd: Creating AF_INET TCP socket.
rpc.nfsd: Creating AF_INET UDP socket.
rpc.nfsd: Creating AF_INET6 TCP socket.
rpc.nfsd: Creating AF_INET6 UDP socket.

The last two messages are misleading, since creation of AF_INET6
sockets now fails silently without kernel IPv6 support.

Fixes: c31fef7f4beb ('nfsd: ignore unsupported address types')

Signed-off-by: Juergen Daubert <jue@jue.il>
---

 utils/nfsd/nfssvc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index fc11d23..e8efd06 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -168,8 +168,6 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
 			continue;
 		}
 
-		xlog(D_GENERAL, "Creating %s %s socket.", family, proto);
-
 		/* open socket and prepare to hand it off to kernel */
 		sockfd = socket(addr->ai_family, addr->ai_socktype,
 				addr->ai_protocol);
@@ -183,6 +181,9 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
 			addr = addr->ai_next;
 			continue;
 		}
+
+		xlog(D_GENERAL, "Created %s %s socket.", family, proto);
+
 #ifdef IPV6_SUPPORTED
 		if (addr->ai_family == AF_INET6 &&
 		    setsockopt(sockfd, IPPROTO_IPV6, IPV6_V6ONLY, &on, sizeof(on))) {
