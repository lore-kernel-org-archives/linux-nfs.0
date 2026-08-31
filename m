Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF9A34BD117;
	Mon, 31 Aug 2026 16:15:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788192949; cv=none; b=HwpZK8u8brvgW0EDI2JUe66+BMlYWebXdc0Qjp2lc5MLesP3v9mill1SoYJY78u9CKwq2/vEUgYLg/n4cWgtenfoHTArYCEI5zambOjvx9es5owmwAPRdjokr9L1YTy1WfbHG3AwVN1N3i561+/HrCAuRdKE+pmFAVvtdXOgu/k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788192949; c=relaxed/simple;
	bh=o99W7qSRRJ+Y/tsip/S0lSm28nLHZLRmUmnaqw+MiHQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=h8r1bQ5aow/O+xoCO7ACL84nChRQp5vjp4FUoldUp3CMdJpEqwGalN7BQMFo8S1rTIumR6xJ9/xESXvjY2V6r8docod6V31dgIy7H7qBmFlFEFB3He7tkjw7fM0s1Bk0RoLzkc8HV6jQYgLOdC2NJh8qoTvNUFAoEJVEry+kIMo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bY4ta6af; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bY4ta6af"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E06CF1F000E9;
	Mon, 31 Aug 2026 16:15:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788192947;
	bh=WlCLzkBgAhOYn2skq/4EcohabDdslPnnLRHwRDovpHs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bY4ta6afoiMZJt88wkRhqrt6a7ucewawJrqM/85+LLGuIXtxdF9FVBZuA+R4kc566
	 WGDk1sa+UTbiErkNUMZ3WchDm+sFLivmlIKt52Xa5FYhQTNIAhQ2Tf59OA6e+sdeIC
	 7CcWqxG/+CRdY0D6RifepOKcb8GB9VtUm9+1mJ4XRP4f+jU5RUjAO96m11ypnqbEFB
	 7WVTZsuAWBtE3X1emFxUkgrohRWDNrheFpK4Kjfe39NoBNdazYY8sTyAaikturWuuc
	 5KxO57VLmdUpH2zwlZSI4tjkyNR73wAij+6BG1gN+u6yER83kPup7qtSDePwjWX/+I
	 OhBqXcaGzLRBg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 31 Aug 2026 12:14:48 -0400
Subject: [PATCH v4 06/14] SUNRPC: report local rpcbind calls that get no
 answer
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-nfsd-nl-hang-v4-6-0f4e89139409@kernel.org>
References: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
In-Reply-To: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Shuah Khan <shuah@kernel.org>
Cc: Slawomir Stepien <sst@poczta.fm>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, 
 Trond Myklebust <trondmy@gmail.com>, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=8066; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=o99W7qSRRJ+Y/tsip/S0lSm28nLHZLRmUmnaqw+MiHQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqlaihYeB4bGwAOJ1LJcPkQPww/FxX4AhbKyhyl
 ueq0R0ZRr2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapWooQAKCRAADmhBGVaC
 Fa4WD/9swYrd6fEZc+rVaRDuLnUvO7QsaDg+Q5jVKDX3DxdqIwOtD1+GH4NW9X/FfYNCzsBDXax
 tEIrbmQ97Ppq9KVSVtBI4L3SbqirWWh9+Y64W2iLfy9n6I6FA8dWF5AjJ48mFQHXIboHxHjINCi
 en6f1wn71CpyhDCSzupxgF37IJ5/qpkal9pObKVkfCMQs6TRupByVXH6N2d3ENtEjowGvW3TSwW
 GKyUYdPY2gHPb3ktfxLNIe/aDvO/nAr7ol6xl5eeIG4FL/UnIGsdleORsWPecTFV8NFeMxW8fY2
 ZfYonPpcCCSFOzRKNhzsyLNcU2p+6kTKANXw0xR50TwJ7TSRusm2P5lkrahRJQ+5BjWncSfEeBE
 kB3r4BqedfGzmXmyvDNpxXzNzfaBlotkJ0ibj/VOn9Zjn2Mryd7Pnw3NZqwzKzouRMTLecQ/76j
 RltnNDnu9XxavHnegPu5JP+3PSHaUOlZhWjeyM7ATyDL/IMbgPzY0Mb52MhY7QRB1/vfwBgd7oT
 3ZwbAGiuvwWvtma1Pvj/iC+Pzto3GJREM/aR2zW+z5jo9Sa/adPLoCo/bm9bzhG8wbMXCEmiSgz
 CJN9OOVVBtd7VBI7v99tD//zSJPQBIx4DVGxZhCGEyNX+qOtoQCeLPK5CnVdSB4/dlYd0K/G/9N
 86pTtTmdjwWSDqQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A caller that creates many listeners in one operation calls svc_register()
