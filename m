Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9C7313D6CC4
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 09:28:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788168482; cv=none; b=ZVl0rpn/jTWRKyhCQdTIgairoc4ZUo5UXvneBmh2LJtz/E+PZbiHoQuwgY+iWnL4gGqwEr8unDGdFI6MJxvl7UPQpPoY1948to+08nrmD0tFDjKieah8hknOoAVA/l+mO4ar8E02wZqMpcYNjs7W/SVqVRetCwRAR/ZIlN3/20U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788168482; c=relaxed/simple;
	bh=GukMwV2+NZibEr0vBXYl/D79zo/zILBKMq2pThiS6qA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=coxRVk7Untplyuh/QDaYmUSDxp4pH6kprEq85LGohKTXqlYNt3qndncLhWkv3S8ttwuJdvfhYmh1fxIVNSAvx15k/sc68PU4ctUzf4zRsoj9nxFymxDvD9Ma8samhS94Hy6QoXSMk5MRWefxCiVoVHRN3w4wPpB0mz12N1RVghk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=JSbjfB5B; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=GGIxbGwc; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="JSbjfB5B";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="GGIxbGwc"
Received: from pps.filterd (m0170391.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V80Na02700832
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 05:27:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=cOtw30DPqtNa
	GMTS+fV+1BAaXdugCLYrnlgRs5e8H+8=; b=JSbjfB5BE2l/bsnnpYujQ3r1WxBC
	EfhHK++L0p+9g/b8DD5x8UR+PZbhxghZShfVgnhhdFNu8hwaGb33RHicAI58mRxw
	ZvqOSjEk5O6CveEkZaSbDZ9BanEOF9iucJGkMuGK3J82fO2BiJBzMlCisC0lpDbs
	7TA/N4BgD2IMNCWoot47fEd4Pd0vbFVKQe6/ZOo0I+GmPblFknG+P4vd7ldzVa36
	0Bzbz9iFROVQu1BKxIBFx3NWLAd3E7GFsjHolvrxyDBmMHfrBAURxperWiWSiTM/
	xtXkkh1UYhtj1tdZgeKgDZZvSVkl+l1VBXsMM7P3p9KCYuOWw90yu7JdaA==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4gbtjsd63a-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 05:27:54 -0400 (EDT)
Received: from pps.filterd (m0142693.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67V90T6d2842117
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 05:27:54 -0400
Received: from esapsmtplv05.us.dell.com (esapsmtplv05.us.dell.com [143.166.203.153])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4gd3pk2f8b-3
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 05:27:53 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1788168474; x=1819704474;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=cOtw30DPqtNaGMTS+fV+1BAaXdugCLYrnlgRs5e8H+8=;
  b=GGIxbGwck4AfLPeC+tYHCfPjqFFGLIC90x7vbzQw0VW6tP9WHSBan5oy
   OplxACZTSsb7/GytyD561m12zp36foplJWVDnEIkKe1G7bq14i51cMuMD
   QendbhEWI+PMAuRbQigQPqwzdmfwLKkGrSvVK3CanQ0GCj3J3gIk0fJdm
   aS3qgvX3S5VcDbA0Q4EpzuRlSf6q2KtzP9dJU+zQ9Mp5Kr7o2JZ1Ygtvl
   nvZ3Q+RIPFCMXTT4gMLDk2prRVKPEvBDAScu9qrmkleUurnztWpS2jsUg
   VOZukpImok0q39+aYoxY5LJamEbq9gwYy7z0B2M3zLO1HMuowjWZRxQBj
   w==;
X-CSE-ConnectionGUID: hib3OLsRTb6IDJYGb5XKbg==
X-CSE-MsgGUID: wVG0hs9/Qsmn5lLpdNpa2Q==
X-LoopCount0: from 10.94.8.206
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.8.206])
  by esapsmtplv05.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 31 Aug 2026 09:27:51 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: steved@redhat.com
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, cel@kernel.org,
        jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/2] nfsdctl: display per-client NFSv4 state usage
