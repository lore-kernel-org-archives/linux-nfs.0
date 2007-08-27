From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/7] SUNRPC: Address a few compiler warnings in
 the RPC client
Date: Mon, 27 Aug 2007 15:15:26 -0400
Message-ID: <46D322CE.40002@oracle.com>
References: <20070827173013.23426.67897.stgit@monet.1015granger.net>
	<1188238002.6701.99.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090605060200090801060605"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPk4v-00065t-92
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 12:16:50 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPk4y-0008F5-CU
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 12:16:53 -0700
In-Reply-To: <1188238002.6701.99.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------090605060200090801060605
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index c796e2f..0ad3042 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -127,7 +127,7 @@ static struct rpc_clnt * rpc_new_client(struct rpc_xprt *xprt, char *servname, s
>>  	struct rpc_clnt		*clnt = NULL;
>>  	struct rpc_auth		*auth;
>>  	int err;
>> -	int len;
>> +	size_t len;
> 
> What if 'len' overflows when we do 'strlen() + 1'?

strlen() returns size_t, which is unsigned.  Thus the overflow would be 
zero.  Seems like that's a better outcome than what would happen today.

>>  	dprintk("RPC:       creating %s client for %s (xprt %p)\n",
>>  			program->name, servname, xprt);
>> @@ -436,7 +436,7 @@ rpc_release_client(struct rpc_clnt *clnt)
>>   */
>>  struct rpc_clnt *rpc_bind_new_program(struct rpc_clnt *old,
>>  				      struct rpc_program *program,
>> -				      int vers)
>> +				      unsigned int vers)
>>  {
>>  	struct rpc_clnt *clnt;
>>  	struct rpc_version *version;
>> @@ -1508,6 +1508,7 @@ void rpc_show_tasks(void)
>>  {
>>  	struct rpc_clnt *clnt;
>>  	struct rpc_task *t;
>> +	int proc = -1;
>>  
>>  	spin_lock(&rpc_client_lock);
>>  	if (list_empty(&all_clients))
>> @@ -1524,9 +1525,11 @@ void rpc_show_tasks(void)
>>  			if (RPC_IS_QUEUED(t))
>>  				rpc_waitq = rpc_qname(t->u.tk_wait.rpc_waitq);
>>  
>> +			if (t->tk_msg.rpc_proc)
>> +				proc = t->tk_msg.rpc_proc->p_proc;
>> +
>>  			printk("%5u %04d %04x %6d %8p %6d %8p %8ld %8s %8p %8p\n",
>> -				t->tk_pid,
>> -				(t->tk_msg.rpc_proc ? t->tk_msg.rpc_proc->p_proc : -1),
>> +				t->tk_pid, proc,
>>  				t->tk_flags, t->tk_status,
>>  				t->tk_client,
>>  				(t->tk_client ? t->tk_client->cl_prog : 0),
> 
> NACK. Look again at your change to rpc_show_tasks. What you are doing
> with your variable 'proc' is _not_ equivalent to the existing code: you
> need to reset proc to '-1' each time you go through the loop.

Noted and fixed.

--------------090605060200090801060605
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmU6IExpbnV4IFByb2plY3RzIEdy
b3VwDQphZHI6OzsxMDE1IEdyYW5nZXIgQXZlbnVlO0FubiBBcmJvcjtNSTs0ODEwNDtVU0EN
CnRpdGxlOlByaW5jaXBhbCBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0OCA2MTQg
NTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnVybDpodHRwOi8vb3NzLm9yYWNsZS5jb20v
fmNlbA0KdmVyc2lvbjoyLjENCmVuZDp2Y2FyZA0KDQo=
--------------090605060200090801060605
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------090605060200090801060605
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090605060200090801060605--
