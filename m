Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 034533DEAEB
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 09:27:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788168476; cv=none; b=jQ+7zMblbfcVWeASWZVzih8JykHtngobVuXEYl8rmrfMpHlTakKXipPEHARG0I4vuUw4nwbkRrw5zK8RLHKUWeL7PynE97Ebj5N153GX61BjBpJtbVdlK9BeSF+UeFpno/0bSo++e62vBCt2l8kQB3dyQK2LNVblTWYW+hTZV00=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788168476; c=relaxed/simple;
	bh=n9gUms+NvSrc5RR/DTZzZ2Vm+gofQJbq8gk9cehcD6A=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=oOAwKJuDWWsUJADe0V8WHkqxZb2M/gIVuIxw/dc42h7lAZUcm9LRqc3aexzJ4QbRBfMcWTOBi4cMTjrk3M+4uSkrD9wiVgd1yZ17IJ6kV7GMD38MHNKqOnriGZWJeuyh1bZGaHU7KYqhNmJYzuPEfx41U/Er78YS4v3PNhkMzw0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=R1gUFipZ; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=QK2asoBp; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="R1gUFipZ";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="QK2asoBp"
Received: from pps.filterd (m0170394.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V7xFSP2785210
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 05:27:52 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=NZUSe7ln1mT3
	hAnAEGFiu+liOp4yFpLUqkkZDQ2ICuo=; b=R1gUFipZiH8OE94SoFc08EvyJ3Vq
	46BYktCn7OH8HTyvmwocpG4LVt5GZ1IDOyGdnscp4NUFpuCvWiPeI/ZQkc/jMs9g
	QcVl3vzYRjXPkYYzYJEYz6Q5RncGPn3M7gkePSNWvb6QXSbK0v4fqPo+d0cDI0AB
	e7Q00rnXDofOdw+rcvq3+jz8ac+ShnrpRGA5KPYF2uiLqj3KwHLuJncmC4FLD5Ty
	dawuBBPdxF7q6ouA6qeBKyRUpEfDoJjKZ5fJaK+bSi4SJPJCqJ/6dv+Z/TdAtQS6
	48x0KQq0CsTTjltEGDyjWkRO24/TiLbnzxDdOE6sVjzEH5xrlDgZ41QLpw==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4gbt01d8a9-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 05:27:52 -0400 (EDT)
Received: from pps.filterd (m0142693.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V90T6c2842117
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 05:27:51 -0400
Received: from esapsmtplv05.us.dell.com (esapsmtplv05.us.dell.com [143.166.203.153])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gd3pk2f8b-2
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 05:27:51 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788168471; x=1819704471;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=NZUSe7ln1mT3hAnAEGFiu+liOp4yFpLUqkkZDQ2ICuo=;
  b=QK2asoBpVeraL+WbWzZ6kyJNc5mcplsbl1cCR+AmFmtaxbYbPr94mxx8
   UnnxxUpd6RWUaWErMux4VfmyGNVS/ZgwyTlZySilJoinB2JvyUDua6K7k
   QYhl7M+kzTXyuVqJNjJmJxjvCUS+lZjFCZi7z2D29Zfo1ElfuUH2MjN24
   tYOc6fx5MlZvxx1gxo3lbt5U7lsK77d3sC7XCxzawt2bnuNkPFJMfJto4
   SL7nZt3IskJFM0LB0kuwAe0s2fasedBfTcJODJ4wlXeGnuc3hc7GVQcKc
   GkY61x7d3DX81ubbDwfLEDaLIF/VUh2uw7FGIQ7ZF+mzlzgH28BCt0QB4
   Q==;
X-CSE-ConnectionGUID: 7TF0pXwdSESn69dotcrGfA==
X-CSE-MsgGUID: xaulqXYTTEC2k3+VeMj00A==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv05.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 09:27:48 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: steved@redhat.com
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, cel@kernel.org,
        jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/2] nfsdctl: add a command to list NFSv4 clients
Date: Mon, 31 Aug 2026 09:27:40 +0000
Message-ID: <b78de46043798e926a9c01427a9ec6a7b90820e4.1787988918.git.prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787988918.git.prabhakar.pujeri@dell.com>
References: <cover.1787988918.git.prabhakar.pujeri@dell.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-31_03,2026-08-27_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 phishscore=0 lowpriorityscore=0 bulkscore=0 suspectscore=0 priorityscore=1501
 clxscore=1015 malwarescore=0 impostorscore=0 spamscore=0 adultscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310080
X-Proofpoint-ORIG-GUID: mcOt3pbwI-iBB7p7dgVKP3Kf3hCl2k9h
X-Proofpoint-GUID: mcOt3pbwI-iBB7p7dgVKP3Kf3hCl2k9h
X-Authority-Analysis: v=2.4 cv=H67rBeYi c=1 sm=1 tr=0 ts=6a954918 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=t4Iba6VQkoKuxR139xjPXA==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=gLxAKuEMs0EQMVFiDJnH:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=ukApeBBUpQeWXRKlOlYA:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDA4MSBTYWx0ZWRfX5ZtOp88nDKjn
 b58aV8/nD6rYnMbJxX8WsJ2XcFXWLZ8OK3lqvAny81k1FqfpCeHYE18tWgPPitm9wThPVqumKy+
 XKc9onLYHAb4DfC4n+nayQiTkguE2RQ=
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDA4MSBTYWx0ZWRfX0mcOitSPzL8D
 5GquUiBc2q0ttE0khNcrVeEuB2UnPHkFFqo9hFO7KxaFuY0ijWDWxR5NvpgXj+zHOpccnItLUUj
 f+BKGPUoByPpfOv9Thsu2+WCGwvGHXrfe6VGEFa0z10koCd56vzTbrqsgQOlKgLZ2HR2WbDil8B
 I9RWiqIibvQ6bXCMjyL3p+N2GZjOZMiJl+b3ON/TeqUKcRMCbnmwia6t1PrNjKJfQgpAg1bWkTX
 Z4H/iue5OtUos6jP33MXTkcK8jATbJNU6wTc7eXSa0WTqtLCzT/csG78/wu9CGmaVLfTHvBMKtG
 dw/3c27bY6ijeTBc2XwzJKS6SVcWdhXuJ1NHjdDOqgkNsBuXjShDaKKsCrnapJXccuNCcOMNRB1
 fSpSYov+BXsIyQ9BRBqf4tFxtfF0k0Ig5YBXdpZyKeON0uF6GmahWrNXd5zDhLQDUMf3gJqhXsu
 8BM0sihkVi8LnMqce4A==
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 bulkscore=0
 priorityscore=1501 spamscore=0 clxscore=1015 lowpriorityscore=0
 suspectscore=0 phishscore=0 impostorscore=0 malwarescore=0 adultscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310081

Monitoring NFSv4 clients currently requires walking the nfsd filesystem
and parsing a separate info file for every client. Add a clients command
that consumes the new NFSD_CMD_CLIENT_GET Netlink dump and presents one
row per client.

Report the server-generated client ID, peer address, minor version,
client state, lease time remaining, reclaim status, and callback state.
Decode the peer from separate IPv4 or IPv6 address, port, and scope-ID
attributes. Keep unknown enum values visible as "unknown" so newer
kernels remain usable with this client.

Detect NLM_F_DUMP_INTR on both client records and NLMSG_DONE. Report an
error instead of silently presenting a client list that may have skipped
or repeated a record.

Update the bundled UAPI header and require NFSD_CMD_CLIENT_GET before
selecting a system copy of that header.

Assisted-by: LLM
Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
Changes since v1:

  - decode separate address, port, and scope-ID attributes
  - reject interrupted dumps and ask the administrator to retry

v1: https://lore.kernel.org/r/b595db7a74fb55fc4c6b3b200c7970e4bb06007b.1787639206.git.prabhakar.pujeri@dell.com

 configure.ac                   |   2 +-
 support/include/nfsd_netlink.h |  38 +++++
 utils/nfsdctl/nfsdctl.8        |  19 +++
 utils/nfsdctl/nfsdctl.adoc     |  12 ++
 utils/nfsdctl/nfsdctl.c        | 255 +++++++++++++++++++++++++++++++++
 5 files changed, 325 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 2ce1e12..66330d0 100644
--- a/configure.ac
+++ b/configure.ac
@@ -259,7 +259,7 @@ AC_CHECK_HEADERS(linux/nfsd_netlink.h)
 
 # ensure the system netlink headers have the latest features
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/nfsd_netlink.h>]],
-			                   [[int foo = NFSD_CMD_SERVER_STATS_GET;]])],
+			                   [[int foo = NFSD_CMD_CLIENT_GET;]])],
 			   [AC_DEFINE([USE_SYSTEM_NFSD_NETLINK_H], 1,
 				      ["Use system's linux/nfsd_netlink.h"])])
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/lockd_netlink.h>]],
diff --git a/support/include/nfsd_netlink.h b/support/include/nfsd_netlink.h
index 87da1d0..715acb4 100644
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
 
