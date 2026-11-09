Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794239880;
	b=Qezh/R3Tj4qdJZ+KAfkIGOZKTipbAtNGUm/eBE1d/hPOfKSPWwbvmED0DL32m1qBxb5s
	 puRanK5NLR81TDeY+Iw6yX51Ep0jSw/MR9pN2X08lM3GToLJiMAEdNPee+iDtz1v/YvWX
	 2CW482JfahrKpq1qos2WvPjTaZv6Cw/1kwX47BaWtbsdjSwTXR2uo2cDUQdzaafOqayDT
	 bf0uYMrWjtFPYnVui3iKuW3gxig49MneJXk2MLZt4dTIV7UFoXjbS6Ex75XyrbhMrJ2nZ
	 t95LSHX1cQDsVvAotUMauGPvHX8925pZEc+VZme1WbqUFCL4CH0aKrHEVDLP0AmxT7Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794239880;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=nD0Fov5vstqjfV2RIFBuUwZ2sOez8ALAEleCpoWGU44=;
	b=NnrAGgN4PMuH097Sas7nHcdAYA0sYhfdcJES8VGzVmy6mCOnMpR2+CkeiX2fHnhFAy8E
	 VG5Xgji6RiqSS2V3/sA2OKPGZpqrH6YafCqx0jwCsXbwjG6WsXz4AUGNfiHQFnnz4kffO
	 ReX0MGjB4ioGbvtwZUSOzsNXOqxru153KflV0a53c/LQ2xEZBy7+DviTczihlfpVyU3X1
	 XeiZiyuMdKblXw8eR1pRqyUw6Y5xfCwmkDEBv+NccD3wgjGzl+k+Gk/s1LMLMlHIX+kmE
	 uRFxTys6/sIzLaXdM7ut064E9ZsF4FH7Uvm8mMVLGmFESPOSdpj2Tv+EZBvBD4gMC8A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=edfVcKt5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F171606A332
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 15:58:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=edfVcKt5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EF8961F008A5;
	Mon,  9 Nov 2026 15:57:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794239880;
	bh=nD0Fov5vstqjfV2RIFBuUwZ2sOez8ALAEleCpoWGU44=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=edfVcKt5dT9bfkM2H0Jq0cZiq4DPMfPE1s30SGSpkuIUfvjO3oe7m1Uk7sennngmU
	 VkO0wZXhhSy5RfpzjbEwTNB3/24rP7Yufu9aUHTgRtDDaSdcFl/Do8ylXFbkpQKk+y
	 9LcffWdccj0/AK+f8Y12S1A8JPzLkmHHY/8s8wdskbzlz+tr/tiUUaKVPFRvhdtNHV
	 fuYA60JcZOxpZWWsXK4cJ1W2W1M59JEPk6mholrDMf0Rud0tEdYtkqAn0+3w+RKEvs
	 jevOSC1O+/woYL5NhWrEavhCfZ70QWW3bTN1aRENt2ZuErwfpbSGMPnIv5EFZWe3mF
	 rbr8Ihe3DV+Jw==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 59618F40066;
	Mon,  9 Nov 2026 10:57:59 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Mon, 09 Nov 2026 10:57:59 -0500
X-ME-Sender: <xms:h-3xavUN0dat1XpGQdZLiqVMSZV0lfpgNpengUMltQqU2_XKn1ccHA>
    <xme:h-3xaibj93i9STPG8Rpb2zd9jLWotfz7e2JDA4Tp7gwTmFE1qI7rwIr4Rxfwv9Cp2
    wQ88eFpVrBvQoStl1ZQ5teFgE8j1shaQhfFMUuDmg4uMRReoiYyBDqmnQ>
X-ME-Proxy-Cause: dmFkZTGOsAKy6WsaaPBJ+vhVKMmGpGpgbJkEBwqSB3xiZt3OBEUw2ME/6CNCRzkgRi1S6M
    UjLJPCojG8lhpPpbAceO69dc1qG1XXa21fs7x0sdc85JB7Z0uTT3Fae+kIcUFawO3jwz2M
    v3ReSsnuXR100ur5B9IXGXuZzvEeWCD3mXCkw6B69Pq2plsgr/mmasxZSpDGhqQYnEvwUq
    CWMCFF7qw010sYJMyD3O7P1JDsv8hD73cH2Td8cb2c1ARpXXkD1vQAFulMFsHEojsplSav
    tXkveGdoQEJJkiE6GUS4VPasmwZTFtBr1ixqu2atK541Bpn976xcVNyauueZcGZbReJcgG
    y5/bhAv51cUPjtJlxZ1KTYM2N4R1re5yGg4sJQaT6xLdSJa93yW2sQrYutrDELKZ6MLOg5
    NSuxGX9RvGm8X6wplpGA2wzLMm7j+n6G0GrpOcGi5WoccOsTossQvlZeKVGCjaeCwl/qeh
    bjAoKQsJSdLNsY76UUTh/V10PEWtcOCx1y6sNNAMPEEx10In/duX2XlNpdbf3WyiZipKqA
    2wqX7Ma4ZesXbd3K0SNo/r4/1BLsigEGrrsZzYcx/jNeoturlfJggBdGu0OHzZbEaKkiNw
    Jkoy6+vRZ6m0piCrrP7ldUwNGWJq9c7vKF7gzcVdKuQf++8yxWCllEFqDb9Q
