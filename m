From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 13/15] SUNRPC: RPC buffer size estimates are too
 large
Date: Wed, 24 Jan 2007 15:41:38 -0500
Message-ID: <45B7C482.9090807@oracle.com>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
	<20070124192020.31133.78494.stgit@localhost.localdomain>
	<20070124203739.GA6587@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010906060107030203060503"
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9oy3-0001FU-2P
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 12:43:39 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9oy3-0008DP-Lv
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 12:43:41 -0800
In-Reply-To: <20070124203739.GA6587@fieldses.org>
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

This is a multi-part message in MIME format.
--------------010906060107030203060503
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Wed, Jan 24, 2007 at 02:20:20PM -0500, Chuck Lever wrote:
>> @@ -753,25 +751,39 @@ call_reserveresult(struct rpc_task *task
>>  static void
>>  call_allocate(struct rpc_task *task)
>>  {
>> +	unsigned int slack = task->tk_auth->au_cslack;
>>  	struct rpc_rqst *req = task->tk_rqstp;
>>  	struct rpc_xprt *xprt = task->tk_xprt;
>> -	unsigned int	bufsiz;
>> +	struct rpc_procinfo *proc = task->tk_msg.rpc_proc;
>>  
>>  	dprint_status(task);
>>  
>> +	task->tk_status = 0;
>>  	task->tk_action = call_bind;
>> +
>>  	if (req->rq_buffer)
>>  		return;
>>  
>> -	/* FIXME: compute buffer requirements more exactly using
>> -	 * auth->au_wslack */
>> -	bufsiz = task->tk_msg.rpc_proc->p_bufsiz + RPC_SLACK_SPACE;
>> +	if (proc->p_proc != 0) {
>> +		BUG_ON(proc->p_arglen == 0);
>> +		if (proc->p_decode != NULL)
>> +			BUG_ON(proc->p_replen == 0);
>> +	}
>>  
>> -	req->rq_buffer = xprt->ops->buf_alloc(task, bufsiz << 1);
>> -	if (req->rq_buffer != NULL) {
>> -		req->rq_bufsize = bufsiz;
>> +	/*
>> +	 * Calculate the size (in quads) of the RPC call
>> +	 * and reply headers, and convert both values
>> +	 * to byte sizes.
>> +	 */
>> + 	req->rq_callsize = RPC_CALLHDRSIZE + (slack << 1) + proc->p_arglen;
>> + 	req->rq_callsize <<= 2;
>> + 	req->rq_rcvsize = RPC_REPHDRSIZE + slack + proc->p_replen;
>> + 	req->rq_rcvsize <<= 2;
> 
> What happened to rslack?  The callsize calculation should be using
> cslack and the rcvsize calculation rslack, I think, right?

As far as I understood it, cslack is the size of the authentication 
verifier for that flavor.  Shouldn't that be the same for calls and replies?

> In the krb5p case there's an extra annoyance: rslack is used to decide
> where to expect page data to start, so it can only take into account
> extra space needed at the beginning.  But krb5p has to add padding, for
> example, to the end of each request.

That padding has to follow XDR rules, though, correct?

--------------010906060107030203060503
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture Linux Projects Group
email;internet:chuck dot lever at nospam oracle dot com
title:Principle Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------010906060107030203060503
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------010906060107030203060503
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010906060107030203060503--
