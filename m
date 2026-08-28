Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 84F6B43B492;
	Fri, 28 Aug 2026 16:37:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787935077; cv=none; b=DA+EUKbn2YLqqy1RELUzy0mwM/++JdII2X8QrtQhKjIO7+5947a9tLvffomCFk1pl581mEXJC3P4QS6LoBwJrYL7T2I8R5Byhz676OII4PueoE0VyrCB/wPLynU7rP5nA/6MfwH3Xr4BlCTH+GnRdSPSdIcUhzkdmKev2ety0ms=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787935077; c=relaxed/simple;
	bh=VtI7n2HnvBxWtHxpVK+v8l92gp2bSc/EpIOPY1kBF3k=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=dZ4tNJaQkIOIICOcZ2cJkD1G3YlFPdGcZ4KvwJl0Zwd4Y8AA1ZXGWmneKTyfix1kn9gdlmA8m1mYAo+SHovx4PaAH+Yj7kPvc+1NnUC5TybZ2SKbmMuyCaIbZp+u6rKyYLO7TO7218Z6zgHhN1TjSjDmpIPO9mBpgUXJrzU1LeQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hprgfaMq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hprgfaMq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AECB61F00A3D;
	Fri, 28 Aug 2026 16:37:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787935075;
	bh=fAEisYK/B9Nm+vH/z1au7xtnCnKTcCwdV0WAKPK4Obg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hprgfaMqiMGnaJighb+wX7cpNBnEH/Lc0OXKLMB4OTA8df0o91ixDcbO4yi8SojgK
	 JgvHAYpTu2N6D/T08SBZiMHuuCDJJqF0VoS3dSI1deF0GV07iJWmakNd8tjMUCuhcV
	 9y0Gd2iAL0Lz2g+YIlFUic1aUNWMIO8x46gHtJ6RxKALjzR5UPnaC6no7FItGLQFdv
	 YrWlhJWrRYkzpasS5zjVqm399P20nHk2hg1Rc4ZIZO0BIT2p/7m3zi9yBCxJtBrGY3
	 VmnwDdiJg6AyAmGYYHWG/VXnPAqQE4r+D7arDh8/aadjOfzUryWoy7OYl0UaAZLnnY
	 6Fjjisxb232yg==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 28 Aug 2026 12:37:36 -0400
Subject: [PATCH v3 06/14] SUNRPC: report local rpcbind calls that get no
 answer
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-nfsd-nl-hang-v3-6-55026685c75d@kernel.org>
References: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
In-Reply-To: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=8220; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=VtI7n2HnvBxWtHxpVK+v8l92gp2bSc/EpIOPY1kBF3k=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqkblVhlWGJWQ9EqXh2MPrGVJKU9Y8VkKCLCODM
 R8QtnuUgv+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapG5VQAKCRAADmhBGVaC
 FWKCD/99a1BDrKpM5+mfJM3ErlDkSc2l+XvBPoTmXuFcwl6Pv0brOf4LBt+QW778kOf0aWV/wz0
 xAsznfHz9Sq1IRvOqw6Tdmd/Un0RrXrA8MpwxfiUoan993+0Kykt55+qR5ZVxFlHcE9RSLTNjMB
 x5/sxAedF2JMxpI2Wlg11ykyBfANir9epuYdl3QH2E8ddIQTPXILrsA/YwHjtethM40WGb7tSoq
 6987YOue4UbfxUkbIrzJVhTrmBB6b+tHt+ZH7RtF6MGsPt05483llTdFZr5yzIFfpQHRLzHXrbo
 fWxa5G6qXjCSV/AWc98tLUEDb0fEfS5a4/+bCMq5lnI5YLSFfyL5kShQSRNmh/qqWH5AJBz6WzS
 xYmY1QcEGYa+dc0junmq4LVplXV74WqXBoVHJousV084jhyfE/aTbxPfRVS6E1Fo4lgAe9hxYX8
 pWJIIOWtsC3rUUXB3N0xNJ/BY3kvB+sBM0eXs5FO2qX/SExQ4dFff/g5pVba84RgBgEx1jJnj4d
 qJCpxC8rvg7hFQn+Zq6PeQVgZb/w6PCCtdFdJJRvd2BJPjsVbaN8c5cRa1A3epnr+KQwR53umj6
 AsQB9i7woBLQJIA9uuOP1QU3aXbJ8So/aGXVRYbl20ETCi0rgXmp+lhDNG8Lzpj1dikk6DMw1OR
 UEnyga6x1a6NfuQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A caller that creates many listeners in one operation calls svc_register()
once for each of them. Every call waits for the local rpcbind on its own,
so a rpcbind that never answers costs the caller one timeout per listener.
The caller has no way to learn that the first call already failed.

An rpcbind failure can occur one of two ways: either rpcbind fails to
respond, or it can respond with -EACCES to indicate that the user
doesn't own the current record.

Give the first case its own errno. rpcb_register_call() returns -ENAVAIL
when the call got no answer, and the existing -EACCES continues to mean a
FALSE reply.

svc_generic_rpcbind_set() has to let -ENAVAIL past vs_rpcb_optnl, since it
is not a refusal. svc_register() applies vs_rpcb_optnl to it instead, so a
v4-only server still creates its listeners, and then keeps a running total
in serv->sv_rpcb_failures. -ENAVAIL never escapes svc_register().

svc_rpcb_failure_count() reports the total. A caller reads the count
before it starts and compares as it goes to determine if there have been
errors.

The users of this infrastructure will be added in later patches.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 include/linux/sunrpc/clnt.h |  3 ++-
 include/linux/sunrpc/svc.h  |  7 +++++--
 net/sunrpc/rpcb_clnt.c      | 10 +++++++---
 net/sunrpc/svc.c            | 42 +++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 55 insertions(+), 7 deletions(-)

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
index 0aa376b82a52..c680137f0fca 100644
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
@@ -422,8 +423,10 @@ static int rpcb_register_call(struct sunrpc_net *sn, struct rpc_clnt *clnt, stru
 	msg->rpc_resp = &result;
 
 	error = rpc_call_sync(clnt, msg, flags);
-	if (error < 0)
+	if (error == -EPROTONOSUPPORT)
 		return error;
+	if (error < 0)
+		return -ENAVAIL;
 
 	if (!result)
 		return -EACCES;
@@ -463,7 +466,8 @@ static int rpcb_register_call(struct sunrpc_net *sn, struct rpc_clnt *clnt, stru
  * IN6ADDR_ANY (ie available for all AF_INET and AF_INET6
  * addresses).
  */
-int rpcb_register(struct net *net, u32 prog, u32 vers, int prot, unsigned short port)
+int rpcb_register(struct net *net, u32 prog, u32 vers, int prot,
+		  unsigned short port)
 {
 	struct rpcbind_args map = {
 		.r_prog		= prog,
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 4f402bbf97ba..54f8e8b0bf28 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1179,10 +1179,40 @@ int svc_generic_rpcbind_set(struct net *net,
 	error = svc_rpcbind_set_version(net, progp, version,
 					family, proto, port);
 
+	/* -ENAVAIL is not a refusal, so vs_rpcb_optnl must not swallow it. */
+	if (error == -ENAVAIL)
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
+			if (ret == -ENAVAIL) {
+				noanswer = true;
+				ret = (vers && vers->vs_rpcb_optnl) ?
+					0 : -ETIMEDOUT;
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

