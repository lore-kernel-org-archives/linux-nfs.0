From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 3: PATCH 04/24] gss_krb5: Use random value to
	initialize confounder
Date: Tue, 06 May 2008 17:03:51 -0400
Message-ID: <20080506210350.3770.10631.stgit@jazz.citi.umich.edu>
References: <20080506210156.3770.95914.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:7406 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762607AbYEFVDv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:03:51 -0400
In-Reply-To: <20080506210156.3770.95914.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Initialize the value used for the confounder to a random value
rather than starting from zero.
Allow for confounders of length 8 or 16 (which will be needed for AES).

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 net/sunrpc/auth_gss/gss_krb5_wrap.c |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index e809571..a0660f5 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -87,8 +87,8 @@ out:
 	return 0;
 }
 
-static inline void
-make_confounder(char *p, int blocksize)
+static void
+make_confounder(char *p, u32 conflen)
 {
 	static u64 i = 0;
 	u64 *q = (u64 *)p;
@@ -102,8 +102,22 @@ make_confounder(char *p, int blocksize)
 	 * uniqueness would mean worrying about atomicity and rollover, and I
 	 * don't care enough. */
 
-	BUG_ON(blocksize != 8);
-	*q = i++;
+	/* initialize to random value */
+	if (i == 0) {
+		i = random32();
+		i = (i << 32) | random32();
+	}
+
+	switch (conflen) {
+	case 16:
+		*q++ = i++;
+		/* fall through */
+	case 8:
+		*q++ = i++;
+		break;
+	default:
+		BUG();
+	}
 }
 
 /* Assumptions: the head and tail of inbuf are ours to play with.

