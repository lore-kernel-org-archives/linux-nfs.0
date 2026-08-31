Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C9523DB636;
	Mon, 31 Aug 2026 12:05:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788177941; cv=none; b=Vj1e5flqlKl1e67+xL6Mg+egD+SZMeAkU6qpqvZ8eD5TjupNOaPsc3ivQlN51QT/F1c1mUPkn5VUacZsR8scZX+Uf0TVqerRnZ8PVpVSff5oUzMvPFI2A1a9DmGbfuUXch3r3xJRQyPMKKcVyXDqqDcJN1C6becmgdxdd2+5BsQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788177941; c=relaxed/simple;
	bh=tCK3/OlqomI9xjvtVhXAwUvs6ZD7l47RHKp+gAvqlPM=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=sBvL4QGNKU8vqnMrKpj15APNyvfVRQ3K9WP5lT2RYC0F7OvepM/O2CfGDdyj7Yjq7VbnBcBeA23lhlJkeFNHoCqb6qAUQaTWhP3/NEKdRRfYVioyI+r3Vcu7HzuIffGYT1jwwfdZT1oyhJJucxFxF/TBxjQblV4l2qY0iv95aag=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=koRVCYvn; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="koRVCYvn"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 772641F000E9;
	Mon, 31 Aug 2026 12:05:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788177940;
	bh=eK4N+prxyq1UeFOdBDRTLJdmEzGIzVB4VhCDo8m8iy8=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=koRVCYvn52Sznk8s1vxJFxbuSYCxeDzWzA6P58fRF8JBFqoGzs/DEZyNIFSrW9Hwp
	 E9YbxhJlVUhIlPm1PLXuXcd3tZT6yRNSLpaSVZvWouDKXe9dRbiwly0a+hHUbP8pWL
	 n1FuAmJOtHQ/9TiO3xGMk7GqFHXT8Lwq3oMwbwhMe7zH0lN8XCGx4OXqf5DFDrQqNP
	 KgKAp+wuicDiYbbceFQhkXq06oPWFM1kQNbPTUl52UzrDFTZToTb8hDSCCEFyumSm8
	 yc5Mbg2Tb9d24xc4djOCwPP0cm/Zy4oKJG/xgrTcUuNSHB8QMWaDA8OWpDm7Y2ySNk
	 oD7dPTbu/VRxg==
Message-ID: <f298080d9c8690d0313a3ef16f2fff2f9576aae4.camel@kernel.org>
Subject: Re: [PATCH v3 06/14] SUNRPC: report local rpcbind calls that get no
 answer
From: Jeff Layton <jlayton@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, Anna
 Schumaker <anna@kernel.org>, "David S. Miller"	 <davem@davemloft.net>, Eric
 Dumazet <edumazet@google.com>, Jakub Kicinski	 <kuba@kernel.org>, Paolo
 Abeni <pabeni@redhat.com>, Simon Horman	 <horms@kernel.org>, Shuah Khan
 <shuah@kernel.org>
Cc: Slawomir Stepien <sst@poczta.fm>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Trond Myklebust
	 <trondmy@gmail.com>, linux-kselftest@vger.kernel.org
Date: Mon, 31 Aug 2026 08:05:37 -0400
In-Reply-To: <c42d685f-18e7-4f38-8ce2-3d8e5402e9f1@app.fastmail.com>
References: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
	 <20260828-nfsd-nl-hang-v3-6-55026685c75d@kernel.org>
	 <c42d685f-18e7-4f38-8ce2-3d8e5402e9f1@app.fastmail.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Sun, 2026-08-30 at 11:51 -0400, Chuck Lever wrote:
>=20
> On Fri, Aug 28, 2026, at 12:37 PM, Jeff Layton wrote:
> > A caller that creates many listeners in one operation calls svc_registe=
r()
> > once for each of them. Every call waits for the local rpcbind on its ow=
n,
> > so a rpcbind that never answers costs the caller one timeout per listen=
er.
> > The caller has no way to learn that the first call already failed.
> >=20
> > An rpcbind failure can occur one of two ways: either rpcbind fails to
> > respond, or it can respond with -EACCES to indicate that the user
> > doesn't own the current record.
> >=20
> > Give the first case its own errno. rpcb_register_call() returns -ENAVAI=
L
> > when the call got no answer, and the existing -EACCES continues to mean=
 a
