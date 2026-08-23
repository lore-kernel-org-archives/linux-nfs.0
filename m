Received: from smtpo75.interia.pl (smtpo75.interia.pl [217.74.67.75])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0472F2BDC1C
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 20:30:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.74.67.75
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787517036; cv=none; b=j+/6FggtxzHd0gc1VipcG/YL3aGXpytR6WbkaO2uZSQoY+vFUz31TI8665vQMkRorkQ/R6YHgeXk5RM4aQkfcgIHhPXyKXDHYle1WGxHBvnSANR9CQ6MxvxrsfDKZ3Vix3eb7Di0X8mM/PReMjo2qh+Y9OcsZX8JhT8BFO6quOQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787517036; c=relaxed/simple;
	bh=fgX5dIrrngNi8qvboXy2ANyqyboqF/OD5hrSyrnQGxY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=pTcaW6jm7izsGX7SzBHIDlT7OLqdNs2NsslobjknKWvUy/SllUhvNI+VX5/q1w77N0cQEmi9gemkCwLAJgCgLadblRbtespAdgjiTJRHm0OYhSqCgEnwVKJo/BqDFjk7FrFh2wwnGt+Bvuubt0j/1QDgx2Is8MFMXCPC3xI36iw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=poczta.fm; spf=pass smtp.mailfrom=poczta.fm; dkim=pass (1024-bit key) header.d=poczta.fm header.i=@poczta.fm header.b=CksGZQsQ; arc=none smtp.client-ip=217.74.67.75
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=poczta.fm
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=poczta.fm
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=poczta.fm header.i=@poczta.fm header.b="CksGZQsQ"
Received: from nr200 (unknown [80.68.231.31])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (P-256) server-digest SHA256)
	(No client certificate requested)
	by poczta.interia.pl (INTERIA.PL) with ESMTPSA;
	Sun, 23 Aug 2026 22:27:59 +0200 (CEST)
Date: Sun, 23 Aug 2026 22:27:56 +0200
From: Slawomir Stepien <sst@poczta.fm>
To: Jeff Layton <jlayton@kernel.org>
Cc: syzbot <syzbot@kernel.org>, syzkaller-bugs@googlegroups.com,
	Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org,
	Lorenzo Bianconi <lorenzo@kernel.org>, Dai.Ngo@oracle.com,
	linux-kernel@vger.kernel.org, neil@brown.name, okorniev@redhat.com,
	syzbot@lists.linux.dev, tom@talpey.com
Subject: Re: [PATCH] nfsd: prevent hung task in nfsd_nl_listener_set_doit()
Message-ID: <aotXzLmrd-B89YRg@nr200>
References: <4601ffd5-c662-4ab1-ab2f-50a67a0a990e@mail.kernel.org>
 <699bacb503758fbe2ebf01f3e8aca95e3eee4128.camel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <699bacb503758fbe2ebf01f3e8aca95e3eee4128.camel@kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=poczta.fm; s=dk;
	t=1787516881; bh=gccscRbE6Dq1I/86KA/cEq4TDd0tJ39N7H/4fIa80Fw=;
	h=Date:From:To:Subject:Message-ID:MIME-Version:Content-Type;
	b=CksGZQsQL6M8YDKHfSdrzVAuvBO86rmTt49KitrJ9yLOfCVl2EgtiOQo1cOO5R2Ms
	 7dpqULGBy4KkENJbnE9y+Q5rdUC0Uk/G6HCI53BqqRZv0V0zR3kHuy7FxgNU+SkET5
	 ogPlVBkJKP4c3Q8q22P/O7yeF3ydIKOW2r4p833o=

On sie 20, 2026 07:37, Jeff Layton wrote:
> On Thu, 2026-08-20 at 06:55 +0000, syzbot wrote:
> > From: Slawomir Stepien <sst@poczta.fm>
> > 
> > In nfsd_nl_listener_set_doit(), the kernel iterates over all
> > NFSD_A_SERVER_SOCK_ADDR attributes provided in a netlink message to
> > configure NFS server listeners. There is currently no limit on the number
> > of attributes a user can send.
> > 
> > For each attribute, svc_xprt_create_from_sa() is called, which may
> > synchronously invoke request_module() to load the corresponding transport
> > module. If a user provides a large number of invalid transport names,
> > request_module() is called sequentially for each, taking a massive amount
> > of time. Since this entire process occurs while holding the global
> > nfsd_mutex, it blocks other tasks attempting to acquire the mutex and
> > triggers a hung task timeout:
> > 
> 
> My LLM latched onto the same explanation, but the request module
> upcalls are actually quite quick and have some other gates on them that
> make this problem hard to hit in practice.

Oh, OK. Thanks for clearing that up!

> The real problem is rpcbind registration, which can be quite slow. The
> fix for that is to make the registration asynchronous, and to not
> trigger errors on rpcbind registration failure. That's a bigger
> project, but let us know if you're interested!

