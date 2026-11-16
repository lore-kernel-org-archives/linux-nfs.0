Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794857542;
	b=SgHQ22Uw/vOexyIqrlg8PRE7LY8yhcH305O3GEpSxjYnHFo0yc2mOHdtFnLTFxwE20Bi
	 3Y71g6gEEIGzcrVvdEhfmZggAtSyrBhJn1n4FaEjEmSzhf1aIygOhL8i3UOHbGCif7Qex
	 Nn+nlsNAKazAhgcQ2TWSMfFVX6B/Z76uQuZgpVlahYDUWptv4fWDmgex5wjKxBoUtDezV
	 wnyEXbGHK9ovDfXDXvNyatsw/YTUpDZF4gB6Lxig+/MqDuS/qydJAueuYKdsGBvbBk9C/
	 KNNx5bBamO1E064zKnCct2JmFnCiN9z65lolqE0KNNHHoyVjWkWWc9Ejvg4vm9wAp2A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794857542;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=ZEIMr6EF+k/i2QSfrEbyqXIr/Dpz+3YkZ2g23ZXT9A4=;
	b=SYvjB2CibpSHHuTN3k5+Rj0QyFFERYDrTZsfVXDRlPehxnBC8X1F3lwCULOSZuN+TvN8
	 uBGhHg6s5Equ5JdtcZtIGtr8FYol1dBT2XgoJGnn6ecAFXwRFHQCM2PrWYXojL6oFqPO0
	 YfVOBe0zLVfCJqEXZvRv9RwqTq+XnC5vTCDnCTn/QGG30/dtD/JPD/n5MqftDDooG8F7l
	 RAYDN4IaGNtG0+Zlj2hluKqp3WhaZltZl51Q6K64GQC8f7QyGsQX+vKFghC1fAtQMjUlY
	 WSEg21h+++pETlcFEVxR992qRkqopmHFg/Mpex4vRZWztXYCTafIPZz7X4iDdGHkffg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=O4nuskAk;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 31511606A32C;
	Mon, 16 Nov 2026 19:32:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=O4nuskAk
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3094D1F000C5;
	Mon, 16 Nov 2026 19:32:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794857541;
	bh=ZEIMr6EF+k/i2QSfrEbyqXIr/Dpz+3YkZ2g23ZXT9A4=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=O4nuskAkLzdyNkorLNE6nrBNrhOdCp8yYSHgsGVbTiwSi/0fcQFeUdDjJ8nV7ZkDq
	 3HNoqHatloVGJXBPLGS8mHAfsRa6S5opxuymF/CJwH4h06J5kz7EOC9ZAsyKwNwZmT
	 26Q69Ytb2B+xhzkQ0+TXnG/hXUW1BWWhslkakhwBPOgILkVBfSe2X0WVoAEn2r2y3q
	 xluUgKvZh+MacnD6q7jc4zQRcosHEHLl1u5HwlwhMdmKgCrQ0fWtCpGQl5lS5SQxIl
	 zdHDOFMQQ8YBv6iWhJli5VvRCG7SGnk1HmpFkQNWVRgpH3ehXjiSByDZH2xqRdDQbq
	 4xDQxA7LIPTNA==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 6CB92F40090;
	Mon, 16 Nov 2026 14:32:20 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Mon, 16 Nov 2026 14:32:20 -0500
X-ME-Sender: <xms:RFr7aktLigboh5T4EUH2EElUd9DIlxZdqjNhmxh5QNQCMZAZ7-vtwg>
    <xme:RFr7asREOlfIHidzh-t-ZZiWBcrGT9dDrffCN1bLlKNfo86FhvGFFz3M3YNEsWB-V
    osuO7Bl-z92PAacBmWA3rgtDeDTTusERy29-5T-BsJ7J3kmwm4CooE>