> > FALSE reply.
> >=20
> > svc_generic_rpcbind_set() has to let -ENAVAIL past vs_rpcb_optnl, since=
 it
> > is not a refusal. svc_register() applies vs_rpcb_optnl to it instead, s=
o a
> > v4-only server still creates its listeners, and then keeps a running to=
tal
> > in serv->sv_rpcb_failures. -ENAVAIL never escapes svc_register().
> >=20
> > svc_rpcb_failure_count() reports the total. A caller reads the count
> > before it starts and compares as it goes to determine if there have bee=
n
> > errors.
> >=20
> > The users of this infrastructure will be added in later patches.
> >=20
> > Assisted-by: LLM
> > Signed-off-by: Jeff Layton <jlayton@kernel.org>
>=20
> > diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> > index 0aa376b82a52..c680137f0fca 100644
> > --- a/net/sunrpc/rpcb_clnt.c
> > +++ b/net/sunrpc/rpcb_clnt.c
> > @@ -412,7 +412,8 @@ static struct rpc_clnt *rpcb_create(struct net=20
> > *net, const char *nodename,
> >  	return rpc_create(&args);
> >  }
> >=20
> > -static int rpcb_register_call(struct sunrpc_net *sn, struct rpc_clnt=
=20
> > *clnt, struct rpc_message *msg, bool is_set)
> > +static int rpcb_register_call(struct sunrpc_net *sn, struct rpc_clnt=
=20
> > *clnt,
> > +			      struct rpc_message *msg, bool is_set)
> >  {
> >  	int flags =3D RPC_TASK_NOCONNECT;
> >  	int error, result =3D 0;
> > @@ -422,8 +423,10 @@ static int rpcb_register_call(struct sunrpc_net=
=20
> > *sn, struct rpc_clnt *clnt, stru
> >  	msg->rpc_resp =3D &result;
> >=20
> >  	error =3D rpc_call_sync(clnt, msg, flags);
> > -	if (error < 0)
> > +	if (error =3D=3D -EPROTONOSUPPORT)
> >  		return error;
> > +	if (error < 0)
> > +		return -ENAVAIL;
> >=20
> >  	if (!result)
> >  		return -EACCES;
>=20
> If I'm reading this correctly, rpcb_register_call() classifies
> every failure except -EPROTONOSUPPORT as "no answer".
>=20
> rpc_call_sync() returns negative errnos that are not "no answer":
> pre-dispatch local failures (-ENOMEM from rpc_new_task()), a fatal
> signal (-ERESTARTSYS), and reply-derived errors from
> rpc_verify_header(): -EPFNOSUPPORT, -EOPNOTSUPP, -EIO, -EACCES
> (auth error), -EKEYREJECTED. All of these show that rpcbind *did*
> answer.
>=20
> Now they become -ENAVAIL, get counted in sv_rpcb_failures, are
> silently converted to success for a vs_rpcb_optnl version, and
> reach userspace as a synthesized -ETIMEDOUT for mandatory versions.
>=20
> Consequences:
>=20
> * The commit message says "-EACCES continues to mean a FALSE
>   reply," but the RPC layer's auth -EACCES is rewritten to
>   -ENAVAIL before the two can be told apart. Its "one of two
>   ways" failure taxonomy is not what the code implements.
>=20
> * "rpcbind not running" (-ECONNREFUSED/-ENOENT) and every
>   other transport error reach nfsd's listener_set ack, the
>   svc_register/svc_unregister tracepoints, and the printk
>   as indistinguishable ETIMEDOUT/ENAVAIL, which IMO is an
>   observability regression.
>=20
> * -ERESTARTSYS -> -ETIMEDOUT drops syscall-restart semantics
>   on a fatal signal during registration.
>=20
> I'm probably missing something.
>=20

Fair point. I've mostly been trying to classify errors as to whether
there is any point is attempting further registrations. For most of the
errors besides -EACCES (aka rpc_auth_error), there is no point.

That said, I've gone in an cleaned up the error handling here, so v4
should be a bit more explicit about how errors are handled.
--=20
Jeff Layton <jlayton@kernel.org>
