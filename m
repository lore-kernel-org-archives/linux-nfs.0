From: steved@redhat.com
Subject: [PATCH 23/23] Fixed a typo in gss_verify_mic_v2()
Date: Wed, 17 Mar 2010 13:03:08 -0400
Message-ID: <1268845388-9516-24-git-send-email-steved@redhat.com>
References: <1268845388-9516-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:43425 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755288Ab0CQR0O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 13:26:14 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1NrweK-0003fC-EE
	for linux-nfs@vger.kernel.org; Wed, 17 Mar 2010 13:03:16 -0400
In-Reply-To: <1268845388-9516-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peter Staubach <staubach@redhat.com>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 net/sunrpc/auth_gss/gss_krb5_unseal.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index e6aec12..aa62b4c 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -200,7 +200,7 @@ gss_verify_mic_v2(struct krb5_ctx *ctx,
 
 	/* do sequencing checks */
 
-	seqnum = be64_to_cpu((__be64 *)ptr + 8);
+	seqnum = be64_to_cpup((__be64 *)ptr + 8);
 
 	return GSS_S_COMPLETE;
 }
-- 
1.6.6.1

