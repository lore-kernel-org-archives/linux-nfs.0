Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39524 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751081AbdE3QNS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 May 2017 12:13:18 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <149616052408.10194.7774163568767478808.stgit@warthog.procyon.org.uk>
References: <149616052408.10194.7774163568767478808.stgit@warthog.procyon.org.uk>
To: James.Bottomley@HansenPartnership.com, ebiederm@xmission.com
Cc: linux-nfs@vger.kernel.org, containers@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        keyrings@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        cgroups@vger.kernel.org
Subject: Example daemon program
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 30 May 2017 17:13:10 +0100
Message-ID: <10295.1496160790@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's a one-shot example daemon that services user-type keys.

David
---
/* request_key() service daemon
 *
 * Copyright (C) 2017 Red Hat, Inc. All Rights Reserved.
 * Written by David Howells (dhowells@redhat.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public Licence
 * as published by the Free Software Foundation; either version
 * 2 of the Licence, or (at your option) any later version.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <keyutils.h>

#define KEY_SERVICE_NS_UTS		0x0001
#define KEY_SERVICE_NS_IPC		0x0002
#define KEY_SERVICE_NS_MNT		0x0004
#define KEY_SERVICE_NS_PID		0x0008
#define KEY_SERVICE_NS_NET		0x0010
#define KEY_SERVICE_NS_CGROUP		0x0020
#define KEY_SERVICE___ALL_NS		0x003f

#define KEY_SERVICE_FD_CLOEXEC		0x0001
#define KEY_SERVICE_FD_NONBLOCK		0x0002

#define KEYCTL_SERVICE_CREATE		30	/* Create a request_key() service channel */
#define KEYCTL_SERVICE_ADD		31	/* Specify the a request pattern we can service */

int main()
{
	key_serial_t key, tring, pring, sring;
	char buf[128], op[12];
	uid_t uid;
	gid_t gid;
	int kfd, len;

	kfd = keyctl(KEYCTL_SERVICE_CREATE, KEY_SERVICE_FD_CLOEXEC);
	if (kfd == -1) {
		perror("service-create");
		exit(1);
	}

	if (keyctl(KEYCTL_SERVICE_ADD, kfd, "user", 0) == -1) {
		perror("service-add");
		exit(1);
	}

	len = read(kfd, buf, sizeof(buf) - 1);
	if (len == -1) {
		perror("read");
		exit(1);
	}
	buf[len] = 0;

	printf("received %d [%s]\n", len, buf);
	if (sscanf(buf, "%12s %x %x %x %x %x %x",
		   op, &key, &uid, &gid, &tring, &pring, &sring) != 7) {
		fprintf(stderr, "sscanf: Insufficient args decoded\n");
		exit(1);
	}

	if (keyctl_assume_authority(key) == -1) {
		perror("assume");
		exit(1);
	}

	if (keyctl_instantiate(key, "foo_bar", 7, 0) == -1) {
		perror("instantiate");
		exit(1);
	}
	
	exit(0);
}
