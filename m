Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E77FE58FD39;
	Thu, 10 Sep 2026 19:47:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789069634; cv=none; b=rjg179qRIVmkC2n6wae1c7j0uZ/8mk+vrSVbyxasId6HQkG5aVSeSThl5/Mz1t3ueOrnG7dJ8RtK6EuPNX2L+M/83CULf373OVfw4RAVELp06yPLdQt3KnOlFzEMtoiZokH5aO5uZtbTonjHft9ZQCVux64YJHAMBSoooO+fG94=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789069634; c=relaxed/simple;
	bh=RX071a9PQBNiEQBheV1K3UmyIzBezfZtMt1I3s6KoNQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Cl7jTkafSKQjn5BGJrv1YluqamgIk3VpoBrnr9IDHiaqWGdVhiJiZtJjCL/ATEURHhIodKQJkqTnNt8cIW1Bg/N4YL33y79DRBkFTjyiYIM79gpN9RNyYL5PF+dl+Em/eavIcdt1QZsXupaGeyyt3id8bcWUVjA3VSgOyUPuaC4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mdhD67lL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mdhD67lL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DE59B1F000FF;
	Thu, 10 Sep 2026 19:47:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789069632;
	bh=ZffiQYbGLW+VYKyj9G1IXT3ZIe+gXXWyt3eyqmXRCyU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=mdhD67lL5P9YOgg7HpKq7NpzrhFf/GCIbmiP+NTpjV8tpFlau2/lwecpkzHaFxN0U
	 tDMXsD1CYFoQ984ZfHJKyNlmfKACwYZGuUEeNbmynEcx6UwBeiv1tzA9eAzGNCBNHJ
	 PkcBZmODfEcA1z70YMCpVdM6OU9ZeExU3l+/4zKNyxVTr1noGrmvlOSkDpmw3AP7N7
	 RG3Fw/U657sLA1k1y2Kq6ieGbMjBzy0OHXhrZwJbid8WnB450kL7P8YNWlYuxJ8MVt
	 N6CoICjthgca24MsutXZ1+rbuCHbG7yWo15wLppk3JY+yf7P760SE0tqu/LDbjQAoD
	 5gqFBE2m9Yl4g==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 21509F4006C;
	Thu, 10 Sep 2026 15:47:11 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 10 Sep 2026 15:47:11 -0400
X-ME-Sender: <xms:PwmjaiY31azRpJ6WADEzOrGS_RzT1Q3vFRbos7NSwGYTI6i-VKOlrw>
    <xme:PwmjagNz68zilixW2T8i9z2DfPvfhNaD125l1Esn4lYtlW9_Oy93qhBRlc00WGf13
    AZCnNDiafNM8gzACms2X54H8DkW5UbzhHIxGq7J4uzO-Wub0K_fMmfC>
X-ME-Proxy-Cause: dmFkZTEk5kidKWEsHw6tcAwcrd1DRhsdAEyJmVHoXJViIP9MoT6XSLAEa3dgVU3vDQ8PCt
    3uJlxew+vCHxhjCEkGB9K4q4YvNCll78mINsejPAPv2f7A8rx/by5L/wMOPhr7GgdojMGl
    mnXqZ7t8u3NY1AQw1jfsoZ59E/bWTRtZObQpdgTWwdMBGhUhoqsL8YIgTQx00JG6UNMEuO
    8Ilamerm2V5Ga6H1/BtEHiTodTCvmooX/eYaJ9uiRYrohmMRz+u0jwptMcXqk692iU72AF
    2IAfu11hEWQXgQaACAaJ1zgeFVG6i3giL9wLCXq+tMouNh1Q0Ts4gaNy3CJ5PY4BJWSjEN
    wV1yA8EUAkJq24vw5ZK1PqUABbUE45Jyg4HUKo4vURKNuFukUSqpXRlfUj/T6lIRK4Z3rP
    LROp/epZKJ1HtPGSy8tVmNtvDfzmWjAyZfsmiJWPWqndxj/D24BXFdDsiWIfBGo60lfSHk
    Wxz7T+YuOToXqN4B9eBLXaI4Df54I0migMCTEAPJAzAWkfjjJoRm1qtndXNG2pvdsu12KN
    vf33lKc0tvW8es7Hzby4tIPPMk3sQClj48jktF9IpaChQ5kT3RM5KwsnB0aYf2FqHx5wZj
    32YCr0zgdIUFiYai7TniZpsmXsN6jhPVbB4GzBQIoEdaWiY6EWSfApy+nvzQ
X-ME-Proxy: <xmx:PwmjauuCiMSXhZhNP8ifBcYQ7zc9_iKBcn34uyIwncDCHRdoBroGIA>
    <xmx:Pwmjak13fTAkrEM6MXrIaINyRc1fbgxhdHLhYghLe_luwH9hDKef3A>
    <xmx:PwmjajC5TbuogHWJqY8F8YR5xYmL1VXnwv-9m65-Ine3Xs4UDFjX8g>
    <xmx:Pwmjahewr_C6xThl1vZw9YGaAVeQWw798YZwO7LUKUqN3tPe2fBctw>
    <xmx:Pwmjalyt3K9f9BCJTopE8HUD0znOpmJP2LgZcpJwVO32A2zygfmaPOmd>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 027437811F0; Thu, 10 Sep 2026 15:47:11 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ADEgH0paMfes
