Return-Path: <SRS0=jvUk=QV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95ABBC10F04
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 16:58:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6C5DC222DD
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 16:58:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2502853AbfBNQ5W (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Feb 2019 11:57:22 -0500
Received: from mx1.redhat.com ([209.132.183.28]:4851 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2502823AbfBNQ5V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Feb 2019 11:57:21 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id BF2CD81DF3;
        Thu, 14 Feb 2019 16:57:20 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 820F8611B0;
        Thu, 14 Feb 2019 16:57:09 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 2/9] keys: Kill off request_key_async{,_with_auxdata}
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Thu, 14 Feb 2019 16:57:08 +0000
Message-ID: <155016342870.11489.3526179007799503736.stgit@warthog.procyon.org.uk>
In-Reply-To: <155016339876.11489.901851271827069026.stgit@warthog.procyon.org.uk>
References: <155016339876.11489.901851271827069026.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 14 Feb 2019 16:57:20 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Kill off request_key_async{,_with_auxdata}() as they're not currently used.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/key.h         |   11 ---------
 security/keys/request_key.c |   50 -------------------------------------------
 2 files changed, 61 deletions(-)

diff --git a/include/linux/key.h b/include/linux/key.h
index 7099985e35a9..aaa93fe3f587 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -280,17 +280,6 @@ extern struct key *request_key_with_auxdata(struct key_type *type,
 					    size_t callout_len,
 					    void *aux);
 
-extern struct key *request_key_async(struct key_type *type,
-				     const char *description,
-				     const void *callout_info,
-				     size_t callout_len);
-
-extern struct key *request_key_async_with_auxdata(struct key_type *type,
-						  const char *description,
-						  const void *callout_info,
-						  size_t callout_len,
-						  void *aux);
-
 extern int wait_for_key_construction(struct key *key, bool intr);
 
 extern int key_validate(const struct key *key);
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index 7e935553af2b..7d716876a29b 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -686,53 +686,3 @@ struct key *request_key_with_auxdata(struct key_type *type,
 	return key;
 }
 EXPORT_SYMBOL(request_key_with_auxdata);
-
-/*
- * request_key_async - Request a key (allow async construction)
- * @type: Type of key.
- * @description: The searchable description of the key.
- * @callout_info: The data to pass to the instantiation upcall (or NULL).
- * @callout_len: The length of callout_info.
- *
- * As for request_key_and_link() except that it does not add the returned key
- * to a keyring if found, new keys are always allocated in the user's quota and
- * no auxiliary data can be passed.
- *
- * The caller should call wait_for_key_construction() to wait for the
- * completion of the returned key if it is still undergoing construction.
- */
-struct key *request_key_async(struct key_type *type,
-			      const char *description,
-			      const void *callout_info,
-			      size_t callout_len)
-{
-	return request_key_and_link(type, description, callout_info,
-				    callout_len, NULL, NULL,
-				    KEY_ALLOC_IN_QUOTA);
-}
-EXPORT_SYMBOL(request_key_async);
-
-/*
- * request a key with auxiliary data for the upcaller (allow async construction)
- * @type: Type of key.
- * @description: The searchable description of the key.
- * @callout_info: The data to pass to the instantiation upcall (or NULL).
- * @callout_len: The length of callout_info.
- * @aux: Auxiliary data for the upcall.
- *
- * As for request_key_and_link() except that it does not add the returned key
- * to a keyring if found and new keys are always allocated in the user's quota.
- *
- * The caller should call wait_for_key_construction() to wait for the
- * completion of the returned key if it is still undergoing construction.
- */
-struct key *request_key_async_with_auxdata(struct key_type *type,
-					   const char *description,
-					   const void *callout_info,
-					   size_t callout_len,
-					   void *aux)
-{
-	return request_key_and_link(type, description, callout_info,
-				    callout_len, aux, NULL, KEY_ALLOC_IN_QUOTA);
-}
-EXPORT_SYMBOL(request_key_async_with_auxdata);