I think I'm not that good to do it correctly and in some reasonable time. I might take a 2nd look at
this and understand the root cause (also, based on your comments in your series) but I think in the
end it might be too hard for me.

> In any case, I've sent a series that includes a similar fix to this
> one, along with some others:
> 
>     https://lore.kernel.org/linux-nfs/20260811-nfsd-nl-hang-v2-0-c0c92b3953c3@kernel.org/
> 
> I'll try to get the follow-on series out later today or tomorrow.

Nice series, I've learnt something from it! I will be looking for v3!

> >   INFO: task blocked for more than 10 seconds.
> >   ...
> >   Call Trace:
> >    <TASK>
> >    __schedule+0x17e7/0x5630 kernel/sched/core.c:7234
> >    schedule+0x164/0x2b0 kernel/sched/core.c:7326
> >    schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
> >    __mutex_lock_common kernel/locking/mutex.c:726 [inline]
> >    __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
> >    nfsd_nl_version_get_doit+0x17c/0xd20 fs/nfsd/nfsctl.c:1889
> >    genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
> >    genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
> >    genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
> >   ...
> >   2 locks held by task/5864:
> >    #0: ffffffff90114168 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40
> >    net/netlink/genetlink.c:1217
> >    #1: ffffffff8eeb1a60 (nfsd_mutex){+.+.}-{4:4}, at:
> >    nfsd_nl_listener_set_doit+0x135/0x1750 fs/nfsd/nfsctl.c:1964
> > 
> > Furthermore, the function does not break out of the loop if
> > svc_xprt_create_from_sa() fails, and it suffers from an O(N^2) complexity
> > issue because svc_find_listener() iterates over the serv->sv_permsocks list
> > for each attribute.
> > 
> > Address this by introducing a hard limit of 128 NFSD_A_SERVER_SOCK_ADDR
> > attributes per netlink message. The limit is enforced before acquiring the
> > nfsd_mutex to prevent lock contention. Additionally, modify the loop to
> > break immediately if listener creation fails, avoiding needless sequential
> > request_module() calls for invalid configurations.
> > 
> > Fixes: 16a471177496 ("NFSD: add listener-{set,get} netlink command")
> > Assisted-by: Gemini:gemini-3.6-flash Gemini:gemini-3.1-pro-preview syzbot
> > Reported-by: syzbot+41bc60511c2884783c27@syzkaller.appspotmail.com
> > Closes: https://syzkaller.appspot.com/bug?extid=41bc60511c2884783c27
> > Link: https://syzkaller.appspot.com/ai_job?id=30871f87-7a83-46b8-ab83-919894b0787b
> > Signed-off-by: Slawomir Stepien <sst@poczta.fm>
> >
> > ---
> > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > index fa92e31d1..516c04c14 100644
> > --- a/fs/nfsd/nfsctl.c
> > +++ b/fs/nfsd/nfsctl.c
> > @@ -1943,6 +1943,8 @@ int nfsd_nl_version_get_doit(struct sk_buff *skb, struct genl_info *info)
> >  	return err;
> >  }
> >  
> > +#define NFSD_MAX_LISTENERS 128
> > +
> >  /**
> >   * nfsd_nl_listener_set_doit - set the nfs running sockets
> >   * @skb: reply buffer
> > @@ -1955,12 +1957,19 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
> >  	struct net *net = genl_info_net(info);
> >  	struct svc_xprt *xprt, *tmp;
> >  	const struct nlattr *attr;
> > +	unsigned int count = 0;
> >  	struct svc_serv *serv;
> >  	LIST_HEAD(permsocks);
> >  	struct nfsd_net *nn;
> >  	bool delete = false;
> >  	int err, rem;
> >  
> > +	nlmsg_for_each_attr_type(attr, NFSD_A_SERVER_SOCK_ADDR, info->nlhdr,
> > +				 GENL_HDRLEN, rem) {
> > +		if (++count > NFSD_MAX_LISTENERS)
> > +			return -EINVAL;
> > +	}
> > +
> >  	mutex_lock(&nfsd_mutex);
> >  
> >  	err = nfsd_create_serv(net);
> > @@ -2073,8 +2082,10 @@ int nfsd_nl_listener_set_doit(struct sk_buff *skb, struct genl_info *info)
> >  		ret = svc_xprt_create_from_sa(serv, xcl_name, net, sa, 0,
> >  					      current_cred());
> >  		/* always save the latest error */
> > -		if (ret < 0)
> > +		if (ret < 0) {
> >  			err = ret;
> > +			break;
> > +		}
> >  	}
> >  
> >  	if (!serv->sv_nrthreads && list_empty(&nn->nfsd_serv->sv_permsocks))
> > 
> > 
> > base-commit: 075b74841bd0065a3bda3440873c747938e69b68
> 
> I have a patch series in progress for this already, which also 

-- 
Slawomir Stepien
