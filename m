Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32910 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751678AbdIMK1a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 06:27:30 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v3 10/14] exportfs: add AF_VSOCK address parsing and printing
Date: Wed, 13 Sep 2017 11:26:46 +0100
Message-Id: <20170913102650.10377-11-stefanha@redhat.com>
In-Reply-To: <20170913102650.10377-1-stefanha@redhat.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add code to parse and print AF_VSOCK addresses since the getaddrinfo(3)
family of functions don't handle this address family.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 support/export/hostname.c | 133 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 133 insertions(+)

diff --git a/support/export/hostname.c b/support/export/hostname.c
index 7f8a6f8..36e75ff 100644
--- a/support/export/hostname.c
+++ b/support/export/hostname.c
@@ -30,6 +30,105 @@
 #include "sockaddr.h"
 #include "exportfs.h"
 
+static char *
+host_ntop_vsock(const struct sockaddr *sap, char *buf, const size_t buflen)
+{
+	struct sockaddr_vm *svm = (struct sockaddr_vm *)sap;
+	snprintf(buf, buflen, "vsock:%u", svm->svm_cid);
+	return buf;
+}
+
+/* Allocate an addrinfo for AF_VSOCK.  Free with host_freeaddrinfo(). */
+static struct addrinfo *
+vsock_alloc_addrinfo(struct sockaddr_vm **svm)
+{
+	struct {
+		struct addrinfo ai;
+		struct sockaddr_vm svm;
+	} *vai;
+
+	vai = calloc(1, sizeof(*vai));
+	if (!vai)
+		return NULL;
+
+	vai->ai.ai_family = AF_VSOCK;
+	vai->ai.ai_socktype = SOCK_STREAM;
+	vai->ai.ai_addrlen = sizeof(vai->svm);
+	vai->ai.ai_addr = (struct sockaddr *)&vai->svm;
+	vai->svm.svm_family = AF_VSOCK;
+
+	if (svm)
+		*svm = &vai->svm;
+
+	return &vai->ai;
+}
+
+/* hostname -> addrinfo */
+static struct addrinfo *
+vsock_hostname_addrinfo(const char *hostname)
+{
+	const char *cid_str;
+	char *end_ptr;
+	struct addrinfo *ai;
+	struct sockaddr_vm *svm;
+	long cid;
+
+	cid_str = hostname + strlen("vsock:");
+	cid = strtol(cid_str, &end_ptr, 10);
+	if (end_ptr == cid_str || *end_ptr != '\0')
+		return NULL;
+	if (cid < 0 || cid > UINT32_MAX)
+		return NULL;
+
+	ai = vsock_alloc_addrinfo(&svm);
+	if (!ai)
+		return NULL;
+
+	ai->ai_canonname = strdup(hostname);
+	if (!ai->ai_canonname) {
+		host_freeaddrinfo(ai);
+		return NULL;
+	}
+
+	svm->svm_cid = cid;
+	return ai;
+}
+
+/* sockaddr -> hostname */
+static char *
+vsock_canonname(const struct sockaddr *sap)
+{
+	const struct sockaddr_vm *svm = (const struct sockaddr_vm *)sap;
+	char *canonname;
+
+	if (asprintf(&canonname, "vsock:%u", svm->svm_cid) < 0)
+		return NULL;
+	return canonname;
+}
+
+/* sockaddr -> addrinfo */
+static struct addrinfo *
+vsock_sockaddr_addrinfo(const struct sockaddr *sap)
+{
+	const struct sockaddr_vm *svm = (const struct sockaddr_vm *)sap;
+	struct sockaddr_vm *ai_svm;
+	struct addrinfo *ai;
+
+	ai = vsock_alloc_addrinfo(&ai_svm);
+	if (!ai)
+		return NULL;
+
+	*ai_svm = *svm;
+
+	ai->ai_canonname = vsock_canonname(sap);
+	if (!ai->ai_canonname) {
+		host_freeaddrinfo(ai);
+		return NULL;
+	}
+
+	return ai;
+}
+
 /**
  * host_ntop - generate presentation address given a sockaddr
  * @sap: pointer to socket address
@@ -52,6 +151,9 @@ host_ntop(const struct sockaddr *sap, char *buf, const size_t buflen)
 		return buf;
 	}
 
+	if (sap->sa_family == AF_VSOCK)
+		return host_ntop_vsock(sap, buf, buflen);
+
 	error = getnameinfo(sap, salen, buf, (socklen_t)buflen,
 						NULL, 0, NI_NUMERICHOST);
 	if (error != 0) {
@@ -69,6 +171,9 @@ host_ntop(const struct sockaddr *sap, char *buf, const size_t buflen)
 
 	memset(buf, 0, buflen);
 
+	if (sap->sa_family == AF_VSOCK)
+		return host_ntop_vsock(sap, buf, buflen);
+
 	if (sin->sin_family != AF_INET) {
 		(void)strncpy(buf, "bad family", buflen - 1);
 		return buf;
@@ -120,6 +225,10 @@ host_pton(const char *paddr)
 			__func__);
 		return NULL;
 	}
+
+	if (strncmp(paddr, "vsock:", strlen("vsock:")) == 0)
+		return vsock_hostname_addrinfo(paddr);
+
 	inet4 = 1;
 	if (inet_pton(AF_INET, paddr, &sin.sin_addr) == 0)
 		inet4 = 0;
@@ -174,6 +283,9 @@ host_addrinfo(const char *hostname)
 	};
 	int error;
 
+	if (strncmp(hostname, "vsock:", strlen("vsock:")) == 0)
+		return vsock_hostname_addrinfo(hostname);
+
 	error = getaddrinfo(hostname, NULL, &hint, &ai);
 	switch (error) {
 	case 0:
@@ -202,6 +314,12 @@ host_addrinfo(const char *hostname)
 void
 host_freeaddrinfo(struct addrinfo *ai)
 {
+	if (ai && ai->ai_family == AF_VSOCK) {
+		free(ai->ai_canonname);
+		free(ai);
+		return;
+	}
+
 	freeaddrinfo(ai);
 }
 
@@ -225,6 +343,9 @@ host_canonname(const struct sockaddr *sap)
 	char buf[NI_MAXHOST];
 	int error;
 
+	if (sap->sa_family == AF_VSOCK)
+		return vsock_canonname(sap);
+
 	if (salen == 0) {
 		xlog(D_GENERAL, "%s: unsupported address family %d",
 				__func__, sap->sa_family);
@@ -260,6 +381,9 @@ host_canonname(const struct sockaddr *sap)
 	const struct in_addr *addr = &sin->sin_addr;
 	struct hostent *hp;
 
+	if (sap->sa_family == AF_VSOCK)
+		return vsock_canonname(sap);
+
 	if (sap->sa_family != AF_INET)
 		return NULL;
 
@@ -291,6 +415,9 @@ host_reliable_addrinfo(const struct sockaddr *sap)
 	struct addrinfo *ai, *a;
 	char *hostname;
 
+	if (sap->sa_family == AF_VSOCK)
+		return vsock_sockaddr_addrinfo(sap);
+
 	hostname = host_canonname(sap);
 	if (hostname == NULL)
 		return NULL;
@@ -340,6 +467,9 @@ host_numeric_addrinfo(const struct sockaddr *sap)
 	struct addrinfo *ai;
 	int error;
 
+	if (sap->sa_family == AF_VSOCK)
+		return vsock_sockaddr_addrinfo(sap);
+
 	if (salen == 0) {
 		xlog(D_GENERAL, "%s: unsupported address family %d",
 				__func__, sap->sa_family);
@@ -388,6 +518,9 @@ host_numeric_addrinfo(const struct sockaddr *sap)
 	char buf[INET_ADDRSTRLEN];
 	struct addrinfo *ai;
 
+	if (sap->sa_family == AF_VSOCK)
+		return vsock_sockaddr_addrinfo(sap);
+
 	if (sap->sa_family != AF_INET)
 		return NULL;
 
-- 
2.13.5

