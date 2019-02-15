Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57C7BC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:10:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 237CA21924
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:10:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389413AbfBOQKl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:10:41 -0500
Received: from mx1.redhat.com ([209.132.183.28]:53120 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729225AbfBOQKl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:10:41 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7456F1244CF;
        Fri, 15 Feb 2019 16:10:40 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id C36E95D70D;
        Fri, 15 Feb 2019 16:10:30 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 19/27] containers: Sample: request_key upcall handling
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:10:30 +0000
Message-ID: <155024703003.21651.3499235528404179500.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 15 Feb 2019 16:10:40 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Implement a sample upcall handling.

Firstly, the test-container sample is modified to (a) create a staging
keyring and to (b) intercept request_key calls for user-type keys inside
the container and place the authentication keys into that rather than
invoking /sbin/request-key.

Secondly, a test-upcall sample is added that will monitor the keyring for
notifications and spawn /sbin/request-key instances for each of key added.
This is run as:

	./test-upcall

to find a keyring called "upcall" in the session keyring (as created by the
./test-container program) and listen for additions to that, or it can be
run as:

	./test-upcall <keyring-id>

to listen on a specific keyring.

Note that the test-upcall sample is designed to be run separately from
test-container so that its stdout can be observed.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 samples/vfs/Makefile         |    6 +
 samples/vfs/test-container.c |   16 +++
 samples/vfs/test-upcall.c    |  243 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 264 insertions(+), 1 deletion(-)
 create mode 100644 samples/vfs/test-upcall.c

diff --git a/samples/vfs/Makefile b/samples/vfs/Makefile
index 25420919ee40..a8e9e1142ae3 100644
--- a/samples/vfs/Makefile
+++ b/samples/vfs/Makefile
@@ -5,7 +5,8 @@ hostprogs-$(CONFIG_SAMPLE_VFS) := \
 	test-fsmount \
 	test-mntinfo \
 	test-statx \
-	test-container
+	test-container \
+	test-upcall
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -18,5 +19,8 @@ HOSTLDLIBS_test-mntinfo += -lm
 HOSTCFLAGS_test-fs-query.o += -I$(objtree)/usr/include
 HOSTCFLAGS_test-fsmount.o += -I$(objtree)/usr/include
 HOSTCFLAGS_test-statx.o += -I$(objtree)/usr/include
+
 HOSTCFLAGS_test-container.o += -I$(objtree)/usr/include
 HOSTLDLIBS_test-container += -lkeyutils
+HOSTCFLAGS_test-upcall.o += -I$(objtree)/usr/include
+HOSTLDLIBS_test-upcall += -lkeyutils
diff --git a/samples/vfs/test-container.c b/samples/vfs/test-container.c
index 44ff57afb5a4..7dc9071399b2 100644
--- a/samples/vfs/test-container.c
+++ b/samples/vfs/test-container.c
@@ -20,6 +20,8 @@
 #include <sys/stat.h>
 #include <keyutils.h>
 
+#define KEYCTL_CONTAINER_INTERCEPT	31	/* Intercept upcalls inside a container */
+
 /* Hope -1 isn't a syscall */
 #ifndef __NR_fsopen
 #define __NR_fsopen -1
