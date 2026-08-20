Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6595E37FF61
	for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2026 18:59:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787252382; cv=none; b=Yv7e4dgIgET9CR+mNZkRKGngUb5zUGcnLoiZVBnbXTLxMElajl1n8r+od5HVZ8GrvQTdaF868c63foDKNWAkSpAT8U0jvL/eUbbSF5X/vPnOuXv5WVVqKzwHm6nNP2MElJJUnblAZeHbJkNj6KsAOk86OKdl7MoCtknF7Ii9iKU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787252382; c=relaxed/simple;
	bh=EaMtHokgTmQKzCm8bbjmnm3WJq0vfvTXE3GVGeZBbPc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=BhpEaBHVFTFPfjXUXpjkyBG9Ic2xa8UaVsJxA0zA5qkRvCcC1g+FfcOdXqAtVCKHqZu+jH04qtiAoD+OKmFV9K/8zH9CPsn+oPZOHyWKXX2bGCDkELUhJHcwl69NLJu9ZZnrdcjiIPbDqPKT0KoZLEl3utvNiD3y5PuJObiFR2I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=JUjUnTSK; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=TO+BT3JY; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=z9HvdeHS; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=6V0beoU6; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="JUjUnTSK";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="TO+BT3JY";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="z9HvdeHS";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="6V0beoU6"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 0BA053F1B;
	Thu, 20 Aug 2026 18:59:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1787252374;
	h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
	 cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=upzIzz6N6x4btw1CkO1HRk7IhNwv/O+gj33sRLG5uKU=;
	b=JUjUnTSKt1nKI0E+iNQoScPkeYDrj5Xy0gLkgvGvonw8LiIGsu/XViYDpLhrC3SAcH0xBo
	Dbc8sYfaSLmAFzWaBACE7RBrqMmjg0n8c7Slte2R4EmWDWx465tDaJ+FvhBGmGcRhEQIcP
	Ppbh1OQ7ucnh7qgULU/1Cx/yHezzcpc=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1787252374;
	h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
	 cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=upzIzz6N6x4btw1CkO1HRk7IhNwv/O+gj33sRLG5uKU=;
	b=TO+BT3JYJqj/R0P0NUGTsyyb9uQYSVydr43zPKzwzP2taUhqQrWiogOQzYV1AuTN9GspdV
	Ys7Bg5gk7sIyytBg==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1787252370;
	h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
	 cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=upzIzz6N6x4btw1CkO1HRk7IhNwv/O+gj33sRLG5uKU=;
	b=z9HvdeHSzxy0gRM2qBXQH1Lk+8BtgBBtVH18EujOdBwwo6SeVsutzckxowA0HB1hEGhbsC
	zS9sJDYC2vORZmlUN4puaT9GOnXLbf44yqeprZwpIWIlpiq/ZhBlLtwKMJDjA2kOI27cws
	rZrKW7aspVeE5NOn1HrStw5o9ofCukQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1787252370;
	h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
	 cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=upzIzz6N6x4btw1CkO1HRk7IhNwv/O+gj33sRLG5uKU=;
	b=6V0beoU6uM+2qgDZZ1DzD+MAMuEaMPyLJDsp5lKG4/agAdM9lUPrCeBFNN4rNolHsUKACb
	u4/dvptU4DVPtsDQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 22ACC27A8;
	Thu, 20 Aug 2026 18:59:29 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id rQ5yBJFOh2r3cwAAD6G6ig
	(envelope-from <pvorel@suse.cz>); Thu, 20 Aug 2026 18:59:29 +0000
Date: Thu, 20 Aug 2026 20:59:22 +0200
From: Petr Vorel <pvorel@suse.cz>
To: manjunath.b.patil@oracle.com
Cc: Dai.Ngo@oracle.com, anna@kernel.org, cel@kernel.org, jlayton@kernel.org,
	linux-nfs@vger.kernel.org, neil@brown.name, okorniev@redhat.com,
	tom@talpey.com, trondmy@kernel.org
Subject: Re: [PATCH] SUNRPC: add transport details to timeout diagnostics
Message-ID: <20260820185922.GA511595@pevik>
Reply-To: Petr Vorel <pvorel@suse.cz>
References: <20260819173055.1956882-1-manjunath.b.patil@oracle.com>
 <20260820111303.455807-1-pvorel@suse.cz>
 <8e43238e-f06d-4da1-a898-2bdc1d827e81@oracle.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8e43238e-f06d-4da1-a898-2bdc1d827e81@oracle.com>
