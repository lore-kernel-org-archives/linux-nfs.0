From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH RFC 03/10] nfsd41: sunrpc: move struct rpc_buffer def
 into a common header file
Date: Tue, 25 Aug 2009 11:43:52 +0300
Message-ID: <4A93A448.3030405@panasas.com>
References: <4A8C9992.2000505@panasas.com> <1250728468-28544-1-git-send-email-bhalevy@panasas.com> <20090824233526.GF8532@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-67.z220-152-67.customer.algx.net ([67.152.220.67]:25711
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751118AbZHYInw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2009 04:43:52 -0400
In-Reply-To: <20090824233526.GF8532@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 25, 2009, 2:35 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Thu, Aug 20, 2009 at 03:34:28AM +0300, Benny Halevy wrote:
>> struct rpc_buffer is currently defined twice, the same way, in sched.c
>> and xprtsock.c.  Move its definition into a sunrpc.h, a common, internal
>> header file.
> 
> Not a huge deal, but: ideally this move would be done before the
> previous patch, which would use it.  (Under the general principal when
> we have the chance, we we anticipate problems rather than introduce them
> and then solve them in a later patch.)

Absolutely. Will do.

Benny

> 
> --b.
> 
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  net/sunrpc/sched.c    |    7 ++-----
>>  net/sunrpc/sunrpc.h   |    8 ++++++++
>>  net/sunrpc/xprtsock.c |    4 ----
>>  3 files changed, 10 insertions(+), 9 deletions(-)
>>
>> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>> index 8f459ab..cef74ba 100644
>> --- a/net/sunrpc/sched.c
>> +++ b/net/sunrpc/sched.c
>> @@ -21,6 +21,8 @@
>>  
>>  #include <linux/sunrpc/clnt.h>
>>  
>> +#include "sunrpc.h"
>> +
>>  #ifdef RPC_DEBUG
>>  #define RPCDBG_FACILITY		RPCDBG_SCHED
>>  #define RPC_TASK_MAGIC_ID	0xf00baa
>> @@ -711,11 +713,6 @@ static void rpc_async_schedule(struct work_struct *work)
>>  	__rpc_execute(container_of(work, struct rpc_task, u.tk_work));
>>  }
>>  
>> -struct rpc_buffer {
>> -	size_t	len;
>> -	char	data[];
>> -};
>> -
>>  /**
>>   * rpc_malloc - allocate an RPC buffer
>>   * @task: RPC task that will use this buffer
>> diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
>> index b1b2e64..7b68daf 100644
>> --- a/net/sunrpc/sunrpc.h
>> +++ b/net/sunrpc/sunrpc.h
>> @@ -27,6 +27,14 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
>>  #ifndef _NET_SUNRPC_SUNRPC_H
>>  #define _NET_SUNRPC_SUNRPC_H
>>  
>> +/*
>> + * Header for dynamically allocated rpc buffers.
>> + */
>> +struct rpc_buffer {
>> +	size_t	len;
>> +	char	data[];
>> +};
>> +
>>  static inline int rpc_reply_expected(struct rpc_task *task)
>>  {
>>  	return (task->tk_msg.rpc_proc != NULL) &&
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index 6e6f939..4098a92 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -2158,10 +2158,6 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
>>  			xprt->stat.bklog_u);
>>  }
>>  
>> -struct rpc_buffer {
>> -	size_t	len;
>> -	char	data[];
>> -};
>>  /*
>>   * Allocate a bunch of pages for a scratch buffer for the rpc code. The reason
>>   * we allocate pages instead doing a kmalloc like rpc_malloc is because we want
>> -- 
>> 1.6.4
>>
