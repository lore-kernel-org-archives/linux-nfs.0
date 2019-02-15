Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A006C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:12:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D3E3421924
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:12:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391141AbfBOQMT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:12:19 -0500
Received: from mx1.redhat.com ([209.132.183.28]:36438 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727559AbfBOQMN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:12:13 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 5B056C2E26;
        Fri, 15 Feb 2019 16:12:12 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 32CEA60933;
        Fri, 15 Feb 2019 16:12:10 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 26/27] keys: Allow containers to be included in key ACLs
 by name
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:12:09 +0000
Message-ID: <155024712939.21651.14094051420890992278.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 15 Feb 2019 16:12:12 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Allow a container to be specified to KEYCTL_GRANT_PERMISSION by name.  This
allows processes that don't have access to the container fd to grant
permission on a key to a container.  This is restricted to the containers
that are children of the current container.

This can be effected with something like:

	keyctl(KEYCTL_GRANT_PERMISSION, key,
	       KEY_ACE_SUBJ_CONTAINER_NAME, "foo-test",
	       KEY_ACE_SEARCH);


Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/container.h   |    1 +
 include/uapi/linux/keyctl.h |    1 +
 kernel/container.c          |   24 ++++++++++++++++++++++++
 security/keys/compat.c      |    4 ++++
 security/keys/internal.h    |    2 +-
 security/keys/keyctl.c      |    2 +-
 security/keys/permission.c  |   19 ++++++++++++++++++-
 7 files changed, 50 insertions(+), 3 deletions(-)

diff --git a/include/linux/container.h b/include/linux/container.h
index cd82074c26a3..fd49ce23467d 100644
--- a/include/linux/container.h
+++ b/include/linux/container.h
@@ -61,6 +61,7 @@ extern struct container init_container;
 #ifdef CONFIG_CONTAINERS
 extern const struct file_operations container_fops;
 
+extern struct container *find_container(const char *name);
 extern int copy_container(unsigned long flags, struct task_struct *tsk,
 			  struct container *container);
 extern void exit_container(struct task_struct *tsk);
diff --git a/include/uapi/linux/keyctl.h b/include/uapi/linux/keyctl.h
index 89ab609f774c..31520da17f37 100644
--- a/include/uapi/linux/keyctl.h
+++ b/include/uapi/linux/keyctl.h
@@ -21,6 +21,7 @@
 enum key_ace_subject_type {
 	KEY_ACE_SUBJ_STANDARD	= 0,	/* subject is one of key_ace_standard_subject */
 	KEY_ACE_SUBJ_CONTAINER	= 1,	/* subject is a container fd */
+	KEY_ACE_SUBJ_CONTAINER_NAME = 2, /* subject is a container name pointer */
 	nr__key_ace_subject_type
 };
 
diff --git a/kernel/container.c b/kernel/container.c
index 81be4ed915c2..c164c16328d6 100644
--- a/kernel/container.c
+++ b/kernel/container.c
@@ -235,6 +235,30 @@ struct container *fd_to_container(int fd)
 	return c;
 }
 
+/**
+ * find_container - Find a child container by name.
+ * @name: The name of the container to find.
+ *
+ * Find a child of the current container by name.
+ */
+struct container *find_container(const char *name)
+{
+	struct container *c = current->container, *p;
+
+	spin_lock(&c->lock);
+	list_for_each_entry(p, &c->children, child_link) {
+		if (strcmp(p->name, name) == 0) {
+			get_container(p);
+			goto found;
+		}
+	}
+
+	p = NULL;
+found:
+	spin_unlock(&c->lock);
+	return p;
+}
+
 /*
  * Handle fork/clone.
  *
diff --git a/security/keys/compat.c b/security/keys/compat.c
index 953156f94320..78c6c0e0eb59 100644
--- a/security/keys/compat.c
+++ b/security/keys/compat.c
@@ -175,6 +175,10 @@ COMPAT_SYSCALL_DEFINE5(keyctl, u32, option,
 	case KEYCTL_MOVE:
 		return keyctl_keyring_move(arg2, arg3, arg4, arg5);
 	case KEYCTL_GRANT_PERMISSION:
+		if (arg3 == KEY_ACE_SUBJ_CONTAINER_NAME)
+			return keyctl_grant_permission(arg2, arg3,
+						       (unsigned long)compat_ptr(arg4),
+						       arg5);
 		return keyctl_grant_permission(arg2, arg3, arg4, arg5);
 
 	default:
diff --git a/security/keys/internal.h b/security/keys/internal.h
index 6cd7b5c17298..aa4ad9c8002e 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -379,7 +379,7 @@ extern long keyctl_set_container_keyring(int, key_serial_t);
 
 extern long keyctl_grant_permission(key_serial_t keyid,
 				    enum key_ace_subject_type type,
-				    unsigned int subject,
+				    unsigned long subject,
 				    unsigned int perm);
 
 /*
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index 02bd73d5a05a..978c9008c3b2 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -1964,7 +1964,7 @@ SYSCALL_DEFINE5(keyctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case KEYCTL_GRANT_PERMISSION:
 		return keyctl_grant_permission((key_serial_t)arg2,
 					       (enum key_ace_subject_type)arg3,
-					       (unsigned int)arg4,
+					       (unsigned long)arg4,
 					       (unsigned int)arg5);
 
 	default:
diff --git a/security/keys/permission.c b/security/keys/permission.c
index f16d1665885f..b0e94ccc4635 100644
--- a/security/keys/permission.c
+++ b/security/keys/permission.c
@@ -407,7 +407,7 @@ static long key_change_acl(struct key *key, struct key_ace *new_ace)
  */
 long keyctl_grant_permission(key_serial_t keyid,
 			     enum key_ace_subject_type type,
-			     unsigned int subject,
+			     unsigned long subject,
 			     unsigned int perm)
 {
 	struct key_ace new_ace;
@@ -436,6 +436,23 @@ long keyctl_grant_permission(key_serial_t keyid,
 		put_container(c);
 		break;
 	}
+	case KEY_ACE_SUBJ_CONTAINER_NAME: {
+		struct container *c;
+		char *name;
+
+		name = strndup_user((const char __user *)subject, 23);
+		if (IS_ERR(name))
+			return PTR_ERR(name);
+		c = find_container(name);
+		kfree(name);
+		if (!c)
+			return -EINVAL;
+		new_ace.type = KEY_ACE_SUBJ_CONTAINER;
+		refcount_inc(&c->tag->usage);
+		new_ace.container_tag = c->tag;
+		put_container(c);
+		break;
+	}
 #endif
 
 	default:

