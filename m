Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41816 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753463AbeDIR61 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Apr 2018 13:58:27 -0400
Subject: Re: [PATCH] clnt_com_create: Restore backwards compatibility with the
 legacy glibc code.
To: Chuck Lever <chuck.lever@oracle.com>
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180409172825.169380-1-steved@redhat.com>
 <A536D92D-14FF-41B1-9943-A838FF8FCBC1@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <53cdf0c9-e236-b0e0-bd88-0da487488f6b@RedHat.com>
Date: Mon, 9 Apr 2018 13:58:26 -0400
MIME-Version: 1.0
In-Reply-To: <A536D92D-14FF-41B1-9943-A838FF8FCBC1@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/09/2018 01:32 PM, Chuck Lever wrote:
> 
> 
>> On Apr 9, 2018, at 11:28 AM, Steve Dickson <steved@redhat.com> wrote:
>>
>> Commit 46e04a73 changed clnt_com_create() to avoid
>> using reserved ports when creating the the CLIENT ptr.
>> This change breaks backward compatibility with the
>> legacy RPC code that was in glibc.
>>
>> This patch reverts that commit to restore backwards compatibility
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>> src/rpc_soc.c | 10 ++++++----
>> 1 file changed, 6 insertions(+), 4 deletions(-)
>>
>> diff --git a/src/rpc_soc.c b/src/rpc_soc.c
>> index af6c482..ed0892a 100644
>> --- a/src/rpc_soc.c
>> +++ b/src/rpc_soc.c
>> @@ -67,8 +67,6 @@
>>
>> extern mutex_t	rpcsoc_lock;
>>
>> -extern int __binddynport(int fd);
>> -
>> static CLIENT *clnt_com_create(struct sockaddr_in *, rpcprog_t, rpcvers_t,
>>     int *, u_int, u_int, char *, int);
>> static SVCXPRT *svc_com_create(int, u_int, u_int, char *);
>> @@ -147,8 +145,7 @@ clnt_com_create(raddr, prog, vers, sockp, sendsz, recvsz, tp, flags)
>> 	bindaddr.maxlen = bindaddr.len =  sizeof (struct sockaddr_in);
>> 	bindaddr.buf = raddr;
>>
>> -	if (__binddynport(fd) == -1)
>> -		goto err;
>> +	bindresvport(fd, NULL);
>> 	cl = clnt_tli_create(fd, nconf, &bindaddr, prog, vers,
>> 				sendsz, recvsz);
>> 	if (cl) {
>> @@ -316,6 +313,7 @@ svc_com_create(fd, sendsize, recvsize, netid)
>> 	SVCXPRT *svc;
>> 	int madefd = FALSE;
>> 	int port;
>> +	struct sockaddr_in sin;
>>
>> 	if ((nconf = __rpc_getconfip(netid)) == NULL) {
>> 		(void) syslog(LOG_ERR, "Could not get %s transport", netid);
>> @@ -332,6 +330,10 @@ svc_com_create(fd, sendsize, recvsize, netid)
>> 		madefd = TRUE;
>> 	}
>>
>> +	memset(&sin, 0, sizeof sin);
>> +	sin.sin_family = AF_INET;
>> +	bindresvport(fd, &sin);
>> +	listen(fd, SOMAXCONN);
> 
> Why do we need to fix the server API too?
I thought about this... and I'm thinking there is
more of an exception of server listening on reserve
ports than clients using using reserve ports.

Plus this make us completely backwards compatibility
which in the long run I think is the right place to be.

steved.
 
> 
> 
>> 	svc = svc_tli_create(fd, nconf, NULL, sendsize, recvsize);
>> 	(void) freenetconfigent(nconf);
>> 	if (svc == NULL) {
>> -- 
>> 2.14.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