X-ME-Proxy: <xmx:h-3xauQA_aP9lwYILWQUh3XLOpiso486gr_EiExsj-mDVXlhsROPYQ>
    <xmx:h-3xari8gJSEtHsuHKnSH9t39gAt_xX7K9CdbSoSe8_athZPnO9vqA>
    <xmx:h-3xau4lX9i_XSY7CbS0Llkv5TDk-kTuYzuGqrWqx748GAq4SdgtQw>
    <xmx:h-3xaoB7kAJjt0rdHNi88pOIK3Ev9-bG0F79cVmng9RwvNjBYPl40w>
    <xmx:h-3xalafTC5GquCbKQ6yeRFTlJJ-tX7ucN5gtPZfloA3OTDTt7itBMq0>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 3F946B6006F; Mon,  9 Nov 2026 10:57:59 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: ArXanrC7RZNR
Date: Mon, 09 Nov 2026 10:57:39 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>
Cc: "Trond Myklebust" <trondmy@kernel.org>, linux-nfs@vger.kernel.org
Message-Id: <66beadbd-5735-4941-821e-059d5cb9850a@app.fastmail.com>
In-Reply-To: <avHiX4PgUIEQFbX2@kernel.org>
References: <20261102215220.16055-1-snitzer@kernel.org>
 <20261102215220.16055-4-snitzer@kernel.org>
 <c8f51ae8-9b07-4187-ab11-349322f636b2@app.fastmail.com>
 <avHiX4PgUIEQFbX2@kernel.org>
Subject: Re: [PATCH 3/3] NFS/localio: give the LOCALIO probe a short timeout of its own
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Mike,

On Mon, Nov 9, 2026, at 10:10 AM, Mike Snitzer wrote:
> On Fri, Nov 06, 2026 at 05:02:09PM -0500, Anna Schumaker wrote:
>> 
>> 
>> On Mon, Nov 2, 2026, at 4:52 PM, Mike Snitzer wrote:
>> > The LOCALIO probe clones the NFS client with rpc_bind_new_program(),
>> > which NULL-pings the new program before the probe sends UUID_IS_LOCAL.
>> > Both calls use the mount's timeout.  With timeo=600 and the default
>> > retrans, a server that does not answer the LOCALIO program holds each
>> > probe for about 170 s.  The client then logs "nfslocalio: server ... not
>> > responding, timed out".  On such a server, one mkdir took about 170 s
>> > of a 202 s run and ended when the probe gave up.
>> >
>> > Give the probe a soft timeout of its own, with no retries and no log
>> > message.  The new nfs module parameter localio_timeout sets it in
>> > seconds, 10 by default and at most 600.  Set it on a private clone of
>> > the NFS client before rpc_bind_new_program(), so that the ping uses it
>> > as well.  Clear cl_noretranstimeo, which NFSv4 mounts set, because with
>> > it a sent call does not time out while the connection stays up.  With
>> > localio_timeout set to 0, the probe uses the NFS client's timeouts, as
>> > before.  The probe still shares the NFS client's transport and runs
>> > beside its RPCs.  The NFS client's own timeouts do not change.
>> >
>> > Tested through a proxy that drops every call to the LOCALIO program:
>> > the probe gave up after 10.6 s and logged nothing.  With
>> > localio_timeout=0 it took 182.9 s and logged the message above.  The
>> > probe still succeeds against a server that supports LOCALIO: with no
>> > proxy, a 64 MiB O_DIRECT write through LOCALIO sent no WRITE RPCs.
>> >
>> > Signed-off-by: Mike Snitzer <snitzer@kernel.org>
>> > ---
>> >  Documentation/filesystems/nfs/localio.rst |  9 ++++
>> >  fs/nfs/localio.c                          | 54 +++++++++++++++++++++--
>> >  2 files changed, 60 insertions(+), 3 deletions(-)
>> >
>> > diff --git a/Documentation/filesystems/nfs/localio.rst 
>> > b/Documentation/filesystems/nfs/localio.rst
>> > index e8f44332cc806..45c6981da0d89 100644
>> > --- a/Documentation/filesystems/nfs/localio.rst
>> > +++ b/Documentation/filesystems/nfs/localio.rst
>> > @@ -316,6 +316,15 @@ It is checked on every I/O: setting it to N sends 
>> > the next I/O of every
>> >  client over the network, and setting it back to Y resumes LOCALIO.  A
>> >  client that probed while it was N is probed again when it is set to Y.
>> > 
>> > +/sys/module/nfs/parameters/localio_timeout (uint)
>> > +sets how many seconds the LOCALIO probe waits for each reply from the
>> > +server, defaults to 10, at most 600.  A server that does not support
>> > +LOCALIO may not answer the probe at all.  If no reply comes in time,
>> > +the probe gives up without a log message.  The client then does not use
>> > +LOCALIO.  The mount's timeouts do not apply to the probe.  Set to 0, the
>> > +probe uses the mount's timeouts instead, as an NFS RPC would.  A change
>> > +applies to the next probe.
>> > +
>> >  /sys/module/nfs/parameters/localio_O_DIRECT_semantics (bool)
>> >  controls if O_DIRECT extends down to the underlying filesystem, defaults
>> >  to N. Application IO must be logical blocksize aligned, otherwise
>> > diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
>> > index 80a496d6fe0d6..06d0755b1f203 100644
>> > --- a/fs/nfs/localio.c
>> > +++ b/fs/nfs/localio.c
>> > @@ -82,6 +82,22 @@ static const struct kernel_param_ops localio_enabled_ops = {
>> >  };
>> >  module_param_cb(localio_enabled, &localio_enabled_ops, &localio_enabled, 0644);
>> > 
>> > +/* Seconds the LOCALIO probe waits for each reply; 0: the NFS client's 
>> > own */
>> 
>> I'm having trouble parsing this. What does '0' mean here?
>> 
>> Thanks,
>> Anna
>
> Sorry about that, not sure what happened.  But how 0 is handled is
> documented in localio.rst (above) and in the comment above
> nfs_init_localioclient() (below).  In any case, this comment can be:
>
>   /*
>    * Seconds the LOCALIO probe waits for each reply.  With 0, the probe uses
>    * the NFS client's timeouts instead.
>    */
>
> Can you fold this in or should I send v2?