Date: Thu, 10 Sep 2026 15:46:48 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "Donald Hunter" <donald.hunter@gmail.com>, "Shuah Khan" <shuah@kernel.org>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, linux-kselftest@vger.kernel.org
Message-Id: <a9efbd67-4a73-49f5-b65e-ea37074e419d@slotpi15m67>
In-Reply-To: <20260910-nfsd-norpcb-v1-4-b4d5182d634c@kernel.org>
References: <20260910-nfsd-norpcb-v1-0-b4d5182d634c@kernel.org>
 <20260910-nfsd-norpcb-v1-4-b4d5182d634c@kernel.org>
Subject: Re: [PATCH 4/5] NFSD: report registerable programs in the listener_set reply
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 10 Sep 2026, Jeff Layton wrote:

> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -2273,12 +2396,28 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
> +	/*
> +	 * Build the reply before the serv can go away, and only on success.
> +	 * A caller that got an errno has nothing to register.
> +	 */
> +	if (!err && userspace_rpcbind) {
> +		rskb = nfsd_nl_listener_set_msg(info, net, serv);
> +		if (IS_ERR(rskb)) {
> +			err = PTR_ERR(rskb);
> +			rskb = NULL;
> +		}
> +	}

The second sentence of the comment is not true after a partial
failure. Take a request with userspace-rpcbind carrying {tcp:2049,
tcp:<port already in use>}. The creation loop continues past the
second failure and keeps only the last errno. The 2049 xprt is on
sv_permsocks, so the serv survives the list_empty() check below, but
this gate skips the reply and the caller sees -EADDRINUSE. nfsd is
now serving on 2049 with nothing registered in rpcbind, and the caller
was never told which listeners came up or which programs to register.
The same end state results when nfsd_nl_listener_set_msg() itself
fails with -ENOMEM.

In kernel-owned mode the survivor would already have been registered
inside svc_xprt_create_from_sa(), so this is a behavioral gap specific
to the new mode. Either tear down the listeners that were created when
any of them fails, or send the reply whenever at least one listener
exists on the serv, regardless of err. The second keeps the existing
partial-success semantics; the caller can then act on what it got.


> +static size_t nfsd_nl_listener_set_msgsize(struct svc_serv *serv)
> +{
> +	size_t size = GENL_HDRLEN +		    /* genlmsg_iput() */
> +		      nla_total_size(0);	    /* userspace-rpcbind */

genlmsg_new() already adds GENL_HDRLEN via genlmsg_total_size(), so
this term double-counts it. Harmless, but the comment will mislead the
next person sizing a reply. Pass only the attribute payload here.


> +	spin_lock_bh(&serv->sv_lock);
> +	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list) {
> +		struct nlattr *attr;
> +
> +		if (!test_bit(XPT_RPCB_UNREG, &xprt->xpt_flags))
> +			continue;
> +
> +		attr = nla_nest_start(skb, NFSD_A_SERVER_SOCK_ADDR);
> +		if (!attr) {
> +			err = -EMSGSIZE;
> +			goto err_serv_unlock;
> +		}
> +
> +		if (nla_put_string(skb, NFSD_A_SOCK_TRANSPORT_NAME,
> +				   xprt->xpt_class->xcl_name) ||
> +		    nla_put(skb, NFSD_A_SOCK_ADDR,
> +			    sizeof(struct sockaddr_storage),
> +			    &xprt->xpt_local)) {
> +			err = -EMSGSIZE;
> +			goto err_serv_unlock;
> +		}
> +
> +		nla_nest_end(skb, attr);
> +	}

This is the same nest emission as the loop in
nfsd_nl_listener_get_doit(), apart from the XPT_RPCB_UNREG filter and
the errno (that one returns -EINVAL). A small helper that emits one
addr nest for an xprt, called from both loops, would keep the two from
drifting, with the size accounting above as the third place to keep
in step.

Also, as noted on patch 2, this filter selects TCP and UDP only; the
spec doc should match.


> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -859,12 +842,44 @@ nfsd_acl_init_request(struct svc_rqst *rqstp,
> +bool nfsd_version_registerable(struct net *net,
> +			       const struct svc_program *progp, u32 version)
> +{
> +	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> +
> +	if (version >= progp->pg_nvers || !progp->pg_vers[version])
> +		return false;
> +
> +	/* nfslocalio is hidden and never reaches rpcbind. */
> +	if (progp->pg_vers[version]->vs_hidden)
> +		return false;
> +
> +#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
> +	if (progp->pg_prog == NFS_ACL_PROGRAM &&
> +	    !nfsd_support_acl_version(version))
> +		return false;
> +#endif

The ACL block is redundant with the first test. The ACL program has
pg_nvers = NFSD_ACL_NRVERS and pg_vers = nfsd_acl_version, whose
slots 0 and 1 and any compiled-out version are NULL, and
nfsd_support_acl_version() checks exactly that range and that array.
Dropping the block removes the function's only program-number special
case and the #if with it.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
