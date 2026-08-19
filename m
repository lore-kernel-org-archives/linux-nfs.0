Received: from mx0a-00069f02.pphosted.com (mx0a-00069f02.pphosted.com [205.220.165.32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EABDB306741
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2026 17:31:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=205.220.165.32
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787160678; cv=none; b=gpTyWDDpkvzov4+4x9lCOcFBhdEnvnB+VZD+Hafju/OLQ3vqdFPSWlh3B0CK7koRdWJs6RhNiH/Bh0K5gH+2GXYIzWGvQyDtqr9x22dvOrJYVbEglA5FXKUsmJ/lZnxkZJ5ARGeQ8AGm62GEjQOM0ScW/AffqXYIjcu5MXe7OEg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787160678; c=relaxed/simple;
	bh=8BVZEECUbnIOSbvsYIxaoHs8OwPOznLd2o+bheJabkY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=pEV3P4F+gLV8VifOAXNxwmjlNvMbmZNYjgBSdAysFm/dnl7mRerurhyJwGwOtAvcfy2UzIPZ/Ps6oNVb27RnqxQZP/Vnevm+hXRH8KB7QY8HqHFovHUXhmX8JlXe+SCKIhQ2QgL3xQAA5+kSPn+dPgk0tCEK2oWlGx2oTTC43yQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com; spf=pass smtp.mailfrom=oracle.com; dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b=Nvo+5VF8; arc=none smtp.client-ip=205.220.165.32
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oracle.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Nvo+5VF8"
Received: from pps.filterd (m0246629.ppops.net [127.0.0.1])
	by mx0b-00069f02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67JHMomx2438760;
	Wed, 19 Aug 2026 17:31:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=cc
	:content-transfer-encoding:date:from:message-id:mime-version
	:subject:to; s=corp-2025-04-25; bh=vl9r5z6OiNWz8Jza7aS9A4IJbEI1f
	il5hBiXYJ8bqdE=; b=Nvo+5VF8NASKtCNigFUJqld7BNP6uxl9Joir3V+BFf3SA
	XZZxpIPooF1oEN6AiiKyM1O6+vONpKmFrxZIBiQ7E9stSzPLO0Gab2nHKW8lsYs6
	fDjConBzy6Rj8glLhh6vLRBe1tr6kjryH8SNZRSyHjKShc31vidwZsLHxptWXHl1
	pTWCxc4ymZMgZjWcSEzhCL/5qulGYteroksow4or2g48veuO/4WuXjwgE0WumPpv
	qbemBxvmU0fKxMLtzOfUu2gutTa/LKX7UCuXwKO0UUiyRFe5tFVYj6CzpEmlNzss
	wqk9cdE1f4vXjqYc9s7dIl3sgRR6KZm5bTvQKZPYA==
Received: from iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (iadpaimrmta02.appoci.oracle.com [147.154.18.20])
	by mx0b-00069f02.pphosted.com (PPS) with ESMTPS id 4g4ydghsfr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Aug 2026 17:31:03 +0000 (GMT)
Received: from pps.filterd (iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com [127.0.0.1])
	by iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (8.18.1.7/8.18.1.7) with ESMTP id 67JHUXUm007235;
	Wed, 19 Aug 2026 17:31:02 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (PPS) with ESMTPS id 4g2ejs7xbt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Aug 2026 17:31:02 +0000 (GMT)
Received: from iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com [127.0.0.1])
	by pps.reinject (8.18.1.12/8.18.1.12) with ESMTP id 67JHV2dE012426;
	Wed, 19 Aug 2026 17:31:02 GMT
Received: from mbpatil-ws.osdevelopmeniad.oraclevcn.com (mbpatil-ol10-ws.webad1iad.osdevelopmeniad.oraclevcn.com [100.100.228.95])
	by iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (PPS) with ESMTP id 4g2ejs7x5t-1;
	Wed, 19 Aug 2026 17:31:02 +0000 (GMT)
From: Manjunath Patil <manjunath.b.patil@oracle.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>,
        Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
        Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
        Tom Talpey <tom@talpey.com>,
        Manjunath Patil <manjunath.b.patil@oracle.com>
Subject: [PATCH] SUNRPC: add transport details to timeout diagnostics
Date: Wed, 19 Aug 2026 10:30:55 -0700
Message-ID: <20260819173055.1956882-1-manjunath.b.patil@oracle.com>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-19_04,2026-08-19_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 mlxlogscore=999
 lowpriorityscore=0 malwarescore=0 bulkscore=0 suspectscore=0 adultscore=0
 phishscore=0 mlxscore=0 spamscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.19.0-2606160000 definitions=main-2608190136
X-Proofpoint-ORIG-GUID: dhzUD3bJcto4_LNgbMpPUTfjCzTFtMyg
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODE5MDEzNSBTYWx0ZWRfXyZZBc1PxshpS
 hvZtLXSij+6zEn7sUi6BM13ByJZdGmZUKMWG43UcnkWRWoOIQjjH8lc/i3PGpCzOYON+asoAfsy
 nJ6L8NEfEZq8JbrTKgsnxY8+VQzbaIT8VdZXdPXqTYPogd/gwYR+CaD8yNNm3B77R7XOr7ldlis
 Lt/sDmUPgxLL69oQUVFQyy0kC3EGjT3tIv/1xk8f2+iFHTj+ONGxaS6OaFxnr5M3Ri5m3q/T/3X
 lDjc+JXuD8bsMVngfzY33hTMl47u68z1J4iCuW9PrwL8BtVdG85EVxEHOZ0aguiV3efI1vwT4L7
 1Pm/AGy2ucAry6KgOLZZWCjEZQcw2NydR4SUY0C0M9TNFo8voJiM5ReIOJmNu85fkD6XPoaz2Zs
 DdeLAnRn06IBoiDejAzia2mAOolg7Bj5uK7Po8BKtG4n4woxnTdDr3VZ40DPdJFO9Q0hSmdKdJT
 SfxMWL4kwQsolZMBhswtzMPD6YpT0XnQ8YPxDuwM=
X-Proofpoint-GUID: dhzUD3bJcto4_LNgbMpPUTfjCzTFtMyg
X-Authority-Analysis: v=2.4 cv=ZIDnX37b c=1 sm=1 tr=0 ts=6a85e858 b=1 cx=c_pps
 a=e1sVV491RgrpLwSTMOnk8w==:117 a=e1sVV491RgrpLwSTMOnk8w==:17
 a=Sv0fKeRqtYgA:10 a=VkNPw1HP01LnGYTKEx00:22 a=jiCTI4zE5U7BLdzWsZGv:22
 a=EIcjfB9IiI4px24ztqRk:22 a=yPCof4ZbAAAA:8 a=D7gTrO1WIdK1LZ6UI90A:9
 a=5yU3S35YU4bGjq-dph-N:22 a=Bho9c0fBagfJEIQBS7DQ:22 cc=ntf awl=host:13521
X-Proofpoint-Spam-Info: AW1haW4tMjYwODE5MDEzNSBTYWx0ZWRfXxKpBkIVJ3uCS
 TS3gf1JRexcN6lUaPPCLgiMWS4qMji0CwUWS30gCtKnemkkycD73gh7yw5OrtIjOKZlfWGPlySq
 xkpGUfkynGDwHBPx7rBByy/JCOALAuaP2+8iEY/Nj/y8fh83gw6j

The existing RPC timeout messages identify only the RPC program and
server name. That makes it difficult to distinguish a server-side
response stall from a transport that is disconnected, reconnecting,
or using a different connection.

Include the RPC client id, transport id, current transport connection
cookie, and RPC task owner in the ratelimited timeout messages. These
fields provide a compact way to correlate a timeout message with
rpcctl and other transport state.

For example, an NFS timeout reports:

  nfs: server 192.168.50.1 clid=4 xprt=1 cc=1 owner=6245
  not responding, timed out

Assisted-by: Codex:gpt-5
Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
---
 net/sunrpc/clnt.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index efa26899bc7d..6b5e2787dc81 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2534,17 +2534,21 @@ static void
 rpc_check_timeout(struct rpc_task *task)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
+	struct rpc_rqst	*req;
+	struct rpc_xprt	*xprt;
 
 	if (RPC_SIGNALLED(task))
 		return;
 
-	if (xprt_adjust_timeout(task->tk_rqstp) == 0)
+	req = task->tk_rqstp;
+	if (xprt_adjust_timeout(req) == 0)
 		return;
+	xprt = req->rq_xprt;
 
 	trace_rpc_timeout_status(task);
 	task->tk_timeouts++;
 
-	if (RPC_IS_SOFTCONN(task) && !rpc_check_connected(task->tk_rqstp)) {
+	if (RPC_IS_SOFTCONN(task) && !rpc_check_connected(req)) {
 		rpc_call_rpcerror(task, -ETIMEDOUT);
 		return;
 	}
@@ -2556,14 +2560,15 @@ rpc_check_timeout(struct rpc_task *task)
 		 * connection gets terminally broken.
 		 */
 		if ((task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT) &&
-		    rpc_check_connected(task->tk_rqstp))
+		    rpc_check_connected(req))
 			return;
 
 		if (clnt->cl_chatty) {
 			pr_notice_ratelimited(
-				"%s: server %s not responding, timed out\n",
+				"%s: server %s clid=%u xprt=%u cc=%u owner=%d not responding, timed out\n",
 				clnt->cl_program->name,
-				task->tk_xprt->servername);
+				xprt->servername, clnt->cl_clid, xprt->id,
+				READ_ONCE(xprt->connect_cookie), task->tk_owner);
 		}
 		if (task->tk_flags & RPC_TASK_TIMEOUT)
 			rpc_call_rpcerror(task, -ETIMEDOUT);
@@ -2576,9 +2581,10 @@ rpc_check_timeout(struct rpc_task *task)
 		task->tk_flags |= RPC_CALL_MAJORSEEN;
 		if (clnt->cl_chatty) {
 			pr_notice_ratelimited(
-				"%s: server %s not responding, still trying\n",
+				"%s: server %s clid=%u xprt=%u cc=%u owner=%d not responding, still trying\n",
 				clnt->cl_program->name,
-				task->tk_xprt->servername);
+				xprt->servername, clnt->cl_clid, xprt->id,
+				READ_ONCE(xprt->connect_cookie), task->tk_owner);
 		}
 	}
 	rpc_force_rebind(clnt);
-- 
2.47.3

