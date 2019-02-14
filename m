Return-Path: <SRS0=jvUk=QV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19C93C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 16:57:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D74FB21928
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 16:57:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2502801AbfBNQ5E (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Feb 2019 11:57:04 -0500
Received: from mx1.redhat.com ([209.132.183.28]:41952 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2502797AbfBNQ5D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Feb 2019 11:57:03 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7E33F7EBC1;
        Thu, 14 Feb 2019 16:57:03 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id C86EB101960D;
        Thu, 14 Feb 2019 16:56:52 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 1/9] keys: Invalidate used request_key authentication
 keys
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Thu, 14 Feb 2019 16:56:50 +0000
Message-ID: <155016341076.11489.17906138075234365532.stgit@warthog.procyon.org.uk>
In-Reply-To: <155016339876.11489.901851271827069026.stgit@warthog.procyon.org.uk>
References: <155016339876.11489.901851271827069026.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 14 Feb 2019 16:57:03 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Invalidate used request_key authentication keys rather than revoking them
so that they get cleaned up immediately rather than potentially hanging
around.  There doesn't seem any need to keep the revoked keys around.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 security/keys/key.c         |    4 ++--
 security/keys/request_key.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/security/keys/key.c b/security/keys/key.c
index 696f1c092c50..d705b950ce2a 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -459,7 +459,7 @@ static int __key_instantiate_and_link(struct key *key,
 
 			/* disable the authorisation key */
 			if (authkey)
-				key_revoke(authkey);
+				key_invalidate(authkey);
 
 			if (prep->expiry != TIME64_MAX) {
 				key->expiry = prep->expiry;
@@ -607,7 +607,7 @@ int key_reject_and_link(struct key *key,
 
 		/* disable the authorisation key */
 		if (authkey)
-			key_revoke(authkey);
+			key_invalidate(authkey);
 	}
 
 	mutex_unlock(&key_construction_mutex);
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index 3f56a312dd35..7e935553af2b 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -224,7 +224,7 @@ static int construct_key(struct key *key, const void *callout_info,
 	/* check that the actor called complete_request_key() prior to
 	 * returning an error */
 	WARN_ON(ret < 0 &&
-		!test_bit(KEY_FLAG_REVOKED, &authkey->flags));
+		!test_bit(KEY_FLAG_INVALIDATED, &authkey->flags));
 
 	key_put(authkey);
 	kleave(" = %d", ret);