once for each of them. Every call waits for the local rpcbind on its own,
so a rpcbind that never answers costs the caller one timeout per listener.
The caller has no way to learn that the first call already failed.

Split rpcb_register_call() failures by whether rpcbind answered:

 - answered: a FALSE reply, or an RPC-level rejection that
   rpc_decode_header() derives from the reply. -EACCES (FALSE reply or
   AUTH_ERROR), -EPROTONOSUPPORT, -EPFNOSUPPORT, -EOPNOTSUPP.
 - never sent: -ENOMEM, -EMSGSIZE, -ERESTARTSYS.
 - no answer: everything else, i.e. transport errors.

Any no-answer error gets represented by -EIO, which is already what the
RPC layer reports for most of it: rpc_check_timeout() returns -EIO for a
soft timeout without RPC_TASK_TIMEOUT, and call_status() documents -EIO
as "shutdown or soft timeout".

Keep a count of the number of rpcbind failures in the serv. Later
patches will use that to watch for hard rpcbind failures, and alter
their behavior accordingly.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 include/linux/sunrpc/clnt.h |  3 ++-
 include/linux/sunrpc/svc.h  |  7 +++++--
 net/sunrpc/rpcb_clnt.c      | 21 ++++++++++++++++++---
 net/sunrpc/svc.c            | 42 +++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 66 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 3c2b8c355ab3..30344c0d6a9d 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -199,7 +199,8 @@ struct rpc_xprt	*rpc_task_get_xprt(struct rpc_clnt *clnt,
 
 int		rpcb_create_local(struct net *);
 void		rpcb_put_local(struct net *);
-int		rpcb_register(struct net *, u32, u32, int, unsigned short);
+int		rpcb_register(struct net *net, u32 prog, u32 vers, int prot,
+			      unsigned short port);
 int		rpcb_v4_register(struct net *net, const u32 program,
 				 const u32 version,
 				 const struct sockaddr *address,
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 2db1b9ec5658..5fa9417e034d 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -78,6 +78,7 @@ struct svc_serv {
 	unsigned int		sv_max_payload;	/* datagram payload size */
 	unsigned int		sv_max_mesg;	/* max_payload + 1 page for overheads */
 	unsigned int		sv_xdrsize;	/* XDR buffer size */
+	atomic_t		sv_rpcb_failures; /* unanswered rpcbind calls */
 	struct list_head	sv_permsocks;	/* all permanent sockets */
 	struct list_head	sv_tempsocks;	/* all temporary sockets */
 	int			sv_tmpcnt;	/* count of temporary "valid" sockets */
@@ -451,6 +452,7 @@ int sunrpc_set_pool_mode(const char *val);
 int sunrpc_get_pool_mode(char *val, size_t size);
 void svc_rpcb_cleanup(struct svc_serv *serv, struct net *net);
 int svc_bind(struct svc_serv *serv, struct net *net);
+unsigned int svc_rpcb_failure_count(struct svc_serv *serv);
 struct svc_serv *svc_create(struct svc_program *, unsigned int,
 			    int (*threadfn)(void *data));
 bool		   svc_rqst_replace_page(struct svc_rqst *rqstp,
@@ -471,8 +473,9 @@ unsigned int	   svc_serv_maxthreads(const struct svc_serv *serv);
 int		   svc_pool_stats_open(struct svc_info *si, struct file *file);
 void		   svc_process(struct svc_rqst *rqstp);
 void		   svc_process_bc(struct rpc_rqst *req, struct svc_rqst *rqstp);
-int		   svc_register(const struct svc_serv *, struct net *, const int,
-				const unsigned short, const unsigned short);
+int		   svc_register(struct svc_serv *serv, struct net *net,
+				const int family, const unsigned short proto,
+				const unsigned short port);
 
 void		   svc_wake_up(struct svc_serv *);
 void		   svc_reserve(struct svc_rqst *rqstp, int space);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 0aa376b82a52..50169ee12bd8 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -412,7 +412,8 @@ static struct rpc_clnt *rpcb_create(struct net *net, const char *nodename,
 	return rpc_create(&args);
 }
 
-static int rpcb_register_call(struct sunrpc_net *sn, struct rpc_clnt *clnt, struct rpc_message *msg, bool is_set)
+static int rpcb_register_call(struct sunrpc_net *sn, struct rpc_clnt *clnt,
+			      struct rpc_message *msg, bool is_set)
 {
 	int flags = RPC_TASK_NOCONNECT;
 	int error, result = 0;
@@ -422,8 +423,22 @@ static int rpcb_register_call(struct sunrpc_net *sn, struct rpc_clnt *clnt, stru
 	msg->rpc_resp = &result;
 
 	error = rpc_call_sync(clnt, msg, flags);
-	if (error < 0)
-		return error;
+	if (error < 0) {
+		switch (error) {
+		/* rpcbind answered; the reply itself carries the error */
+		case -EPROTONOSUPPORT:
+		case -EPFNOSUPPORT:
+		case -EOPNOTSUPP:
+		case -EACCES:
+		/* the call never made it onto the wire */
+		case -ENOMEM:
+		case -EMSGSIZE:
+		case -ERESTARTSYS:
+			return error;
+		}
+		/* anything else, we assume that rpcbind isn't functional */
+		return -EIO;
+	}
 
 	if (!result)
 		return -EACCES;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 4f402bbf97ba..ca6f90653327 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1179,10 +1179,40 @@ int svc_generic_rpcbind_set(struct net *net,
 	error = svc_rpcbind_set_version(net, progp, version,
 					family, proto, port);
 
+	/* -EIO means no answer, not a refusal, so vs_rpcb_optnl must keep it. */
+	if (error == -EIO)
+		return error;
+
 	return (vers->vs_rpcb_optnl) ? 0 : error;
 }
 EXPORT_SYMBOL_GPL(svc_generic_rpcbind_set);
 
+/**
+ * svc_rpcb_failure_count - local rpcbind calls for @serv that got no answer
+ * @serv: RPC service to query
+ *
+ * svc_register() adds one for each of its calls that got no answer. A reply
+ * that refuses one entry does not count, because rpcbind answered and the
+ * next entry may still succeed.
+ *
+ * The count is kept per serv rather than per net. The local rpcbind client
+ * is per-net and lockd shares it, but a count that another service can move
+ * says nothing about this serv's own calls.
+ *
+ * This is for callers that cannot see the svc_register() return, because a
+ * transport class sits in between. Such a caller reads the count before it
+ * starts and compares as it goes, so there is no state to reset between
+ * operations. The count never resets, and callers must not attach meaning
+ * to the value itself.
+ *
+ * Return: the number of unanswered calls since this serv was created.
+ */
+unsigned int svc_rpcb_failure_count(struct svc_serv *serv)
+{
+	return atomic_read(&serv->sv_rpcb_failures);
+}
+EXPORT_SYMBOL_GPL(svc_rpcb_failure_count);
+
 /**
  * svc_register - register an RPC service with the local portmapper
  * @serv: svc_serv struct for the service to register
@@ -1193,10 +1223,11 @@ EXPORT_SYMBOL_GPL(svc_generic_rpcbind_set);
  *
  * Service is registered for any address in the passed-in protocol family
  */
-int svc_register(const struct svc_serv *serv, struct net *net,
+int svc_register(struct svc_serv *serv, struct net *net,
 		 const int family, const unsigned short proto,
 		 const unsigned short port)
 {
+	bool			noanswer = false;
 	unsigned int		p, i;
 	int			error = 0;
 
@@ -1208,10 +1239,16 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 		struct svc_program *progp = &serv->sv_programs[p];
 
 		for (i = 0; i < progp->pg_nvers; i++) {
+			const struct svc_version *vers = progp->pg_vers[i];
 			int ret;
 
 			ret = progp->pg_rpcbind_set(net, progp, i,
 					family, proto, port);
+			if (ret == -EIO) {
+				noanswer = true;
+				if (vers && vers->vs_rpcb_optnl)
+					ret = 0;
+			}
 			if (ret < 0) {
 				printk(KERN_WARNING "svc: failed to register "
 					"%sv%u RPC service (errno %d).\n",
@@ -1223,6 +1260,9 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 		}
 	}
 
+	if (noanswer)
+		atomic_inc(&serv->sv_rpcb_failures);
+
 	return error;
 }
 

-- 
2.55.0

