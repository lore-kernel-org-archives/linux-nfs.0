Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9883A3BD62F
	for <linux-nfs@vger.kernel.org>; Sun, 30 Aug 2026 15:51:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788105107; cv=none; b=FDs1mZSzu8sfDVVj7fXp/gM34Ac3hlSITtgAaFT28GTQwK44pbX/QgHVDPUZbejEFco2XahwNFsBUcWX2ArFxPD8vw88Hy3pdyDeXIqvVpnJzYEDMaUKOgMLp08uzDiRvKaPX81+U0dq4Iy1uCXX+Eu4NpS8OM9MxQiHKVQcU0w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788105107; c=relaxed/simple;
	bh=zPoTZBWeuzp9tw4sNm+IqZoe78/45i/N3KFUSENPoDQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=mu7ZMIFHhIPbhcXrIzpmgEj2IxNy8yeDaVNcoE+5TcD/mj1rv6kGnJ7Dn8+qADEDlh46I4UtSnM5XeqtZgr4ZI45jiMlrJ03h1cAQXeRaAubIB5L0upTyYAXDkTI++EBWzUSwclBIL5f5CAwmBBIPvQ2RyuFusgQSsds2LngahY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CHSIEqUv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CHSIEqUv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C2E551F000E9;
	Sun, 30 Aug 2026 15:51:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788105106;
	bh=wOskgzyMfc4qb7zwpN+sQ1ngkR2Lb1XD9ZhpGv5+asU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=CHSIEqUv9MUiwrMZPg/rt4SU0IAaWMLBuuTHqhPdUB3KUIB2QonHxWw0hQE1qEL9f
	 fvVA0AweJ+ZnU139Lzt5WTmGYMNGZglLCNllif2E23azKNLBfI0l7qnHN31w5ISLcH
	 c0H7hc4BqcwimgWADkloX0dDQmH0F/pf/N660v2LdB2nJdy2omvcZ0We3o9X37mXU3
	 cig7EY/EK1HJDVca33+uf2WWOoryDBXZ5+ZTqSvVeaBdY1L9WOex+nwylGr+HK/FL1
	 Ks9bDNagwhlBaoamMI1LUSfCHWyZgSHD42d/41WaGE2ufYh5w/0et7e2elAp2rTuAm
	 c1ZYjP4DkJjyw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id D9222F40066;
	Sun, 30 Aug 2026 11:51:44 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 30 Aug 2026 11:51:44 -0400
X-ME-Sender: <xms:kFGUasoIgoJ5ocO5Or1eq2gxR5EMkk3uBXRPsMAqrpP1G86kKFGycQ>
    <xme:kFGUatcNCofI4r9WBIa8MSeakoGV7nzb38mOBZn8elAFjqysD-jB35osFlxhoAHjn
    _Vl1-RbZ1E_SBvl8FTo71l3LiePxyrUySqUfr4b0o1P9Xz3canyJAcd>
X-ME-Proxy-Cause: dmFkZTF/bf4onkPHQP5Yh1jVTLAwRgvlhGMjkwJYjnr9qN/iUhzsekyFQzTMv0YaN8kk6N
    9TV9DtUUD3x4+fuyggTeVOuuhUxHEfyZelYhaAGVCpQ/FCCEpn4lQ/VCSJq225GmomHm7x
    IaNJn64Somc4aZqCTH96FqdV6gp7GDVY3kOqpOt+lWgparR8ldx//d4ROdAJJJK/9lfHzT
    AHGpCL8eIZIkTgveRRjWE3zhj3xAsAxzM0VgERPLseQkZO5m/5v99safYk5P7G+GT1+f18
    MhjWc47gNBd3Fba8J7QAR8a3/D5AKYQC2R8Sc6AiYdBw/Z1hsNjNCHBn2GZS1C9XE9JajT
    hc3+5D53yQ4TCs3LnX/HBvQZWV5FhcC8VAGul/cWjTT+BT33XMrkJdfnr+U8Dq3ueVCCZg
    2BfLZ6Ycjp9Ks10wzYRnZ/CFNXj8zXxBuSEIoELRaVjdM/1yFZfelyS8nXNmPS8XXnlXTL
    r/8/X0/of2s7v8QU/C0HAeV+NpI74X2tCtrt9QATIRWFmCko8Zhb1+ViW6o//7xb3pHZl1
    iKrWRRKiAF3idgr2MTPDwq30OOwYWydB73Ii+GJamh7RT1N7OoPCMgBy372P1mZOyIyv/q
    PlMm7KIog1WPZJpn/WSif0ajjw4WKVym6h0GLPMkM+Hy1c00hqFalroCwdGA