Date: Mon, 31 Aug 2026 09:27:41 +0000
Message-ID: <8c01bc79b768be1a2824b4691d80fd1c7d1384d7.1787988918.git.prabhakar.pujeri@dell.com>
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
X-Authority-Analysis: v=2.4 cv=R9Yz39RX c=1 sm=1 tr=0 ts=6a95491a cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=t4Iba6VQkoKuxR139xjPXA==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=aNt9FJNJ8fZyd9HhltU_:22 a=VwQbUJbxAAAA:8
 a=iLNU1ar6AAAA:8 a=oZIGi6-CDSk9Cc5Qcs8A:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-ORIG-GUID: N5yHcxXGRsyE-JNLLXTrYo5W5nCVOH1B
X-Proofpoint-GUID: N5yHcxXGRsyE-JNLLXTrYo5W5nCVOH1B
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDA4MSBTYWx0ZWRfX2aOymo3KM//V
 tMEtrzWJ7+H9H8Unq0V4aSTW/+KRPJI3A49BkDXx0w2nfI8SDDcOvjRCtGibXHuDeC/68KSXX9i
 RPRh46jgROV3Sz6iYc7wy2fqhG3nWvJ6Xrs/wWTvKNz6oXrr12QGNgJsGIo6ZcXcko5I9ir1ssr
 ZUetS54xVFVs05ZOp5Z3GFlREkKXV4vCSG/iBfjTZEaklGmMuLNY+J3EPPrIKZKw/OCYwbe3jgH
 6NeiSmFKTbxqkjmkTUtdA8QNZEYmnTqQwluQKv1O6Ev2/EkRAZ3ZPGPF2KsS79WVwjZbPPc4rFj
 CqP+NhMHb80iB37CsyWtFOxapfphWCn0ocGGqaCaB9sFV73NIZRMoGl4PWkPA8e3tq6A0I6Dukd
 DWfy/fV/YNtCCnnb4awLvoYibM6wg1Wzc/4XK3vlYjMNTFqHTFsTjSgahDX4U6kN5UqaVxF1H0n
 7KIMgyDg63ri2Wni9ow==
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDA4MSBTYWx0ZWRfXz9cqKF4b9bHq
 8Aa+NeaQVyfswgm9+UxNM7QY79cmZfcXsPqxZkyi9laFoYoX+5F/0is0CeEWNf9PGau7SI1BPVu
 xWl98CsYsoiCqVrULxonQASTrxdzsBw=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 clxscore=1015
 priorityscore=1501 impostorscore=0 lowpriorityscore=0 adultscore=0
 suspectscore=0 phishscore=0 spamscore=0 malwarescore=0 bulkscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608310081

Extend the clients table with the session and stateid record counts
exported by NFSD. These totals help an operator identify which client is
retaining server-side state before using the detailed nfsd filesystem
views.

Decode both four-byte and eight-byte representations of the Netlink uint
attributes and display the complete u64 value. Display a dash when a
count attribute is absent or malformed. This keeps the command accurate
when a new nfsdctl is used with a kernel that supports the base client
dump but not the count extension.

Require the last count attribute before selecting the system UAPI header
so building against a header with only the base command still uses the
bundled copy.

Assisted-by: LLM
Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
Changes since v1:

  - decode 32-bit and 64-bit variable-width uint count attributes
  - store and format all counts as uint64_t values

v1: https://lore.kernel.org/r/05399eaee964c52a935f65b2c793f77cb8a2a97a.1787639206.git.prabhakar.pujeri@dell.com

 configure.ac                   |  2 +-
 support/include/nfsd_netlink.h |  5 +++
 utils/nfsdctl/nfsdctl.8        |  8 +++--
 utils/nfsdctl/nfsdctl.adoc     |  8 +++--
 utils/nfsdctl/nfsdctl.c        | 63 +++++++++++++++++++++++++++++++---
 5 files changed, 75 insertions(+), 11 deletions(-)

