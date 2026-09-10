Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 11AF63ACF01
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 18:22:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789064535; cv=none; b=tiPyaICCv+ElUsfCY4jXhOm77Q+lxOVHqsY2o0470YuSAdKubYYwhQtncD+dIMjOJBDO2YkieAL1mMfO9fyrGnuho5OPnyjDZKXFpYjo/Dpmhc5yFVoCUvaxkDkUbWCVkSW1UvY+h0jcrH4weZdBZ+dZ6alJRn3aJs3CsLsq3p0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789064535; c=relaxed/simple;
	bh=HLaTVxITECMP5SR5Dwc8g9G8b90lOZ+vjhYsOCcyE6Y=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=IWtwspJfcpftfNCwe+75m8KhHKtyUbkISv/64ttP2SkQVEL3QUnStI7xbGXfE5d14sxe4ehHDpbzn8Lts3xLfTpjPY3CUy2V4BZ8eXODNqmO2rK89yc6gYBltlnTWnvs47eVfjkDO1x7Ovf3gAc/4PdKZdzC8YeAIJ6k3NenaEU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BDTQ8oe1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BDTQ8oe1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 338E81F0089A;
	Thu, 10 Sep 2026 18:22:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789064534;
	bh=4pKSZF+A2xnFhRw0BUgjH4wak7LVpM2Gc0ulHuc0d28=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BDTQ8oe1SdO0ighhZGY5ZyATKgnGA89iK+uG6cslO21N4QKB4zRh2NBKjQZqZhjdl
	 p2eFczPhEhGN6e00tjwi733pAwdJrNqdtIPVPDr0mYdMjx+8bQhdr9q58Pu8epySL9
	 E7tfRIl9+DT6/K39oTqAkCqEEPXxzIs4wpGTwk/mrDzv5n7RsJdyg5Rluerc0w+kek
	 goh7cqCmqSF0xBhs4lZqqaXbI6Ji0Wo854nTFJOQL9bcwP/Q3kxl048do/Zi7iboSc
	 VsR4y7qnNYmxGtYqhGLotMCg1DvH6EIbcDUhNomR6mV7AZEta2fHl/2gciRhRQpowp
	 wqRagMbjqKNtQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 10 Sep 2026 14:22:05 -0400
Subject: [PATCH RFC nfs-utils 4/7] nfsdctl: add rpcbind registration
 helpers
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-nfsdctl-rpcb-v1-4-4bba1e7a3a43@kernel.org>
References: <20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org>
In-Reply-To: <20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=11825; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=HLaTVxITECMP5SR5Dwc8g9G8b90lOZ+vjhYsOCcyE6Y=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqovVQshQ4Rl6YwFAluydM1JTri1/jdcSwi9OC7
 sh24I187duJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqL1UAAKCRAADmhBGVaC
 FWwSD/40oDYI7EEVJgD9zTEcKiCZ5tytW8E4bY4P2Jl1y1vWab23eHezIfiFlGpwGVJcFmBdUys
 CeqPTCQH5n5GVhqv943oVcpp6o+wUn8XOhBzLqcFB1e8iDJjam3p2jXscHGjrM4/hftAxkHGTu/
 782aNl9oY858GjBXfGB0r+7dMS+VxGSBYhaytc6eR9P9asmmT9WRFlykPtjE++Wo1W05bBciQ+f
 0kwhB1KbV1oh0VEjZ7tDxvb0mw+LDoVxiicqE1dN215yRzik+hAUF8Iqg4Omf6MLorTja50yy0N
 oLiofhFgWr96RMumqY5I8HidB/oZjGh27ttKDHQGUVWlP8cRnbLwtkgimAZuXXhW825PU4dv7cD
 WJu77TibfeYFnPWvn0QD+IrCeAKeBcWeoNn+N21cXLXZ4GMZAPpK0XSMBINPgHAWDeo5GFrwOPv
 tv3zhWtrCAVptcU52eBua0/j2sdss86rR1Wnxd3KQKFC+TbLmJhP20H/4vXMXtiBwIVFbE6QZ+Y
 ZPz+R5WSiZ11VignhXbjLzd/hTA/OPShDbDEwJqAWeDPsiATjNXJXkzbw6S0RtfeHOvm9PKiYr7
 yEE8TXWGIf8d2uIBR1HJqUSQxcvt41cDUKLR5xtjcTMIRdCz3tv4xgRvZ2T9wnUtQ40BxkvDa3w
 kY110FPhMmM3/PQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Add the code that calls the local rpcbind. The callers come next.

nfsd_rpcb_register() matches each listener against each program that the
kernel reported. It calls rpcb_set() for every pair.

nfsd_rpcb_unset_all() clears every nfsd entry with nfs_svc_unregister().
That helper calls rpcb_unset() with no netconfig, so one call covers
every netid.

