From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH] NLM: Revert parts of commit 24e36663
Date: Fri, 26 Sep 2008 11:50:08 -0400
Message-ID: <RTPCLUEXC2-PRDcarcR0000003b@RTPMVEXC1-PRD.hq.netapp.com>
References: <20080924184732.4078.83334.stgit@tarkus.1015granger.net>
 <1222282496.7390.39.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chuck Lever <chuck.lever@oracle.com>, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48234 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752733AbYIZPuO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 11:50:14 -0400
In-Reply-To: <1222282496.7390.39.camel@localhost>
References: <20080924184732.4078.83334.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
 <1222282496.7390.39.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 02:54 PM 9/24/2008, Trond Myklebust wrote:
>On Wed, 2008-09-24 at 14:50 -0400, Chuck Lever wrote:
>> statd and some servers always need lockd to listen on UDP, so always
>> start both lockd listener sockets.
>> 
>> This probably leaks an svc_serv if the TCP listener can't be created,
>> but it will do for now.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>
>ACK. We need this also in order to deal with servers that only send NLM
>callbacks on UDP (yeah, I know that's lame...).

Lame it may be, but performing a single callback over TCP is expensive,
and if it's frequent enough, can lead to socket exhaustion from TIME_WAIT.

Thumbs-up for this patch. The worst thing about the unpatched issue is that
if the server tries UDP callbacks for a TCP mount, then the client never knows
the lock was available. It enters a polling loop and many races can occur.

I posted some patches to that a while back (when we used sourceforge),
they're not a prerequisite to this change, but perhaps relevant for hardening
purposes:

<http://sourceforge.net/mailarchive/forum.php?thread_name=EXNANE01OSQeSOzNCWb00000734%40exnane01.hq.netapp.com&forum_name=nfs>


Tom.

>
>Trond
>
>> ---
>> 
>> I currently have this workaround lurking in my git repo.  Is there some kind
>> of fix for this issue planned for 2.6.28?
>> 
>> This is only a reminder, not a suggested patch.
>> 
>>  fs/lockd/svc.c |   31 +++++++++++++------------------
>>  1 files changed, 13 insertions(+), 18 deletions(-)
>> 
>> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
>> index a7b604c..36b6d03 100644
>> --- a/fs/lockd/svc.c
>> +++ b/fs/lockd/svc.c
>> @@ -213,25 +213,23 @@ lockd(void *vrqstp)
>>  }
>>  
>>  /*
>> - * Make any sockets that are needed but not present.
>> - * If nlm_udpport or nlm_tcpport were set as module
>> - * options, make those sockets unconditionally
>> + * Create UDP and TCP listeners for lockd.  Even if we only
>> + * have TCP NFS mounts and TCP NFSDs, some services (such
>> + * as rpc.statd) still require UDP.
>>   */
>> -static int make_socks(struct svc_serv *serv, const unsigned short proto)
>> +static int make_socks(struct svc_serv *serv)
>>  {
>>  	static int warned;
>>  	struct svc_xprt *xprt;
>>  	int err = 0;
>>  
>> -	if (proto == IPPROTO_UDP || nlm_udpport) {
>> -		xprt = svc_find_xprt(serv, "udp", 0, 0);
>> -		if (!xprt)
>> -			err = svc_create_xprt(serv, "udp", nlm_udpport,
>> -					      SVC_SOCK_DEFAULTS);
>> -		else
>> -			svc_xprt_put(xprt);
>> -	}
>> -	if (err >= 0 && (proto == IPPROTO_TCP || nlm_tcpport)) {
>> +	xprt = svc_find_xprt(serv, "udp", 0, 0);
>> +	if (!xprt)
>> +		err = svc_create_xprt(serv, "udp", nlm_udpport,
>> +				      SVC_SOCK_DEFAULTS);
>> +	else
>> +		svc_xprt_put(xprt);
>> +	if (err >= 0) {
>>  		xprt = svc_find_xprt(serv, "tcp", 0, 0);
>>  		if (!xprt)
>>  			err = svc_create_xprt(serv, "tcp", nlm_tcpport,
>> @@ -260,11 +258,8 @@ int lockd_up(const unsigned short proto)
>>  	/*
>>  	* Check whether we're already up and running.
>>  	*/
>> -	if (nlmsvc_rqst) {
>> -		if (proto)
>> -			error = make_socks(nlmsvc_rqst->rq_server, proto);
>> +	if (nlmsvc_rqst)
>>  		goto out;
>> -	}
>>  
>>  	/*
>>  	* Sanity check: if there's no pid,
>> @@ -281,7 +276,7 @@ int lockd_up(const unsigned short proto)
>>  		goto out;
>>  	}
>>  
>> -	if ((error = make_socks(serv, proto)) < 0)
>> +	if ((error = make_socks(serv)) < 0)
>>  		goto destroy_and_out;
>>  
>>  	/*
>> 
>-- 
>Trond Myklebust
>Linux NFS client maintainer
>
>NetApp
>Trond.Myklebust@netapp.com
>www.netapp.com
>--
>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