That reads much better to me. I'll fold it into the patch!

Anna

>
> Thanks,
> Mike
>
>
>> > @@ -156,13 +172,45 @@ const struct rpc_program nfslocalio_program = {
>> > 
>> >  /*
>> >   * nfs_init_localioclient - Initialise an NFS localio client connection
>> > + *
>> > + * A server that does not support LOCALIO may not answer its RPCs at all.
>> > + * The probe shares the NFS client's transport and runs beside its RPCs.
>> > + * With localio_timeout set, it gets a quiet, soft timeout of that many
>> > + * seconds of its own, whatever timeouts the mount uses.  With 0, it uses
>> > + * the NFS client's timeouts, as an NFS RPC would.
>> >   */
>> >  static struct rpc_clnt *nfs_init_localioclient(struct nfs_client *clp)
>> >  {
>> > -	struct rpc_clnt *rpcclient_localio;
>> > +	unsigned int timeout_secs = READ_ONCE(localio_timeout);
>> > +	struct rpc_clnt *parent = clp->cl_rpcclient;
>> > +	struct rpc_clnt *probe = NULL, *rpcclient_localio;
>> > 
>> > -	rpcclient_localio = rpc_bind_new_program(clp->cl_rpcclient,
>> > -						 &nfslocalio_program, 1);
>> > +	/*
>> > +	 * rpc_bind_new_program() pings the new program with the timeout of
>> > +	 * the client it clones, so set the probe's timeout on a private
>> > +	 * clone first.  The clone's cl_timeout points at the transport's
>> > +	 * timeout: give it its own copy rather than write through it.
>> > +	 */
>> > +	if (timeout_secs) {
>> > +		probe = rpc_clone_client(parent);
>> > +		if (IS_ERR(probe))
>> > +			return probe;
>> > +		probe->cl_timeout_default = (struct rpc_timeout) {
>> > +			.to_initval	= timeout_secs * HZ,
>> > +			.to_maxval	= timeout_secs * HZ,
>> > +			.to_retries	= 0,
>> > +		};
>> > +		probe->cl_timeout = &probe->cl_timeout_default;
>> > +		probe->cl_softrtry = 1;
>> > +		probe->cl_noretranstimeo = 0;
>> > +		probe->cl_chatty = 0;
>> > +		parent = probe;
>> > +	}
>> > +
>> > +	rpcclient_localio = rpc_bind_new_program(parent, &nfslocalio_program, 1);
>> > +	/* The new client holds a reference to its parent, the probe clone */
>> > +	if (probe)
>> > +		rpc_shutdown_client(probe);
>> > 
>> >  	dprintk_rcu("%s: server (%s) %s NFS LOCALIO.\n",
>> >  		__func__, rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR),
>> > -- 
>> > 2.52.0