Three rules match what the kernel did:

- nfsdctl registers the wildcard address with the listener's port. It
  does not register the address that the listener uses.
  __svc_rpcb_register4() and __svc_rpcb_register6() did the same.
- nfsdctl does not register an RDMA listener. svc_register() runs only
  from svc_setup_socket(), so an RDMA listener never reached rpcbind.
- nfsdctl does not register a program that carries the no-udp flag on
  udp or udp6. NFSv4 sets vs_need_cong_ctrl, so the kernel never
  advertised NFSv4 there.

A failed call writes a warning and does not stop the caller. NFSv4 does
not need rpcbind. A v2 or v3 client that already knows the port does not
need it either.

rpcb_set() and the netconfig database are TI-RPC only, so the
registration side sits under HAVE_LIBTIRPC with a warning stub, matching
getport.c and rpc_socket.c. nfsd_rpcb_unset_all() needs neither and
stays unconditional; nfs_svc_unregister() has a pmap_unset() variant.

struct server_socket moves to the new header, because both files read it.
The netlink spec generates nfsdctl.h, so the definition cannot live
there.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 utils/nfsdctl/Makefile.am |  10 +-
 utils/nfsdctl/nfsdctl.c   |  13 +--
 utils/nfsdctl/rpcbind.c   | 251 ++++++++++++++++++++++++++++++++++++++++++++++
 utils/nfsdctl/rpcbind.h   |  42 ++++++++
 4 files changed, 300 insertions(+), 16 deletions(-)

diff --git a/utils/nfsdctl/Makefile.am b/utils/nfsdctl/Makefile.am
index 89c7ecd6f30b..1390c43c855d 100644
--- a/utils/nfsdctl/Makefile.am
+++ b/utils/nfsdctl/Makefile.am
@@ -5,9 +5,11 @@ EXTRA_DIST      = $(man8_MANS)
 
 sbin_PROGRAMS	= nfsdctl
 
-noinst_HEADERS = nfsdctl.h
-nfsdctl_SOURCES = nfsdctl.c
-nfsdctl_CFLAGS = $(LIBNL3_CFLAGS) $(LIBNLGENL3_CFLAGS) $(LIBREADLINE_CFLAGS)
-nfsdctl_LDADD = ../../support/nfs/libnfs.la $(LIBNL3_LIBS) $(LIBNLGENL3_LIBS) $(LIBREADLINE_LIBS)
+noinst_HEADERS = nfsdctl.h rpcbind.h
+nfsdctl_SOURCES = nfsdctl.c rpcbind.c
+nfsdctl_CFLAGS = $(LIBNL3_CFLAGS) $(LIBNLGENL3_CFLAGS) $(LIBREADLINE_CFLAGS) \
+		 $(TIRPC_CFLAGS)
+nfsdctl_LDADD = ../../support/nfs/libnfs.la $(LIBNL3_LIBS) $(LIBNLGENL3_LIBS) \
+		$(LIBREADLINE_LIBS) $(LIBTIRPC)
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index dd815ac53489..860ea9c09ad2 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -46,6 +46,7 @@
 
 #include "nfslib.h"
 #include "nfsdctl.h"
+#include "rpcbind.h"
 #include "conffile.h"
 #include "xlog.h"
 
