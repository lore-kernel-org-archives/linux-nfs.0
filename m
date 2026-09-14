Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86DEF35CB60
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 16:00:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789401657; cv=none; b=Auld33bJ6ElrtG+CJDk7bv6extgOW3RKCe+pPlvxiMGBrvbUEGwDkMfSwyCzdxB5dlKkn53FPcrp4IPTMHUjCK5TuLQhaAXWoLcRkBmNTtAB4ktXguUqOmuJEWxRpMiT95SgtQJu2cDsBMbXF2ZLXeiFPEQiYFgcvi7nV5h7ebw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789401657; c=relaxed/simple;
	bh=HLaTVxITECMP5SR5Dwc8g9G8b90lOZ+vjhYsOCcyE6Y=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=gF1hF8L4fJhDHhx1LOCiiOL2giUPAS7XmsAjx+WL7P0SJOsYeiAQcBkXx5dLXFaqoZaLzDnJwvXyvvXKfghunOQMNP0z2zBMBQlJ97hs2HqzTvT0cTlDs/tDQnur2BAPkW4PEYluZLATKk8jx9dQguNxvVJbNNuiZLKR1jYKOiw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EcuFnW1d; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EcuFnW1d"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AF3961F00899;
	Mon, 14 Sep 2026 16:00:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789401655;
	bh=4pKSZF+A2xnFhRw0BUgjH4wak7LVpM2Gc0ulHuc0d28=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=EcuFnW1ddu0L8WoeGgQ0eNIQfFlv8UnDvuHb79RbVIGNlqeFRvW3qc7jumIqu98yg
	 nlhb8Ycx0ovlofatL79Zgtsom45AvCbfmKz6hv2LKyKdXNsPhHKt5d7X9dQe7Ry+xm
	 uxScP7FNbB7cW/6VJOTOVlMPf2sDFilaMaoQYSTFGd7Y40fUfSAoyCSHhYZY9X51Vm
	 3YCDjl0UpNETCxtKl1B17mxYMBMh5LvRCyE0+LFbAsElulutEBl8zuUsH2ooL1HBA/
	 w3q+qIN4ZF14spSw5K9LTrPD48Yh/rCUNZnVMA8cBV+sg6Mb9yerIZ8HB32332Rbfs
	 7+BRpKNrbkt+A==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 12:00:32 -0400
Subject: [PATCH RFC nfs-utils v2 04/10] nfsdctl: add rpcbind registration
 helpers
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nfsdctl-rpcb-v2-4-b2c679ac0107@kernel.org>
References: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
In-Reply-To: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=11825; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=HLaTVxITECMP5SR5Dwc8g9G8b90lOZ+vjhYsOCcyE6Y=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqBoxhXPh+Avxkd92//tsFJlu50e5oS331jN/I
 PRySnqvetaJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqgaMQAKCRAADmhBGVaC
 FXkSD/44GczuUAArF4e9z/8FSp5+2h4knYhQPPlI3b3sMCXupVVS/WqJwvPRg0ti0awtW3nRCCJ
 KlWJPIqx4guf3zIwHEJMnBHXKwIMWNb7TjlJB2D2ojpWkq+rsz/R5cL/MfwfhiAgQXeye8N8Goo
 tyUrKHOxsrOei7snOaRqi8t0hYr3j71CbRf6lpnfVoQbfGi4kGAorrXIXxRmmJdtNM1klPzUBmK
 q6WduasL+WRZtrlvTgCQUW54fuLivDTgCRHJyElcxIHsAfMKWoopqM7qksdEPXQD5aLhBbesijz
 ZhNr+9FA02OtyOpIkwNIIzMS050NJQaoS6h5N+7UeD9pmmFaRxEskgYzjM5xxpD9VfwpevbNKFs
 nTlozFtb02GMAebhiczeK6+dcNYbrtKdAv11miaK7JSRhZvGvkuqWfcwcCWIYlyiQ1rIyNBGfg6
 dXHZyOQp0mn3OlSEgbheZtHPnZuQkAzbbvIWTEx6byeAZyPT5nPhi7gqyYgi3tpy1g5WM/KP6MG
 BHiHDBv9G3OHGitOOGAlIjg+AGTyHr1BgWwP/eevEAgFBgttC/Oyx0o9zEIilnDpmsJzMfGh3+/
 BGzxWWAtUksrVTreQf1kR7xWPRcWVZ67ZCHu73VmfnL/lhyJKIp4IZy+0SqPAACZ8DwK94NgA/U
 Otn+EO48Z4MKrBw==
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