@@ -260,6 +280,23 @@ enum {
 	NFSD_A_SERVER_STATS_MAX = (__NFSD_A_SERVER_STATS_MAX - 1)
 };
 
+enum {
+	NFSD_A_CLIENT_CLIENTID = 1,
+	NFSD_A_CLIENT_PAD,
+	NFSD_A_CLIENT_ADDRESS4,
+	NFSD_A_CLIENT_ADDRESS6,
+	NFSD_A_CLIENT_ADDRESS_PORT,
+	NFSD_A_CLIENT_ADDRESS_SCOPE_ID,
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
@@ -280,6 +317,7 @@ enum {
 	NFSD_CMD_UNLOCK_FILESYSTEM,
 	NFSD_CMD_UNLOCK_EXPORT,
 	NFSD_CMD_SERVER_STATS_GET,
+	NFSD_CMD_CLIENT_GET,
 
 	__NFSD_CMD_MAX,
 	NFSD_CMD_MAX = (__NFSD_CMD_MAX - 1)
diff --git a/utils/nfsdctl/nfsdctl.8 b/utils/nfsdctl/nfsdctl.8
index 1f526e7..18a7a56 100644
--- a/utils/nfsdctl/nfsdctl.8
+++ b/utils/nfsdctl/nfsdctl.8
@@ -81,6 +81,15 @@ This subcommand takes no arguments. Note that if a "threads=" value is not set i
 nfs.conf, 16 server threads will be brought online.
 .RE
 .sp
+\fBclients\fP
+.RS 4
+List NFSv4 clients known to the server. The output reports each client\(cqs
+server-generated client ID, peer address, minor version, lease and callback
+states, lease time remaining, and reclaim status. This subcommand requires
+elevated privileges. If the client set changes in a way that interrupts the
+dump, the command reports an error and should be retried.
+.RE
+.sp
 \fBlistener\fP
 .RS 4
 Get/set the listening sockets for the server. Run this without arguments to
@@ -259,6 +268,16 @@ nfsdctl listener
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
index e85348e..d227562 100644
--- a/utils/nfsdctl/nfsdctl.adoc
+++ b/utils/nfsdctl/nfsdctl.adoc
@@ -46,6 +46,14 @@ Each subcommand can also accept its own set of options and arguments. The
   This subcommand takes no arguments. Note that if a "threads=" value is not set in
   nfs.conf, 16 server threads will be brought online.
 
+*clients*::
+
+  List NFSv4 clients known to the server. The output reports each client's
+  server-generated client ID, peer address, minor version, lease and callback
+  states, lease time remaining, and reclaim status. This subcommand requires
+  elevated privileges. If the client set changes in a way that interrupts the
+  dump, the command reports an error and should be retried.
+
 *listener*::
 
   Get/set the listening sockets for the server. Run this without arguments to
@@ -138,6 +146,10 @@ Get a list of current listening sockets:
 
   nfsdctl listener
 
+Show the NFSv4 clients known to the server:
+
+  nfsdctl clients
+
 Show the supported and enabled NFS versions:
 
   nfsdctl version
diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index c712674..c0a6d5f 100644
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
@@ -84,6 +85,31 @@ struct server_socket {
 	bool active;
 };
 
+#define MAX_CLIENT_ADDRESS_LEN	80
+
+struct nfsd_client {
+	char		address[MAX_CLIENT_ADDRESS_LEN];
+	struct in_addr	address4;
+	struct in6_addr	address6;
+	uint64_t	clientid;
+	int64_t		lease_remaining;
+	uint32_t	address_scope_id;
+	uint32_t	minor_version;
+	uint32_t	state;
+	uint32_t	callback_state;
+	uint16_t	address_port;
+	bool		have_address4;
+	bool		have_address6;
+	bool		have_address_port;
+	bool		reclaim_complete;
+};
+
+struct client_dump_ctx {
+	int *ret;
+	bool header_printed;
+	bool dump_interrupted;
+};
+
 #define MAX_NFSD_SOCKETS		256
 
 int nfsd_socket_count;
@@ -184,6 +210,16 @@ static int finish_handler(struct nl_msg *msg, void *arg)
 	return NL_SKIP;
 }
 
+static int client_finish_handler(struct nl_msg *msg, void *arg)
+{
+	struct client_dump_ctx *ctx = arg;
+
+	if (nlmsg_hdr(msg)->nlmsg_flags & NLM_F_DUMP_INTR)
+		ctx->dump_interrupted = true;
+	*ctx->ret = 0;
+	return NL_SKIP;
+}
+
 static int ack_handler(struct nl_msg *msg, void *arg)
 {
 	int *ret = arg;
@@ -241,6 +277,145 @@ static void parse_rpc_status_get(struct genlmsghdr *gnlh)
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
+static void format_client_address(const struct nfsd_client *client, char *buf,
+				  size_t buflen)
+{
+	char host[INET6_ADDRSTRLEN];
+
+	snprintf(buf, buflen, "%s", "unknown");
+	if (!client->have_address_port ||
+	    client->have_address4 == client->have_address6)
+		return;
+
+	if (client->have_address4) {
+		if (!inet_ntop(AF_INET, &client->address4, host, sizeof(host)))
+			return;
+		snprintf(buf, buflen, "%s:%u", host,
+			 ntohs(client->address_port));
+		return;
+	}
+
+	if (!inet_ntop(AF_INET6, &client->address6, host, sizeof(host)))
+		return;
+	if (client->address_scope_id)
+		snprintf(buf, buflen, "[%s%%%u]:%u", host,
+			 client->address_scope_id, ntohs(client->address_port));
+	else
+		snprintf(buf, buflen, "[%s]:%u", host,
+			 ntohs(client->address_port));
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
+		case NFSD_A_CLIENT_ADDRESS4:
+			if (nla_len(attr) == sizeof(client.address4)) {
+				memcpy(&client.address4, nla_data(attr),
+				       sizeof(client.address4));
+				client.have_address4 = true;
+			}
+			break;
+		case NFSD_A_CLIENT_ADDRESS6:
+			if (nla_len(attr) == sizeof(client.address6)) {
+				memcpy(&client.address6, nla_data(attr),
+				       sizeof(client.address6));
+				client.have_address6 = true;
+			}
+			break;
+		case NFSD_A_CLIENT_ADDRESS_PORT:
+			if (nla_len(attr) == sizeof(client.address_port)) {
+				memcpy(&client.address_port, nla_data(attr),
+				       sizeof(client.address_port));
+				client.have_address_port = true;
+			}
+			break;
+		case NFSD_A_CLIENT_ADDRESS_SCOPE_ID:
+			if (nla_len(attr) == sizeof(client.address_scope_id))
+				client.address_scope_id = nla_get_u32(attr);
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
+	format_client_address(&client, client.address, sizeof(client.address));
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
@@ -410,6 +585,11 @@ static int recv_handler(struct nl_msg *msg, void *arg)
 	case NFSD_CMD_POOL_MODE_GET:
 		parse_pool_mode_get(gnlh);
 		break;
+	case NFSD_CMD_CLIENT_GET:
+		if (nlmsg_hdr(msg)->nlmsg_flags & NLM_F_DUMP_INTR)
+			((struct client_dump_ctx *)arg)->dump_interrupted = true;
+		parse_client_get(gnlh, arg);
+		break;
 	case LOCKD_CMD_SERVER_GET:
 		parse_lockd_get(gnlh);
 		break;
@@ -639,6 +819,76 @@ out:
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
+	ctx.ret = &ret;
+	nl_cb_err(cb, NL_CB_CUSTOM, error_handler, &ret);
+	nl_cb_set(cb, NL_CB_FINISH, NL_CB_CUSTOM, client_finish_handler, &ctx);
+	nl_cb_set(cb, NL_CB_ACK, NL_CB_CUSTOM, ack_handler, &ret);
+	nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, recv_handler, &ctx);
+
+	while (ret > 0)
+		nl_recvmsgs(sock, cb);
+	if (ret < 0) {
+		xlog(L_ERROR, "Error: %s", strerror(-ret));
+		ret = 1;
+	} else if (ctx.dump_interrupted) {
+		xlog(L_ERROR, "NFSv4 client list changed during dump; retry");
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
@@ -1942,6 +2192,7 @@ static int nlm_func(struct nl_sock *sock, int argc, char ** argv)
 
 enum nfsdctl_commands {
 	NFSDCTL_STATUS,
+	NFSDCTL_CLIENTS,
 	NFSDCTL_THREADS,
 	NFSDCTL_VERSION,
 	NFSDCTL_LISTENER,
@@ -1954,6 +2205,8 @@ static int parse_command(char *str)
 {
 	if (!strcmp(str, "status"))
 		return NFSDCTL_STATUS;
+	if (!strcmp(str, "clients"))
+		return NFSDCTL_CLIENTS;
 	if (!strcmp(str, "threads"))
 		return NFSDCTL_THREADS;
 	if (!strcmp(str, "version"))
@@ -1973,6 +2226,7 @@ typedef int (*nfsdctl_func)(struct nl_sock *sock, int argc, char **argv);
 
 static nfsdctl_func func[] = {
 	[NFSDCTL_STATUS] = status_func,
+	[NFSDCTL_CLIENTS] = clients_func,
 	[NFSDCTL_THREADS] = threads_func,
 	[NFSDCTL_VERSION] = version_func,
 	[NFSDCTL_LISTENER] = listener_func,
@@ -1997,6 +2251,7 @@ static void usage(void)
 	printf("    threads              get/set nfsd thread settings\n");
 	printf("    nlm                  get current nlm settings\n");
 	printf("    status               get current RPC processing info\n");
+	printf("    clients              get current NFSv4 client information\n");
 	printf("    autostart            start server with settings from /etc/nfs.conf\n");
 }
 
-- 
2.54.0
