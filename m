From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 13/15] SUNRPC: RPC buffer size estimates are too
	large
Date: Wed, 24 Jan 2007 15:37:39 -0500
Message-ID: <20070124203739.GA6587@fieldses.org>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
	<20070124192020.31133.78494.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9osP-0000dZ-Si
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 12:37:50 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9osQ-0002AY-E9
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 12:37:51 -0800
In-Reply-To: <20070124192020.31133.78494.stgit@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, Jan 24, 2007 at 02:20:20PM -0500, Chuck Lever wrote:
> @@ -753,25 +751,39 @@ call_reserveresult(struct rpc_task *task
>  static void
>  call_allocate(struct rpc_task *task)
>  {
> +	unsigned int slack = task->tk_auth->au_cslack;
>  	struct rpc_rqst *req = task->tk_rqstp;
>  	struct rpc_xprt *xprt = task->tk_xprt;
> -	unsigned int	bufsiz;
> +	struct rpc_procinfo *proc = task->tk_msg.rpc_proc;
>  
>  	dprint_status(task);
>  
> +	task->tk_status = 0;
>  	task->tk_action = call_bind;
> +
>  	if (req->rq_buffer)
>  		return;
>  
> -	/* FIXME: compute buffer requirements more exactly using
> -	 * auth->au_wslack */
> -	bufsiz = task->tk_msg.rpc_proc->p_bufsiz + RPC_SLACK_SPACE;
> +	if (proc->p_proc != 0) {
> +		BUG_ON(proc->p_arglen == 0);
> +		if (proc->p_decode != NULL)
> +			BUG_ON(proc->p_replen == 0);
> +	}
>  
> -	req->rq_buffer = xprt->ops->buf_alloc(task, bufsiz << 1);
> -	if (req->rq_buffer != NULL) {
> -		req->rq_bufsize = bufsiz;
> +	/*
> +	 * Calculate the size (in quads) of the RPC call
> +	 * and reply headers, and convert both values
> +	 * to byte sizes.
> +	 */
> + 	req->rq_callsize = RPC_CALLHDRSIZE + (slack << 1) + proc->p_arglen;
> + 	req->rq_callsize <<= 2;
> + 	req->rq_rcvsize = RPC_REPHDRSIZE + slack + proc->p_replen;
> + 	req->rq_rcvsize <<= 2;

What happened to rslack?  The callsize calculation should be using
cslack and the rcvsize calculation rslack, I think, right?

In the krb5p case there's an extra annoyance: rslack is used to decide
where to expect page data to start, so it can only take into account
extra space needed at the beginning.  But krb5p has to add padding, for
example, to the end of each request.

We could deal with that by setting rslack high enough to take into
account the padding at the end, and then shifting the data back as we
decode, to ensure that the start of the plaintext page data ends up
exactly where rslack would predict it should.

Currently, though, the krb5p code just decrypts in place, and it might
take a little work to get it to do the simultaneous moving and decoding.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