X-Spamd-Result: default: False [-3.50 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	HAS_REPLYTO(0.30)[pvorel@suse.cz];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	RCVD_TLS_ALL(0.00)[];
	ARC_NA(0.00)[];
	MISSING_XM_UA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	MIME_TRACE(0.00)[0:+];
	RCPT_COUNT_SEVEN(0.00)[10];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	FROM_HAS_DN(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[oracle.com:email,imap1.dmz-prg2.suse.org:helo];
	FROM_EQ_ENVFROM(0.00)[];
	TO_DN_NONE(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	REPLYTO_EQ_FROM(0.00)[]
X-Spam-Flag: NO
X-Spam-Score: -3.50
X-Spam-Level: 



> On 8/20/26 4:13 AM, Petr Vorel wrote:
> >  > The existing RPC timeout messages identify only the RPC program and >
> > server name. That makes it difficult to distinguish a server-side >
> > response stall from a transport that is disconnected, reconnecting, > or
> > using a different


> > > The existing RPC timeout messages identify only the RPC program and
> > > server name. That makes it difficult to distinguish a server-side
> > > response stall from a transport that is disconnected, reconnecting,
> > > or using a different connection.

> > > Include the RPC client id, transport id, current transport connection
> > > cookie, and RPC task owner in the ratelimited timeout messages. These
> > > fields provide a compact way to correlate a timeout message with
> > > rpcctl and other transport state.

> > > For example, an NFS timeout reports:

> > >   nfs: server 192.168.50.1 clid=4 xprt=1 cc=1 owner=6245
> > >   not responding, timed out

> > Nice improvement, thanks!


> > > Assisted-by: Codex:gpt-5
> > > Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
> > > ---
> > >  net/sunrpc/clnt.c | 20 +++++++++++++-------
> > >  1 file changed, 13 insertions(+), 7 deletions(-)

> > > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> > > index efa26899bc7d..6b5e2787dc81 100644
> > > --- a/net/sunrpc/clnt.c
> > > +++ b/net/sunrpc/clnt.c
> > > @@ -2534,17 +2534,21 @@ static void
> > >  rpc_check_timeout(struct rpc_task *task)
> > >  {
> > >  	struct rpc_clnt	*clnt = task->tk_client;
> > > +	struct rpc_rqst	*req;
> > > +	struct rpc_xprt	*xprt;

> > nit: Would it work to assign req and task earlier (just readability?)
> > Or is it not safe before checking RPC_SIGNALLED(task)?

> > 	struct rpc_clnt	*clnt = task->tk_client;
> > 	struct rpc_rqst	*req = task->tk_rqstp;
> > 	struct rpc_xprt	*xprt = req->rq_xprt;

> > The rest LGTM.
> > Reviewed-by: Petr Vorel <pvorel@suse.cz>

> > Kind regards,
> > Petr

> Hi Petr,

Hi Manjunath,

> Thanks for the review and the Reviewed-by tag.

yw.

> I kept the assignments after RPC_SIGNALLED(task) intentionally, preserving
> the existing behavior where a signalled task returns before we dereference
> task->tk_rqstp. xprt is also needed only after xprt_adjust_timeout(req)
> reports an expired timeout.

Understand, fair enough.

> I would prefer to retain the current ordering for those reasons. Also I am
> open if maintainers chose to alter it.

+1

Kind regards,
Petr

> Thanks,                   Manjunath


> > >  	if (RPC_SIGNALLED(task))
> > >  		return;
> > > -	if (xprt_adjust_timeout(task->tk_rqstp) == 0)
> > > +	req = task->tk_rqstp;
> > > +	if (xprt_adjust_timeout(req) == 0)
> > >  		return;
> > > +	xprt = req->rq_xprt;
> > >  	trace_rpc_timeout_status(task);
> > >  	task->tk_timeouts++;
> > > -	if (RPC_IS_SOFTCONN(task) && !rpc_check_connected(task->tk_rqstp)) {
> > > +	if (RPC_IS_SOFTCONN(task) && !rpc_check_connected(req)) {
> > >  		rpc_call_rpcerror(task, -ETIMEDOUT);
> > >  		return;
> > >  	}
> > > @@ -2556,14 +2560,15 @@ rpc_check_timeout(struct rpc_task *task)
> > >  		 * connection gets terminally broken.
> > >  		 */
> > >  		if ((task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT) &&
> > > -		    rpc_check_connected(task->tk_rqstp))
> > > +		    rpc_check_connected(req))
> > >  			return;
> > >  		if (clnt->cl_chatty) {
> > >  			pr_notice_ratelimited(
> > > -				"%s: server %s not responding, timed out\n",
> > > +				"%s: server %s clid=%u xprt=%u cc=%u owner=%d not responding, timed out\n",
> > >  				clnt->cl_program->name,
> > > -				task->tk_xprt->servername);
> > > +				xprt->servername, clnt->cl_clid, xprt->id,
> > > +				READ_ONCE(xprt->connect_cookie), task->tk_owner);
> > >  		}
> > >  		if (task->tk_flags & RPC_TASK_TIMEOUT)
> > >  			rpc_call_rpcerror(task, -ETIMEDOUT);
> > > @@ -2576,9 +2581,10 @@ rpc_check_timeout(struct rpc_task *task)
> > >  		task->tk_flags |= RPC_CALL_MAJORSEEN;
> > >  		if (clnt->cl_chatty) {
> > >  			pr_notice_ratelimited(
> > > -				"%s: server %s not responding, still trying\n",
> > > +				"%s: server %s clid=%u xprt=%u cc=%u owner=%d not responding, still trying\n",
> > >  				clnt->cl_program->name,
> > > -				task->tk_xprt->servername);
> > > +				xprt->servername, clnt->cl_clid, xprt->id,
> > > +				READ_ONCE(xprt->connect_cookie), task->tk_owner);
> > >  		}
> > >  	}
> > >  	rpc_force_rebind(clnt);


