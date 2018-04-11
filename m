Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55702 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753890AbeDKPwq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Apr 2018 11:52:46 -0400
Subject: Re: [PATCH] clnt_create: Restore using reserve ports for client
 connections
To: Chuck Lever <chuck.lever@oracle.com>
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180411150803.26680-1-steved@redhat.com>
 <04AFBB38-DB95-4B3F-A39F-C323F914F780@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <93737583-5f5a-49d0-2255-25a4d54a3812@RedHat.com>
Date: Wed, 11 Apr 2018 11:52:39 -0400
MIME-Version: 1.0
In-Reply-To: <04AFBB38-DB95-4B3F-A39F-C323F914F780@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/11/2018 11:20 AM, Chuck Lever wrote:
> Hi Steve-
> 
>> On Apr 11, 2018, at 9:08 AM, Steve Dickson <steved@redhat.com> wrote:
>>
>> Commit 46e04a73 changed clnt_create(3) not to
>> use reserve ports when binding a connection to
>> a server.
>>
>> For certain legacy apps, like some of the NIS commands,
>> the client has to used reserve port to be able
>> to communicate with the server.
> 
> This is still not clear.
> 
> The problem is not that the RPC client has to use a reserved
> port, it's that the client implementations currently assume
> that clnt_create(3) will allocate a reserved port for them,
> which is undocumented API behavior.
An assumption that that has been valid for the last 20yrs
so that assumption is part of the API... IMHO... 

I'm going to leave as is... 

> 
> One more comment below.
> 
> 
>> So the use of reserve ports in clnt_create(3)
>> has been restored.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>> src/clnt_generic.c | 3 +--
>> src/rpc_soc.c      | 3 +--
>> 2 files changed, 2 insertions(+), 4 deletions(-)
>>
>> diff --git a/src/clnt_generic.c b/src/clnt_generic.c
>> index e5a314f..774292b 100644
>> --- a/src/clnt_generic.c
>> +++ b/src/clnt_generic.c
>> @@ -341,8 +341,7 @@ clnt_tli_create(int fd, const struct netconfig *nconf,
>> 		servtype = nconf->nc_semantics;
>> 		if (!__rpc_fd2sockinfo(fd, &si))
>> 			goto err;
>> -		if (__binddynport(fd) == -1)
>> -			goto err;
>> +		bindresvport(fd, NULL);
> 
> If this is the last __binddynport call site in clnt_generic.c,
> you can remove its forward declaration (line 50 in my copy of
> the source).
Yeah there is a couple of those... already cleaned up... 

Thanks..

steved.

> 
> 
>> 	} else {
>> 		if (!__rpc_fd2sockinfo(fd, &si))
>> 			goto err;
>> diff --git a/src/rpc_soc.c b/src/rpc_soc.c
>> index af6c482..f32a27c 100644
>> --- a/src/rpc_soc.c
>> +++ b/src/rpc_soc.c
>> @@ -147,8 +147,7 @@ clnt_com_create(raddr, prog, vers, sockp, sendsz, recvsz, tp, flags)
>> 	bindaddr.maxlen = bindaddr.len =  sizeof (struct sockaddr_in);
>> 	bindaddr.buf = raddr;
>>
>> -	if (__binddynport(fd) == -1)
>> -		goto err;
>> +	bindresvport(fd, NULL);
>> 	cl = clnt_tli_create(fd, nconf, &bindaddr, prog, vers,
>> 				sendsz, recvsz);
>> 	if (cl) {
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
