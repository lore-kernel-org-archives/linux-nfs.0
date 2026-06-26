Received: from smtp-o-3.desy.de (smtp-o-3.desy.de [131.169.56.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED2A12E738E
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2026 12:52:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=131.169.56.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782478364; cv=none; b=jq3vKoPt9MS7heMzvhp04lIx7cv/Nb6CSy6ihp3nq5fd9QOSqW8nyZXTZdLeXDuaG3tsEVe+F3uFm8A24D+MhVlSKlErNF0fVKfx7c2NbxCz2FDPp/wyh0NXNF/xVL4h8BygMdU0aPctVZruZYwXfLZyMs57FyerTLatd/Xbx0Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782478364; c=relaxed/simple;
	bh=O0kMPVSQ9Fsl5+c7l9TveE2IZMpiHkm5ShhN6DsNEY0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=AVFqIXVMR8hhs68HV0i7vQBDAxJN89/Van4SmILiFywyAdIxNxBa5GLcX98cLjdfHLEhu4VOq6BkpZGsqv9G7dt6vZg6piK/vUVbkelJrS73i8xu1O8KQhO/y1GHg9GXJQyiUxCY2Pp9Bh3dHtMPCNt/Cd4WjYPzXjJRT09hZOo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de; spf=pass smtp.mailfrom=desy.de; dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b=R1gi4Nid; arc=none smtp.client-ip=131.169.56.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=desy.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="R1gi4Nid"
Received: from smtp-o-2.desy.de (smtp-o-2.desy.de [IPv6:2001:638:700:1038::1:9b])
	by smtp-o-3.desy.de (Postfix) with ESMTP id ADE4B11F9E7
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2026 14:52:33 +0200 (CEST)
Received: from smtp-buf-2.desy.de (smtp-buf-2.desy.de [131.169.56.165])
	by smtp-o-2.desy.de (Postfix) with ESMTP id 2489313F655
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2026 14:52:26 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-2.desy.de 2489313F655
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
	t=1782478346; bh=NM1m6/KIcviMgvKIAXltIU7Y9AuV34r/Rf2/faQ7IRo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=R1gi4Nidvxla65fAcJfVtDikcDFyJ+CM83EXULmu3+lDnGzxS6Vu/Af8krIg0qxdB
	 Mb4A+aByYUSG0U65s0a+7R19WeNy3NxKiM6Hq41Mq6rJkDDTNA6rXBWgj8sbP7CTz8
	 loEz7aOgnuDtiwhjpz9iJk4uSwtYRqFka5XoSvjA=
Received: from smtp-m-2.desy.de (smtp-m-2.desy.de [131.169.56.130])
	by smtp-buf-2.desy.de (Postfix) with ESMTP id 16AEF120043;
	Fri, 26 Jun 2026 14:52:26 +0200 (CEST)
Received: from b1722.mx.srv.dfn.de (b1722.mx.srv.dfn.de [IPv6:2001:638:d:c302:acdc:1979:2:e7])
	by smtp-m-2.desy.de (Postfix) with ESMTP id 08B7A160043;
	Fri, 26 Jun 2026 14:52:26 +0200 (CEST)
Received: from smtp-intra-1.desy.de (smtp-intra-1.desy.de [IPv6:2001:638:700:1038::1:52])
	by b1722.mx.srv.dfn.de (Postfix) with ESMTP id 757CA160060;
	Fri, 26 Jun 2026 14:52:25 +0200 (CEST)
Received: from z-prx-3.desy.de (z-prx-3.desy.de [131.169.10.30])
	by smtp-intra-1.desy.de (Postfix) with ESMTP id 686C880046;
	Fri, 26 Jun 2026 14:52:25 +0200 (CEST)
Received: from localhost (localhost [IPv6:::1])
	by z-prx-3.desy.de (Postfix) with ESMTP id 6089A14052E;
	Fri, 26 Jun 2026 14:52:25 +0200 (CEST)
Received: from z-prx-3.desy.de ([IPv6:::1])
 by localhost (z-prx-3.desy.de [IPv6:::1]) (amavis, port 10026) with ESMTP
 id CAnFK-2J63jc; Fri, 26 Jun 2026 14:52:25 +0200 (CEST)
Received: from nairi.fritz.box (unknown [IPv6:2001:638:700:e064::1b])
	by z-prx-3.desy.de (Postfix) with ESMTPSA id 65836140478;
	Fri, 26 Jun 2026 14:52:23 +0200 (CEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: trondmy@kernel.org,
	chuck.lever@oracle.com,
	jlayton@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 1/1] [RFC] sunrpc: inject process namespace into machinename field
Date: Fri, 26 Jun 2026 14:52:16 +0200
Message-ID: <20260626125216.1467845-2-tigran.mkrtchyan@desy.de>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260626125216.1467845-1-tigran.mkrtchyan@desy.de>
References: <20260626125216.1467845-1-tigran.mkrtchyan@desy.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On large shared machines often multiple jobs of a same user run in
parallel. For debugging, it's usually impossible to identify requests
coming from different processes.

The batch systems like HTCondor or SLURM start every job in it's own
namespace, thus passing namespace info to the server will help by
debugging.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 net/sunrpc/auth_unix.c | 27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 6c742a3400c4..b218cfa9871a 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -15,6 +15,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/auth.h>
 #include <linux/user_namespace.h>
+#include <linux/pid_namespace.h>
 
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
@@ -117,6 +118,28 @@ unx_marshal(struct rpc_task *task, struct xdr_stream *xdr)
 	struct group_info *gi = cred->cr_cred->group_info;
 	struct user_namespace *userns = clnt->cl_cred ?
 		clnt->cl_cred->user_ns : &init_user_ns;
+	char ns_aware_nodename[UNX_MAXNODENAME + 1];
+	int ns_aware_nodename_len;
+
+	struct pid_namespace *pid_ns = task_active_pid_ns(current);
+
+	/* the process runs in a dedicated namespace */
+	if (pid_ns != &init_pid_ns) {
+		/* Format as: <pid_ns_inum>@<current-hostname> */
+		int prefix_len = snprintf(ns_aware_nodename, sizeof(ns_aware_nodename),
+			"%u@", pid_ns->ns.inum);
+
+		if (prefix_len < sizeof(ns_aware_nodename))
+			strscpy(ns_aware_nodename + prefix_len, clnt->cl_nodename,
+				sizeof(ns_aware_nodename) - prefix_len);
+		else
+			strscpy(ns_aware_nodename, clnt->cl_nodename, sizeof(ns_aware_nodename));
+
+		ns_aware_nodename_len = strlen(ns_aware_nodename);
+	} else {
+		ns_aware_nodename_len = clnt->cl_nodelen;
+		strscpy(ns_aware_nodename, clnt->cl_nodename, sizeof(ns_aware_nodename));
+	}
 
 	/* Credential */
 
@@ -126,8 +149,8 @@ unx_marshal(struct rpc_task *task, struct xdr_stream *xdr)
 	*p++ = rpc_auth_unix;
 	cred_len = p++;
 	*p++ = xdr_zero;	/* stamp */
-	if (xdr_stream_encode_opaque(xdr, clnt->cl_nodename,
-				     clnt->cl_nodelen) < 0)
+	if (xdr_stream_encode_opaque(xdr, ns_aware_nodename,
+				     ns_aware_nodename_len) < 0)
 		goto marshal_failed;
 	p = xdr_reserve_space(xdr, 3 * sizeof(*p));
 	if (!p)
-- 
2.54.0