X-ME-Proxy-Cause: dmFkZTE29gHG6vvSuZ1IvrXOmMKQwwGMxNM1wHmkAxAp+qE+Ue0gnmPHCJmmDnrKsA4MJA
    exZxloFjp+5c8vPYr122uCQxKvYZt+f3iIh1nvg3bEf1hBkApPsLov+rmkO9ZmyhSGRH+h
    0pMhmVQdnIoQwLPNpyQJk1iYU93KNLGix9r40T1YRZ1Lt7n3NQfw1ZbGmV/1mleBNR9i+V
    gTWo8RvYDQEU/ixfbhvKVLP64fin19j9cH6lFJqpIKXYzeFHFnGUo9N7Rax/82lBAIz9is
    Na8q3ze25YdLNdqH24xsGKJCWxhxMZ9oHF6fMJGQO218o9OsutyAdiGK7vIwI7mY9FBdK7
    yG2Erv4reZK/uKK75uR/9mK9eHNUpqTtgnHGLW5GtUYBncB047ASgxwPwzt1k8brrZuFgd
    t5nLmiaLxWw8EupXLZrlG+L3zxDXls8dZirMxTmPqvkZ0ibLfrNNrLYj+2TN6U1TNGnd9T
    jxIH+nWh0ZxCGoTMvRcF6yfgaEHh2Ic8YfMpqbqqAGmrPMIMt+20XAoxaQf+LV9VSgowzD
    8W+1mLMzgTP4aiuZd0wsQyZH2K0MSwKDzU7CtlUvO11TULjVTfDbdEXRDlccJIis8A3GQM
    1oJlqhYnE8G0Jl4tpZaUzw6IkUKqg1L4rAabHVoMWawQiakTTLmyMRaViUDA
X-ME-Proxy: <xmx:RFr7auG8rBN8nUX0eSHCrsSK9Sulh85hvI2vCu1ZEGk8bCfAZa0_Gg>
    <xmx:RFr7auSW1WP1LgpeSLwxpJk-xuLXgWIU5Q_0HGsIBUsjjf1UjlxSlg>
    <xmx:RFr7akOKXG0jpccyt0yZgmKRH-4qbbV4eA5NKcc4dd4EaQKeqlL-mQ>
    <xmx:RFr7armARqWOALNIKAeA-H0tbWdi1dBqGjLkzToCxWoG4tYCkJMF0Q>
    <xmx:RFr7ambUyCXXV1zBDVqNagc1eeclCnib9x8NDaZR4wU1PHYpfELXXtX7>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5115DB6006E; Mon, 16 Nov 2026 14:32:20 -0500 (EST)
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
X-ThreadId: AB_Ze6YMkrK7
Date: Mon, 16 Nov 2026 14:32:00 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Andrew Pam" <andrew@sericyb.com.au>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Rafael J. Wysocki" <rafael@kernel.org>, "Mike Snitzer" <snitzer@kernel.org>,
 linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <0d9f6196-6737-4936-a8fd-97192d96ad3f@app.fastmail.com>
In-Reply-To: <20261116131428.1024230-2-andrew@sericyb.com.au>
References: <20261116131428.1024230-1-andrew@sericyb.com.au>
 <20261116131428.1024230-2-andrew@sericyb.com.au>
Subject: Re: [PATCH v2 1/3] SUNRPC: freeze rpciod and xprtiod across system sleep
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Andrew,

