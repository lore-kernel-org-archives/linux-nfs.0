From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 06/19] Use get_random_bytes() to create confounder
Date: Thu, 21 Feb 2008 13:44:17 -0500
Message-ID: <20080221184417.19195.55123.stgit@jazz.citi.umich.edu>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:48155 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753137AbYBUSoR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 13:44:17 -0500
Received: from jazz.citi.umich.edu (jazz.citi.umich.edu [141.211.133.62])
	by citi.umich.edu (Postfix) with ESMTP id 62F094606
	for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2008 13:44:17 -0500 (EST)
In-Reply-To: <20080221184208.19195.94518.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of using an incementing value for the confounder, use
get_random_bytes() which gives us the desired unpredictable value.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 net/sunrpc/auth_gss/gss_krb5_wrap.c |   15 +--------------
 1 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index a2c92f1..7a0002f 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -90,20 +90,7 @@ out:
 static inline void
 make_confounder(char *p, int blocksize)
 {
-	static u64 i = 0;
-	u64 *q = (u64 *)p;
-
-	/* rfc1964 claims this should be "random".  But all that's really
-	 * necessary is that it be unique.  And not even that is necessary in
-	 * our case since our "gssapi" implementation exists only to support
-	 * rpcsec_gss, so we know that the only buffers we will ever encrypt
-	 * already begin with a unique sequence number.  Just to hedge my bets
-	 * I'll make a half-hearted attempt at something unique, but ensuring
-	 * uniqueness would mean worrying about atomicity and rollover, and I
-	 * don't care enough. */
-
-	BUG_ON(blocksize != 8);
-	*q = i++;
+	get_random_bytes(p, blocksize);
 }
 
 /* Assumptions: the head and tail of inbuf are ours to play with.

