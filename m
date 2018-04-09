Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47368 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754475AbeDIUEZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Apr 2018 16:04:25 -0400
Subject: Re: [PATCH] clnt_com_create: Restore backwards compatibility with the
 legacy glibc code.
To: Chuck Lever <chuck.lever@oracle.com>
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180409172825.169380-1-steved@redhat.com>
 <A536D92D-14FF-41B1-9943-A838FF8FCBC1@oracle.com>
 <53cdf0c9-e236-b0e0-bd88-0da487488f6b@RedHat.com>
 <9DA13A82-6D1C-47F3-8E16-6267DE195EAB@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <5977917e-d9f8-4378-e5be-e83a5e3a3392@RedHat.com>
Date: Mon, 9 Apr 2018 16:04:24 -0400
MIME-Version: 1.0
In-Reply-To: <9DA13A82-6D1C-47F3-8E16-6267DE195EAB@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/09/2018 02:40 PM, Chuck Lever wrote:
> 
> 
>> On Apr 9, 2018, at 11:58 AM, Steve Dickson <SteveD@RedHat.com> wrote:
>>
>>
>>
>> On 04/09/2018 01:32 PM, Chuck Lever wrote:
>>>
>>>
>>>> On Apr 9, 2018, at 11:28 AM, Steve Dickson <steved@redhat.com> wrote:
>>>>
>>>> Commit 46e04a73 changed clnt_com_create() to avoid
>>>> using reserved ports when creating the the CLIENT ptr.
>>>> This change breaks backward compatibility with the
>>>> legacy RPC code that was in glibc.
>>>>
>>>> This patch reverts that commit to restore backwards compatibility
>>>>
>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>> ---
>>>> src/rpc_soc.c | 10 ++++++----
>>>> 1 file changed, 6 insertions(+), 4 deletions(-)
>>>>
>>>> diff --git a/src/rpc_soc.c b/src/rpc_soc.c
>>>> index af6c482..ed0892a 100644
>>>> --- a/src/rpc_soc.c
>>>> +++ b/src/rpc_soc.c
>>>> @@ -67,8 +67,6 @@
>>>>
>>>> extern mutex_t	rpcsoc_lock;
>>>>
>>>> -extern int __binddynport(int fd);
>>>> -
>>>> static CLIENT *clnt_com_create(struct sockaddr_in *, rpcprog_t, rpcvers_t,
>>>>    int *, u_int, u_int, char *, int);
>>>> static SVCXPRT *svc_com_create(int, u_int, u_int, char *);
>>>> @@ -147,8 +145,7 @@ clnt_com_create(raddr, prog, vers, sockp, sendsz, recvsz, tp, flags)
>>>> 	bindaddr.maxlen = bindaddr.len =  sizeof (struct sockaddr_in);
>>>> 	bindaddr.buf = raddr;
>>>>
>>>> -	if (__binddynport(fd) == -1)
>>>> -		goto err;
>>>> +	bindresvport(fd, NULL);
>>>> 	cl = clnt_tli_create(fd, nconf, &bindaddr, prog, vers,
>>>> 				sendsz, recvsz);
>>>> 	if (cl) {
>>>> @@ -316,6 +313,7 @@ svc_com_create(fd, sendsize, recvsize, netid)
>>>> 	SVCXPRT *svc;
>>>> 	int madefd = FALSE;
>>>> 	int port;
>>>> +	struct sockaddr_in sin;
>>>>
>>>> 	if ((nconf = __rpc_getconfip(netid)) == NULL) {
>>>> 		(void) syslog(LOG_ERR, "Could not get %s transport", netid);
>>>> @@ -332,6 +330,10 @@ svc_com_create(fd, sendsize, recvsize, netid)
>>>> 		madefd = TRUE;
>>>> 	}
>>>>
>>>> +	memset(&sin, 0, sizeof sin);
>>>> +	sin.sin_family = AF_INET;
>>>> +	bindresvport(fd, &sin);
>>>> +	listen(fd, SOMAXCONN);
>>>
>>> Why do we need to fix the server API too?
>> I thought about this... and I'm thinking there is
>> more of an exception of server listening on reserve
>> ports than clients using using reserve ports.
> 
> Hi Steve-
> 
> I think you mean that there are fewer legacy servers
> than there are legacy clients? I don't see how that
> matters: There's no benefit at all for having a
> server listen on a dynamically-assigned privileged
> port. Nothing can be broken if the server API uses
> an ephemeral port.
> 
> 
>> Plus this make us completely backwards compatibility
>> which in the long run I think is the right place to be.
> 
> Philosophically I agree that backwards compatibility
> is good, but I think you're "going to hell with the
> joke" as they say.
> 
> The point of backwards compatibility is that we don't
> want to break applications that depend on some behavior.
> There can't be any applications that depend on this
> behavior because there's no functional benefit to it,
> only a downside, which we have no reason not to fix.The downside is we are changing an API that has 
been established for since the 80's... What good
could that possibly do WRT legacy servers?
 
> 
> I'm going to firmly object on this one, unless you have
> a clearly documented breakage that requires the legacy
> server API to use bindresvport(3).
Here is what the man page says "If the socket is not bound to a 
local TCP port, then this routine binds it to an arbitrary port."

The point being it also does not talk about creating a 
listening connection either... Changing the (undocumented)
API like this can cause nothing but problems... IMHO...

Basically, not making this change will cause a fork with 
all the major distros since it very import for them to be 
backward compatible esp in enterprise worlds. Upstream not 
so much... Who really uses raw upstream bits in a stable
environment... understood... But this brings me to my point.

What problem is being fixed by changing an 20+ year API? 
Where are the bug reports that this change is needed
or wanted? 

> 
> Also, it would be great to get a man page update on the
> legacy clnt API that documents the behavior when a root
> caller uses that API. That gives some guarantee that it
> doesn't get changed again inadvertently.
I need to look, but I think glibc still "owns" the
man pages... 

steved.
