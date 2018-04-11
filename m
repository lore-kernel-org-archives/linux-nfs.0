Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45608 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752435AbeDKMeg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Apr 2018 08:34:36 -0400
Subject: Re: [Libtirpc-devel] [PATCH 1/2] Restore using reserve ports for
 client connections
To: Chuck Lever <chuck.lever@oracle.com>
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180410213043.5545-1-steved@redhat.com>
 <1E130010-3BB3-4BB8-9521-1B6096BC615B@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <44316a1b-82ff-261c-b691-31b5621fb4e7@RedHat.com>
Date: Wed, 11 Apr 2018 08:34:35 -0400
MIME-Version: 1.0
In-Reply-To: <1E130010-3BB3-4BB8-9521-1B6096BC615B@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hey,

On 04/10/2018 06:17 PM, Chuck Lever wrote:
> 
> 
>> On Apr 10, 2018, at 3:30 PM, Steve Dickson <steved@redhat.com> wrote:
>>
>> Commit 46e04a73 changed both clnt_com_create()
>> and clnt_tli_create() to avoid using reserve ports when
>> creating connection to the server.
>>
>> For certain legacy apps, the client has to used
>> reserve port to be able to communicate with its
>> server so using of reserve ports is restored.
> 
> Hi Steve-
> 
> Which legacy apps use clnt_tli_create and require this behavior?
yphelper, yppush and ypxfr via the clnt_create() call. At least
that's all I have found so far.

> There is no backwards compatibility requirement for this API.
Well unlike the server side, the client will not be squatting
on these port for an absorbent amount time. 99% of the time they
are UDP connection so the ports are immediately reusable,
unlike TCP connection that get stuck in TIME_WAIT and
there is a requirement for reserve port be used to talk
to the server. 

So I'm feeling pretty strong that there is no problem at
all with the client using reserve ports for their short
lived connection. Not using them would cause more problems
as we have already seen.

steved.
 
> 
> 
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
>>
>> ------------------------------------------------------------------------------
>> Check out the vibrant tech community on one of the world's most
>> engaging tech sites, Slashdot.org! http://sdm.link/slashdot
>> _______________________________________________
>> Libtirpc-devel mailing list
>> Libtirpc-devel@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel
> 
> --
> Chuck Lever
> 
> 
> 
