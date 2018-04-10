Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:48664 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753911AbeDJPVd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Apr 2018 11:21:33 -0400
Subject: Re: [PATCH] clnt_com_create: Restore backwards compatibility with the
 legacy glibc code.
To: Chuck Lever <chuck.lever@oracle.com>
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180409172825.169380-1-steved@redhat.com>
 <A536D92D-14FF-41B1-9943-A838FF8FCBC1@oracle.com>
 <53cdf0c9-e236-b0e0-bd88-0da487488f6b@RedHat.com>
 <9DA13A82-6D1C-47F3-8E16-6267DE195EAB@oracle.com>
 <5977917e-d9f8-4378-e5be-e83a5e3a3392@RedHat.com>
 <B692EA3A-3B03-48D2-AFD2-941601DF403F@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <84f65189-360a-11b9-2f80-9fb2296e8dde@RedHat.com>
Date: Tue, 10 Apr 2018 11:21:32 -0400
MIME-Version: 1.0
In-Reply-To: <B692EA3A-3B03-48D2-AFD2-941601DF403F@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/09/2018 05:11 PM, Chuck Lever wrote:
> 
> 
>> On Apr 9, 2018, at 2:04 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>>
>>
>>
>> On 04/09/2018 02:40 PM, Chuck Lever wrote:
>>>
>>>
>>>> On Apr 9, 2018, at 11:58 AM, Steve Dickson <SteveD@RedHat.com> wrote:
>>>>
>>>>
>>>>
>>>> On 04/09/2018 01:32 PM, Chuck Lever wrote:
>>>>>
>>>>>
>>>>>> On Apr 9, 2018, at 11:28 AM, Steve Dickson <steved@redhat.com> wrote:
>>>>>>
>>>>>> Commit 46e04a73 changed clnt_com_create() to avoid
>>>>>> using reserved ports when creating the the CLIENT ptr.
>>>>>> This change breaks backward compatibility with the
>>>>>> legacy RPC code that was in glibc.
>>>>>>
>>>>>> This patch reverts that commit to restore backwards compatibility
>>>>>>
>>>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>>>> ---
>>>>>> src/rpc_soc.c | 10 ++++++----
>>>>>> 1 file changed, 6 insertions(+), 4 deletions(-)
>>>>>>
>>>>>> diff --git a/src/rpc_soc.c b/src/rpc_soc.c
>>>>>> index af6c482..ed0892a 100644
>>>>>> --- a/src/rpc_soc.c
>>>>>> +++ b/src/rpc_soc.c
>>>>>> @@ -67,8 +67,6 @@
>>>>>>
>>>>>> extern mutex_t	rpcsoc_lock;
>>>>>>
>>>>>> -extern int __binddynport(int fd);
>>>>>> -
>>>>>> static CLIENT *clnt_com_create(struct sockaddr_in *, rpcprog_t, rpcvers_t,
>>>>>>   int *, u_int, u_int, char *, int);
>>>>>> static SVCXPRT *svc_com_create(int, u_int, u_int, char *);
>>>>>> @@ -147,8 +145,7 @@ clnt_com_create(raddr, prog, vers, sockp, sendsz, recvsz, tp, flags)
>>>>>> 	bindaddr.maxlen = bindaddr.len =  sizeof (struct sockaddr_in);
>>>>>> 	bindaddr.buf = raddr;
>>>>>>
>>>>>> -	if (__binddynport(fd) == -1)
>>>>>> -		goto err;
>>>>>> +	bindresvport(fd, NULL);
>>>>>> 	cl = clnt_tli_create(fd, nconf, &bindaddr, prog, vers,
>>>>>> 				sendsz, recvsz);
>>>>>> 	if (cl) {
>>>>>> @@ -316,6 +313,7 @@ svc_com_create(fd, sendsize, recvsize, netid)
>>>>>> 	SVCXPRT *svc;
>>>>>> 	int madefd = FALSE;
>>>>>> 	int port;
>>>>>> +	struct sockaddr_in sin;
>>>>>>
>>>>>> 	if ((nconf = __rpc_getconfip(netid)) == NULL) {
>>>>>> 		(void) syslog(LOG_ERR, "Could not get %s transport", netid);
>>>>>> @@ -332,6 +330,10 @@ svc_com_create(fd, sendsize, recvsize, netid)
>>>>>> 		madefd = TRUE;
>>>>>> 	}
>>>>>>
>>>>>> +	memset(&sin, 0, sizeof sin);
>>>>>> +	sin.sin_family = AF_INET;
>>>>>> +	bindresvport(fd, &sin);
>>>>>> +	listen(fd, SOMAXCONN);
>>>>>
>>>>> Why do we need to fix the server API too?
>>>> I thought about this... and I'm thinking there is
>>>> more of an exception of server listening on reserve
>>>> ports than clients using using reserve ports.
>>>
>>> Hi Steve-
>>>
>>> I think you mean that there are fewer legacy servers
>>> than there are legacy clients? I don't see how that
>>> matters: There's no benefit at all for having a
>>> server listen on a dynamically-assigned privileged
>>> port. Nothing can be broken if the server API uses
>>> an ephemeral port.
>>>
>>>
>>>> Plus this make us completely backwards compatibility
>>>> which in the long run I think is the right place to be.
>>>
>>> Philosophically I agree that backwards compatibility
>>> is good, but I think you're "going to hell with the
>>> joke" as they say.
>>>
>>> The point of backwards compatibility is that we don't
>>> want to break applications that depend on some behavior.
>>> There can't be any applications that depend on this
>>> behavior because there's no functional benefit to it,
>>> only a downside, which we have no reason not to fix.
>> The downside is we are changing an API that has 
>> been established for since the 80's... What good
>> could that possibly do WRT legacy servers?
> 
> That's the wrong question, IMO. It won't hurt legacy
> servers at all, and will benefit everyone else.
> 
> 
>>> I'm going to firmly object on this one, unless you have
>>> a clearly documented breakage that requires the legacy
>>> server API to use bindresvport(3).
>> Here is what the man page says "If the socket is not bound to a 
>> local TCP port, then this routine binds it to an arbitrary port."
>>
>> The point being it also does not talk about creating a 
>> listening connection either... Changing the (undocumented)
>> API like this can cause nothing but problems... IMHO...
> 
> Please show me one specific breakage that will result
> in removing bindresvport from svc_com_create. Just one,
> and I promise I will crawl back into my hole.
The patch also restores the listen() which is
something I can see  a server apps depending on. 

> 
> In case it wasn't clear, my preference is for a patch
> that reverts only the removal of bindresvport(3) from
> clnt_com_create. The svc_com_create change is safe and
> should remain unreverted.
> 
> I don't like reverting the clnt_com_create change, but
> I won't object to it, and there is clear evidence that
> some old programs are inconvenienced by that change.
I do not want to be in that position again... 
I just don't want to wait around to see what breaks.

> 
> 
>> Basically, not making this change will cause a fork with 
>> all the major distros since it very import for them to be 
>> backward compatible esp in enterprise worlds.
> 
> That sounds like an overstatement. Who claims they won't
> take libtirpc with an unprivileged svc_com_create? I would
> really like to understand why.
I'm just assuming most distros want to be backward compatible
and not break legacy apps... Maybe I'm wrong... 
 
> 
> 
>> Upstream not 
>> so much... Who really uses raw upstream bits in a stable
>> environment... understood... But this brings me to my point.
>>
>> What problem is being fixed by changing an 20+ year API? 
> 
> The problem is legacy clients and servers are squatting on
> ports that are assigned to other network services. These
> patches mitigate that problem. There is more to be done.
Any examples of these... The only one I know is rpcbind
which can be fixed in another ways.... 

> 
> The backwards compatibility issue is that some old servers
> believe that clients have to use a privileged source port
> to show that they are an authorized RPC consumer. We address
> that by reverting clnt_com_create to use bindresvport(3),
> although we can easily decide this is a security bug that
> is worth forcing legacy API consumers to fix their usage.
> 
> There is no similar backwards compatibility issue for
> clients talking to servers. That's just a fact about how
> RPC operates: the client uses rpcbind to discover the
> server's port. After that, there's no additional check to
> see if that service port is less than 1024.
Well its going to be hard for the client to talk
to the server if the server is no longer listening ;-)

> 
> 
>> Where are the bug reports that this change is needed
>> or wanted? 
> 
> I was presented with a list of five or more bug reports
> from various distributors that go back to almost 2000
> where RPC consumers have caused issues occupying IANA-
> assigned reserved ports.
> 
> https://sourceforge.net/p/libtirpc/mailman/libtirpc-devel/?viewmonth=201801&viewday=12&style=flat
> 
> The bottom item on that page is Guillem's e-mail that
> cites bug reports on this issue.
> 
> 
>>> Also, it would be great to get a man page update on the
>>> legacy clnt API that documents the behavior when a root
>>> caller uses that API. That gives some guarantee that it
>>> doesn't get changed again inadvertently.
>> I need to look, but I think glibc still "owns" the
>> man pages... 
> 
> That should be fixed if that's true. Since RPC is to be
> removed from glibc I can't think why they'd want to keep
> the RPC man pages.
I'll talk to the glibc people to what they are planning... 

steved.
> 
> However, libtirpc has a bunch of man pages for the legacy
> APIs. At least those can be updated.
> 
> 
> --
> Chuck Lever
> 
> 
> 
