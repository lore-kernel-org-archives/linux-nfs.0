Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C230344236A
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 14:34:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792161285; cv=none; b=kcUw9U1aNCu8W/qxGXk699u1d2ngMybokwj1BRofGsB5gI5gBwgww5PSCFWoTNk5w3UC5gwVioL8wgW78VKI0oiHzv5h61dFboXJcEEePAijNFTUwP7d3DnXaylQ2Wl55czcO3L9hCS3/M+XIuZXork9bK4Du4WMQ5TCTBKYLJI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792161285; c=relaxed/simple;
	bh=4Xmk20YAouaBsLJ2zaHEh4Co848DUBzF0HOruCgy7x0=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=JKurHKA732a0wxg2DnUQQiwFD22afV44FA03hc+NJpLoGWgY4vCv+zt+t6qnJbfNfmkxCGbqY0bTiXAoL9358OyTsrwd3eJVcYFORI+wzrfHb8yJ/+/GsuTXnV4uPTtK4w6ib819oxu1mRYm4mD02XY72j4PoiRC4alsiLikQ0E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FvQvgYbc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FvQvgYbc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 417C81F000C4;
	Fri, 16 Oct 2026 14:34:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792161284;
	bh=sieuFFnp2vwR6zEgQpCZJ9ZpLYS3Tw1RExv8zbF0RRA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=FvQvgYbcehFolCjpEGrCcMRwSTFQBNMMHLy8Y0h40HYEtM46SFYu8h51NH/mIwUVN
	 zCevd/jQ/3BvljiiunKumFg1AVgRucjNa1JQrfhBhvyjilrxSJiDOxd+zz+B+P3JR1
	 80QenB26sgVkRsj9KK2nF/YXhrcs6oa9bB2w0lnZCNkzKPChc3e31pczqsqFNzYdx6
	 XcOdbXpYy3HcZNe/i/sdyXNp9M2VVZHwPYCxecpoAij8r413WBEqr4ULsEkmpbhwsk
	 La5QktI4/4fWAG9NZYT7FHiw9Zn3bW2P2hkGdt1g6jBeugnQiYuKa/6z73iXeACfIY
	 uSZZbWTC/ZTag==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 99361F40066;
	Fri, 16 Oct 2026 10:34:43 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 16 Oct 2026 10:34:43 -0400
X-ME-Sender: <xms:AzbSamyxrJHaKBKXY8hknZc_0yVzzY1neDh2r60bSnOAknUa_m7LEQ>
    <xme:AzbSatFmDUE9EqootCwJYYuGiCRPBKoLck06C4Vh90BW4yghamoaYyXnfO5l5l67M
    vocki6OCnT9rU9WOvkXle5WeFEQhUudCCNrkVvJGxqpf-_s8sCNEP-v>
X-ME-Proxy-Cause: dmFkZTF4z7V4Ey2iY6xxLCyuyY0qeyxSrefaQYO2sk/c0+1wL9iovk2LKnJHHcDa3HiP6j
    Si3buioX6X+S+lknpevHaxnx1/5rOYH67dvlF9r3Qoqdtvt8kJXGkwNhxlw1JSZlE0PRh9
    ZvsSCutfnS6ibvBytfc8Eez2pc6GlYusPaBdeyNWARtmkGoHCx3LBdzjzeYLk5JYQzS4A1
    lKFHcWBpkLgCDW/B4CipMSn+S2jlLwuDe8PHv1qdOERmKHuUy5QgEN9i9CnfRr9ujQcC8y
    9JvZcvDRVETAbTU6a4Yqa+/Wf4fuz0ATkglddUtkwjiPYe0AMlMkOf68tXOgAjdeHCAUL9
    by1/qm6GqNhIH+9rpyDt33Hwq0HfKZ8t1fnj2t0edA2VezlBEEXZYkjFFo7yf0lPO1L/l8
    3yhAxyvOdBMRuqQSbgBu+Rsh4XT9PAFPRbw8LfYDLrw/tKYQ2If9aRl830TzF49rK3ARI1
    cqzbrqadqW7xZTIC0lSIVTxUOc1q//2dBpRb86G1090NXsk3LFbLlfmDKFWt4aXw0wP4yw
    1X8VMMaAaoVmFdfupPpLoGPTDWxJqyvrzv6I9ebMS49UYuKgD+avHPGVrO/anl5I4UnynL
    6Yc3c7uhftcwSTbfLTDXHoTfGmFMcCm9pRmva+oeBKxd9L3EAfYyTnc7RIDg
