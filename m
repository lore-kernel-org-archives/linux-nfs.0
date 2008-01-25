From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 043/100] sunrpc: gss: simplify rsi_parse logic
Date: Fri, 25 Jan 2008 18:16:23 -0500
Message-ID: <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47399 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761637AbYAYXRj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:39 -0500
In-Reply-To: <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make an obvious simplification that removes a few lines and some
unnecessary indentation; no change in behavior.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/svcauth_gss.c |   52 +++++++++++++++++--------------------
 1 files changed, 24 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 688cc31..e8ed848 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -224,38 +224,34 @@ static int rsi_parse(struct cache_detail *cd,
 
 	/* major/minor */
 	len = qword_get(&mesg, buf, mlen);
-	if (len < 0)
+	if (len <= 0)
 		goto out;
-	if (len == 0) {
+	rsii.major_status = simple_strtoul(buf, &ep, 10);
+	if (*ep)
+		goto out;
+	len = qword_get(&mesg, buf, mlen);
+	if (len <= 0)
+		goto out;
+	rsii.minor_status = simple_strtoul(buf, &ep, 10);
+	if (*ep)
 		goto out;
-	} else {
-		rsii.major_status = simple_strtoul(buf, &ep, 10);
-		if (*ep)
-			goto out;
-		len = qword_get(&mesg, buf, mlen);
-		if (len <= 0)
-			goto out;
-		rsii.minor_status = simple_strtoul(buf, &ep, 10);
-		if (*ep)
-			goto out;
 
-		/* out_handle */
-		len = qword_get(&mesg, buf, mlen);
-		if (len < 0)
-			goto out;
-		status = -ENOMEM;
-		if (dup_to_netobj(&rsii.out_handle, buf, len))
-			goto out;
+	/* out_handle */
+	len = qword_get(&mesg, buf, mlen);
+	if (len < 0)
+		goto out;
+	status = -ENOMEM;
+	if (dup_to_netobj(&rsii.out_handle, buf, len))
+		goto out;
 
-		/* out_token */
-		len = qword_get(&mesg, buf, mlen);
-		status = -EINVAL;
-		if (len < 0)
-			goto out;
-		status = -ENOMEM;
-		if (dup_to_netobj(&rsii.out_token, buf, len))
-			goto out;
-	}
+	/* out_token */
+	len = qword_get(&mesg, buf, mlen);
+	status = -EINVAL;
+	if (len < 0)
+		goto out;
+	status = -ENOMEM;
+	if (dup_to_netobj(&rsii.out_token, buf, len))
+		goto out;
 	rsii.h.expiry_time = expiry;
 	rsip = rsi_update(&rsii, rsip);
 	status = 0;
-- 
1.5.4.rc2.60.gb2e62