On Mon, Nov 16, 2026, at 8:14 AM, Andrew Pam wrote:
> After hibernation takes its snapshot, the kernel thaws devices to write
> the image, and the NIC with them. Freezable kernel threads and
> workqueues stay frozen until the image is restored, but rpciod and
> xprtiod are not freezable, so RPCs continue to be transmitted, and
> transports reconnected, until power-off. The server acts on them; the
> restored image knows nothing of them.
>
> With NFSv4.1 this wedges the mount after resume. Captured between a
> client that hibernated and its server (Linux 7.0 client, 6.12 server):
>
>   - 05:06:02 last exchange before the snapshot; client snd_nxt
>     2711544997.
>   - 05:06:15 hibernation entry.
>   - 05:06:44 and 05:07:48, after the snapshot: a lease-renewal
>     SEQUENCE on slot 0 (seqid 192219), the next (192220), and
>     DELEGRETURNs on slots 1-5. The server executes all of them and
>     acknowledges up to TCP sequence 2711546645.
>   - 14 hours later, on resume: the client retransmits the slot 0
>     SEQUENCE from TCP sequence 2711544997. The server discards it as a
>     duplicate and acknowledges 2711546645, which the client ignores as
>     acknowledging unsent data. Nothing more crosses the connection.
>   - On reconnecting, slot 0 gets NFS4ERR_SEQ_MISORDERED (server at
>     192220, client at 192219) every 15 seconds indefinitely; the state
>     manager waits in nfs4_begin_drain_session() for that task, and
>     every other RPC waits behind it.
>
> Other resumes produced the same rollback with different symptoms:
> requests accepted by the server's TCP but never reaching nfsd, or a
> partial overlap that left nfsd reading a session ID as a record marker
> ("svc_tcp_read_marker nfsd RPC fragment too large"). Restarting the
> server is the only recovery.
>
> Make both workqueues freezable, as the SMB client already does for all
> of its workqueues (WQ_FREEZABLE | WQ_MEM_RECLAIM). Work queued while
> frozen runs after thaw_processes(), in the restored kernel, which is
> consistent with the server. Memory preallocation for the image happens
> before freeze_kernel_threads(), so writeback through rpciod is still
> available then, and pm_restrict_gfp_mask() keeps reclaim from issuing
> I/O while the image is written.
>
> WQ_FREEZABLE is consulted only when freezing and thawing, not when work
> is queued or run, so normal operation is unaffected. Entering system
> sleep now waits for in-flight rpciod and xprtiod items to finish; these
> are short state-machine steps with non-blocking sends and connects. If
> one ever blocked for longer than freeze_timeout_msecs, suspend or
> hibernation would fail, naming the busy workqueue, where today it
> proceeds. The SMB client and XFS accept the same trade-off for their
> reclaim workqueues.
>
> This does not stop the network stack from acknowledging data the
> server sends after the snapshot, such as a callback or a reply to a
> request still in flight when the snapshot was taken; that remains
> a general hibernation and TCP problem.
>
> No Fixes: tag: rpciod has never been freezable, so no single commit
> introduced this.

Can you take a human editing-pass over this commit message, please? Try
to really focus it on what this patch does and why it is important. The
"No Fixes: tag:" part really sticks out to me as an unnecessary addition,
and the testing stuff (below) should be in the cover letter and not the
patch itself.

>
> Tested in QEMU/KVM: an NFSv4.2 client hibernating in test_resume mode
> (the image is written, then restored at once) against a 7.4-rc2 nfsd
> with a 10 second lease, with 1.2 GB of incompressible data in memory and
> the swap device throttled so that writing the image takes 81 seconds.
> Without this patch the server received 12 SEQUENCE renewals during the
> image write, none of which the restored client knew of; after the
> restore the client's mountstats show a SEQUENCE error, two extra
> connections and 10 seconds of queueing before it recovered. With this
> series the server received nothing from the snapshot until the restore,
> and the client resumed without errors. The indefinite hang seen on real
> hardware was not reproduced in the VM: it also needs a request holding
> a session slot across the restore.
>
> Drafted with an AI coding assistant (Claude), which analysed the packet
> capture, wrote the change and this description, and ran the test above.
>
> Signed-off-by: Andrew Pam <andrew@sericyb.com.au>
> ---
>  net/sunrpc/sched.c | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index 016f16ca5779..41f25309b8fb 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -1276,13 +1276,18 @@ static int rpciod_start(void)
>  	struct workqueue_struct *wq;
> 
>  	/*
> -	 * Create the rpciod thread and wait for it to start.
> +	 * Both workqueues are freezable so that no RPC is transmitted, and
> +	 * no connection is made, between taking a hibernation snapshot and
> +	 * powering off. Anything sent then changes the server's state but is
> +	 * missing from the image, and is forgotten when the image is restored.

Let's leave the original comment alone, please.

>  	 */
> -	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
> +	wq = alloc_workqueue("rpciod",
> +			     WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_FREEZABLE, 0);

Note that this change is going to conflict with Chuck's "NFS: Set WQ_SYSFS on nfsiod"
patch that I'm expecting to go into v7.5:  https://lore.kernel.org/linux-nfs/20260915-performance-v3-3-ae26d460bfd3@kernel.org/

Thanks,
Anna

>  	if (!wq)
>  		goto out_failed;
>  	rpciod_workqueue = wq;
> -	wq = alloc_workqueue("xprtiod", WQ_UNBOUND | WQ_MEM_RECLAIM, 0);
> +	wq = alloc_workqueue("xprtiod",
> +			     WQ_UNBOUND | WQ_MEM_RECLAIM | WQ_FREEZABLE, 0);
>  	if (!wq)
>  		goto free_rpciod;
>  	xprtiod_workqueue = wq;
> -- 
> 2.53.0