X-ME-Proxy: <xmx:kFGUaqpPr5xkJyalO1Wzkv8LjutEjHki99dHhZJJcQtqxG9fGjVevw>
    <xmx:kFGUan7fpTmiHS7ztmUCI_27Ok4WUEYRNLoCljd0gxQhZ9gtxW8ljg>
    <xmx:kFGUaiBR8vjFDCL5bilTTkiWXycJXT_au2s2ecn5dv3dnxfd18MFuQ>
    <xmx:kFGUahYiYbqooYUTqu9P8YyEGA3Iwlp1dqeP1eWpS8G7lWf_y5FXzg>
    <xmx:kFGUauKPj1MFqSQU1isXd2QLlRRUDDSsw0TVKm9vLokSHEKMCibuwLC_>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id AC0237811F0; Sun, 30 Aug 2026 11:51:44 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AdUlRa5mv3Ro
Date: Sun, 30 Aug 2026 11:51:27 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "Shuah Khan" <shuah@kernel.org>
Cc: "Slawomir Stepien" <sst@poczta.fm>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 "Trond Myklebust" <trondmy@gmail.com>, linux-kselftest@vger.kernel.org
Message-Id: <c42d685f-18e7-4f38-8ce2-3d8e5402e9f1@app.fastmail.com>
In-Reply-To: <20260828-nfsd-nl-hang-v3-6-55026685c75d@kernel.org>
References: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
 <20260828-nfsd-nl-hang-v3-6-55026685c75d@kernel.org>
Subject: Re: [PATCH v3 06/14] SUNRPC: report local rpcbind calls that get no answer
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Aug 28, 2026, at 12:37 PM, Jeff Layton wrote:
> A caller that creates many listeners in one operation calls svc_register()
> once for each of them. Every call waits for the local rpcbind on its own,
> so a rpcbind that never answers costs the caller one timeout per listener.
> The caller has no way to learn that the first call already failed.
>
> An rpcbind failure can occur one of two ways: either rpcbind fails to
> respond, or it can respond with -EACCES to indicate that the user
> doesn't own the current record.
>
> Give the first case its own errno. rpcb_register_call() returns -ENAVAIL
> when the call got no answer, and the existing -EACCES continues to mean a
> FALSE reply.
>
> svc_generic_rpcbind_set() has to let -ENAVAIL past vs_rpcb_optnl, since it
> is not a refusal. svc_register() applies vs_rpcb_optnl to it instead, so a
> v4-only server still creates its listeners, and then keeps a running total
> in serv->sv_rpcb_failures. -ENAVAIL never escapes svc_register().
>
> svc_rpcb_failure_count() reports the total. A caller reads the count
> before it starts and compares as it goes to determine if there have been
> errors.
>
> The users of this infrastructure will be added in later patches.
>
> Assisted-by: LLM
> Signed-off-by: Jeff Layton <jlayton@kernel.org>

> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index 0aa376b82a52..c680137f0fca 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -412,7 +412,8 @@ static struct rpc_clnt *rpcb_create(struct net 
> *net, const char *nodename,
>  	return rpc_create(&args);
>  }
> 
> -static int rpcb_register_call(struct sunrpc_net *sn, struct rpc_clnt 
> *clnt, struct rpc_message *msg, bool is_set)
> +static int rpcb_register_call(struct sunrpc_net *sn, struct rpc_clnt 
> *clnt,
> +			      struct rpc_message *msg, bool is_set)
>  {
>  	int flags = RPC_TASK_NOCONNECT;
>  	int error, result = 0;
> @@ -422,8 +423,10 @@ static int rpcb_register_call(struct sunrpc_net 
> *sn, struct rpc_clnt *clnt, stru
>  	msg->rpc_resp = &result;
> 
>  	error = rpc_call_sync(clnt, msg, flags);
> -	if (error < 0)
> +	if (error == -EPROTONOSUPPORT)
>  		return error;
> +	if (error < 0)
> +		return -ENAVAIL;
> 
>  	if (!result)
>  		return -EACCES;

If I'm reading this correctly, rpcb_register_call() classifies
every failure except -EPROTONOSUPPORT as "no answer".

rpc_call_sync() returns negative errnos that are not "no answer":
pre-dispatch local failures (-ENOMEM from rpc_new_task()), a fatal
signal (-ERESTARTSYS), and reply-derived errors from
rpc_verify_header(): -EPFNOSUPPORT, -EOPNOTSUPP, -EIO, -EACCES
(auth error), -EKEYREJECTED. All of these show that rpcbind *did*
answer.

Now they become -ENAVAIL, get counted in sv_rpcb_failures, are
silently converted to success for a vs_rpcb_optnl version, and
reach userspace as a synthesized -ETIMEDOUT for mandatory versions.

Consequences:

* The commit message says "-EACCES continues to mean a FALSE
  reply," but the RPC layer's auth -EACCES is rewritten to
  -ENAVAIL before the two can be told apart. Its "one of two
  ways" failure taxonomy is not what the code implements.

* "rpcbind not running" (-ECONNREFUSED/-ENOENT) and every
  other transport error reach nfsd's listener_set ack, the
  svc_register/svc_unregister tracepoints, and the printk
  as indistinguishable ETIMEDOUT/ENAVAIL, which IMO is an
  observability regression.

* -ERESTARTSYS -> -ETIMEDOUT drops syscall-restart semantics
  on a fatal signal during registration.

I'm probably missing something.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
