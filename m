Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A35FBC4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:08:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7C1552192B
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:08:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391509AbfBOQID (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:08:03 -0500
Received: from mx1.redhat.com ([209.132.183.28]:58296 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388125AbfBOQIB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:08:01 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id F1D80BF9DD;
        Fri, 15 Feb 2019 16:08:00 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id CF843101E841;
        Fri, 15 Feb 2019 16:07:58 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 05/27] containers: Open a socket inside a container
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:07:58 +0000
Message-ID: <155024687804.21651.13220990774688382294.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 15 Feb 2019 16:08:01 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Provide a system call to open a socket inside of a container, using that
container's network namespace.  This allows netlink to be used to manage
the container.

	fd = container_socket(int container_fd,
			      int domain, int type, int protocol);

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/x86/entry/syscalls/syscall_32.tbl |    1 +
 arch/x86/entry/syscalls/syscall_64.tbl |    1 +
 include/linux/socket.h                 |    3 ++-
 include/linux/syscalls.h               |    2 ++
 kernel/sys_ni.c                        |    1 +
 net/compat.c                           |    2 +-
 net/socket.c                           |   34 +++++++++++++++++++++++++++-----
 7 files changed, 37 insertions(+), 7 deletions(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 8666693510f9..f4c9beff77a6 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -409,3 +409,4 @@
 395	i386	sb_notify		sys_sb_notify			__ia32_sys_sb_notify
 396	i386	container_create	sys_container_create		__ia32_sys_container_create
 397	i386	fork_into_container	sys_fork_into_container		__ia32_sys_fork_into_container
+398	i386	container_socket	sys_container_socket		__ia32_sys_container_socket
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index d40d4790fcb2..e20cdf7b5527 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -354,6 +354,7 @@
 343	common	sb_notify		__x64_sys_sb_notify
 344	common	container_create	__x64_sys_container_create
 345	common	fork_into_container	__x64_sys_fork_into_container
+346	common	container_socket	__x64_sys_container_socket
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/socket.h b/include/linux/socket.h
index ab2041a00e01..154ac900a8a5 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -10,6 +10,7 @@
 #include <linux/compiler.h>		/* __user			*/
 #include <uapi/linux/socket.h>
 
+struct net;
 struct pid;
 struct cred;
 
@@ -376,7 +377,7 @@ extern int __sys_sendto(int fd, void __user *buff, size_t len,
 			int addr_len);
 extern int __sys_accept4(int fd, struct sockaddr __user *upeer_sockaddr,
 			 int __user *upeer_addrlen, int flags);
-extern int __sys_socket(int family, int type, int protocol);
+extern int __sys_socket(struct net *net, int family, int type, int protocol);
 extern int __sys_bind(int fd, struct sockaddr __user *umyaddr, int addrlen);
 extern int __sys_connect(int fd, struct sockaddr __user *uservaddr,
 			 int addrlen);
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 15e5cc704df3..547334c6ffc2 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -947,6 +947,8 @@ asmlinkage long sys_container_create(const char __user *name, unsigned int flags
 				     unsigned long spare3, unsigned long spare4,
 				     unsigned long spare5);
 asmlinkage long sys_fork_into_container(int containerfd);
+asmlinkage long sys_container_socket(int containerfd,
+				     int domain, int type, int protocol);
 
 /*
  * Architecture-specific system calls
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index a23ad529d548..ce9c5bb30e7f 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -236,6 +236,7 @@ COND_SYSCALL(shmdt);
 /* net/socket.c */
 COND_SYSCALL(socket);
 COND_SYSCALL(socketpair);
+COND_SYSCALL(container_socket);
 COND_SYSCALL(bind);
 COND_SYSCALL(listen);
 COND_SYSCALL(accept);
diff --git a/net/compat.c b/net/compat.c
index 959d1c51826d..1b2db740fd33 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -856,7 +856,7 @@ COMPAT_SYSCALL_DEFINE2(socketcall, int, call, u32 __user *, args)
 
 	switch (call) {
 	case SYS_SOCKET:
-		ret = __sys_socket(a0, a1, a[2]);
+		ret = __sys_socket(current->nsproxy->net_ns, a0, a1, a[2]);
 		break;
 	case SYS_BIND:
 		ret = __sys_bind(a0, compat_ptr(a1), a[2]);
diff --git a/net/socket.c b/net/socket.c
index 7d271a1d0c7e..7406580598b9 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -80,6 +80,7 @@
 #include <linux/highmem.h>
 #include <linux/mount.h>
 #include <linux/fs_context.h>
+#include <linux/container.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/compat.h>
@@ -1326,9 +1327,9 @@ int sock_create_kern(struct net *net, int family, int type, int protocol, struct
 }
 EXPORT_SYMBOL(sock_create_kern);
 
-int __sys_socket(int family, int type, int protocol)
+int __sys_socket(struct net *net, int family, int type, int protocol)
 {
-	int retval;
+	long retval;
 	struct socket *sock;
 	int flags;
 
@@ -1346,7 +1347,7 @@ int __sys_socket(int family, int type, int protocol)
 	if (SOCK_NONBLOCK != O_NONBLOCK && (flags & SOCK_NONBLOCK))
 		flags = (flags & ~SOCK_NONBLOCK) | O_NONBLOCK;
 
-	retval = sock_create(family, type, protocol, &sock);
+	retval = __sock_create(net, family, type, protocol, &sock, 0);
 	if (retval < 0)
 		return retval;
 
@@ -1355,9 +1356,32 @@ int __sys_socket(int family, int type, int protocol)
 
 SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
 {
-	return __sys_socket(family, type, protocol);
+	return __sys_socket(current->nsproxy->net_ns, family, type, protocol);
 }
 
+/*
+ * Create a socket inside a container.
+ */
+#ifdef CONFIG_CONTAINERS
+SYSCALL_DEFINE4(container_socket,
+		int, containerfd, int, family, int, type, int, protocol)
+{
+	struct fd f = fdget(containerfd);
+	long ret;
+
+	if (!f.file)
+		return -EBADF;
+	ret = -EINVAL;
+	if (is_container_file(f.file)) {
+		struct container *c = f.file->private_data;
+
+		ret = __sys_socket(c->ns->net_ns, family, type, protocol);
+	}
+	fdput(f);
+	return ret;
+}
+#endif
+
 /*
  *	Create a pair of connected sockets.
  */
@@ -2555,7 +2579,7 @@ SYSCALL_DEFINE2(socketcall, int, call, unsigned long __user *, args)
 
 	switch (call) {
 	case SYS_SOCKET:
-		err = __sys_socket(a0, a1, a[2]);
+		err = __sys_socket(current->nsproxy->net_ns, a0, a1, a[2]);
 		break;
 	case SYS_BIND:
 		err = __sys_bind(a0, (struct sockaddr __user *)a1, a[2]);

