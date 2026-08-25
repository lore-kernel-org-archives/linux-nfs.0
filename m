Received: from mx0a-00154904.pphosted.com (mx0a-00154904.pphosted.com [148.163.133.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 401663BB699
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 06:52:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.133.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787640753; cv=none; b=IjoC/NrqmVGgs8eW3UvuCi1e5RiT440k/7INPR4GcAcv/Cnkog5WY3KBA1excjQ8e5qCzXQC4NAwmD7XqzGmsFCtco3HpmATkX1O5ZHECoQ0QRm8sf/3kszD2godtb7sp0bOEC2qhvE566l9TUyGD0Q5+htjHlQHWaSskqocYt8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787640753; c=relaxed/simple;
	bh=gtubL7BkJmDM9XnVsOn6gvnE1uH5qqZnMFO0Z5xf6og=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=mXdsNuLb1D0gNkWclykvtsx4/3e12zvsaOh/PYu5Mn13OVVMMzcJi3aBASE5U1B0voy9R6bez5wfAtM0dMbBWodYfCIL39rZtBPmVpQ2ULXM8Q7jCzdAHzN/KcuEw78ldiixlyUodvd5Hz5gWhxBbrywFq0rJ4XoTSZdG7GqZ+w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=f8dfsV3R; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=lMnyKaFp; arc=none smtp.client-ip=148.163.133.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="f8dfsV3R";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="lMnyKaFp"
Received: from pps.filterd (m0170389.ppops.net [127.0.0.1])
	by mx0a-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P2RMwx959243
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:31 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:in-reply-to:message-id
	:mime-version:references:subject:to; s=smtpout1; bh=o017mhO94d3Y
	4cjphHB9zLtMF1+Kol7Yt1ERtMSr2WI=; b=f8dfsV3R36SMYFFSHWgJaiIhsXg/
	WJvd/skD45/RpfhnjRmI9Nf5mzY1kiIcjlHqHbfopxdHI97rt6q+VG6Vo4c73oh2
	0uGTryPzEVlzCztx0rZxKsnFbGf9N2IV4XlKEwFocWjGToJki816tm32GkMxCVE/
	PSO5MyV4aeirwdbiI9v9nKwusT2zBV4gKar6FHwOPzxWKts4wMZRsYFhWCHaYAxl
	I8EJwZz0Fyuy9ria7mRQfWbVq+F1NH0CZTMVv7nDEKrdXIW5IZ+bUpEAhYDxYHk5
	CLfAFrOSSwIjco+AQ7B1EbeBFQt/NDLKzcU9HABHly81LoK7EBxHqRozpA==
Received: from mx0b-00154901.pphosted.com (mx0b-00154901.pphosted.com [67.231.157.37])
	by mx0a-00154904.pphosted.com (PPS) with ESMTPS id 4g77se9wuj-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:31 -0400 (EDT)
Received: from pps.filterd (m0144104.ppops.net [127.0.0.1])
	by mx0b-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67P4bBjk889540
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:30 -0400
Received: from esapsmtplv08.us.dell.com (esapsmtplv08.us.dell.com [143.166.203.145])
	by mx0b-00154901.pphosted.com (PPS) with ESMTPS id 4g946b9ahw-4
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2026 02:52:29 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787640750; x=1819176750;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=o017mhO94d3Y4cjphHB9zLtMF1+Kol7Yt1ERtMSr2WI=;
  b=lMnyKaFpKL/RM42gY/TkALf+yBx3fHKcfzL5TygzPRUqALbXIakb5yPL
   BDKH7f4z5MFykCxzIcKclYFw2bioRRGY7Q9jzswZnppI6fVfClVg6tBEL
   3WoU02tYbDaTcsV25ofDH1aU2V1mKBauJAIRxoLNOd2P9/ykzEsHr14TM
   dGD77NgnXnXvqxwXKYtLkiY3+mGkJ6RwDAjRdQ1uBrMrGc92MC42EDEaz
   IDhS6Gtb8RrNaR2CvWv8kx5H/yc7ui7hCX4cN8dkzS3neoeOu1ZWI7L6x
   qKDwUoeTi4pJf0pGuM7NMSuwfSEMXugy0IJZw5PigYu5bk1AEdgTHPU0x
   g==;
X-CSE-ConnectionGUID: zSldUC2wSsGRs20y/MxHEQ==
X-CSE-MsgGUID: R+TGOsbxTEqOQsq4VDoVBw==
X-LoopCount0: from 10.94.13.48
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from w-96j1th4.apac.dell.com (HELO W-96J1TH4.blr.amer.dell.com) ([10.94.13.48])
  by esapsmtplv08.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 25 Aug 2026 06:52:28 +0000
From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
To: steved@redhat.com
Cc: cel@kernel.org, jlayton@kernel.org, linux-nfs@vger.kernel.org,
        Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH v1 3/3] nfsdctl: display per-client NFSv4 state usage
Date: Tue, 25 Aug 2026 06:52:15 +0000
Message-ID: <05399eaee964c52a935f65b2c793f77cb8a2a97a.1787639206.git.prabhakar.pujeri@dell.com>
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
X-Proofpoint-GUID: RE-OmNFdSQ1JHoHfWL49BUsm1Pyl8R5L
X-Authority-Analysis: v=2.4 cv=AobeGu9P c=1 sm=1 tr=0 ts=6a8d3baf cx=c_pps
 a=Z2e5DKjA+8LiMDv5v6mwwA==:117 a=7aFXbidJGpJUqALx8qt4zQ==:17
 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=6gNNCFAoQcIphELLPWWu:22 a=PpEg0BoV_A2aca28hXd0:22 a=iLNU1ar6AAAA:8
 a=xu6Koo9iHHN4bcdTtPkA:9 a=hlJyneSgMmFPbskH-t2w:22
X-Proofpoint-ORIG-GUID: RE-OmNFdSQ1JHoHfWL49BUsm1Pyl8R5L
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfX5MPFTb46WluL
 fZ8Jt+GroltJDvUG+cb1nJ+wv6Jwx9dOxzto4L5wnX8rz5aOGsDmFhqsNA9hbJ45hZ4CmaPn7Xm
 RBRnITBOzmXEP4GvLREgc7k0kN4gs2bbANXVODv6dQkWaGDxa8Uqney8Vphyp3dwo0ZbNlygQQa
 cQsTv6NB7rga49RfzSZHbYKN4wnb+TIO0YejQ48Gm1kSZyrne6AOjnG3UnxTCrMb9j+9e58Pwco
 lc1KJn7t+7nRAFEfPYtjatmvi+oF0xjgYhdhOEf/U1/nVqRlnO2V7Hq/jaHlpI7r6Y1mRao/mr+
 GYj0Pc6lfYdcLeazRAYIRWgkLgNDEylZaEUTcT5uDOOuzcSyz8dNmNN9qi9eiGLZAZ6MPI6xtkG
 GsuGE/dxy9b5somWQWCRTP0JdRbjNCOpEdihoIzEW2vzRiteTQt+KmzeKRilSlQS8aCq2grYqv3
 xRtO42kBCmPOxJK7ddg==
X-Proofpoint-Spam-Info: AW1haW4tMjYwODI1MDA1NyBTYWx0ZWRfX+VrkcLitq86H
 S2qwoJrvAkFtPPRm5QNH6zX41rXmx2WZGl1nYVWb7wslmKLzp5xjH55f4r0hQWrM4BwNQDoyFDc
 qeIHhHAWagxoQoUW6ZCZLnEsvPdltLU=
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0
 adultscore=0 clxscore=1015 phishscore=0 bulkscore=0 spamscore=0
 impostorscore=0 malwarescore=0 priorityscore=1501 lowpriorityscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608250057

Extend the clients table with the session and stateid record counts
exported by NFSD. These totals help an operator identify which client is
retaining server-side state before using the detailed nfsd filesystem
views.

Display a dash when a count attribute is absent. This keeps the command
accurate when a new nfsdctl is used with a kernel that supports the base
client dump but not the count extension. Require the last count attribute
before selecting the system UAPI header so building against a header with
only the base command still uses the bundled copy.

Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 configure.ac                   |  2 +-
 support/include/nfsd_netlink.h |  5 ++++
 utils/nfsdctl/nfsdctl.8        |  5 ++--
 utils/nfsdctl/nfsdctl.adoc     |  5 ++--
 utils/nfsdctl/nfsdctl.c        | 51 +++++++++++++++++++++++++++++++---
 5 files changed, 59 insertions(+), 9 deletions(-)

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
index ae49538..49c9531 100644
--- a/support/include/nfsd_netlink.h
+++ b/support/include/nfsd_netlink.h
@@ -290,6 +290,11 @@ enum {
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
index 36af317..3850461 100644
--- a/utils/nfsdctl/nfsdctl.8
+++ b/utils/nfsdctl/nfsdctl.8
@@ -85,8 +85,9 @@ nfs.conf, 16 server threads will be brought online.
 .RS 4
 List NFSv4 clients known to the server. The output reports each client\(cqs
 server-generated client ID, peer address, minor version, lease and callback
-states, lease time remaining, and reclaim status. This subcommand requires
-elevated privileges.
+states, lease time remaining, reclaim status, session count, and counts of
+open, lock, delegation, and layout stateids. This subcommand requires elevated
+privileges.
 .RE
 .sp
 \fBlistener\fP
diff --git a/utils/nfsdctl/nfsdctl.adoc b/utils/nfsdctl/nfsdctl.adoc
index 3e70b99..55575de 100644
--- a/utils/nfsdctl/nfsdctl.adoc
+++ b/utils/nfsdctl/nfsdctl.adoc
@@ -50,8 +50,9 @@ Each subcommand can also accept its own set of options and arguments. The
 
   List NFSv4 clients known to the server. The output reports each client's
   server-generated client ID, peer address, minor version, lease and callback
-  states, lease time remaining, and reclaim status. This subcommand requires
-  elevated privileges.
+  states, lease time remaining, reclaim status, session count, and counts of
+  open, lock, delegation, and layout stateids. This subcommand requires elevated
+  privileges.
 
 *listener*::
 
diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index 7f12860..9e5505d 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -94,6 +94,11 @@ struct nfsd_client {
 	uint32_t	minor_version;
 	uint32_t	state;
 	uint32_t	callback_state;
+	uint32_t	sessions;
+	uint32_t	open_stateids;
+	uint32_t	lock_stateids;
+	uint32_t	delegation_stateids;
+	uint32_t	layout_stateids;
 	bool		reclaim_complete;
 };
 
@@ -290,6 +295,14 @@ static const char *callback_state_name(uint32_t state)
 	}
 }
 
+static void format_client_count(uint32_t count, char *buf, size_t buflen)
+{
+	if (count == UINT32_MAX)
+		snprintf(buf, buflen, "%s", "-");
+	else
+		snprintf(buf, buflen, "%u", count);
+}
+
 static void format_client_address(const struct nlattr *attr, char *buf,
 				  size_t buflen)
 {
@@ -334,7 +347,13 @@ static void parse_client_get(struct genlmsghdr *gnlh,
 		.address = "unknown",
 		.state = UINT32_MAX,
 		.callback_state = UINT32_MAX,
+		.sessions = UINT32_MAX,
+		.open_stateids = UINT32_MAX,
+		.lock_stateids = UINT32_MAX,
+		.delegation_stateids = UINT32_MAX,
+		.layout_stateids = UINT32_MAX,
 	};
+	char sessions[11], opens[11], locks[11], delegations[11], layouts[11];
 	struct nlattr *attr;
 	int rem;
 
@@ -363,22 +382,46 @@ static void parse_client_get(struct genlmsghdr *gnlh,
 		case NFSD_A_CLIENT_CALLBACK_STATE:
 			client.callback_state = nla_get_u32(attr);
 			break;
+		case NFSD_A_CLIENT_SESSIONS:
+			client.sessions = nla_get_u32(attr);
+			break;
+		case NFSD_A_CLIENT_OPEN_STATEIDS:
+			client.open_stateids = nla_get_u32(attr);
+			break;
+		case NFSD_A_CLIENT_LOCK_STATEIDS:
+			client.lock_stateids = nla_get_u32(attr);
+			break;
+		case NFSD_A_CLIENT_DELEGATION_STATEIDS:
+			client.delegation_stateids = nla_get_u32(attr);
+			break;
+		case NFSD_A_CLIENT_LAYOUT_STATEIDS:
+			client.layout_stateids = nla_get_u32(attr);
+			break;
 		default:
 			break;
 		}
 	}
 
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
@@ -796,7 +839,7 @@ out:
 static void clients_usage(void)
 {
 	printf("Usage: %s clients\n", taskname);
-	printf("    Display NFSv4 clients and their current state.\n");
+	printf("    Display NFSv4 clients and their current state usage.\n");
 }
 
 static int clients_func(struct nl_sock *sock, int argc, char **argv)
-- 
2.54.0

