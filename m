Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3936C4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:12:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AB2712192B
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:12:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727559AbfBOQM2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:12:28 -0500
Received: from mx1.redhat.com ([209.132.183.28]:36804 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727183AbfBOQM1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:12:27 -0500
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 823E8C7943;
        Fri, 15 Feb 2019 16:12:25 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 4BEFE60C62;
        Fri, 15 Feb 2019 16:12:19 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 27/27] containers: Sample to grant access to a key in a
 container
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:12:17 +0000
Message-ID: <155024713756.21651.13272811997083735868.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 15 Feb 2019 16:12:26 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Provide a sample program that will grant access to the specified key for a
container named "foo-test" (as created by the test-container sample) and
then link the key into the container keyring (either given on the command
line or searches for a keyring called "_container" in the session keyring
as placed there by the test-container sample).

So, for example, this could be used to place an rxrpc key in the container
keyring for kAFS inside the container to use:

 (1) Poke kerberos to get a ticket for accessing AFS.

	# kinit
	# aklog-kafs redhat.com

 (2) Find the rxrpc key ID:

	# keyctl show
	Session Keyring
	1071328996 --alswrv      0     0  keyring: _ses
	 574060623 ---lswrv      0 65534   \_ keyring: _uid.0
	1004048468 --alswrv      0     0   \_ rxrpc: afs@redhat.com
	 918328787 --alswrv      0     0   \_ keyring: upcall
	 996275498 --alswrv      0     0   \_ keyring: _container
	 785497401 --alswrv      0     0       \_ user: foobar

     which would be 1004048468 in this example.

 (3) Invoke the sample:

	# test-cont-grant 1004048468

     The rxrpc key can now be seen in the container keyring:

	# keyctl show
	Session Keyring
	1071328996 --alswrv      0     0  keyring: _ses
	 574060623 ---lswrv      0 65534   \_ keyring: _uid.0
	1004048468 --alswrv      0     0   \_ rxrpc: afs@redhat.com
	 918328787 --alswrv      0     0   \_ keyring: upcall
	 996275498 --alswrv      0     0   \_ keyring: _container
	 785497401 --alswrv      0     0       \_ user: foobar
	1004048468 --alswrv      0     0       \_ rxrpc: afs@redhat.com

 (4) Mount the kAFS filesystem inside the container:

	> mount -t afs "%redhat.com:root.cell" /mnt

The contents of /mnt can then be used from inside the container using the
key placed into the container keyring.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 samples/vfs/Makefile          |    3 +
 samples/vfs/test-cont-grant.c |   84 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 87 insertions(+)
 create mode 100644 samples/vfs/test-cont-grant.c

diff --git a/samples/vfs/Makefile b/samples/vfs/Makefile
index a8e9e1142ae3..c8eea193a856 100644
--- a/samples/vfs/Makefile
+++ b/samples/vfs/Makefile
@@ -6,6 +6,7 @@ hostprogs-$(CONFIG_SAMPLE_VFS) := \
 	test-mntinfo \
 	test-statx \
 	test-container \
+	test-cont-grant \
 	test-upcall
 
 # Tell kbuild to always build the programs
@@ -22,5 +23,7 @@ HOSTCFLAGS_test-statx.o += -I$(objtree)/usr/include
 
 HOSTCFLAGS_test-container.o += -I$(objtree)/usr/include
 HOSTLDLIBS_test-container += -lkeyutils
+HOSTCFLAGS_test-cont-grant.o += -I$(objtree)/usr/include
+HOSTLDLIBS_test-cont-grant += -lkeyutils
 HOSTCFLAGS_test-upcall.o += -I$(objtree)/usr/include
 HOSTLDLIBS_test-upcall += -lkeyutils
diff --git a/samples/vfs/test-cont-grant.c b/samples/vfs/test-cont-grant.c
new file mode 100644
index 000000000000..da4a60bc71fa
--- /dev/null
+++ b/samples/vfs/test-cont-grant.c
@@ -0,0 +1,84 @@
+/* Link a key into a container keyring and grant perms to the container.
+ *
+ * Copyright (C) 2019 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <errno.h>
+#include <sys/wait.h>
+#include <linux/mount.h>
+#include <linux/unistd.h>
+#include <dirent.h>
+#include <sys/stat.h>
+#include <keyutils.h>
+
+#define KEYCTL_GRANT_PERMISSION		36	/* Grant a permit to a key */
+
+enum key_ace_subject_type {
+	KEY_ACE_SUBJ_STANDARD	= 0,	/* subject is one of key_ace_standard_subject */
+	KEY_ACE_SUBJ_CONTAINER	= 1,	/* subject is a container fd */
+	KEY_ACE_SUBJ_CONTAINER_NAME = 2, /* subject is a container name pointer */
+};
+
+enum key_ace_standard_subject {
+	KEY_ACE_EVERYONE	= 0,	/* Everyone, including owner and group */
+	KEY_ACE_GROUP		= 1,	/* The key's group */
+	KEY_ACE_OWNER		= 2,	/* The owner of the key */
+	KEY_ACE_POSSESSOR	= 3,	/* Any process that possesses of the key */
+};
+
+#define KEY_ACE_VIEW		0x00000001 /* Can describe the key */
+#define KEY_ACE_READ		0x00000002 /* Can read the key content */
+#define KEY_ACE_WRITE		0x00000004 /* Can update/modify the key content */
+#define KEY_ACE_SEARCH		0x00000008 /* Can find the key by search */
+#define KEY_ACE_LINK		0x00000010 /* Can make a link to the key */
+#define KEY_ACE_SET_SECURITY	0x00000020 /* Can set owner, group, ACL */
+#define KEY_ACE_INVAL		0x00000040 /* Can invalidate the key */
+#define KEY_ACE_REVOKE		0x00000080 /* Can revoke the key */
+#define KEY_ACE_JOIN		0x00000100 /* Can join keyring */
+#define KEY_ACE_CLEAR		0x00000200 /* Can clear keyring */
+
+int main(int argc, char *argv[])
+{
+	key_serial_t key, keyring;
+
+	if (argc == 2) {
+		printf("Find keyring '_container'...\n");
+		keyring = keyctl_search(KEY_SPEC_SESSION_KEYRING, "keyring", "_container", 0);
+		if (keyring == -1) {
+			perror("keyctl_search");
+			exit(1);
+		}
+
+		key = atoi(argv[1]);
+	} else if (argc == 3) {
+		printf("Use specified keyring...\n");
+		keyring = atoi(argv[2]);
+		key = atoi(argv[1]);
+	} else {
+		fprintf(stderr, "Format: test-cont-grant <key> [<cont-keyring>]\n");
+		exit(2);
+	}
+
+	if (keyctl(KEYCTL_GRANT_PERMISSION, key,
+		   KEY_ACE_SUBJ_CONTAINER_NAME, "foo-test",
+		   KEY_ACE_SEARCH) < 0) {
+		perror("keyctl_grant/s");
+		exit(1);
+	}
+
+	if (keyctl_link(key, keyring) < 0) {
+		perror("keyctl_link");
+		exit(1);
+	}
+
+	exit(0);
+}