diff --git a/configure.ac b/configure.ac
index 66330d0..0b22523 100644
--- a/configure.ac
+++ b/configure.ac
@@ -259,7 +259,7 @@ AC_CHECK_HEADERS(linux/nfsd_netlink.h)
 
 # ensure the system netlink headers have the latest features
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/nfsd_netlink.h>]],
-			                   [[int foo = NFSD_CMD_CLIENT_GET;]])],
+			                   [[int foo = NFSD_A_CLIENT_LAYOUT_STATEIDS;]])],
 			   [AC_DEFINE([USE_SYSTEM_NFSD_NETLINK_H], 1,
 				      ["Use system's linux/nfsd_netlink.h"])])
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/lockd_netlink.h>]],
diff --git a/support/include/nfsd_netlink.h b/support/include/nfsd_netlink.h
index 715acb4..d977833 100644
--- a/support/include/nfsd_netlink.h
+++ b/support/include/nfsd_netlink.h
@@ -292,6 +292,11 @@ enum {
 	NFSD_A_CLIENT_LEASE_REMAINING,
 	NFSD_A_CLIENT_RECLAIM_COMPLETE,
 	NFSD_A_CLIENT_CALLBACK_STATE,
+	NFSD_A_CLIENT_SESSIONS,
+	NFSD_A_CLIENT_OPEN_STATEIDS,
+	NFSD_A_CLIENT_LOCK_STATEIDS,
+	NFSD_A_CLIENT_DELEGATION_STATEIDS,
+	NFSD_A_CLIENT_LAYOUT_STATEIDS,
 
 	__NFSD_A_CLIENT_MAX,
 	NFSD_A_CLIENT_MAX = (__NFSD_A_CLIENT_MAX - 1)
diff --git a/utils/nfsdctl/nfsdctl.8 b/utils/nfsdctl/nfsdctl.8
index 18a7a56..e4e823e 100644
--- a/utils/nfsdctl/nfsdctl.8
+++ b/utils/nfsdctl/nfsdctl.8
@@ -85,9 +85,11 @@ nfs.conf, 16 server threads will be brought online.
 .RS 4
 List NFSv4 clients known to the server. The output reports each client\(cqs
 server-generated client ID, peer address, minor version, lease and callback
-states, lease time remaining, and reclaim status. This subcommand requires
-elevated privileges. If the client set changes in a way that interrupts the
-dump, the command reports an error and should be retried.
+states, lease time remaining, reclaim status, session count, and counts of
+open, lock, delegation, and layout stateids. This subcommand requires elevated
+privileges.
+If the client set changes in a way that interrupts the dump, the command
+reports an error and should be retried.
 .RE
 .sp
 \fBlistener\fP
diff --git a/utils/nfsdctl/nfsdctl.adoc b/utils/nfsdctl/nfsdctl.adoc
index d227562..a25dc0a 100644
--- a/utils/nfsdctl/nfsdctl.adoc
+++ b/utils/nfsdctl/nfsdctl.adoc
@@ -50,9 +50,11 @@ Each subcommand can also accept its own set of options and arguments. The
 
   List NFSv4 clients known to the server. The output reports each client's
   server-generated client ID, peer address, minor version, lease and callback
-  states, lease time remaining, and reclaim status. This subcommand requires
-  elevated privileges. If the client set changes in a way that interrupts the
-  dump, the command reports an error and should be retried.
+  states, lease time remaining, reclaim status, session count, and counts of
+  open, lock, delegation, and layout stateids. This subcommand requires elevated
+  privileges.
+  If the client set changes in a way that interrupts the dump, the command
+  reports an error and should be retried.
 
 *listener*::
 
diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index c0a6d5f..096714f 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -101,6 +101,11 @@ struct nfsd_client {
 	bool		have_address4;
 	bool		have_address6;
 	bool		have_address_port;
+	uint64_t	sessions;
+	uint64_t	open_stateids;
+	uint64_t	lock_stateids;
+	uint64_t	delegation_stateids;
+	uint64_t	layout_stateids;
 	bool		reclaim_complete;
 };
 
@@ -309,6 +314,26 @@ static const char *callback_state_name(uint32_t state)
 	}
 }
 
