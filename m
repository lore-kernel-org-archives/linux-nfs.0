From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 05/20] svc: xpt_max_payload
Date: Wed, 29 Aug 2007 14:06:16 -0500
Message-ID: <C2FB2DD8.3A88C%tom@opengridcomputing.com>
References: <46D5AF90.4040607@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQSkh-0001cW-BL
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 11:58:55 -0700
Received: from mail.es335.com ([67.65.19.105])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQSkj-0005Yj-JB
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 11:59:00 -0700
In-Reply-To: <46D5AF90.4040607@oracle.com>
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




On 8/29/07 12:40 PM, "Chuck Lever" <chuck.lever@oracle.com> wrote:

> Tom Tucker wrote:
>> Store the max payload supported by the transport in the switch
>> instead of reaching into the socket since not all transports
>> (RDMA) have a socket.
>> 
>> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
>> Signed-off-by: Peter Leckie <pleckie@melbourne.sgi.com>
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>> ---
>> 
>>  include/linux/sunrpc/svcsock.h |    6 ++++++
>>  net/sunrpc/svc.c               |    5 ++---
>>  net/sunrpc/svcsock.c           |    2 ++
>>  3 files changed, 10 insertions(+), 3 deletions(-)
>> 
>> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
>> index 3faa95c..4e24e6d 100644
>> --- a/include/linux/sunrpc/svcsock.h
>> +++ b/include/linux/sunrpc/svcsock.h
>> @@ -35,6 +35,12 @@ struct svc_xprt {
>> * Return 1 if sufficient space to write reply to network.
>> */
>> int   (*xpt_has_wspace)(struct svc_sock *);
>> + /*
>> +  * Stores the largest payload (i.e. READ, WRITE or READDIR
>> +  * data length not including NFS headers) supported by the
>> +  * svc_sock.
>> +  */
>> + u32   xpt_max_payload;
>>  };
> 
> Only worth 2 cents, but perhaps you could make a separate section within
> svc_xprt for these variables, rather than mixing them with the xpt
> methods.  I think separating these is more traditional Linux style.
>

Agreed. I'll change it.
 
> I notice that the type of the client's rpc_xprt->max_payload is size_t,
> which may be the wrong type -- u32 might be better.
> 
Not sure. I simply defined it to match the svc_max_payload function
signature.
 
>>  /*
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index 72a900f..41f9ee0 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -1036,10 +1036,9 @@ err_bad:
>>   */
>>  u32 svc_max_payload(const struct svc_rqst *rqstp)
>>  {
>> - int max = RPCSVC_MAXPAYLOAD_TCP;
>> + struct svc_sock *svsk = rqstp->rq_sock;
>> + int max = svsk->sk_xprt->xpt_max_payload;
>>  
>> - if (rqstp->rq_sock->sk_sock->type == SOCK_DGRAM)
>> -  max = RPCSVC_MAXPAYLOAD_UDP;
>> if (rqstp->rq_server->sv_max_payload < max)
>> max = rqstp->rq_server->sv_max_payload;
>> return max;
>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> index b16dad4..0dc94a8 100644
>> --- a/net/sunrpc/svcsock.c
>> +++ b/net/sunrpc/svcsock.c
>> @@ -897,6 +897,7 @@ static const struct svc_xprt svc_udp_xpr
>> .xpt_detach = svc_sock_detach,
>> .xpt_free = svc_sock_free,
>> .xpt_has_wspace = svc_udp_has_wspace,
>> + .xpt_max_payload = RPCSVC_MAXPAYLOAD_UDP,
>>  };
>>  
>>  static void
>> @@ -1368,6 +1369,7 @@ static const struct svc_xprt svc_tcp_xpr
>> .xpt_free = svc_sock_free,
>> .xpt_prep_reply_hdr = svc_tcp_prep_reply_hdr,
>> .xpt_has_wspace = svc_tcp_has_wspace,
>> + .xpt_max_payload = RPCSVC_MAXPAYLOAD_TCP,
>>  };
>>  
>>  static void



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
