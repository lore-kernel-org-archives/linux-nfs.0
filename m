From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] net: fix htmldocs sunrpc, clnt.c
Date: Thu, 24 Sep 2009 19:46:06 +0300
Message-ID: <4ABBA24E.7090709@panasas.com>
References: <1253794781.5860.29.camel@ht.satnam> <4ABB9C17.3020307@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Andy Adamson <andros@netapp.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	David Miller <davem@davemloft.net>, linux-nfs@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>,
	Jaswinder Singh Rajput <jaswinder@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753067AbZIXQqJ@vger.kernel.org>
In-Reply-To: <4ABB9C17.3020307@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep. 24, 2009, 19:19 +0300, Randy Dunlap <randy.dunlap@oracle.com> wrote:
> Jaswinder Singh Rajput wrote:
>>   DOCPROC Documentation/DocBook/networking.xml
>>   Warning(net/sunrpc/clnt.c:647): No description found for parameter 'req'
>>   Warning(net/sunrpc/clnt.c:647): No description found for parameter 'tk_ops'
>>   Warning(net/sunrpc/clnt.c:647): Excess function parameter 'ops' description in 'rpc_run_bc_task'
>>
>> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
> 
> Ack.  Already sent, but possibly lost.

Ack.  thanks!

> 
>> Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
>> Cc: Benny Halevy <bhalevy@panasas.com>
>> Cc: Andy Adamson <andros@netapp.com>
>> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Cc: Randy Dunlap <randy.dunlap@oracle.com>
>> Cc: David Miller <davem@davemloft.net>
>> ---
>>  net/sunrpc/clnt.c |    5 +++--
>>  1 files changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index a417d5a..38829e2 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -640,10 +640,11 @@ EXPORT_SYMBOL_GPL(rpc_call_async);
>>  /**
>>   * rpc_run_bc_task - Allocate a new RPC task for backchannel use, then run
>>   * rpc_execute against it
>> - * @ops: RPC call ops
>> + * @req: RPC request
>> + * @tk_ops: RPC call ops
>>   */
>>  struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req,
>> -					const struct rpc_call_ops *tk_ops)
>> +				const struct rpc_call_ops *tk_ops)
>>  {
>>  	struct rpc_task *task;
>>  	struct xdr_buf *xbufp = &req->rq_snd_buf;
> 
