Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC617438012;
	Thu, 20 Aug 2026 11:37:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787225847; cv=none; b=T6HuaP21FXgdZLF3/VCOUHnH3bTKrIEF2aF1Zmw5GR5F2qyR4/bW4Ze5k4CJlLxpc6LZRB69BkRvtTdVcEOivtSyZ1S4bQWgiSTde6abdPghaJbq67CLPTQfnAYYpUt8loGiYwGMBkJm2f1vut9ACeA5Fr+c+r79QAdPRvamLDo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787225847; c=relaxed/simple;
	bh=oqTEbapJ7m7OJal1cTCQ+CBSUzwlIduS9wikKb3wDiw=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=H6PV8N0kwd4Bweb5sBJz4FtvcC2x6iAmyuCLObU10DRskWLfI1/Oy5Ey4hq3uLIS10Gf1a5YWopd1GeuXo6kA10ZK0lDYMs6miF9mt8JNJRzBCFZEA8a/oM0mFZPvfMpA2Bh3GNVD3JuEdi4JVtiCqYdhhwQ4mbWjsngoEupJ3E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GfgXJkGA; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GfgXJkGA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F19F61F00A3F;
	Thu, 20 Aug 2026 11:37:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787225834;
	bh=blFnMC+DqJzzIMmp8d38EvkiAJPI2DffUzalk7L15Ro=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=GfgXJkGATjfRyfwTXEMZKd41dS9xb5UI9heYlSXnKuZEceP6aEPnrYhD1aXzDHVcU
	 GF4D/ER/Q3o3dcm3ePSJVy8InDBw0TG/mv5vZ6+lK7LPyJ0TKOqik0fuKsZzUxS0pm
	 4hdCaUqWvK/cNsuMgpbu4inZ95BIe/zVIjEa5DvzD7r/4kF/SdsFgpwITMFOpRj9pY
	 +qOJ5EGG/gxrJrEW1B/i4A82pvvEAuSZjT9H7q3MoACauagf6YsGjHY1KtVrCXiXdz
	 qE+/yuelGTzQhe7Sm3N1S8CFsozf3YOMdgjV1wutGq2Q3EdizfcfGriQ8aq985wRRA
	 SWdYyRx6eKC3w==
Message-ID: <699bacb503758fbe2ebf01f3e8aca95e3eee4128.camel@kernel.org>
Subject: Re: [PATCH] nfsd: prevent hung task in nfsd_nl_listener_set_doit()
From: Jeff Layton <jlayton@kernel.org>
To: syzbot <syzbot@kernel.org>, syzkaller-bugs@googlegroups.com, Slawomir
 Stepien <sst@poczta.fm>, Chuck Lever <cel@kernel.org>,
 linux-nfs@vger.kernel.org, Lorenzo Bianconi	 <lorenzo@kernel.org>
Cc: Dai.Ngo@oracle.com, linux-kernel@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzbot@lists.linux.dev, tom@talpey.com
Date: Thu, 20 Aug 2026 07:37:12 -0400
In-Reply-To: <4601ffd5-c662-4ab1-ab2f-50a67a0a990e@mail.kernel.org>
References: <4601ffd5-c662-4ab1-ab2f-50a67a0a990e@mail.kernel.org>
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

On Thu, 2026-08-20 at 06:55 +0000, syzbot wrote:
> From: Slawomir Stepien <sst@poczta.fm>
>=20
> In nfsd_nl_listener_set_doit(), the kernel iterates over all
> NFSD_A_SERVER_SOCK_ADDR attributes provided in a netlink message to
> configure NFS server listeners. There is currently no limit on the number
> of attributes a user can send.
>=20
> For each attribute, svc_xprt_create_from_sa() is called, which may
> synchronously invoke request_module() to load the corresponding transport
> module. If a user provides a large number of invalid transport names,
> request_module() is called sequentially for each, taking a massive amount
> of time. Since this entire process occurs while holding the global
> nfsd_mutex, it blocks other tasks attempting to acquire the mutex and
> triggers a hung task timeout:
>=20

My LLM latched onto the same explanation, but the request module
upcalls are actually quite quick and have some other gates on them that
make this problem hard to hit in practice.

The real problem is rpcbind registration, which can be quite slow. The
fix for that is to make the registration asynchronous, and to not
trigger errors on rpcbind registration failure. That's a bigger
project, but let us know if you're interested!

