Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794002551;
	b=cJQ3m38f5kpb8WHbruCAwNV3Spexvf7Jz7YPDPp/dzY9/cIKlNr4YVzLtrTjKCc+U0zx
	 KKU/VYL6oApZ8FXTqeN82QCngxMoEr/Uql7TKrUo/y3K6t6OCgJbQcqmV9l14rAUP5xwe
	 YmscD/oPnyIe1yHViJoi8KlhzeLM8x7mw/20UnY1sSvziikECavNa6VXaL8xUz3R3IzEE
	 mRwpdEjr96SeALZzT7pkdHmQB2Hm7W4XROmDqRap2HeYI3K+tED0RkHwLSFGIVisH4v3e
	 Bw/ujcZ/fCWp0PvATyY5QEmxrJRvMEpmjJzcfgHbNSr6fspeKfRno6HgA7yv/ZwspNQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794002551;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=yRXuZdIWjsru7fb6CShC+wlXWZFlvmna7/vFb0+IhUE=;
	b=S8R5E6cwRf2NEBUH/9ITDZfYFsN/n7RebrPajNoIoVqPpL32ft9jA0xPyEweE+SuSxFe
	 F/Q2QpmqLOwDrErH0jAwE6Uc8sKq1EbNdRGSMttVs0dpdiRFLnh2ZtsBPUrHnqUwqZzFC
	 cP+McWnVUwqu7QefM+X/2vWWvbBduGDsBGtSbueYQ//i66Zd9OcspmIy0dUiF3Al248qb
	 wybGlDVHDWaqMmhNuuVpUeH33B0cUAKrOLxiF44/WKkAhSe86tJ+XlKGupIiWZi7rnW5/
	 eRryNEmoFWr87IrrxPiiYFM1JhmacLTcvK9Tf2idpBeQZzowcbzj2Bk5ybzE/vROJTA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mUvGFNGM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A173E606A32C
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 22:02:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mUvGFNGM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 533161F008A1
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 22:02:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794002550;
	bh=yRXuZdIWjsru7fb6CShC+wlXWZFlvmna7/vFb0+IhUE=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=mUvGFNGMiv5X7YfMHuHzqBtC0Y5C9v1ceouRgS6P46AQyNJ6ZPs5yzB6makoAaZrr
	 3vkEiZC3g5BS7uiVII79x21tYCABAPkkJhEsoeJU3eemt6B6fJ5faS96Y8U7SKcLYD
	 /3Bj9jt8eb4jjG7HY37dvxS6/bYZ2f8x61TI7XPQb/+N+a+oXbbPoL+q5X5vu7M0hs
	 /T0v8Wm2P28ZnFvfgNEJf/UQdr8QYgHZGaw3/qgfeVHE0SS/UmIl0i/o4kygwzRYGu
	 2QpjlrAApImVEOhMFJ0/S1w0tlaLyLC2FJApA/WE1X2NOHULKtLMoNjckP3gWiMHPj
	 peBaSU4SutckA==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 81508F40067;
	Fri,  6 Nov 2026 17:02:29 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Fri, 06 Nov 2026 17:02:29 -0500
X-ME-Sender: <xms:dU7uajIvQAVPD8eOFzIC2Z9Q-hTq7mBZ06ltDr4Q4Bk1tGte34SjJA>
    <xme:dU7uah_YYaBPb8fAtZMlf33BagfXK_oClTB4LyFBDrWYY_Zog9Sq7gzLivK7BSZqc
    hSd_DJjidqMp7fu24m3TR_rvWmCX98zaZS3NGtfvF1ZyJiWYUiB3lV_>
X-ME-Proxy-Cause: dmFkZTF5U7TN8NDnptAQx+NYplUYolbmkahfvZZc/hiLKZu/NBwyX52RBtPw2JHhhumTBz
    lAKYEoE1njMbAEfXU88qn96fDldokseKxhvfM8ZT3bGUBZLF1WsYghP3yCpMI7zKolKdZd
    SOTQ0L0s+uYOJjqpTqpCvZ/P1Godmy5/n+V4gDd343PF8kgUn0JNxsqtccC6v5au0Hnfvm
    //XDwLtxyiBsBSRg8sudmnxVjVH45Wwsy/gNKSPWDKW8GB/0xeI5LV7JW6poFSsIIcAnCm
    Hng8ajzLACupHa2L/jLQQj2MwN3KhK2ODJESszZTAr2poNbLAs6XKdQEeicaeD/HsjRWbN
    MykGV5opybtDE9t3KRKWV44dA4Topj42bHGga2cJtsB+2I+vP2w5Ui5NAh6OLkx16wiNJG
    VmVTRmOy8G25q1WDUGn1IXallcgiY3F/lO92UqSfkkkw6kXdqdAIFAROF+Qt/E0AbxjyBZ
    1xpdCjTixC6MPadyfZthgE7bf3OMnT0aK6+8cd+8idzc6g31uiuiPPkHBbGsvm8KVzvZaq
    jTsWjb4ZS0PvTgp00qxIUlc94+I2M7BHuX+F2SoLxFyHOeZhzbJqsLTYyijwj+CqjG2+oH
    0YQglGHHBvsUF2HFeBjL+J/XRXhGqaA2uwuYygAEiig/aPfyReC2SXchl6BA
