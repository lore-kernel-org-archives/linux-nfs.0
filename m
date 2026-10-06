Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 653BD3C0A0E
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 21:23:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791321840; cv=none; b=LLmr1e/foCfhGMpQp15vYZXCnIKBygD++KNIX38qZRssO2nHKZYj7Mca4RNelFj9QqAWk26PSkx/YdHbXmif1WV2Q6G/EsR58szAG7eS+bjd7ku5w29Aq8Nd6BZraGo+FZOl9m1UP3MBZMMYzbt/JpcmnedGX+ef8G640Qiw3io=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791321840; c=relaxed/simple;
	bh=z5pPBWStISMaENokrkQFhDnzSdAReUpYk74mhPd7gIE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=iiBy9uKrdS9YzgwVeRHhQIxBDEHb+oYkzu5YLtbbLe8WOVnv3bENaoRYgNDg4QL609h1Bv8FIsu+drX4Hz9fjO/ya5XIPlYuLKj9yg2KCNn0rP/uMfHAw59r1dxWPs8AlYmIey8Qli1buJrUE3mW+tlvTaj72a93f0ZjEraqfSI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lerCCNgE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lerCCNgE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AFF6F1F0089B;
	Tue,  6 Oct 2026 21:23:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791321839;
	bh=lbdRhrD1QzSQSV1dSwqzJ+i12X19SvUtcVKeYZ4LK6s=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=lerCCNgEnHnBHY1vfOSlCUcF7q6Y2vtwMiSytaJJwJKQyEDUnQWnZQuSoKUcaN6k2
	 55kkhf7Asd7myLl2/8OHTUMDqb1dF17G2tWnDc4AxhG1Vnk/TrIurpeTD/cmM7jlpo
	 NnbTryx9WogSBR9QSCyunippOVSUKBi0ZwCmcy5uCV582hgrpvZ2/pn43HKOo64eSf
	 Vz2WKi8tzLK7jZ8wjD5GE0mJ4I/iioOr06C6gTHssrhfRPty3ScKDrgjr5Mj9QUc2w
	 dEuGDylbzoIgfzNHfWbuOKNpB4u6IT1zMnRgHJloTs+ah/+jkW9pGzR1KkJQoYNC8T
	 4W4+vEfHKDCGg==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id E249EF40068;
	Tue,  6 Oct 2026 17:23:57 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 06 Oct 2026 17:23:57 -0400
X-ME-Sender: <xms:7WbFasLBFTz6_AfQvZx5kea7sDhzSxDa7j_rg1yaBQKpR0QFZZO-vg>
    <xme:7WbFam-fvtc0MUbmc09ZBXthfrv3jpWrQgGBVwAwXFCJkV7-iQ6qGvNVqTTemL3f-
    8DO7B96I3prcLk-YuAJ1sH9ESKPiN8HhCnwXezvn615oe-6rT8UddkA>
X-ME-Proxy-Cause: dmFkZTFNyJ6f9mKMnX6jb7Y6xPOiaDRd1EqORygMJpk8PxW420JCT4dd+KtZ62a6vTF6c3
    6jdAMn5n3njXHhuoJpdasQCVDiIN/3OPXNMSV7be5pVxutHtE00VcHAIQtj069Q71kodUd
    LbQDPWKeaE2lS1q1Ay5DW5rrUXGhQBXs+OmXKS4e4e9z0p6pX6G51b6XECfXVD9S2QgR9n
    INlRAguu4HaEQeuoQAq4zwTqunmMHmeipqM1SAxNXOnOOENDqPjfdVl1tMW8T6ajVdNxn2
    KbEg/q60MUu524TA4k0mmnSlsCOtkOITBGL6BV3rP9r7xNOio8Pczrg6886VWKEOmZdnoA
    lhOiZYGlSoAqq74XbvuXDpZ+6FXAHyY520497Kn30mpDdVtcivYumQicm7RTNk+G3KvenH
    a1Es5RWPUwLowDJV7cIZCEs760YLL8Ethx55CX2H4VbdRQX4FwBMRhBEOx0CDrGQRlvvxI
    RfomreUeg14XhCi9UrrWOgynT887i61lDkUxx27/j4aeeHDeCp2fO7Q0hwyZdiVEk7jtiK
    nlmrm2qGpZziI4+dKwlmR5PiC+UoSvxtn195PZIBvvxo+3GtHc5TUu+K1rclTb7+8ORnwO
    N+6uVMQMcEDj21KnDgDehRWvwxl0d+4dnRdWEIstL5FuwYz0F5msy4Zxer/g
