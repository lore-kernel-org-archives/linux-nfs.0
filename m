Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51972 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932105Ab0ARUUw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jan 2010 15:20:52 -0500
Date: Mon, 18 Jan 2010 15:20:47 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: chuck.lever@oracle.com, steved@redhat.com
Subject: Re: should mount.nfs prefer IPv4 addresses (was: enabling IPv6)
Message-ID: <20100118152047.70f9ab80@tlielax.poochiereds.net>
In-Reply-To: <20100118144746.1e05865e@tlielax.poochiereds.net>
References: <20100118144746.1e05865e@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 18 Jan 2010 14:47:46 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> With the commit of the statd patches over the weekend, we're now
> positioned to be able to ship IPv6-enabled nfs-utils in distros. There
> is a potential snag though...
> 
> Consider this situation:
> 
> Admin has a Linux server set up. Server has both IPv4 and IPv6 addrs.
> Both addresses are in DNS.
> 
> Without an IPv6-enabled nfs-utils, he mounts via IPv4 and all works
> fine. Now with an IPv6 enabled nfs-utils, mount.nfs prefers the IPv6
> addr and the mount fails (or hangs for a long time and then fails, if
> it's using NFSv4)...
> 
> While I don't really like it, I think we may need to consider making
> mount.nfs prefer IPv4 addrs when it can resolve a hostname to both v4
> and v6. Otherwise, we run the risk of breaking an awful lot of working
> setups...
> 

Apologies for the self reply and non-descript initial title.

For discussion purposes, here's a patch to do what I'm thinking of. It
seems to work and do the right thing. You can still force a mount over
ipv6 by using the right proto/mountproto options.

Comments welcome...

---------------------[snip]----------------------

mount.nfs: prefer IPv4 addresses over IPv6

We're poised to enable IPv6 in nfs-utils in distros. There is a potential
problem however. glibc seems to prefer IPv6 addrs.

If someone has a working IPv4 server today that has an IPv6 address,
then clients may start trying to mount over that address. If the server
doesn't support NFS serving over IPv6 (and virtually no linux servers
currently do), then the mount will start failing.

Avoid this problem by making the mount.nfs code prefer IPv4 addresses
when they are available.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/mount/network.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 92bba2d..6723f8f 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -203,7 +203,7 @@ static const unsigned int *nfs_default_proto()
 int nfs_lookup(const char *hostname, const sa_family_t family,
 		struct sockaddr *sap, socklen_t *salen)
 {
-	struct addrinfo *gai_results;
+	struct addrinfo *gai_results, *gai_pref;
 	struct addrinfo gai_hint = {
 #ifdef HAVE_DECL_AI_ADDRCONFIG
 		.ai_flags	= AI_ADDRCONFIG,
@@ -229,12 +229,29 @@ int nfs_lookup(const char *hostname, const sa_family_t family,
 		return ret;
 	}
 
-	switch (gai_results->ai_addr->sa_family) {
+	/*
+	 * It will probably be quite a while before we have enough IPv6
+	 * capable servers to be able to prefer using IPv6. For now, we
+	 * only use IPv6 when there is no IPv4 address available in the
+	 * results.
+	 */
+	gai_pref = gai_results;
+	while (gai_pref) {
+		if (gai_pref->ai_addr->sa_family == AF_INET)
+			break;
+		gai_pref = gai_pref->ai_next;
+	}
+
+	/* no IPv4 addr found, just use first on the list */
+	if (gai_pref == NULL)
+		gai_pref = gai_results;
+
+	switch (gai_pref->ai_addr->sa_family) {
 	case AF_INET:
 	case AF_INET6:
-		if (len >= gai_results->ai_addrlen) {
-			*salen = gai_results->ai_addrlen;
-			memcpy(sap, gai_results->ai_addr, *salen);
+		if (len >= gai_pref->ai_addrlen) {
+			*salen = gai_pref->ai_addrlen;
+			memcpy(sap, gai_pref->ai_addr, *salen);
 			ret = 1;
 		}
 		break;
-- 
1.6.5.2

