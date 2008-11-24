From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NLM: client-side nlm_lookup_host() should avoid matching on
	srcaddr
Date: Mon, 24 Nov 2008 12:51:55 -0500
Message-ID: <20081124175112.2828.84326.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:45187 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbYKXRwb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Nov 2008 12:52:31 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit c98451bd, the loop in nlm_lookup_host() unconditionally
compares the host's h_srcaddr field to the incoming source address.
For client-side nlm_host entries, both are always AF_UNSPEC, so this
check is unnecessary.

Since commit 781b61a6, which added support for AF_INET6 addresses to
nlm_cmp_addr(), nlm_cmp_addr() now returns FALSE for AF_UNSPEC
addresses, which causes nlm_lookup_host() to create a fresh nlm_host
entry every time it is called on the client.

These extra entries will eventually expire once the server is
unmounted, so the impact of this regression, introduced with lockd
IPv6 support in 2.6.28, should be minor.

We could fix this by adding an arm in nlm_cmp_addr() for AF_UNSPEC
addresses, but really, nlm_lookup_host() shouldn't be matching on the
srcaddr field for client-side nlm_host lookups.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 9fd8889..70fc63a 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -167,7 +167,8 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 			continue;
 		if (host->h_server != ni->server)
 			continue;
-		if (!nlm_cmp_addr(nlm_srcaddr(host), ni->src_sap))
+		if (ni->server &&
+		    !nlm_cmp_addr(nlm_srcaddr(host), ni->src_sap))
 			continue;
 
 		/* Move to head of hash chain. */

