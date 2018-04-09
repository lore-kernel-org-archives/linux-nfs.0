Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:47496 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752422AbeDIVLo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Apr 2018 17:11:44 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH] clnt_com_create: Restore backwards compatibility with the
 legacy glibc code.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5977917e-d9f8-4378-e5be-e83a5e3a3392@RedHat.com>
Date: Mon, 9 Apr 2018 15:11:29 -0600
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B692EA3A-3B03-48D2-AFD2-941601DF403F@oracle.com>
References: <20180409172825.169380-1-steved@redhat.com>
 <A536D92D-14FF-41B1-9943-A838FF8FCBC1@oracle.com>
 <53cdf0c9-e236-b0e0-bd88-0da487488f6b@RedHat.com>
 <9DA13A82-6D1C-47F3-8E16-6267DE195EAB@oracle.com>
 <5977917e-d9f8-4378-e5be-e83a5e3a3392@RedHat.com>
To: Steve Dickson <SteveD@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Apr 9, 2018, at 2:04 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>=20
>=20
>=20
> On 04/09/2018 02:40 PM, Chuck Lever wrote:
>>=20
>>=20
>>> On Apr 9, 2018, at 11:58 AM, Steve Dickson <SteveD@RedHat.com> =
wrote:
>>>=20
>>>=20
>>>=20
>>> On 04/09/2018 01:32 PM, Chuck Lever wrote:
>>>>=20
>>>>=20
>>>>> On Apr 9, 2018, at 11:28 AM, Steve Dickson <steved@redhat.com> =
wrote:
>>>>>=20
>>>>> Commit 46e04a73 changed clnt_com_create() to avoid
>>>>> using reserved ports when creating the the CLIENT ptr.
>>>>> This change breaks backward compatibility with the
>>>>> legacy RPC code that was in glibc.
>>>>>=20
>>>>> This patch reverts that commit to restore backwards compatibility
>>>>>=20
>>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>>> ---
>>>>> src/rpc_soc.c | 10 ++++++----
>>>>> 1 file changed, 6 insertions(+), 4 deletions(-)
>>>>>=20
>>>>> diff --git a/src/rpc_soc.c b/src/rpc_soc.c
>>>>> index af6c482..ed0892a 100644
>>>>> --- a/src/rpc_soc.c
>>>>> +++ b/src/rpc_soc.c
>>>>> @@ -67,8 +67,6 @@
>>>>>=20
>>>>> extern mutex_t	rpcsoc_lock;
>>>>>=20
>>>>> -extern int __binddynport(int fd);
>>>>> -
>>>>> static CLIENT *clnt_com_create(struct sockaddr_in *, rpcprog_t, =
rpcvers_t,
>>>>>   int *, u_int, u_int, char *, int);
>>>>> static SVCXPRT *svc_com_create(int, u_int, u_int, char *);
>>>>> @@ -147,8 +145,7 @@ clnt_com_create(raddr, prog, vers, sockp, =
sendsz, recvsz, tp, flags)
>>>>> 	bindaddr.maxlen =3D bindaddr.len =3D  sizeof (struct =
sockaddr_in);
>>>>> 	bindaddr.buf =3D raddr;
>>>>>=20
>>>>> -	if (__binddynport(fd) =3D=3D -1)
>>>>> -		goto err;
>>>>> +	bindresvport(fd, NULL);
>>>>> 	cl =3D clnt_tli_create(fd, nconf, &bindaddr, prog, vers,
>>>>> 				sendsz, recvsz);
>>>>> 	if (cl) {
>>>>> @@ -316,6 +313,7 @@ svc_com_create(fd, sendsize, recvsize, netid)
>>>>> 	SVCXPRT *svc;
>>>>> 	int madefd =3D FALSE;
>>>>> 	int port;
>>>>> +	struct sockaddr_in sin;
>>>>>=20
>>>>> 	if ((nconf =3D __rpc_getconfip(netid)) =3D=3D NULL) {
>>>>> 		(void) syslog(LOG_ERR, "Could not get %s transport", =
netid);
>>>>> @@ -332,6 +330,10 @@ svc_com_create(fd, sendsize, recvsize, netid)
>>>>> 		madefd =3D TRUE;
>>>>> 	}
>>>>>=20
>>>>> +	memset(&sin, 0, sizeof sin);
>>>>> +	sin.sin_family =3D AF_INET;
>>>>> +	bindresvport(fd, &sin);
>>>>> +	listen(fd, SOMAXCONN);
>>>>=20
>>>> Why do we need to fix the server API too?
>>> I thought about this... and I'm thinking there is
>>> more of an exception of server listening on reserve
>>> ports than clients using using reserve ports.
>>=20
>> Hi Steve-
>>=20
>> I think you mean that there are fewer legacy servers
>> than there are legacy clients? I don't see how that
>> matters: There's no benefit at all for having a
>> server listen on a dynamically-assigned privileged
>> port. Nothing can be broken if the server API uses
>> an ephemeral port.
>>=20
>>=20
>>> Plus this make us completely backwards compatibility
>>> which in the long run I think is the right place to be.
>>=20
>> Philosophically I agree that backwards compatibility
>> is good, but I think you're "going to hell with the
>> joke" as they say.
>>=20
>> The point of backwards compatibility is that we don't
>> want to break applications that depend on some behavior.
>> There can't be any applications that depend on this
>> behavior because there's no functional benefit to it,
>> only a downside, which we have no reason not to fix.
> The downside is we are changing an API that has=20
> been established for since the 80's... What good
> could that possibly do WRT legacy servers?

That's the wrong question, IMO. It won't hurt legacy
servers at all, and will benefit everyone else.


>> I'm going to firmly object on this one, unless you have
>> a clearly documented breakage that requires the legacy
>> server API to use bindresvport(3).
> Here is what the man page says "If the socket is not bound to a=20
> local TCP port, then this routine binds it to an arbitrary port."
>=20
> The point being it also does not talk about creating a=20
> listening connection either... Changing the (undocumented)
> API like this can cause nothing but problems... IMHO...

Please show me one specific breakage that will result
in removing bindresvport from svc_com_create. Just one,
and I promise I will crawl back into my hole.

In case it wasn't clear, my preference is for a patch
that reverts only the removal of bindresvport(3) from
clnt_com_create. The svc_com_create change is safe and
should remain unreverted.

I don't like reverting the clnt_com_create change, but
I won't object to it, and there is clear evidence that
some old programs are inconvenienced by that change.


> Basically, not making this change will cause a fork with=20
> all the major distros since it very import for them to be=20
> backward compatible esp in enterprise worlds.

That sounds like an overstatement. Who claims they won't
take libtirpc with an unprivileged svc_com_create? I would
really like to understand why.


> Upstream not=20
> so much... Who really uses raw upstream bits in a stable
> environment... understood... But this brings me to my point.
>=20
> What problem is being fixed by changing an 20+ year API?=20

The problem is legacy clients and servers are squatting on
ports that are assigned to other network services. These
patches mitigate that problem. There is more to be done.

The backwards compatibility issue is that some old servers
believe that clients have to use a privileged source port
to show that they are an authorized RPC consumer. We address
that by reverting clnt_com_create to use bindresvport(3),
although we can easily decide this is a security bug that
is worth forcing legacy API consumers to fix their usage.

There is no similar backwards compatibility issue for
clients talking to servers. That's just a fact about how
RPC operates: the client uses rpcbind to discover the
server's port. After that, there's no additional check to
see if that service port is less than 1024.


> Where are the bug reports that this change is needed
> or wanted?=20

I was presented with a list of five or more bug reports
from various distributors that go back to almost 2000
where RPC consumers have caused issues occupying IANA-
assigned reserved ports.

=
https://sourceforge.net/p/libtirpc/mailman/libtirpc-devel/?viewmonth=3D201=
801&viewday=3D12&style=3Dflat

The bottom item on that page is Guillem's e-mail that
cites bug reports on this issue.


>> Also, it would be great to get a man page update on the
>> legacy clnt API that documents the behavior when a root
>> caller uses that API. That gives some guarantee that it
>> doesn't get changed again inadvertently.
> I need to look, but I think glibc still "owns" the
> man pages...=20

That should be fixed if that's true. Since RPC is to be
removed from glibc I can't think why they'd want to keep
the RPC man pages.

However, libtirpc has a bunch of man pages for the legacy
APIs. At least those can be updated.


--
Chuck Lever