X-ME-Proxy: <xmx:dU7uanmfstWMb6xj_yR9whwLFVt0DcO4GZVayXh0zdyQRHyjMIZXDw>
    <xmx:dU7uaikgq1Iqwlmb195WyQ6ZPa8jRSh5FTQ6Xod8_tsxAozHfs6m1g>
    <xmx:dU7uagsD74_R48uXnlbUbRNMqmWsreEcM7jxL6Fs9x-2JcNAvP2hmw>
    <xmx:dU7uatmuNWgfDQ8xzRbGQR0bWkRH_3uSnKodD7J_r2RX4qXOfnW83g>
    <xmx:dU7uajty0WUUPRtXXw7whgI9tpCHSaMmfNkrqwLZYDiQgPvhYR2DNqB->
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 6BE3EB6006E; Fri,  6 Nov 2026 17:02:29 -0500 (EST)
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
Date: Fri, 06 Nov 2026 17:02:09 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org
Message-Id: <c8f51ae8-9b07-4187-ab11-349322f636b2@app.fastmail.com>
In-Reply-To: <20261102215220.16055-4-snitzer@kernel.org>
References: <20261102215220.16055-1-snitzer@kernel.org>
 <20261102215220.16055-4-snitzer@kernel.org>
Subject: Re: [PATCH 3/3] NFS/localio: give the LOCALIO probe a short timeout of its own
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Nov 2, 2026, at 4:52 PM, Mike Snitzer wrote:
> The LOCALIO probe clones the NFS client with rpc_bind_new_program(),
> which NULL-pings the new program before the probe sends UUID_IS_LOCAL.
> Both calls use the mount's timeout.  With timeo=600 and the default
> retrans, a server that does not answer the LOCALIO program holds each
> probe for about 170 s.  The client then logs "nfslocalio: server ... not
> responding, timed out".  On such a server, one mkdir took about 170 s
> of a 202 s run and ended when the probe gave up.
>
> Give the probe a soft timeout of its own, with no retries and no log
> message.  The new nfs module parameter localio_timeout sets it in
> seconds, 10 by default and at most 600.  Set it on a private clone of
> the NFS client before rpc_bind_new_program(), so that the ping uses it
> as well.  Clear cl_noretranstimeo, which NFSv4 mounts set, because with
> it a sent call does not time out while the connection stays up.  With
> localio_timeout set to 0, the probe uses the NFS client's timeouts, as
> before.  The probe still shares the NFS client's transport and runs
> beside its RPCs.  The NFS client's own timeouts do not change.
>
> Tested through a proxy that drops every call to the LOCALIO program:
> the probe gave up after 10.6 s and logged nothing.  With
> localio_timeout=0 it took 182.9 s and logged the message above.  The
> probe still succeeds against a server that supports LOCALIO: with no
> proxy, a 64 MiB O_DIRECT write through LOCALIO sent no WRITE RPCs.
>
> Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> ---
>  Documentation/filesystems/nfs/localio.rst |  9 ++++
>  fs/nfs/localio.c                          | 54 +++++++++++++++++++++--
>  2 files changed, 60 insertions(+), 3 deletions(-)
>
> diff --git a/Documentation/filesystems/nfs/localio.rst 
> b/Documentation/filesystems/nfs/localio.rst
> index e8f44332cc806..45c6981da0d89 100644
> --- a/Documentation/filesystems/nfs/localio.rst
> +++ b/Documentation/filesystems/nfs/localio.rst
> @@ -316,6 +316,15 @@ It is checked on every I/O: setting it to N sends 
> the next I/O of every
>  client over the network, and setting it back to Y resumes LOCALIO.  A
>  client that probed while it was N is probed again when it is set to Y.
> 
> +/sys/module/nfs/parameters/localio_timeout (uint)
> +sets how many seconds the LOCALIO probe waits for each reply from the
> +server, defaults to 10, at most 600.  A server that does not support
> +LOCALIO may not answer the probe at all.  If no reply comes in time,
> +the probe gives up without a log message.  The client then does not use
> +LOCALIO.  The mount's timeouts do not apply to the probe.  Set to 0, the
> +probe uses the mount's timeouts instead, as an NFS RPC would.  A change
> +applies to the next probe.
> +
>  /sys/module/nfs/parameters/localio_O_DIRECT_semantics (bool)
>  controls if O_DIRECT extends down to the underlying filesystem, defaults
>  to N. Application IO must be logical blocksize aligned, otherwise
> diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
> index 80a496d6fe0d6..06d0755b1f203 100644
> --- a/fs/nfs/localio.c
> +++ b/fs/nfs/localio.c
> @@ -82,6 +82,22 @@ static const struct kernel_param_ops localio_enabled_ops = {
>  };
>  module_param_cb(localio_enabled, &localio_enabled_ops, &localio_enabled, 0644);
> 
> +/* Seconds the LOCALIO probe waits for each reply; 0: the NFS client's 
> own */