X-ME-Proxy: <xmx:7WbFalEqShAXQADKzuiptA6fR6Fwxhsed7RMmUi2cF1ST8sA7KWlvg>
    <xmx:7WbFavR_0d8NexXkjU-AmOS3VcALJwEzrsL9_DF2cEUceLhui1vMLw>
    <xmx:7WbFarbimJMsZQ4iTpTdIIF4O9RtvvIEeg9EmW2Sk31yCg7Akr3wOQ>
    <xmx:7WbFaq3BMRnjrUw1wCCZNZ67pPhXCOiW1WveMKJQlSBwLtbZeY4UsQ>
    <xmx:7WbFaurgs8jevCqLI9wJ51rY-XWj-SNxMImgwsqXay6YriaxaGzUOdSQ>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C186AB6006F; Tue,  6 Oct 2026 17:23:57 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AQUtHn2Yp4ZR
Date: Tue, 06 Oct 2026 17:23:37 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Manjunath Patil" <manjunath.b.patil@oracle.com>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org, "Chuck Lever" <cel@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Message-Id: <6213dd5a-ec6d-46b8-962a-53f05db796ca@app.fastmail.com>
In-Reply-To: <20260819173055.1956882-1-manjunath.b.patil@oracle.com>
References: <20260819173055.1956882-1-manjunath.b.patil@oracle.com>
Subject: Re: [PATCH] SUNRPC: add transport details to timeout diagnostics
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Manjunath,

On Wed, Aug 19, 2026, at 1:30 PM, Manjunath Patil wrote:
> The existing RPC timeout messages identify only the RPC program and
> server name. That makes it difficult to distinguish a server-side
> response stall from a transport that is disconnected, reconnecting,
> or using a different connection.
>
> Include the RPC client id, transport id, current transport connection
> cookie, and RPC task owner in the ratelimited timeout messages. These
> fields provide a compact way to correlate a timeout message with
> rpcctl and other transport state.
>
> For example, an NFS timeout reports:
>
>   nfs: server 192.168.50.1 clid=4 xprt=1 cc=1 owner=6245
>   not responding, timed out
>
> Assisted-by: Codex:gpt-5
> Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
> ---
>  net/sunrpc/clnt.c | 20 +++++++++++++-------
>  1 file changed, 13 insertions(+), 7 deletions(-)
>
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index efa26899bc7d..6b5e2787dc81 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -2534,17 +2534,21 @@ static void
>  rpc_check_timeout(struct rpc_task *task)
>  {
>  	struct rpc_clnt	*clnt = task->tk_client;
> +	struct rpc_rqst	*req;
> +	struct rpc_xprt	*xprt;
> 
>  	if (RPC_SIGNALLED(task))
>  		return;
> 
> -	if (xprt_adjust_timeout(task->tk_rqstp) == 0)
> +	req = task->tk_rqstp;
> +	if (xprt_adjust_timeout(req) == 0)
>  		return;
> +	xprt = req->rq_xprt;
> 
>  	trace_rpc_timeout_status(task);
>  	task->tk_timeouts++;
> 
> -	if (RPC_IS_SOFTCONN(task) && !rpc_check_connected(task->tk_rqstp)) {
> +	if (RPC_IS_SOFTCONN(task) && !rpc_check_connected(req)) {
>  		rpc_call_rpcerror(task, -ETIMEDOUT);
>  		return;
>  	}
> @@ -2556,14 +2560,15 @@ rpc_check_timeout(struct rpc_task *task)
>  		 * connection gets terminally broken.
>  		 */
>  		if ((task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT) &&
> -		    rpc_check_connected(task->tk_rqstp))
> +		    rpc_check_connected(req))
>  			return;
> 
>  		if (clnt->cl_chatty) {
>  			pr_notice_ratelimited(
> -				"%s: server %s not responding, timed out\n",
> +				"%s: server %s clid=%u xprt=%u cc=%u owner=%d not responding, 
> timed out\n",
>  				clnt->cl_program->name,
> -				task->tk_xprt->servername);
> +				xprt->servername, clnt->cl_clid, xprt->id,
> +				READ_ONCE(xprt->connect_cookie), task->tk_owner);
>  		}
>  		if (task->tk_flags & RPC_TASK_TIMEOUT)
>  			rpc_call_rpcerror(task, -ETIMEDOUT);
> @@ -2576,9 +2581,10 @@ rpc_check_timeout(struct rpc_task *task)
>  		task->tk_flags |= RPC_CALL_MAJORSEEN;
>  		if (clnt->cl_chatty) {
>  			pr_notice_ratelimited(
> -				"%s: server %s not responding, still trying\n",
> +				"%s: server %s clid=%u xprt=%u cc=%u owner=%d not responding, 
> still trying\n",

More observability around this makes sense. Any reason you're adding to the notice
here and not making it a new tracepoint for the extra information? I'm worried
people might have tooling around watching for unresponsive servers and this
might break whatever regexes they're using to look for this.

Anna

>  				clnt->cl_program->name,
> -				task->tk_xprt->servername);
> +				xprt->servername, clnt->cl_clid, xprt->id,
> +				READ_ONCE(xprt->connect_cookie), task->tk_owner);
>  		}
>  	}
>  	rpc_force_rebind(clnt);
> -- 
> 2.47.3
