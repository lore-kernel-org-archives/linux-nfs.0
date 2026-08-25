Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 11DC73921E9
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 06:52:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787640752; cv=none; b=h+M71uzbUp912+U9TdMmV+pwreGgmzfrbzCK9sRSsOgmc4kzK2oyJssbPcVNxmUDSXkPCAxp4nUc8hZWWdjyCo8aGZb+EfCTLtWTogEl3d3qcXFiLcYz8IiXz8YJRDFOSM3szZZ6KED2UoHWWNjsi6aekHiF0HKeDNfiqa5yK4w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787640752; c=relaxed/simple;
	bh=JY4pgz7OouO5fRDxpV+jrPYLY7Q9SXsipBuzM/xDi0E=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=RlnXV/nCFAfKFBn1D4w0ez6TDi6i7CWYVYgcCc52e5Jx6EXouTHFBOujT15qwuM//4rtrz7KUKMvGVnkLzq+XIm5CZHs5pIfOLldRRI9M9zYzNOPvoD432MrHvEZS6VsDrjuuBv8arc/J7tBKZQ6I6fRQLtt7iu3evcfNZyUKfs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=I+P7qN+L; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=LB6FZnoK; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="I+P7qN+L";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="LB6FZnoK"
Received: from pps.filterd (m0170390.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P2R7S83564566
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:29 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=aMLgQzqmGre7
	51wyRliyCpoDmI/z5K5XERlQRlqTPJc=; b=I+P7qN+LJ+pxiDk2jEUKbrqSt/Ky
	Z0ez7HhI/Dr9FnUJR2ko2ibfZa6UmMcJ3qFVPKtsz7N0pS0vodoFpMuzEnhTTx9A
	W/qZSOzDmIc0gb2Q60j/jKTmUB7qPDrRzPpQP0wgCuBZag+o0PIRidyDt87GyCCy
	mx4dYQ6+XdW/rQsz4vhNy6n/WFxeDJ5JriVTbwu30Mj/GUWh3/kOkaVYc65c9bv7
	g+MjHpbIO9A1YiNYDGg0AvxBAIe27mwuYIofvRVCzgXK0p47zB8MuWFEqmqHA90G
	kLQ8ClLTTacBkPifH2KrII4N1ANv4f/ZWYAZNkYQUlsEB27Ubce//aUBIQ==
Received: from mx0b-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4g76ty2288-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:28 -0400 (EDT)
Received: from pps.filterd (m0144104.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P4bBjj889540
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:28 -0400
Received: from esapsmtplv08.us.dell.com (esapsmtplv08.us.dell.com [143.166.203.145])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4g946b9ahw-3
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:27 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787640748; x=1819176748;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=aMLgQzqmGre751wyRliyCpoDmI/z5K5XERlQRlqTPJc=;
  b=LB6FZnoKHQynDMy07+cHmsEN/+od60eOQ1Lza/MntWPnQCJXrrlDMiPd
   R3DXFavuxNS1UbXQBKbgo/k/mob/6/iISy4FoOkdDQ1Fqqosk8x6TmN8p
   YPV4a8MieVcP+JswdQx0F2YIiRyObTQ8BIHwU3QBsBtkkSB1upe9X2nas
   VZp/8rzmudjXOXNdstqjuVh/z89ArGo/JMLg9fdo3IG+fUQ8wNMt0tugE
   ReGiYsNuiCwDyojrZ1ncFLJDVWg2dbeoLEIuFUSa4XWvZZ6is2FTv+CZz
   HLE1PP6r3hgbYc9Dq64fHqYedtdfnGdONbKEzhIXq/3fGMeSx+qvZoCMd
   A==;
X-CSE-ConnectionGUID: pHZ3pCZYTpOoX8e30DKrtA==
X-CSE-MsgGUID: jiz49/jkQe2vjEt7aYDRRQ==
X-LoopCount0: from 10.94.13.48
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.13.48])
  by esapsmtplv08.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 25 Aug 2026 06:52:26 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: steved@redhat.com
