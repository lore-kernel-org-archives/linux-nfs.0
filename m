Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794237025;
	b=OksI/aijK29XeKGECzc96CH85Cnma+BiQXLyqRd9yIrkP5f3+Irj4QPk000S1AMwgjcX
	 zlt4ijCb6vJh8oubveyVCqS7JiQC3qAOKtSEw3O8YHAwvESj/Z27+B9qL2hiz2zAuivA5
	 My8Rp/MqcqCCBMiCp+SFwzU7ArfvBN+zVSPYXIzHxOrkPRMh6GHb5QpBGudwPSp/71RQi
	 l1PLPG+B/8MsNDxHJC4mzLDbRd9k6ETKQkrWgm/zBs20wlw7N6nEC7JLEER/hd9GJd3zO
	 TZP2oHISg/0D+tQOdsQIJQ61Jt87ZCIdqwbVcSmeBHMUwDIJfg7fH1oqjvu08ZD4DpQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794237025;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=tZoV2P5ZP3IUMfU0egkrTuYGdW2HkJ2d3omty6T6Lvw=;
	b=R9Ox64qfmSkhB1B/WEqmIVTHp5Gau7ruqJGZdoCve4DVNU6nKPWw+A0lALLrt9iXvk4/
	 5bT112vkxiN/Lc+Zu9CERmGjkDcLvVByPQHlQYCb74l/cj/lMHTEL+cnKI2c+gdlsFV6B
	 lcFzAc2/OTvyoGI8LmeQ6zNdeasyM7flhOd+lbci/Be9OsoKCCFu4xbjsN2reFAsAkVXI
	 w3W4QZvKUgkVhdI+pQ1DzgutPab0Iw8Pc0I4YBRBeI8HxLPoFVKLTik+7mRpqB0tBnz9d
	 FIMJe6BuxtPAjJ6yq6y1k3ZghQJZntFNkKPtI3o6Pf4/RciVSewfg94gBGjWZH1/u2Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mFpgh1v3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0DB47606A325
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 15:10:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mFpgh1v3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 75A1B1F0089F;
	Mon,  9 Nov 2026 15:10:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794237024;
	bh=tZoV2P5ZP3IUMfU0egkrTuYGdW2HkJ2d3omty6T6Lvw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=mFpgh1v3Wf5/0EfIhhU2y1USlpAX5Z+qfMtgpk9pogbyrFfJMBsohr4rGhmpzzpjE
	 GvwbLqfDCBZ4HY6hxEV1505gnDDEC+mAOTAKk63biL/Yrrx6sl21fGKELyICa8UuoB
	 k8wddRH0H9yYu1YWgMmzPpJijyaIjwBkW32BZ7eeHOKJErtqSeU8SIBJRLsxX0b2Fh
	 +970osl8zwBjJwcpEm8ioE+RE0Y9OSLmDvtcgdpg6WJu4yBXMaCSvN6ZW/3bpQe5/O
	 kBEezFvrT1ZSP2ppuVQxGJn6iiNt9G/Z/OJQFJG3kryRM2jzfT/uEHOvZUz5Fs3JDz
	 ecuZhc7yM4ZPA==
Date: Mon, 9 Nov 2026 10:10:23 -0500
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] NFS/localio: give the LOCALIO probe a short timeout
 of its own
Message-ID: <avHiX4PgUIEQFbX2@kernel.org>
References: <20261102215220.16055-1-snitzer@kernel.org>
 <20261102215220.16055-4-snitzer@kernel.org>
 <c8f51ae8-9b07-4187-ab11-349322f636b2@app.fastmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c8f51ae8-9b07-4187-ab11-349322f636b2@app.fastmail.com>