I'm having trouble parsing this. What does '0' mean here?

Thanks,
Anna

> +static unsigned int localio_timeout __read_mostly = 10;
> +
> +static int localio_timeout_set(const char *val, const struct 
> kernel_param *kp)
> +{
> +	return param_set_uint_minmax(val, kp, 0, 600);
> +}
> +
> +static const struct kernel_param_ops localio_timeout_ops = {
> +	.set = localio_timeout_set,
> +	.get = param_get_uint,
> +};
> +module_param_cb(localio_timeout, &localio_timeout_ops, 
> &localio_timeout, 0644);
> +MODULE_PARM_DESC(localio_timeout,
> +		 "LOCALIO probe timeout in seconds (default 10), 0 to use the 
> mount's default");
> +
>  static void nfs_local_do_read(struct nfs_local_kiocb *iocb,
>  			      const struct rpc_call_ops *call_ops);
>  static void nfs_local_do_write(struct nfs_local_kiocb *iocb,
> @@ -156,13 +172,45 @@ const struct rpc_program nfslocalio_program = {
> 
>  /*
>   * nfs_init_localioclient - Initialise an NFS localio client connection
> + *
> + * A server that does not support LOCALIO may not answer its RPCs at all.
> + * The probe shares the NFS client's transport and runs beside its RPCs.
> + * With localio_timeout set, it gets a quiet, soft timeout of that many
> + * seconds of its own, whatever timeouts the mount uses.  With 0, it uses
> + * the NFS client's timeouts, as an NFS RPC would.
>   */
>  static struct rpc_clnt *nfs_init_localioclient(struct nfs_client *clp)
>  {
> -	struct rpc_clnt *rpcclient_localio;
> +	unsigned int timeout_secs = READ_ONCE(localio_timeout);
> +	struct rpc_clnt *parent = clp->cl_rpcclient;
> +	struct rpc_clnt *probe = NULL, *rpcclient_localio;
> 
> -	rpcclient_localio = rpc_bind_new_program(clp->cl_rpcclient,
> -						 &nfslocalio_program, 1);
> +	/*
> +	 * rpc_bind_new_program() pings the new program with the timeout of
> +	 * the client it clones, so set the probe's timeout on a private
> +	 * clone first.  The clone's cl_timeout points at the transport's
> +	 * timeout: give it its own copy rather than write through it.
> +	 */
> +	if (timeout_secs) {
> +		probe = rpc_clone_client(parent);
> +		if (IS_ERR(probe))
> +			return probe;
> +		probe->cl_timeout_default = (struct rpc_timeout) {
> +			.to_initval	= timeout_secs * HZ,
> +			.to_maxval	= timeout_secs * HZ,
> +			.to_retries	= 0,
> +		};
> +		probe->cl_timeout = &probe->cl_timeout_default;
> +		probe->cl_softrtry = 1;
> +		probe->cl_noretranstimeo = 0;
> +		probe->cl_chatty = 0;
> +		parent = probe;
> +	}
> +
> +	rpcclient_localio = rpc_bind_new_program(parent, &nfslocalio_program, 1);
> +	/* The new client holds a reference to its parent, the probe clone */
> +	if (probe)
> +		rpc_shutdown_client(probe);
> 
>  	dprintk_rcu("%s: server (%s) %s NFS LOCALIO.\n",
>  		__func__, rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR),
> -- 
> 2.52.0
