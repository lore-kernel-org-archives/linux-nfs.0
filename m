Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.54
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794862739;
	b=iwpo8Yw0mXus5Ki8I1BqSCBMZwGmJPb26SV3PteinfUQnG/AdObhFpDZl2kkWRMqYyjK
	 dOpTWWV4+Z8afGJkp4Rxi6DU/UIa1dcjGvMGbf+fkm+ldZ3lg7wXmMv5HNmqyeKei2i0A
	 JYcN/6QGbQSDHGe0SfucVo/ZcYoYlwEL381XUQXkyBVJSGHg+rN+ymb89gWXbrONBTNLR
	 dwYtKmeeeWe26WlVfpGO0qb43WlKO0a8jlS2VjWrdP+uV+vy89oz9hZ6/xFvhKOubgqnC
	 2clny2ZG58zR9BzFTaltYSAZITGP6jXiNmf0PzEs6unSlm+jzSyT/fj8yhVtoHOth6w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794862739;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:
	 X-Google-Original-From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=J0pyjDoOS/1DPJDbIbZOWIxwcHmmx6jrPnU06jhF1Jg=;
	b=BVpcITq234Zuy8wPsCeEld+6jerfGAtD4sOxynZUlUAjIJAfw3F0CGMKK4CoTetuhdI3
	 2xtBdU+1FGyv6Rv9EPClWfhSsxrRCJ/DU1S74XmRnH3gjMj0QBi4RKruwzzYfPR/RTOWK
	 dNtxrk9eY6UsBH0ZTkvFnWWIFLrRqf6Hj9/QjKL0/McBteAEEzzdbnDWW3hO/m0DsQZ5i
	 5JZ+9EZzH2sEPeanxOrTztsWoP5ejBPygY0vPKrPswPpyjICMhxNoi9VDSvoG3utZWZyU
	 6WviB/X7Fuo27hAoWNvsiIp0gISoiJyO7vkeBk+D4vmq/XtnHs3soRKh8fWegmETFqQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=eqVLSXuV;
	arc=none smtp.remote-ip=209.85.161.54
