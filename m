Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CDDCC4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:12:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3467421924
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:12:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2392441AbfBOQMF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:12:05 -0500
Received: from mx1.redhat.com ([209.132.183.28]:46436 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388701AbfBOQME (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:12:04 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2E58EC0AE662;
        Fri, 15 Feb 2019 16:12:04 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 0617D5D6A9;
        Fri, 15 Feb 2019 16:12:01 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 25/27] keys: Provide a way to ask for the container
 keyring
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:11:58 +0000
Message-ID: <155024711895.21651.13875852239032339316.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 15 Feb 2019 16:12:04 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Provide a constant that can be used in place of a key ID to indicate the
keyring belonging to the current process's container.  Used as:

	key_serial_t container_keyring =
		keyctl_get_key_ID(KEY_SPEC_CONTAINER_KEYRING, 0);

Note that this is merely a 'macro' for the ID of the keyring.  To be able
to actually do anything with it requires the keyring to grant appropriate
permissions to the denizens of the container.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/uapi/linux/keyctl.h  |    1 +
 samples/vfs/test-container.c |   15 +++++++++++++++
 security/keys/process_keys.c |    7 +++++++
 3 files changed, 23 insertions(+)

diff --git a/include/uapi/linux/keyctl.h b/include/uapi/linux/keyctl.h
index 7136d14dd4d7..89ab609f774c 100644
--- a/include/uapi/linux/keyctl.h
+++ b/include/uapi/linux/keyctl.h
@@ -88,6 +88,7 @@ enum key_ace_standard_subject {
 #define KEY_SPEC_GROUP_KEYRING		-6	/* - key ID for GID-specific keyring */
 #define KEY_SPEC_REQKEY_AUTH_KEY	-7	/* - key ID for assumed request_key auth key */
 #define KEY_SPEC_REQUESTOR_KEYRING	-8	/* - key ID for request_key() dest keyring */
+#define KEY_SPEC_CONTAINER_KEYRING	-9	/* - key ID for current->container's keyring */
 
 /* request-key default keyrings */
 #define KEY_REQKEY_DEFL_NO_CHANGE		-1
diff --git a/samples/vfs/test-container.c b/samples/vfs/test-container.c
index 7b2081693fce..4716dd50b696 100644
--- a/samples/vfs/test-container.c
+++ b/samples/vfs/test-container.c
@@ -20,6 +20,7 @@
 #include <sys/stat.h>
 #include <keyutils.h>
 
+#define KEY_SPEC_CONTAINER_KEYRING	-9	/* - key ID for current->container's keyring */
 #define KEYCTL_CONTAINER_INTERCEPT	31	/* Intercept upcalls inside a container */
 #define KEYCTL_SET_CONTAINER_KEYRING	35	/* Attach a keyring to a container */
 #define KEYCTL_GRANT_PERMISSION		36	/* Grant a permit to a key */
@@ -160,6 +161,8 @@ static inline int fork_into_container(int containerfd)
 static __attribute__((noreturn))
 void container_init(void)
 {
+	key_serial_t ckey;
+
 	if (0) {
 		/* Do a bit of debugging on the container. */
 		struct dirent **dlist;
@@ -203,6 +206,12 @@ void container_init(void)
 		exit(1);
 	}
 
+	ckey = keyctl_get_keyring_ID(KEY_SPEC_CONTAINER_KEYRING, 0);
+	if (ckey == -1)
+		perror("keyctl_get_keyring_ID");
+	else
+		printf("Container keyring %d\n", ckey);
+	
 	setenv("PS1", "container>", 1);
 	execl("/bin/bash", "bash", NULL);
 	perror("execl");
@@ -310,6 +319,12 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 
+	if (keyctl(KEYCTL_GRANT_PERMISSION, keyring,
+		   KEY_ACE_SUBJ_STANDARD, KEY_ACE_OWNER, 0) < 0) {
+		perror("keyctl_grant/s");
+		exit(1);
+	}
+
 	if (keyctl(KEYCTL_SET_CONTAINER_KEYRING, cfd, keyring) < 0) {
 		perror("keyctl_set_container_keyring");
 		exit(1);
diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index f296a1cc979a..f8f580a760c9 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -725,6 +725,13 @@ key_ref_t lookup_user_key(key_serial_t id, unsigned long lflags,
 		key_ref = make_key_ref(key, 1);
 		break;
 
+	case KEY_SPEC_CONTAINER_KEYRING:
+		key = current->container->keyring;
+		if (!key)
+			goto error;
+		key_ref = make_key_ref(key, 0);
+		goto error;
+
 	default:
 		key_ref = ERR_PTR(-EINVAL);
 		if (id < 1)

