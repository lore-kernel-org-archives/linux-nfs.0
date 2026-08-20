Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CDC5741A571
	for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2026 11:13:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787224401; cv=none; b=crve+LXNPOtdDKC5SF7SFoXSDfNUmBwfLdboYK/Dh0qoAfLjjfjn3NW0lE7bvy8nrg5I2szRK3/gUgdsLctQH5QgyI5gmqdMVEMtFM4E4ClCqpQ/x+0qJ8q5PXaCNLVSUv3/bSbzrBm5GkY/I0HmNlYStvlp7TdZrF10dGS4/ow=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787224401; c=relaxed/simple;
	bh=AH0W0dIv9a2G/YfO0yb1oW+E9pE+xdIfYA9m8/sAGRg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=DLbSMve5YDcrYZ6gdvdSampKsirJFoxbIRMpCi7lmuDn5iQxlH67jUVrAvkiHKBaAXS7a7ZDWm2+alK8eS9Qg+gJK0RiaJSDZTj+jcyu7TlfvPDIHIbUYfA6GVBZmpVPfgyzfdGriPS1YscrLWUXaWqI/D3x+UbV8aez+JT+A98=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=akkCT59m; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=oB5yyMOW; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=iOHhsdYV; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=07ybdQ6Y; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="akkCT59m";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="oB5yyMOW";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="iOHhsdYV";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="07ybdQ6Y"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 8C1463EB1;
	Thu, 20 Aug 2026 11:13:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1787224393; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=iVaN6m5iaPE2/RcaUDlaQ+2EeNF4oLr697qmspXVpUg=;
	b=akkCT59mGsY4Mjq5GmkParKBlCdYqwTqKuDEQrG0XDP6QS6M3QAKOkpbfASww0d0aGNdn4
	lwmfYzJqb0fH2R+o+CmCRx8PpQK9jAIvTcekT4xRi13wdm5FCuUxIszaNKvCAbTUOPbVi9
	vPqbbAy3BDKkWuwWsi0oGGdL7IbJ+ic=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1787224393;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=iVaN6m5iaPE2/RcaUDlaQ+2EeNF4oLr697qmspXVpUg=;
	b=oB5yyMOWFZtCeD0br6kq1AXlptl2ciiGdYMHhz4xA27r/qX+dNCvqonKHKAkRlWdvdtxnY
	XEsdo34YRYT/Y0DQ==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1787224389; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=iVaN6m5iaPE2/RcaUDlaQ+2EeNF4oLr697qmspXVpUg=;
	b=iOHhsdYV+Ucgs1GeOsXFfOiRvLurm8MtonWMo376DHR1mEFVsEQ2UVsjwhu6xX36nAW9Nc
	//e5s8Rdc0PljntdWAEnWgffcCbDTipHQy8ma9ieW7HvmfeBxvGfo5d7X7RITNTcdUtm0H
	xVm0j91r/lbFBGp8rzm2MmFFpgubwTE=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1787224389;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=iVaN6m5iaPE2/RcaUDlaQ+2EeNF4oLr697qmspXVpUg=;
	b=07ybdQ6Y9iRCxOzSSfQRAo21SEDVbW15aHETNvs1Ds5zBiPdH1OHTMLGXCZe1NcnzlMlmM
	BbjwVacFvUtbthAQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 99ED327A8;
	Thu, 20 Aug 2026 11:13:08 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id ZnRQJEThhmrsKwAAD6G6ig
	(envelope-from <pvorel@suse.cz>); Thu, 20 Aug 2026 11:13:08 +0000
From: Petr Vorel <pvorel@suse.cz>
To: manjunath.b.patil@oracle.com
Cc: Dai.Ngo@oracle.com,
	anna@kernel.org,
	cel@kernel.org,
	jlayton@kernel.org,
	linux-nfs@vger.kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	tom@talpey.com,
	trondmy@kernel.org,
	Petr Vorel <pvorel@suse.cz>
Subject: [PATCH] SUNRPC: add transport details to timeout diagnostics
Date: Thu, 20 Aug 2026 13:13:03 +0200
Message-ID: <20260820111303.455807-1-pvorel@suse.cz>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260819173055.1956882-1-manjunath.b.patil@oracle.com>
References: <20260819173055.1956882-1-manjunath.b.patil@oracle.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Spamd-Result: default: False [-2.80 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	MID_CONTAINS_FROM(1.00)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	R_MISSING_CHARSET(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-0.997];
	MIME_GOOD(-0.10)[text/plain];
	RCPT_COUNT_SEVEN(0.00)[11];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[oracle.com:email,imap1.dmz-prg2.suse.org:helo,suse.cz:mid,suse.cz:email];
	RCVD_COUNT_TWO(0.00)[2];
	RCVD_TLS_ALL(0.00)[]
X-Spam-Flag: NO
X-Spam-Score: -2.80
X-Spam-Level: 

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

Nice improvement, thanks!

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

nit: Would it work to assign req and task earlier (just readability?)
Or is it not safe before checking RPC_SIGNALLED(task)?

	struct rpc_clnt	*clnt = task->tk_client;
	struct rpc_rqst	*req = task->tk_rqstp;
	struct rpc_xprt	*xprt = req->rq_xprt;

The rest LGTM.
Reviewed-by: Petr Vorel <pvorel@suse.cz>

Kind regards,
Petr


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
> +				"%s: server %s clid=%u xprt=%u cc=%u owner=%d not responding, timed out\n",
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
> +				"%s: server %s clid=%u xprt=%u cc=%u owner=%d not responding, still trying\n",
>  				clnt->cl_program->name,
> -				task->tk_xprt->servername);
> +				xprt->servername, clnt->cl_clid, xprt->id,
> +				READ_ONCE(xprt->connect_cookie), task->tk_owner);
>  		}
>  	}
>  	rpc_force_rebind(clnt);