On Fri, Nov 06, 2026 at 05:02:09PM -0500, Anna Schumaker wrote:
> 
> 
> On Mon, Nov 2, 2026, at 4:52 PM, Mike Snitzer wrote:
> > The LOCALIO probe clones the NFS client with rpc_bind_new_program(),
> > which NULL-pings the new program before the probe sends UUID_IS_LOCAL.
> > Both calls use the mount's timeout.  With timeo=600 and the default
> > retrans, a server that does not answer the LOCALIO program holds each
> > probe for about 170 s.  The client then logs "nfslocalio: server ... not
> > responding, timed out".  On such a server, one mkdir took about 170 s
> > of a 202 s run and ended when the probe gave up.
> >
> > Give the probe a soft timeout of its own, with no retries and no log
> > message.  The new nfs module parameter localio_timeout sets it in
> > seconds, 10 by default and at most 600.  Set it on a private clone of
> > the NFS client before rpc_bind_new_program(), so that the ping uses it
> > as well.  Clear cl_noretranstimeo, which NFSv4 mounts set, because with
> > it a sent call does not time out while the connection stays up.  With
> > localio_timeout set to 0, the probe uses the NFS client's timeouts, as
> > before.  The probe still shares the NFS client's transport and runs
> > beside its RPCs.  The NFS client's own timeouts do not change.
> >
> > Tested through a proxy that drops every call to the LOCALIO program:
> > the probe gave up after 10.6 s and logged nothing.  With
> > localio_timeout=0 it took 182.9 s and logged the message above.  The
> > probe still succeeds against a server that supports LOCALIO: with no
> > proxy, a 64 MiB O_DIRECT write through LOCALIO sent no WRITE RPCs.
> >
> > Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> > ---
> >  Documentation/filesystems/nfs/localio.rst |  9 ++++
> >  fs/nfs/localio.c                          | 54 +++++++++++++++++++++--
> >  2 files changed, 60 insertions(+), 3 deletions(-)
> >
> > diff --git a/Documentation/filesystems/nfs/localio.rst 
> > b/Documentation/filesystems/nfs/localio.rst
> > index e8f44332cc806..45c6981da0d89 100644
> > --- a/Documentation/filesystems/nfs/localio.rst
> > +++ b/Documentation/filesystems/nfs/localio.rst
> > @@ -316,6 +316,15 @@ It is checked on every I/O: setting it to N sends 
> > the next I/O of every
> >  client over the network, and setting it back to Y resumes LOCALIO.  A
> >  client that probed while it was N is probed again when it is set to Y.
> > 
> > +/sys/module/nfs/parameters/localio_timeout (uint)
> > +sets how many seconds the LOCALIO probe waits for each reply from the
> > +server, defaults to 10, at most 600.  A server that does not support
> > +LOCALIO may not answer the probe at all.  If no reply comes in time,
> > +the probe gives up without a log message.  The client then does not use
> > +LOCALIO.  The mount's timeouts do not apply to the probe.  Set to 0, the
> > +probe uses the mount's timeouts instead, as an NFS RPC would.  A change
> > +applies to the next probe.
> > +
> >  /sys/module/nfs/parameters/localio_O_DIRECT_semantics (bool)
> >  controls if O_DIRECT extends down to the underlying filesystem, defaults
> >  to N. Application IO must be logical blocksize aligned, otherwise
> > diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
> > index 80a496d6fe0d6..06d0755b1f203 100644
> > --- a/fs/nfs/localio.c
> > +++ b/fs/nfs/localio.c
> > @@ -82,6 +82,22 @@ static const struct kernel_param_ops localio_enabled_ops = {
> >  };
> >  module_param_cb(localio_enabled, &localio_enabled_ops, &localio_enabled, 0644);
> > 
> > +/* Seconds the LOCALIO probe waits for each reply; 0: the NFS client's 
> > own */
> 
> I'm having trouble parsing this. What does '0' mean here?
> 
> Thanks,
> Anna

Sorry about that, not sure what happened.  But how 0 is handled is
documented in localio.rst (above) and in the comment above
nfs_init_localioclient() (below).  In any case, this comment can be:

  /*
   * Seconds the LOCALIO probe waits for each reply.  With 0, the probe uses
   * the NFS client's timeouts instead.
   */

Can you fold this in or should I send v2?

Thanks,
Mike


> > @@ -156,13 +172,45 @@ const struct rpc_program nfslocalio_program = {
> > 
> >  /*
> >   * nfs_init_localioclient - Initialise an NFS localio client connection
> > + *
> > + * A server that does not support LOCALIO may not answer its RPCs at all.
> > + * The probe shares the NFS client's transport and runs beside its RPCs.
> > + * With localio_timeout set, it gets a quiet, soft timeout of that many
> > + * seconds of its own, whatever timeouts the mount uses.  With 0, it uses
> > + * the NFS client's timeouts, as an NFS RPC would.
> >   */
> >  static struct rpc_clnt *nfs_init_localioclient(struct nfs_client *clp)
> >  {
> > -	struct rpc_clnt *rpcclient_localio;
> > +	unsigned int timeout_secs = READ_ONCE(localio_timeout);
> > +	struct rpc_clnt *parent = clp->cl_rpcclient;
> > +	struct rpc_clnt *probe = NULL, *rpcclient_localio;
> > 
> > -	rpcclient_localio = rpc_bind_new_program(clp->cl_rpcclient,
> > -						 &nfslocalio_program, 1);
> > +	/*
> > +	 * rpc_bind_new_program() pings the new program with the timeout of
> > +	 * the client it clones, so set the probe's timeout on a private
> > +	 * clone first.  The clone's cl_timeout points at the transport's
> > +	 * timeout: give it its own copy rather than write through it.
> > +	 */
> > +	if (timeout_secs) {
> > +		probe = rpc_clone_client(parent);
> > +		if (IS_ERR(probe))
> > +			return probe;
> > +		probe->cl_timeout_default = (struct rpc_timeout) {
> > +			.to_initval	= timeout_secs * HZ,
> > +			.to_maxval	= timeout_secs * HZ,
> > +			.to_retries	= 0,
> > +		};
> > +		probe->cl_timeout = &probe->cl_timeout_default;
> > +		probe->cl_softrtry = 1;
> > +		probe->cl_noretranstimeo = 0;
> > +		probe->cl_chatty = 0;
> > +		parent = probe;
> > +	}
> > +
> > +	rpcclient_localio = rpc_bind_new_program(parent, &nfslocalio_program, 1);
> > +	/* The new client holds a reference to its parent, the probe clone */
> > +	if (probe)
> > +		rpc_shutdown_client(probe);
> > 
> >  	dprintk_rcu("%s: server (%s) %s NFS LOCALIO.\n",
> >  		__func__, rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR),
> > -- 
> > 2.52.0