+static void parse_client_uint(const struct nlattr *attr, uint64_t *value)
+{
+	switch (nla_len(attr)) {
+	case sizeof(uint32_t):
+		*value = nla_get_u32(attr);
+		break;
+	case sizeof(uint64_t):
+		*value = nla_get_u64(attr);
+		break;
+	}
+}
+
+static void format_client_count(uint64_t count, char *buf, size_t buflen)
+{
+	if (count == UINT64_MAX)
+		snprintf(buf, buflen, "%s", "-");
+	else
+		snprintf(buf, buflen, "%" PRIu64, count);
+}
+
 static void format_client_address(const struct nfsd_client *client, char *buf,
 				  size_t buflen)
 {
@@ -344,7 +369,13 @@ static void parse_client_get(struct genlmsghdr *gnlh,
 		.address = "unknown",
 		.state = UINT32_MAX,
 		.callback_state = UINT32_MAX,
+		.sessions = UINT64_MAX,
+		.open_stateids = UINT64_MAX,
+		.lock_stateids = UINT64_MAX,
+		.delegation_stateids = UINT64_MAX,
+		.layout_stateids = UINT64_MAX,
 	};
+	char sessions[21], opens[21], locks[21], delegations[21], layouts[21];
 	struct nlattr *attr;
 	int rem;
 
@@ -394,23 +425,47 @@ static void parse_client_get(struct genlmsghdr *gnlh,
 		case NFSD_A_CLIENT_CALLBACK_STATE:
 			client.callback_state = nla_get_u32(attr);
 			break;
+		case NFSD_A_CLIENT_SESSIONS:
+			parse_client_uint(attr, &client.sessions);
+			break;
+		case NFSD_A_CLIENT_OPEN_STATEIDS:
+			parse_client_uint(attr, &client.open_stateids);
+			break;
+		case NFSD_A_CLIENT_LOCK_STATEIDS:
+			parse_client_uint(attr, &client.lock_stateids);
+			break;
+		case NFSD_A_CLIENT_DELEGATION_STATEIDS:
+			parse_client_uint(attr, &client.delegation_stateids);
+			break;
+		case NFSD_A_CLIENT_LAYOUT_STATEIDS:
+			parse_client_uint(attr, &client.layout_stateids);
+			break;
 		default:
 			break;
 		}
 	}
 	format_client_address(&client, client.address, sizeof(client.address));
 
+	format_client_count(client.sessions, sessions, sizeof(sessions));
+	format_client_count(client.open_stateids, opens, sizeof(opens));
+	format_client_count(client.lock_stateids, locks, sizeof(locks));
+	format_client_count(client.delegation_stateids, delegations,
+			    sizeof(delegations));
+	format_client_count(client.layout_stateids, layouts, sizeof(layouts));
+
 	if (!ctx->header_printed) {
-		printf("%-18s %-47s %-4s %-11s %8s %7s %8s\n",
+		printf("%-18s %-47s %-4s %-11s %8s %5s %5s %5s %5s %6s %7s %8s\n",
 		       "clientid", "address", "vers", "state", "lease",
-		       "reclaim", "callback");
+		       "sess", "open", "lock", "deleg", "layout", "reclaim",
+		       "callback");
 		ctx->header_printed = true;
 	}
 
 	printf("0x%016" PRIx64 " %-47s 4.%-2u %-11s %8" PRId64
-	       " %7s %8s\n",
+	       " %5s %5s %5s %5s %6s %7s %8s\n",
 	       client.clientid, client.address, client.minor_version,
 	       client_state_name(client.state), client.lease_remaining,
+	       sessions, opens, locks, delegations, layouts,
 	       client.minor_version ?
 		(client.reclaim_complete ? "yes" : "no") : "-",
 	       callback_state_name(client.callback_state));
@@ -822,7 +877,7 @@ out:
 static void clients_usage(void)
 {
 	printf("Usage: %s clients\n", taskname);
-	printf("    Display NFSv4 clients and their current state.\n");
+	printf("    Display NFSv4 clients and their current state usage.\n");
 }
 
 static int clients_func(struct nl_sock *sock, int argc, char **argv)
-- 
2.54.0