X-ME-Proxy: <xmx:AzbSamMO5I_v6vOwbpHa1bWMG5MUowbq7vuAnEsvBC9aPqteKfAvXQ>
    <xmx:AzbSasuVFS82npQNZCSu1LMCl-zc0DSwGMjJI0PBV6Y8GTAHzYwe2A>
    <xmx:AzbSagWlSvz7eC-V8VyZOB_k08ZwrL5Z3pDOyUnzCBEB8tA2IIFpXw>
    <xmx:AzbSaktCOP0kHziqN3uU8DFIj8IE9pyWRdnN2C3RCc13p3yRUonN4g>
    <xmx:AzbSasWlevEAVD0edYqJD_CGwQtxQwrPaqyrknaBIDjETQRbQjNUHTuN>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 72949782738; Fri, 16 Oct 2026 10:34:43 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AV0wmJNhj1I7
Date: Fri, 16 Oct 2026 10:34:23 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "HeonJe Lee" <lhjnano@gmail.com>
Cc: linux-nfs@vger.kernel.org, jlayton@kernel.org
Message-Id: <62b23f24-5fb5-4459-aec6-635697a40eae@slotpi15m67>
In-Reply-To: <20261015114755.33331-1-lhjnano@gmail.com>
References: <20261015114755.33331-1-lhjnano@gmail.com>
Subject: Re: [PATCH] NFSD: wait for nfsdcld to open the cld pipe
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 10/15/26 7:47 AM, HeonJe Lee wrote:
> When nfsd starts, nfsd4_cld_tracking_init() waits up to one second
> for nfsdcld to open the freshly created cld pipe and fails the
> entire nfsd startup if it does not. nfsdcld is the only supported
> client tracking backend, so a slow daemon takes NFS down entirely.

Thanks for the report!


> In the field this was observed as a 44 minute outage after nfsd
> restarted alongside twenty plus other services.

I don't see how a 44-minute outage follows from the kernel code
path above. If you have the journal from that restart, I'd like to
see the NFSD and nfsdcld timestamps around it. More on that below.


> The cld pipe queues upcalls for late readers
> (RPC_PIPE_WAIT_FOR_OPEN). Drop the cld_running() pre-check and let
> the GetVersion upcall sit in the queue: nfsdcld picks it up as soon
> as it opens the pipe, and the 30 second rpc_pipefs queue timeout
> purges it with -ETIMEDOUT if the daemon never shows up. A missing
> nfsdcld now delays nfsd start by up to 30 seconds before failing,
> instead of failing outright at one second.

Running NFSD without nfsdcld is a legitimate configuration. Test rigs
and ephemeral servers do it and accept that clients cannot reclaim
after a server restart.

The comment you removed explains that the pre-check exists precisely
so that an absent daemon does not cost the 30-second rpc_pipefs
timeout. It also says the wait is short because nfsdcld "should
already be running before nfsd is started." That assumption is
where the actual bug is.

nfs-server.service already has After=nfsdcld.service. The ordering
does not help because nfsdcld calls daemon(0, 0) before it opens its
sqlite database and before cld_pipe_init() installs the inotify
watch on the rpc_pipefs directory. Its unit is Type=forking, so
systemd considers nfsdcld started as soon as the parent exits, while
the child may still be running schema migration or, on the first
start after an upgrade, importing legacy nfsdcltrack records. On a
busy boot that window is easily longer than a second.

The other nfs-utils daemons that systemd has to wait for (gssd,
svcgssd, idmapd, statd, exportd) use the daemon_init() and
daemon_ready() helpers in support/nfs/mydaemon.c, where the parent
does not exit until the child reports that it is ready. nfsdcld
never adopted them. Converting it, with daemon_ready() after
cld_pipe_init() succeeds, makes the existing service ordering mean
what the kernel comment assumes. Once the watch is installed, the
latency from pipe creation to open is one event-loop wakeup, which a
one-second wait covers with plenty of margin.

Please consider a fix in nfsdcld rather than in the kernel. If your
journal shows nfsdcld already had its watch in place and still
opened the pipe more than a second after nfsd created it, that would
be evidence the kernel needs a longer wait, and I'd reconsider a
kernel code change.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