@@ -72,18 +73,6 @@ struct nfs_version {
 
 struct nfs_version nfsd_versions[MAX_NFS_VERSIONS];
 
-/*
- * All of the existing netids are short strings (3-4 chars), but let's allow
- * for up to 16.
- */
-#define MAX_CLASS_NAME_LEN	16
-
-struct server_socket {
-	struct sockaddr_storage	ss;
-	char name[MAX_CLASS_NAME_LEN];
-	bool active;
-};
-
 #define MAX_NFSD_SOCKETS		256
 
 int nfsd_socket_count;
diff --git a/utils/nfsdctl/rpcbind.c b/utils/nfsdctl/rpcbind.c
new file mode 100644
index 000000000000..23034097b485
--- /dev/null
+++ b/utils/nfsdctl/rpcbind.c
@@ -0,0 +1,251 @@
+/*
+ * rpcbind.c -- register nfsd listeners with the local rpcbind
+ *
+ * A kernel that accepts NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND makes no
+ * rpcbind call of its own, so this program makes them instead. The kernel
+ * used to do this under nfsd_mutex, where a slow rpcbind stalled every
+ * other NFSD netlink operation.
+ *
+ * lockd still registers NLM itself, so nothing here touches it.
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <errno.h>
+#include <netinet/in.h>
+#include <string.h>
+#include <sys/socket.h>
+
+#include <rpc/rpc.h>
+
+#ifdef HAVE_LIBTIRPC
+#include <rpc/rpcb_clnt.h>
+#include <netconfig.h>
+#endif	/* HAVE_LIBTIRPC */
+
+#include "nfslib.h"
+#include "rpcmisc.h"
+#include "sockaddr.h"
+#include "xlog.h"
+#include "rpcbind.h"
+
+#ifdef USE_SYSTEM_NFSD_NETLINK_H
+#include <linux/nfsd_netlink.h>
+#else
+#include "nfsd_netlink.h"
+#endif
+
+#ifndef ARRAY_SIZE
+#define ARRAY_SIZE(x)		(sizeof(x) / sizeof((x)[0]))
+#endif
+
+/*
+ * Programs to clear at shutdown. There is no reply to read at that point,
+ * so clear a superset. rpcb_unset() of an absent entry does nothing.
+ */
+static const struct {
+	rpcprog_t	program;
+	rpcvers_t	version;
+} nfsd_rpcb_all[] = {
+	{ NFS_PROGRAM,		2 },
+	{ NFS_PROGRAM,		3 },
+	{ NFS_PROGRAM,		4 },
+	{ NFS_ACL_PROGRAM,	2 },
+	{ NFS_ACL_PROGRAM,	3 },
+};
+
+/**
+ * nfsd_rpcb_unset_all - remove every nfsd entry from the local rpcbind
+ *
+ * rpcb_unset() matches [program, version, netid] and takes no address, so
+ * one call clears every netid. This mirrors the svc_unregister() sweep that
+ * svc_rpcb_setup() used to run, which an sv_no_rpcbind serv no longer does.
+ */
+void nfsd_rpcb_unset_all(void)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(nfsd_rpcb_all); i++)
+		nfs_svc_unregister(nfsd_rpcb_all[i].program,
+				   nfsd_rpcb_all[i].version);
+}
+
+#ifdef HAVE_LIBTIRPC
+
+/*
+ * Map a transport name and address family to an rpcbind netid.
+ *
+ * Returns NULL for a transport that the kernel never registered. RDMA is
+ * the case that matters: svc_register() is only reached from
+ * svc_setup_socket(), so an RDMA listener was always absent from rpcbind.
+ */
+static const char *nfsd_rpcb_netid(const char *transport, int family)
+{
+	bool v6 = (family == AF_INET6);
+
+	if (!strcmp(transport, "tcp"))
+		return v6 ? "tcp6" : "tcp";
+	if (!strcmp(transport, "udp"))
+		return v6 ? "udp6" : "udp";
+	return NULL;
+}
+
+/*
+ * Build the address to register. The kernel registered the wildcard address
+ * with the listener's port, not the address the listener is bound to, so
+ * match that.
+ */
+static bool nfsd_rpcb_wildcard(const struct sockaddr_storage *ss,
+			       struct sockaddr_storage *out, socklen_t *len)
+{
+	memset(out, 0, sizeof(*out));
+
+	switch (ss->ss_family) {
+	case AF_INET: {
+		struct sockaddr_in *s4 = (struct sockaddr_in *)out;
+
+		s4->sin_family = AF_INET;
+		s4->sin_addr.s_addr = htonl(INADDR_ANY);
+		s4->sin_port = ((const struct sockaddr_in *)ss)->sin_port;
+		*len = sizeof(*s4);
+		return true;
+	}
+	case AF_INET6: {
+		struct sockaddr_in6 *s6 = (struct sockaddr_in6 *)out;
+
+		s6->sin6_family = AF_INET6;
+		s6->sin6_addr = in6addr_any;
+		s6->sin6_port = ((const struct sockaddr_in6 *)ss)->sin6_port;
+		*len = sizeof(*s6);
+		return true;
+	}
+	}
+	return false;
+}
+
+static bool nfsd_rpcb_set_one(rpcprog_t program, rpcvers_t version,
+			      const char *netid,
+			      const struct sockaddr_storage *ss)
+{
+	struct sockaddr_storage wild;
+	struct netconfig *nconf;
+	struct netbuf nb;
+	socklen_t len;
+	bool ok;
+
+	if (!nfsd_rpcb_wildcard(ss, &wild, &len))
+		return false;
+
+	nconf = getnetconfigent(netid);
+	if (!nconf) {
+		xlog(L_WARNING, "no netconfig entry for %s", netid);
+		return false;
+	}
+
+	nb.buf = &wild;
+	nb.len = len;
+	nb.maxlen = len;
+
+	ok = (rpcb_set(program, version, nconf, &nb) == TRUE);
+	freenetconfigent(nconf);
+	return ok;
+}
+
+/**
+ * nfsd_rpcb_register - register the listeners the kernel reported
+ * @listeners: listeners that came up, from the listener_set reply
+ * @nlisteners: number of entries in @listeners
+ * @progs: programs and versions the kernel would have registered
+ * @nprogs: number of entries in @progs
+ *
+ * A failure is not fatal. NFSv4 does not need rpcbind, and a v2/v3 client
+ * that already knows the port does not need it either, so an unadvertised
+ * server is better than no server.
+ */
+void nfsd_rpcb_register(const struct server_socket *listeners, int nlisteners,
+			const struct nfsd_rpcb_prog *progs, int nprogs)
+{
+	unsigned int failed = 0;
+	int i, j, k;
+
+	/*
+	 * Clear first. rpcbind cannot express "drop one of two TCP ports",
+	 * and the kernel no longer sweeps stale entries at serv creation.
+	 */
+	nfsd_rpcb_unset_all();
+
+	for (i = 0; i < nlisteners; i++) {
+		const struct server_socket *l = &listeners[i];
+		const char *netid;
+		bool dup = false;
+
+		netid = nfsd_rpcb_netid(l->name, l->ss.ss_family);
+		if (!netid)
+			continue;
+
+		/*
+		 * The address registered is the wildcard, so two listeners
+		 * that share a netid and port produce the same entry.
+		 */
+		for (k = 0; k < i; k++) {
+			const struct server_socket *o = &listeners[k];
+			const char *other;
+
+			other = nfsd_rpcb_netid(o->name, o->ss.ss_family);
+			if (other && !strcmp(other, netid) &&
+			    nfs_get_port((const struct sockaddr *)&o->ss) ==
+			    nfs_get_port((const struct sockaddr *)&l->ss)) {
+				dup = true;
+				break;
+			}
+		}
+		if (dup)
+			continue;
+
+		for (j = 0; j < nprogs; j++) {
+			const struct nfsd_rpcb_prog *p = &progs[j];
+
+			/*
+			 * NFSv4 needs congestion control, so the kernel
+			 * never advertised it over UDP.
+			 */
+			if ((p->flags & NFSD_RPCBIND_FLAGS_NO_UDP) &&
+			    !strncmp(netid, "udp", 3))
+				continue;
+
+			if (nfsd_rpcb_set_one(p->program, p->version, netid,
+					      &l->ss))
+				continue;
+
+			xlog(L_WARNING,
+			     "cannot register program %u version %u on %s port %u",
+			     p->program, p->version, netid,
+			     nfs_get_port((const struct sockaddr *)&l->ss));
+			failed++;
+		}
+	}
+
+	if (failed)
+		xlog(L_WARNING,
+		     "some rpcbind registrations failed. Clients that look up the server in rpcbind cannot find it.");
+}
+
+#else	/* !HAVE_LIBTIRPC */
+
+/*
+ * rpcb_set() and the netconfig database are TI-RPC only, so a build
+ * without it cannot own the registration. userspace_rpcbind_supported()
+ * answers false there and the kernel keeps doing the calls itself, which
+ * leaves this unreachable.
+ */
+void nfsd_rpcb_register(const struct server_socket *UNUSED(listeners),
+			int UNUSED(nlisteners),
+			const struct nfsd_rpcb_prog *UNUSED(progs),
+			int UNUSED(nprogs))
+{
+	xlog(L_WARNING, "built without TI-RPC: cannot register with rpcbind");
+}
+
+#endif	/* !HAVE_LIBTIRPC */
diff --git a/utils/nfsdctl/rpcbind.h b/utils/nfsdctl/rpcbind.h
new file mode 100644
index 000000000000..46145da6ed99
--- /dev/null
+++ b/utils/nfsdctl/rpcbind.h
@@ -0,0 +1,42 @@
+/*
+ * rpcbind.h -- register nfsd listeners with the local rpcbind
+ */
+
+#ifndef _UTILS_NFSDCTL_RPCBIND_H
+#define _UTILS_NFSDCTL_RPCBIND_H
+
+#include <stdbool.h>
+#include <stdint.h>
+#include <sys/socket.h>
+
+#ifndef NFS_PROGRAM
+#define NFS_PROGRAM		100003
+#endif
+#ifndef NFS_ACL_PROGRAM
+#define NFS_ACL_PROGRAM		100227
+#endif
+
+/*
+ * All of the existing netids are short strings (3-4 chars), but let's allow
+ * for up to 16.
+ */
+#define MAX_CLASS_NAME_LEN	16
+
+struct server_socket {
+	struct sockaddr_storage	ss;
+	char name[MAX_CLASS_NAME_LEN];
+	bool active;
+};
+
+/* One [program, version] that the kernel would have registered. */
+struct nfsd_rpcb_prog {
+	uint32_t	program;
+	uint32_t	version;
+	uint32_t	flags;
+};
+
+void nfsd_rpcb_unset_all(void);
+void nfsd_rpcb_register(const struct server_socket *listeners, int nlisteners,
+			const struct nfsd_rpcb_prog *progs, int nprogs);
+
+#endif /* _UTILS_NFSDCTL_RPCBIND_H */

-- 
2.55.0