@@ -187,6 +189,7 @@ void container_init(void)
  */
 int main(int argc, char *argv[])
 {
+	key_serial_t keyring;
 	pid_t pid;
 	int fsfd, mfd, cfd, ws;
 
@@ -259,6 +262,19 @@ int main(int argc, char *argv[])
 	E(close(fsfd));
 	E(close(mfd));
 
+	/* Create a keyring to catch upcalls. */
+	printf("Intercepting...\n");
+	keyring = add_key("keyring", "upcall", NULL, 0, KEY_SPEC_SESSION_KEYRING);
+	if (keyring == -1) {
+		perror("add_key/u");
+		exit(1);
+	}
+
+	if (keyctl(KEYCTL_CONTAINER_INTERCEPT, cfd, "user", 0, keyring) < 0) {
+		perror("keyctl_container_intercept");
+		exit(1);
+	}
+
 	/* Start the 'init' process. */
 	printf("Forking...\n");
 	switch ((pid = fork_into_container(cfd))) {
diff --git a/samples/vfs/test-upcall.c b/samples/vfs/test-upcall.c
new file mode 100644
index 000000000000..225fa0325d1b
--- /dev/null
+++ b/samples/vfs/test-upcall.c
@@ -0,0 +1,243 @@
+/* Container keyring upcall management test.
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
+#include <fcntl.h>
+#include <errno.h>
+#include <poll.h>
+#include <sys/mman.h>
+#include <sys/ioctl.h>
+#include <keyutils.h>
+#include <linux/watch_queue.h>
+
+#define KEYCTL_WATCH_KEY		30	/* Watch a key or ring of keys for changes */
+#define KEYCTL_QUERY_REQUEST_KEY_AUTH	32	/* Query a request_key_auth key */
+#define KEYCTL_MOVE			33	/* Move keys between keyrings */
+#define KEYCTL_FIND_LRU			34	/* Find the least-recently used key in a keyring */
+
+struct keyctl_query_request_key_auth {
+	char		operation[32];	/* Operation name, typically "create" */
+	uid_t		fsuid;		/* UID of requester */
+	gid_t		fsgid;		/* GID of requester */
+	key_serial_t	target_key;	/* The key being instantiated */
+	key_serial_t	thread_keyring;	/* The requester's thread keyring */
+	key_serial_t	process_keyring; /* The requester's process keyring */
+	key_serial_t	session_keyring; /* The requester's session keyring */
+	long long	spare[1];
+};
+
+static void process_request(key_serial_t keyring, key_serial_t key)
+{
+	struct keyctl_query_request_key_auth info;
+	char target[32], uid[32], gid[32], thread[32], process[32], session[32];
+	void *callout;
+	long len;
+
+#if 0
+	key = keyctl(KEYCTL_FIND_LRU, keyring, ".request_key_auth");
+	if (key == -1) {
+		perror("keyctl/find");
+		exit(1);
+	}
+#endif
+
+	if (keyctl(KEYCTL_QUERY_REQUEST_KEY_AUTH, key, &info) == -1) {
+		perror("keyctl/query");
+		exit(1);
+	}
+
+	len = keyctl_read_alloc(key, &callout);
+	if (len == -1) {
+		perror("keyctl/read");
+		exit(1);
+	}
+
+	sprintf(target, "%d", info.target_key);
+	sprintf(uid, "%d", info.fsuid);
+	sprintf(gid, "%d", info.fsgid);
+	sprintf(thread, "%d", info.thread_keyring);
+	sprintf(process, "%d", info.process_keyring);
+	sprintf(session, "%d", info.session_keyring);
+
+	printf("Authentication key %d\n", key);
+	printf("- %s %s\n", info.operation, target);
+	printf("- uid=%s gid=%s\n", uid, gid);
+	printf("- rings=%s,%s,%s\n", thread, process, session);
+	printf("- callout='%s'\n", (char *)callout);
+
+	switch (fork()) {
+	case 0:
+		/* Only pass the auth token of interest onto /sbin/request-key */
+		if (keyctl(KEYCTL_MOVE, key, keyring, KEY_SPEC_THREAD_KEYRING) < 0) {
+			perror("keyctl_move/1");
+			exit(1);
+		}
+
+		if (keyctl_join_session_keyring(NULL) < 0) {
+			perror("keyctl_join");
+			exit(1);
+		}
+
+		if (keyctl(KEYCTL_MOVE, key,
+			   KEY_SPEC_THREAD_KEYRING, KEY_SPEC_SESSION_KEYRING) < 0) {
+			perror("keyctl_move/2");
+			exit(1);
+		}
+
+		execl("/sbin/request-key",
+		      "request-key", info.operation, target, uid, gid, thread, process, session,
+		      NULL);
+		perror("execve");
+		exit(1);
+
+	case -1:
+		perror("fork");
+		exit(1);
+
+	default:
+		return;
+	}
+}
+
+/*
+ * We saw a change on the keyring.
+ */
+static void saw_key_change(struct watch_notification *n)
+{
+	struct key_notification *k = (struct key_notification *)n;
+	unsigned int len = n->info & WATCH_INFO_LENGTH;
+
+	if (len != sizeof(struct key_notification))
+		return;
+
+	printf("KEY %d change=%u aux=%d\n", k->key_id, n->subtype, k->aux);
+
+	process_request(k->key_id, k->aux);
+}
+
+/*
+ * Consume and display events.
+ */
+static int consumer(int fd, struct watch_queue_buffer *buf)
+{
+	struct watch_notification *n;
+	struct pollfd p[1];
+	unsigned int head, tail, mask = buf->meta.mask;
+
+	for (;;) {
+		p[0].fd = fd;
+		p[0].events = POLLIN | POLLERR;
+		p[0].revents = 0;
+
+		if (poll(p, 1, -1) == -1) {
+			perror("poll");
+			break;
+		}
+
+		printf("ptrs h=%x t=%x m=%x\n",
+		       buf->meta.head, buf->meta.tail, buf->meta.mask);
+
+		while (head = __atomic_load_n(&buf->meta.head, __ATOMIC_ACQUIRE),
+		       tail = buf->meta.tail,
+		       tail != head
+		       ) {
+			n = &buf->slots[tail & mask];
+			printf("NOTIFY[%08x-%08x] ty=%04x sy=%04x i=%08x\n",
+			       head, tail, n->type, n->subtype, n->info);
+			if ((n->info & WATCH_INFO_LENGTH) == 0)
+				goto out;
+
+			switch (n->type) {
+			case WATCH_TYPE_META:
+				if (n->subtype == WATCH_META_REMOVAL_NOTIFICATION)
+					printf("REMOVAL of watchpoint %08x\n",
+					       n->info & WATCH_INFO_ID);
+				break;
+			case WATCH_TYPE_KEY_NOTIFY:
+				saw_key_change(n);
+				break;
+			}
+
+			tail += (n->info & WATCH_INFO_LENGTH) >> WATCH_LENGTH_SHIFT;
+			__atomic_store_n(&buf->meta.tail, tail, __ATOMIC_RELEASE);
+		}
+	}
+
+out:
+	return 0;
+}
+
+/*
+ * We're only interested in key insertion events.
+ */
+static struct watch_notification_filter filter = {
+	.nr_filters	= 1,
+	.filters = {
+		[0] = {
+			.type			= WATCH_TYPE_KEY_NOTIFY,
+			.subtype_filter[0]	= (1 << NOTIFY_KEY_LINKED),
+		},
+	}
+};
+
+int main(int argc, char *argv[])
+{
+	struct watch_queue_buffer *buf;
+	key_serial_t keyring;
+	size_t page_size = sysconf(_SC_PAGESIZE);
+	int fd;
+
+	if (argc == 1) {
+		keyring = keyctl_search(KEY_SPEC_SESSION_KEYRING, "keyring",
+					"upcall", 0);
+		if (keyring == -1) {
+			perror("keyctl_search");
+			exit(1);
+		}
+	} else if (argc == 2) {
+		keyring = strtoul(argv[1], NULL, 0);
+	} else {
+		fprintf(stderr, "Format: test-upcall [<keyring>]\n");
+		exit(2);
+	}
+
+	/* Create a watch on the keyring to detect the addition of keys. */
+	fd = open("/dev/watch_queue", O_RDWR | O_CLOEXEC);
+	if (fd == -1) {
+		perror("/dev/watch_queue");
+		exit(1);
+	}
+
+	if (ioctl(fd, IOC_WATCH_QUEUE_SET_SIZE, 1) == -1) {
+		perror("/dev/watch_queue(size)");
+		exit(1);
+	}
+
+	if (ioctl(fd, IOC_WATCH_QUEUE_SET_FILTER, &filter) == -1) {
+		perror("/dev/watch_queue(filter)");
+		exit(1);
+	}
+
+	buf = mmap(NULL, page_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
+	if (buf == MAP_FAILED) {
+		perror("mmap");
+		exit(1);
+	}
+
+	if (keyctl(KEYCTL_WATCH_KEY, keyring, fd, 0x01) == -1) {
+		perror("keyctl");
+		exit(1);
+	}
+
+	return consumer(fd, buf);
+}