In any case, I've sent a series that includes a similar fix to this
one, along with some others:

    https://lore.kernel.org/linux-nfs/20260811-nfsd-nl-hang-v2-0-c0c92b3953=
c3@kernel.org/

I'll try to get the follow-on series out later today or tomorrow.


>   INFO: task blocked for more than 10 seconds.
>   ...
>   Call Trace:
>    <TASK>
>    __schedule+0x17e7/0x5630 kernel/sched/core.c:7234
>    schedule+0x164/0x2b0 kernel/sched/core.c:7326
>    schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
>    __mutex_lock_common kernel/locking/mutex.c:726 [inline]
>    __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
>    nfsd_nl_version_get_doit+0x17c/0xd20 fs/nfsd/nfsctl.c:1889
>    genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
>    genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
>    genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
>   ...
>   2 locks held by task/5864:
>    #0: ffffffff90114168 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40
>    net/netlink/genetlink.c:1217
>    #1: ffffffff8eeb1a60 (nfsd_mutex){+.+.}-{4:4}, at:
>    nfsd_nl_listener_set_doit+0x135/0x1750 fs/nfsd/nfsctl.c:1964
>=20
> Furthermore, the function does not break out of the loop if
> svc_xprt_create_from_sa() fails, and it suffers from an O(N^2) complexity
> issue because svc_find_listener() iterates over the serv->sv_permsocks li=
st
> for each attribute.
>=20
> Address this by introducing a hard limit of 128 NFSD_A_SERVER_SOCK_ADDR
> attributes per netlink message. The limit is enforced before acquiring th=
e
> nfsd_mutex to prevent lock contention. Additionally, modify the loop to
> break immediately if listener creation fails, avoiding needless sequentia=
l
> request_module() calls for invalid configurations.
>=20
> Fixes: 16a471177496 ("NFSD: add listener-{set,get} netlink command")
> Assisted-by: Gemini:gemini-3.6-flash Gemini:gemini-3.1-pro-preview syzbot
> Reported-by: syzbot+41bc60511c2884783c27@syzkaller.appspotmail.com
> Closes: https://syzkaller.appspot.com/bug?extid=3D41bc60511c2884783c27
> Link: https://syzkaller.appspot.com/ai_job?id=3D30871f87-7a83-46b8-ab83-9=
19894b0787b
> Signed-off-by: Slawomir Stepien <sst@poczta.fm>
>
> ---
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index fa92e31d1..516c04c14 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -1943,6 +1943,8 @@ int nfsd_nl_version_get_doit(struct sk_buff *skb, s=
truct genl_info *info)
>  	return err;
>  }
> =20
> +#define NFSD_MAX_LISTENERS 128
> +
>  /**
>   * nfsd_nl_listener_set_doit - set the nfs running sockets
>   * @skb: reply buffer
> @@ -1955,12 +1957,19 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb=
, struct genl_info *info)
>  	struct net *net =3D genl_info_net(info);
>  	struct svc_xprt *xprt, *tmp;
>  	const struct nlattr *attr;
> +	unsigned int count =3D 0;
>  	struct svc_serv *serv;
>  	LIST_HEAD(permsocks);
>  	struct nfsd_net *nn;
>  	bool delete =3D false;
>  	int err, rem;
> =20
> +	nlmsg_for_each_attr_type(attr, NFSD_A_SERVER_SOCK_ADDR, info->nlhdr,
> +				 GENL_HDRLEN, rem) {
> +		if (++count > NFSD_MAX_LISTENERS)
> +			return -EINVAL;
> +	}
> +
>  	mutex_lock(&nfsd_mutex);
> =20
>  	err =3D nfsd_create_serv(net);
> @@ -2073,8 +2082,10 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb,=
 struct genl_info *info)
>  		ret =3D svc_xprt_create_from_sa(serv, xcl_name, net, sa, 0,
>  					      current_cred());
>  		/* always save the latest error */
> -		if (ret < 0)
> +		if (ret < 0) {
>  			err =3D ret;
> +			break;
> +		}
>  	}
> =20
>  	if (!serv->sv_nrthreads && list_empty(&nn->nfsd_serv->sv_permsocks))
>=20
>=20
> base-commit: 075b74841bd0065a3bda3440873c747938e69b68

I have a patch series in progress for this already, which also=20
--=20
Jeff Layton <jlayton@kernel.org>