Received: from mail-oo1-f54.google.com (mail-oo1-f54.google.com [209.85.161.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E008A606A322
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 20:58:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E008A606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=eqVLSXuV
Received: by mail-oo1-f54.google.com with SMTP id 006d021491bc7-71af0656bedso831579eaf.0
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 12:58:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1794862738; x=1795467538; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=J0pyjDoOS/1DPJDbIbZOWIxwcHmmx6jrPnU06jhF1Jg=;
        b=eqVLSXuVx/ZXOSgUBvoLTz+ClEhP/HK140ge6dGWmQnKXjJ44HfuVZsSFdW7So9Jd0
         ZDro5xDZcfy2idfJPmzjd7r+sT29Yh8mnbGOnFRFlGv+4/4QlH8yRL2PmlPHiBSzKNom
         Lxn4kkKUEMTmGpyeHjrvQfCHj8XLHInF+IQutChFrgGi+nr6Rm+0bgoknUgFlr9lLIyM
         sTh8HQ1kJhsZSoxelmjCzqkJMHyJEEvkoJIGkbOLCP0apXgm0kPa0sRdtzWEujoFExpu
         vBEsQ5Lxa6JLtHkUY9vVBsRYgxJQ/PVKcHHQkKqXm4HC00iFrgQjLVmNEATYn1jhSFbT
         y2IA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794862738; x=1795467538;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=J0pyjDoOS/1DPJDbIbZOWIxwcHmmx6jrPnU06jhF1Jg=;
        b=pK/B9BuLBi6yOjc0z2mKoWsB+WHmZW52d8E/42sG810+oCgyG2elTO8+yyTLpbNtnu
         56SjS5SdcotyAXuiEExhlq8GUPivbuWJPI3n9n2r633emDm3XTD6st2eVp6XVT6Dpkot
         alJn3N7b4pumTVeoOlCfeNy5iWnx5HQqKMCJ5GSCoKIPnaOCVHeMVqbBtbPBMm4G+HE8
         cqkfgSADoPvCUegkJo9JLR0ddBcvidxPGiu1Q1kzk3FoJ/db8kLoe5ZmGqPYgyUqyteH
         uw4q8HcMG7sfgXxf2pr6+4bnDSnzPLGDRnmMg04r19ZY6aT4czHu9g7ohOg2vbGqF3F/
         I2zQ==
X-Gm-Message-State: APuU4Z/5Oc5oS4Om5elY1EDewLvzFd4O0BcjP7lflmAX5E1iesvybhUR
	vWXoyjAkDMj08blMuUzAEXVEMk9EltY+nvu9/moHdBrM84+td/vTSYD3jKJ4AaBTAio=
X-Gm-Gg: AYBFou1t1na0wBjSAqt14aTixricnuxwdVfMwMIbKKmbffBCjuIwbSgZwqsEWEVTqmU
	P8RDYHBpaQozCJGk94nirCgiiByMJwZ1X++YETgfp03GlFznN+SHpO8JBW5AvsrKAq+wU1gxoEC
	sNwNC7YTpafHCpY3feTw/gV/Es8LXto087H0NrNpqp5JC7WFZ4JMnEUiLeIc8w4+TQX80UMCKQP
	fg8vlYqjpC+dfudA1uPRHYnLzX5l8UrXQdT6KuexTlpPnyKc9m9JAbRbeZkkkiWu3aTF87MBgbP
	JlZRCe6lMFJH1Vj/gR0V0lknrKeZMIIv8px4NepduJNR2Vkfv1fxS9ZIgME0ngfw5N9XHRQHUUu
	iazGU4xI4sx6rzFiobr0twNiu+Q5fVyRZ4ufJsY1Z+0+0+yizMPKdN57pgyFJvIa/Fo80OFwa7w
	sql1F8/zHJI57P45BojPn83jnNS7FXOPfO7gTRYmlbHIHnz4Dd46+PrXTWeO2Ae5z7xKiB4t1/G
	rIDCftfn3GbM5OjoGkr4JDFiSz5bFWMuc+IEnMmsu0UqO/rUjE0XiLNRdsqKlk94DcnbsakTS7G
	1pexF+dK1TfYPrzpBZI7k7pGjV5ZvopugpJHUfmK3vfbs7ROs9vFgsNTb+k4tTZ6GizIYEjbkbR
	FylcF3amfn+lB7w==
X-Received: by 2002:a05:6820:c44b:20b0:71a:f794:49c2 with SMTP id 006d021491bc7-71af7944c62mr1723906eaf.55.1794862737574;
        Mon, 16 Nov 2026 12:58:57 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-862ca4d11fasm3175528a34.19.2026.11.16.12.58.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Nov 2026 12:58:55 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH] nfsdctl: bound the rpcbind calls to one 1s attempt
Date: Mon, 16 Nov 2026 15:58:52 -0500
Message-ID: <2221871feaf9ae6ec4970238fe11805abd2496c6.1794862543.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

libtirpc's rpcb_set() and rpcb_unset() create a client for every call
and wait 60s for each reply. A local rpcbind that accepts the connection
and never answers stalls nfsdctl for a minute per call: five UNSETs when
the threads stop, and five UNSETs plus one SET per listener netid and
program when they start. libtirpc's setter for that timeout is private.

Make the SET and UNSET calls on a client of nfsdctl's own, built with
nfs_get_rpcclient(): AF_LOCAL on _PATH_RPCBINDSOCK first, then TCP to
127.0.0.1 port 111, as libtirpc's local_rpcb() orders them. Each pass
uses one client, and each call is one attempt of 1s, matching
17ceb2fecc7c ("SUNRPC: bound the local rpcbind client timeout to 1s"):
"The local rpcbind is on loopback or on an AF_LOCAL socket, and it
answers in microseconds."

A call that gets no answer ends the pass with one warning, as
ba8c47f04942 and df1ff8e4e275 do for the kernel's svc_register() and
svc_unregister() sweep. A registration pass whose opening UNSET sweep
gets no answer makes no SET. A reply of FALSE is logged and the pass
continues, as before.

nfs_svc_unregister() is unchanged, and a build without TI-RPC keeps
using it.

With the local rpcbind SIGSTOPped, on a kernel that leaves the nfsd
registration to nfsdctl, "nfsdctl threads 0" returned after 3.4s, where
it took 302.7s before. lockd's own registration in the kernel accounts
for 2s of that. "nfsdctl autostart" now ends its registration pass after
1s. The THREADS_SET that follows still fails with EIO, because lockd
cannot register.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 utils/nfsdctl/rpcbind.c | 199 +++++++++++++++++++++++++++++++++++-----
 1 file changed, 178 insertions(+), 21 deletions(-)

diff --git a/utils/nfsdctl/rpcbind.c b/utils/nfsdctl/rpcbind.c
index 23034097b485..a705c54d8f40 100644
--- a/utils/nfsdctl/rpcbind.c
+++ b/utils/nfsdctl/rpcbind.c
@@ -15,17 +15,23 @@
 
 #include <errno.h>
 #include <netinet/in.h>
+#include <stdio.h>
+#include <stdlib.h>
 #include <string.h>
 #include <sys/socket.h>
+#include <sys/un.h>
+#include <unistd.h>
 
 #include <rpc/rpc.h>
 
 #ifdef HAVE_LIBTIRPC
 #include <rpc/rpcb_clnt.h>
+#include <rpc/rpcb_prot.h>
 #include <netconfig.h>
 #endif	/* HAVE_LIBTIRPC */
 
 #include "nfslib.h"
+#include "nfsrpc.h"
 #include "rpcmisc.h"
 #include "sockaddr.h"
 #include "xlog.h"
@@ -43,7 +49,7 @@
 
 /*
  * Programs to clear at shutdown. There is no reply to read at that point,
- * so clear a superset. rpcb_unset() of an absent entry does nothing.
+ * so clear a superset. An UNSET of an absent entry does nothing.
  */
 static const struct {
 	rpcprog_t	program;
@@ -56,24 +62,135 @@ static const struct {
 	{ NFS_ACL_PROGRAM,	3 },
 };
 
+#ifdef HAVE_LIBTIRPC
+
+/*
+ * libtirpc's rpcb_set() and rpcb_unset() wait 60s for each call, and its
+ * setter for that timeout is not exported. The local rpcbind answers in
+ * microseconds, so make the calls on a client of our own with one attempt
+ * of 1s, as the kernel's own rpcbind client does.
+ */
+static const struct timeval nfsd_rpcb_timeout = { 1, 0 };
+
+enum nfsd_rpcb_status {
+	NFSD_RPCB_OK,
+	NFSD_RPCB_DECLINED,
+	NFSD_RPCB_NO_ANSWER,
+};
+
+/* AF_LOCAL first, then loopback TCP, as libtirpc's local_rpcb() does. */
+static CLIENT *nfsd_rpcb_client(void)
+{
+	const struct sockaddr_un sun = {
+		.sun_family	= AF_LOCAL,
+		.sun_path	= _PATH_RPCBINDSOCK,
+	};
+	const struct sockaddr_in sin = {
+		.sin_family	= AF_INET,
+		.sin_port	= htons(111),
+		.sin_addr.s_addr = htonl(INADDR_LOOPBACK),
+	};
+	struct timeval timeout = nfsd_rpcb_timeout;
+	CLIENT *clnt;
+
+	clnt = nfs_get_rpcclient((const struct sockaddr *)&sun, SUN_LEN(&sun),
+				 0, RPCBPROG, RPCBVERS, &timeout);
+	if (clnt) {
+		xlog(D_GENERAL, "rpcbind: using %s", _PATH_RPCBINDSOCK);
+		return clnt;
+	}
+
+	timeout = nfsd_rpcb_timeout;
+	clnt = nfs_get_rpcclient((const struct sockaddr *)&sin, sizeof(sin),
+				 IPPROTO_TCP, RPCBPROG, RPCBVERS, &timeout);
+	if (clnt)
+		xlog(D_GENERAL, "rpcbind: using 127.0.0.1 port 111 over TCP");
+	return clnt;
+}
+
+/*
+ * A transport error means rpcbind accepted the connection and did not
+ * answer. Every later call on this pass would wait the same, so the caller
+ * stops.
+ */
+static enum nfsd_rpcb_status nfsd_rpcb_call(CLIENT *clnt, rpcproc_t proc,
+					    struct rpcb *parms)
+{
+	enum clnt_stat stat;
+	bool_t rslt = FALSE;
+
+	stat = CLNT_CALL(clnt, proc, (xdrproc_t)xdr_rpcb, (char *)parms,
+			 (xdrproc_t)xdr_bool, (char *)&rslt, nfsd_rpcb_timeout);
+	switch (stat) {
+	case RPC_SUCCESS:
+		return rslt ? NFSD_RPCB_OK : NFSD_RPCB_DECLINED;
+	case RPC_TIMEDOUT:
+	case RPC_CANTRECV:
+	case RPC_CANTSEND:
+		xlog(L_WARNING,
+		     "rpcbind did not answer %s of program %u version %u: %s. Skipping the remaining rpcbind calls.",
+		     proc == RPCBPROC_SET ? "SET" : "UNSET",
+		     parms->r_prog, parms->r_vers, clnt_sperrno(stat));
+		return NFSD_RPCB_NO_ANSWER;
+	default:
+		xlog(D_GENERAL, "rpcbind call failed: %s", clnt_sperrno(stat));
+		return NFSD_RPCB_DECLINED;
+	}
+}
+
+/*
+ * An empty netid and address unset every netid of [program, version], as
+ * rpcb_unset() with no netconfig does.
+ */
+static enum nfsd_rpcb_status nfsd_rpcb_unset_sweep(CLIENT *clnt)
+{
+	char empty[] = "";
+	char owner[16];
+	struct rpcb parms = {
+		.r_netid	= empty,
+		.r_addr		= empty,
+		.r_owner	= owner,
+	};
+	enum nfsd_rpcb_status status;
+	unsigned int i;
+
+	snprintf(owner, sizeof(owner), "%d", (int)geteuid());
+
+	for (i = 0; i < ARRAY_SIZE(nfsd_rpcb_all); i++) {
+		parms.r_prog = nfsd_rpcb_all[i].program;
+		parms.r_vers = nfsd_rpcb_all[i].version;
+
+		status = nfsd_rpcb_call(clnt, RPCBPROC_UNSET, &parms);
+		if (status == NFSD_RPCB_NO_ANSWER)
+			return status;
+		if (status == NFSD_RPCB_DECLINED)
+			xlog(D_GENERAL,
+			     "Failed to unregister program %u, version %u",
+			     parms.r_prog, parms.r_vers);
+	}
+	return NFSD_RPCB_OK;
+}
+
 /**
  * nfsd_rpcb_unset_all - remove every nfsd entry from the local rpcbind
  *
- * rpcb_unset() matches [program, version, netid] and takes no address, so
- * one call clears every netid. This mirrors the svc_unregister() sweep that
- * svc_rpcb_setup() used to run, which an sv_no_rpcbind serv no longer does.
+ * This mirrors the svc_unregister() sweep that svc_rpcb_setup() used to
+ * run, which an sv_no_rpcbind serv no longer does.
  */
 void nfsd_rpcb_unset_all(void)
 {
-	unsigned int i;
+	CLIENT *clnt;
 
-	for (i = 0; i < ARRAY_SIZE(nfsd_rpcb_all); i++)
-		nfs_svc_unregister(nfsd_rpcb_all[i].program,
-				   nfsd_rpcb_all[i].version);
+	clnt = nfsd_rpcb_client();
+	if (!clnt) {
+		xlog(D_GENERAL, "cannot reach rpcbind: %s",
+		     clnt_sperrno(rpc_createerr.cf_stat));
+		return;
+	}
+	nfsd_rpcb_unset_sweep(clnt);
+	CLNT_DESTROY(clnt);
 }
 
-#ifdef HAVE_LIBTIRPC
-
 /*
  * Map a transport name and address family to an rpcbind netid.
  *
@@ -125,32 +242,47 @@ static bool nfsd_rpcb_wildcard(const struct sockaddr_storage *ss,
 	return false;
 }
 
-static bool nfsd_rpcb_set_one(rpcprog_t program, rpcvers_t version,
-			      const char *netid,
-			      const struct sockaddr_storage *ss)
+static enum nfsd_rpcb_status nfsd_rpcb_set_one(CLIENT *clnt,
+					       rpcprog_t program,
+					       rpcvers_t version,
+					       const char *netid,
+					       const struct sockaddr_storage *ss)
 {
+	enum nfsd_rpcb_status status;
 	struct sockaddr_storage wild;
 	struct netconfig *nconf;
+	struct rpcb parms;
 	struct netbuf nb;
+	char owner[16];
 	socklen_t len;
-	bool ok;
 
 	if (!nfsd_rpcb_wildcard(ss, &wild, &len))
-		return false;
+		return NFSD_RPCB_DECLINED;
 
 	nconf = getnetconfigent(netid);
 	if (!nconf) {
 		xlog(L_WARNING, "no netconfig entry for %s", netid);
-		return false;
+		return NFSD_RPCB_DECLINED;
 	}
 
 	nb.buf = &wild;
 	nb.len = len;
 	nb.maxlen = len;
 
-	ok = (rpcb_set(program, version, nconf, &nb) == TRUE);
+	parms.r_addr = taddr2uaddr(nconf, &nb);
 	freenetconfigent(nconf);
-	return ok;
+	if (!parms.r_addr)
+		return NFSD_RPCB_DECLINED;
+
+	snprintf(owner, sizeof(owner), "%d", (int)geteuid());
+	parms.r_prog = program;
+	parms.r_vers = version;
+	parms.r_netid = (char *)netid;
+	parms.r_owner = owner;
+
+	status = nfsd_rpcb_call(clnt, RPCBPROC_SET, &parms);
+	free(parms.r_addr);
+	return status;
 }
 
 /**
@@ -167,14 +299,25 @@ static bool nfsd_rpcb_set_one(rpcprog_t program, rpcvers_t version,
 void nfsd_rpcb_register(const struct server_socket *listeners, int nlisteners,
 			const struct nfsd_rpcb_prog *progs, int nprogs)
 {
+	enum nfsd_rpcb_status status;
 	unsigned int failed = 0;
+	CLIENT *clnt;
 	int i, j, k;
 
+	clnt = nfsd_rpcb_client();
+	if (!clnt) {
+		xlog(L_WARNING,
+		     "cannot reach rpcbind: %s. Clients that look up the server in rpcbind cannot find it.",
+		     clnt_sperrno(rpc_createerr.cf_stat));
+		return;
+	}
+
 	/*
 	 * Clear first. rpcbind cannot express "drop one of two TCP ports",
 	 * and the kernel no longer sweeps stale entries at serv creation.
 	 */
-	nfsd_rpcb_unset_all();
+	if (nfsd_rpcb_unset_sweep(clnt) == NFSD_RPCB_NO_ANSWER)
+		goto out;
 
 	for (i = 0; i < nlisteners; i++) {
 		const struct server_socket *l = &listeners[i];
@@ -215,9 +358,12 @@ void nfsd_rpcb_register(const struct server_socket *listeners, int nlisteners,
 			    !strncmp(netid, "udp", 3))
 				continue;
 
-			if (nfsd_rpcb_set_one(p->program, p->version, netid,
-					      &l->ss))
+			status = nfsd_rpcb_set_one(clnt, p->program,
+						   p->version, netid, &l->ss);
+			if (status == NFSD_RPCB_OK)
 				continue;
+			if (status == NFSD_RPCB_NO_ANSWER)
+				goto out;
 
 			xlog(L_WARNING,
 			     "cannot register program %u version %u on %s port %u",
@@ -230,10 +376,21 @@ void nfsd_rpcb_register(const struct server_socket *listeners, int nlisteners,
 	if (failed)
 		xlog(L_WARNING,
 		     "some rpcbind registrations failed. Clients that look up the server in rpcbind cannot find it.");
+out:
+	CLNT_DESTROY(clnt);
 }
 
 #else	/* !HAVE_LIBTIRPC */
 
+void nfsd_rpcb_unset_all(void)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(nfsd_rpcb_all); i++)
+		nfs_svc_unregister(nfsd_rpcb_all[i].program,
+				   nfsd_rpcb_all[i].version);
+}
+
 /*
  * rpcb_set() and the netconfig database are TI-RPC only, so a build
  * without it cannot own the registration. userspace_rpcbind_supported()
-- 
2.53.0