Cc: cel@kernel.org, jlayton@kernel.org, linux-nfs@vger.kernel.org,
        Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH v1 2/3] nfsdctl: add a command to list NFSv4 clients
Date: Tue, 25 Aug 2026 06:52:14 +0000
Message-ID: <b595db7a74fb55fc4c6b3b200c7970e4bb06007b.1787639206.git.prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787639206.git.prabhakar.pujeri@dell.com>
References: <cover.1787639206.git.prabhakar.pujeri@dell.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-25_01,2026-08-24_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 phishscore=0 suspectscore=0 malwarescore=0 impostorscore=0 adultscore=0
 clxscore=1015 bulkscore=0 lowpriorityscore=0 spamscore=0 priorityscore=1501
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608250056
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfX0NEeea7FVFaZ
 tV8isRq/dbxtpsnNokCUxd6H/2El2LLrrH0TKRqbHbBbyhyeY9EfzieqRkoOiu2/Q8NCqmZRb06
 297r7Xlwx6k1MfNs1Zl15Fkgve5kg+iVrj8n5kHSX4ABZR1TV5h/rEovJT9hkyc5ypsM8MWQFgk
 JKKlJ0X2pssIhwB+SjHvE2A07fmJP/Y/t/l+Tg/1hBpABv8cScitJpR9miCc3bssX9FhGIREblr
 /Dl6RSeJLrqBJNV9OzcXM/MujDw+ewrT3emiXwuBJA/oEzk7LKENJcwxiVlpmls73yspbKFR17r
 uSJMMk70sp21Am6ZkPlY9wqDTk6/2ALMFfQ7drntkJpIi+ni4rS06xW3qd4lHZQetu4HdoS/TqU
 JbCQSjaG1xKSMc/CgUCAfQyQYyaKVe92w//1yEeGH30z4YISfB1v2WMcVpNTmPVGbfKRR56fKmC
 UxlcpJuDkiYUeF57eTg==
X-Proofpoint-GUID: 5njftc2zRrUfSVDqrtG8XiW8vHNCTgZs
X-Proofpoint-Spam-Info: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfX/lOKCtRueZNa
 t2H6mX9YrqA687FWXQhJx0Njovymz/VtAj4t7A3V9O5+BnuzeTR1XS3j5ylDut8cdjr3ox66K3L
 iDG0TLro8drj5KGvsqR1mW81BpTza5M=
X-Proofpoint-ORIG-GUID: 5njftc2zRrUfSVDqrtG8XiW8vHNCTgZs
X-Authority-Analysis: v=2.4 cv=BMGDalQG c=1 sm=1 tr=0 ts=6a8d3bac cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=7aFXbidJGpJUqALx8qt4zQ==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=sEWawkeXllE7TocFc0N_:22 a=iLNU1ar6AAAA:8
 a=NLa1KX1cNuthu6F1XXsA:9 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0
 lowpriorityscore=0 malwarescore=0 clxscore=1015 spamscore=0
 priorityscore=1501 adultscore=0 phishscore=0 suspectscore=0 impostorscore=0
 bulkscore=0 classifier=typeunknown authscore=0 authtc= authcc= route=outbound
 adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608250057

Monitoring NFSv4 clients currently requires walking the nfsd filesystem
and parsing a separate info file for every client. Add a clients command
that consumes the new NFSD_CMD_CLIENT_GET Netlink dump and presents one
row per client.

Report the server-generated client ID, peer address, minor version,
client state, lease time remaining, reclaim status, and callback state.
Format both IPv4 and IPv6 socket addresses, including their ports and
IPv6 scope IDs. Keep unknown enum values visible as "unknown" so newer
kernels remain usable with this client.

Update the bundled UAPI header and require NFSD_CMD_CLIENT_GET before
selecting a system copy of that header.

Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 configure.ac                   |   2 +-
 support/include/nfsd_netlink.h |  35 ++++++
 utils/nfsdctl/nfsdctl.8        |  18 +++
 utils/nfsdctl/nfsdctl.adoc     |  11 ++
 utils/nfsdctl/nfsdctl.c        | 217 +++++++++++++++++++++++++++++++++
 5 files changed, 282 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 96aa82c..66330d0 100644
--- a/configure.ac
+++ b/configure.ac
@@ -259,7 +259,7 @@ AC_CHECK_HEADERS(linux/nfsd_netlink.h)
 
 # ensure the system netlink headers have the latest features
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/nfsd_netlink.h>]],
-			                   [[int foo = NFSD_A_SERVER_IN_GRACE;]])],
+			                   [[int foo = NFSD_CMD_CLIENT_GET;]])],
 			   [AC_DEFINE([USE_SYSTEM_NFSD_NETLINK_H], 1,
 				      ["Use system's linux/nfsd_netlink.h"])])
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/lockd_netlink.h>]],
diff --git a/support/include/nfsd_netlink.h b/support/include/nfsd_netlink.h
index e1fc2db..ae49538 100644
--- a/support/include/nfsd_netlink.h
+++ b/support/include/nfsd_netlink.h
@@ -50,6 +50,26 @@ enum nfsd_xprtsec_mode {
 	NFSD_XPRTSEC_MODE_MTLS = 4,
 };
 
+/*
+ * State of an NFSv4 client record.
+ */
+enum nfsd_client_state {
+	NFSD_CLIENT_STATE_UNCONFIRMED,
+	NFSD_CLIENT_STATE_ACTIVE,
+	NFSD_CLIENT_STATE_COURTESY,
+	NFSD_CLIENT_STATE_EXPIRABLE,
+};
+
+/*
+ * State of an NFSv4 client's callback channel.
+ */
+enum nfsd_callback_state {
+	NFSD_CALLBACK_STATE_UP,
+	NFSD_CALLBACK_STATE_UNKNOWN,
+	NFSD_CALLBACK_STATE_DOWN,
+	NFSD_CALLBACK_STATE_FAULT,
+};
+
 enum {
 	NFSD_A_CACHE_NOTIFY_CACHE_TYPE = 1,
 
@@ -261,6 +281,20 @@ enum {
 	NFSD_A_SERVER_STATS_MAX = (__NFSD_A_SERVER_STATS_MAX - 1)
 };
 
+enum {
+	NFSD_A_CLIENT_CLIENTID = 1,
+	NFSD_A_CLIENT_PAD,
+	NFSD_A_CLIENT_ADDRESS,
+	NFSD_A_CLIENT_MINOR_VERSION,
+	NFSD_A_CLIENT_STATE,
+	NFSD_A_CLIENT_LEASE_REMAINING,
+	NFSD_A_CLIENT_RECLAIM_COMPLETE,
+	NFSD_A_CLIENT_CALLBACK_STATE,
+
+	__NFSD_A_CLIENT_MAX,
+	NFSD_A_CLIENT_MAX = (__NFSD_A_CLIENT_MAX - 1)
+};
+
 enum {
 	NFSD_CMD_RPC_STATUS_GET = 1,
 	NFSD_CMD_THREADS_SET,
@@ -281,6 +315,7 @@ enum {
 	NFSD_CMD_UNLOCK_FILESYSTEM,
 	NFSD_CMD_UNLOCK_EXPORT,
 	NFSD_CMD_SERVER_STATS_GET,
+	NFSD_CMD_CLIENT_GET,
 
 	__NFSD_CMD_MAX,
 	NFSD_CMD_MAX = (__NFSD_CMD_MAX - 1)
diff --git a/utils/nfsdctl/nfsdctl.8 b/utils/nfsdctl/nfsdctl.8
index 58d5cd9..36af317 100644
--- a/utils/nfsdctl/nfsdctl.8
+++ b/utils/nfsdctl/nfsdctl.8
@@ -81,6 +81,14 @@ This subcommand takes no arguments. Note that if a "threads=" value is not set i
 nfs.conf, 16 server threads will be brought online.
 .RE
 .sp
+\fBclients\fP
+.RS 4
+List NFSv4 clients known to the server. The output reports each client\(cqs
+server-generated client ID, peer address, minor version, lease and callback
+states, lease time remaining, and reclaim status. This subcommand requires
+elevated privileges.
+.RE
+.sp
 \fBlistener\fP
 .RS 4
 Get/set the listening sockets for the server. Run this without arguments to
@@ -260,6 +268,16 @@ nfsdctl listener
 .fi
 .if n .RE
 .sp
+Show the NFSv4 clients known to the server:
+.sp
+.if n .RS 4
+.nf
+.fam C
+nfsdctl clients
+.fam
+.fi
+.if n .RE
+.sp
 Show the supported and enabled NFS versions:
 .sp
 .if n .RS 4
diff --git a/utils/nfsdctl/nfsdctl.adoc b/utils/nfsdctl/nfsdctl.adoc
index 7e03933..3e70b99 100644
--- a/utils/nfsdctl/nfsdctl.adoc
+++ b/utils/nfsdctl/nfsdctl.adoc
@@ -46,6 +46,13 @@ Each subcommand can also accept its own set of options and arguments. The
   This subcommand takes no arguments. Note that if a "threads=" value is not set in
   nfs.conf, 16 server threads will be brought online.
 
+*clients*::
+
+  List NFSv4 clients known to the server. The output reports each client's
+  server-generated client ID, peer address, minor version, lease and callback
+  states, lease time remaining, and reclaim status. This subcommand requires
+  elevated privileges.
+
 *listener*::
 
   Get/set the listening sockets for the server. Run this without arguments to
@@ -139,6 +146,10 @@ Get a list of current listening sockets:
 
   nfsdctl listener
 
+Show the NFSv4 clients known to the server:
+
+  nfsdctl clients
+
 Show the supported and enabled NFS versions:
 
   nfsdctl version
diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index 2b1faef..7f12860 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -8,6 +8,7 @@
 #include <linux/version.h>
 #include <netlink/genl/genl.h>
 #include <errno.h>
+#include <inttypes.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <stdarg.h>
@@ -84,6 +85,22 @@ struct server_socket {
 	bool active;
 };
 
+#define MAX_CLIENT_ADDRESS_LEN	80
+
+struct nfsd_client {
+	char		address[MAX_CLIENT_ADDRESS_LEN];
+	uint64_t	clientid;
+	int64_t		lease_remaining;
+	uint32_t	minor_version;
+	uint32_t	state;
+	uint32_t	callback_state;
+	bool		reclaim_complete;
+};
+
+struct client_dump_ctx {
+	bool header_printed;
+};
+
 #define MAX_NFSD_SOCKETS		256
 
 int nfsd_socket_count;
@@ -241,6 +258,132 @@ static void parse_rpc_status_get(struct genlmsghdr *gnlh)
 	printf("\n");
 }
 
+static const char *client_state_name(uint32_t state)
+{
+	switch (state) {
+	case NFSD_CLIENT_STATE_UNCONFIRMED:
+		return "unconfirmed";
+	case NFSD_CLIENT_STATE_ACTIVE:
+		return "active";
+	case NFSD_CLIENT_STATE_COURTESY:
+		return "courtesy";
+	case NFSD_CLIENT_STATE_EXPIRABLE:
+		return "expirable";
+	default:
+		return "unknown";
+	}
+}
+
+static const char *callback_state_name(uint32_t state)
+{
+	switch (state) {
+	case NFSD_CALLBACK_STATE_UP:
+		return "up";
+	case NFSD_CALLBACK_STATE_UNKNOWN:
+		return "unknown";
+	case NFSD_CALLBACK_STATE_DOWN:
+		return "down";
+	case NFSD_CALLBACK_STATE_FAULT:
+		return "fault";
+	default:
+		return "unknown";
+	}
+}
+
+static void format_client_address(const struct nlattr *attr, char *buf,
+				  size_t buflen)
+{
+	const struct sockaddr *sa = nla_data(attr);
+	char host[INET6_ADDRSTRLEN];
+
+	snprintf(buf, buflen, "%s", "unknown");
+	if (nla_len(attr) < sizeof(sa->sa_family))
+		return;
+
+	switch (sa->sa_family) {
+	case AF_INET: {
+		const struct sockaddr_in *sin = nla_data(attr);
+
+		if (nla_len(attr) < sizeof(*sin) ||
+		    !inet_ntop(AF_INET, &sin->sin_addr, host, sizeof(host)))
+			return;
+		snprintf(buf, buflen, "%s:%u", host, ntohs(sin->sin_port));
+		break;
+	}
+	case AF_INET6: {
+		const struct sockaddr_in6 *sin6 = nla_data(attr);
+
+		if (nla_len(attr) < sizeof(*sin6) ||
+		    !inet_ntop(AF_INET6, &sin6->sin6_addr, host, sizeof(host)))
+			return;
+		if (sin6->sin6_scope_id)
+			snprintf(buf, buflen, "[%s%%%u]:%u", host,
+				 sin6->sin6_scope_id, ntohs(sin6->sin6_port));
+		else
+			snprintf(buf, buflen, "[%s]:%u", host,
+				 ntohs(sin6->sin6_port));
+		break;
+	}
+	}
+}
+
+static void parse_client_get(struct genlmsghdr *gnlh,
+			     struct client_dump_ctx *ctx)
+{
+	struct nfsd_client client = {
+		.address = "unknown",
+		.state = UINT32_MAX,
+		.callback_state = UINT32_MAX,
+	};
+	struct nlattr *attr;
+	int rem;
+
+	nla_for_each_attr(attr, genlmsg_attrdata(gnlh, 0),
+			  genlmsg_attrlen(gnlh, 0), rem) {
+		switch (nla_type(attr)) {
+		case NFSD_A_CLIENT_CLIENTID:
+			client.clientid = nla_get_u64(attr);
+			break;
+		case NFSD_A_CLIENT_ADDRESS:
+			format_client_address(attr, client.address,
+					      sizeof(client.address));
+			break;
+		case NFSD_A_CLIENT_MINOR_VERSION:
+			client.minor_version = nla_get_u32(attr);
+			break;
+		case NFSD_A_CLIENT_STATE:
+			client.state = nla_get_u32(attr);
+			break;
+		case NFSD_A_CLIENT_LEASE_REMAINING:
+			client.lease_remaining = nla_get_s64(attr);
+			break;
+		case NFSD_A_CLIENT_RECLAIM_COMPLETE:
+			client.reclaim_complete = true;
+			break;
+		case NFSD_A_CLIENT_CALLBACK_STATE:
+			client.callback_state = nla_get_u32(attr);
+			break;
+		default:
+			break;
+		}
+	}
+
+	if (!ctx->header_printed) {
+		printf("%-18s %-47s %-4s %-11s %8s %7s %8s\n",
+		       "clientid", "address", "vers", "state", "lease",
+		       "reclaim", "callback");
+		ctx->header_printed = true;
+	}
+
+	printf("0x%016" PRIx64 " %-47s 4.%-2u %-11s %8" PRId64
+	       " %7s %8s\n",
+	       client.clientid, client.address, client.minor_version,
+	       client_state_name(client.state), client.lease_remaining,
+	       client.minor_version ?
+		(client.reclaim_complete ? "yes" : "no") : "-",
+	       callback_state_name(client.callback_state));
+}
+
 static void parse_version_get(struct genlmsghdr *gnlh)
 {
 	struct nlattr *attr;
@@ -418,6 +561,9 @@ static int recv_handler(struct nl_msg *msg, void *arg)
 	case NFSD_CMD_POOL_MODE_GET:
 		parse_pool_mode_get(gnlh);
 		break;
+	case NFSD_CMD_CLIENT_GET:
+		parse_client_get(gnlh, arg);
+		break;
 	case LOCKD_CMD_SERVER_GET:
 		parse_lockd_get(gnlh);
 		break;
@@ -647,6 +793,72 @@ out:
 	return ret;
 }
 
+static void clients_usage(void)
+{
+	printf("Usage: %s clients\n", taskname);
+	printf("    Display NFSv4 clients and their current state.\n");
+}
+
+static int clients_func(struct nl_sock *sock, int argc, char **argv)
+{
+	struct client_dump_ctx ctx = {};
+	struct genlmsghdr *ghdr;
+	struct nlmsghdr *nlh;
+	struct nl_msg *msg;
+	struct nl_cb *cb;
+	int opt, ret;
+
+	optind = 1;
+	while ((opt = getopt_long(argc, argv, "h", help_only_options, NULL)) != -1) {
+		switch (opt) {
+		case 'h':
+			clients_usage();
+			return 0;
+		}
+	}
+
+	if (!nfsd_nl_family_setup(sock))
+		return 1;
+
+	msg = netlink_msg_alloc(sock, nfsd_nl_family);
+	if (!msg)
+		return 1;
+
+	nlh = nlmsg_hdr(msg);
+	nlh->nlmsg_flags |= NLM_F_DUMP;
+	ghdr = nlmsg_data(nlh);
+	ghdr->cmd = NFSD_CMD_CLIENT_GET;
+
+	cb = nl_cb_alloc(NL_CB_CUSTOM);
+	if (!cb) {
+		xlog(L_ERROR, "failed to allocate netlink callbacks");
+		ret = 1;
+		goto out;
+	}
+
+	ret = nl_send_auto(sock, msg);
+	if (ret < 0)
+		goto out_cb;
+
+	ret = 1;
+	nl_cb_err(cb, NL_CB_CUSTOM, error_handler, &ret);
+	nl_cb_set(cb, NL_CB_FINISH, NL_CB_CUSTOM, finish_handler, &ret);
+	nl_cb_set(cb, NL_CB_ACK, NL_CB_CUSTOM, ack_handler, &ret);
+	nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, recv_handler, &ctx);
+
+	while (ret > 0)
+		nl_recvmsgs(sock, cb);
+	if (ret < 0) {
+		xlog(L_ERROR, "Error: %s", strerror(-ret));
+		ret = 1;
+	}
+out_cb:
+	nl_cb_put(cb);
+out:
+	nlmsg_free(msg);
+	return ret;
+}
+
 static int threads_doit(struct nl_sock *sock, int cmd, int grace, int lease,
 			int pool_count, int *pool_threads, char *scope, int minthreads,
 			uuid_t fh_key)
@@ -1950,6 +2162,7 @@ static int nlm_func(struct nl_sock *sock, int argc, char ** argv)
 
 enum nfsdctl_commands {
 	NFSDCTL_STATUS,
+	NFSDCTL_CLIENTS,
 	NFSDCTL_THREADS,
 	NFSDCTL_VERSION,
 	NFSDCTL_LISTENER,
@@ -1962,6 +2175,8 @@ static int parse_command(char *str)
 {
 	if (!strcmp(str, "status"))
 		return NFSDCTL_STATUS;
+	if (!strcmp(str, "clients"))
+		return NFSDCTL_CLIENTS;
 	if (!strcmp(str, "threads"))
 		return NFSDCTL_THREADS;
 	if (!strcmp(str, "version"))
@@ -1981,6 +2196,7 @@ typedef int (*nfsdctl_func)(struct nl_sock *sock, int argc, char **argv);
 
 static nfsdctl_func func[] = {
 	[NFSDCTL_STATUS] = status_func,
+	[NFSDCTL_CLIENTS] = clients_func,
 	[NFSDCTL_THREADS] = threads_func,
 	[NFSDCTL_VERSION] = version_func,
 	[NFSDCTL_LISTENER] = listener_func,
@@ -2005,6 +2221,7 @@ static void usage(void)
 	printf("    threads              get/set nfsd thread settings\n");
 	printf("    nlm                  get current nlm settings\n");
 	printf("    status               get current RPC processing info\n");
+	printf("    clients              get current NFSv4 client information\n");
 	printf("    autostart            start server with settings from /etc/nfs.conf\n");
 }
 
-- 
2.54.0

