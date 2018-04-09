Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:46834 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751919AbeDISlD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Apr 2018 14:41:03 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH] clnt_com_create: Restore backwards compatibility with the
 legacy glibc code.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <53cdf0c9-e236-b0e0-bd88-0da487488f6b@RedHat.com>
Date: Mon, 9 Apr 2018 12:40:49 -0600
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9DA13A82-6D1C-47F3-8E16-6267DE195EAB@oracle.com>
References: <20180409172825.169380-1-steved@redhat.com>
 <A536D92D-14FF-41B1-9943-A838FF8FCBC1@oracle.com>
 <53cdf0c9-e236-b0e0-bd88-0da487488f6b@RedHat.com>
To: Steve Dickson <SteveD@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Apr 9, 2018, at 11:58 AM, Steve Dickson <SteveD@RedHat.com> wrote:
>=20
>=20
>=20
> On 04/09/2018 01:32 PM, Chuck Lever wrote:
>>=20
>>=20
>>> On Apr 9, 2018, at 11:28 AM, Steve Dickson <steved@redhat.com> =
wrote:
>>>=20
>>> Commit 46e04a73 changed clnt_com_create() to avoid
>>> using reserved ports when creating the the CLIENT ptr.
>>> This change breaks backward compatibility with the
>>> legacy RPC code that was in glibc.
>>>=20
>>> This patch reverts that commit to restore backwards compatibility
>>>=20
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>> src/rpc_soc.c | 10 ++++++----
>>> 1 file changed, 6 insertions(+), 4 deletions(-)
>>>=20
>>> diff --git a/src/rpc_soc.c b/src/rpc_soc.c
>>> index af6c482..ed0892a 100644
>>> --- a/src/rpc_soc.c
>>> +++ b/src/rpc_soc.c
>>> @@ -67,8 +67,6 @@
>>>=20
>>> extern mutex_t	rpcsoc_lock;
>>>=20
>>> -extern int __binddynport(int fd);
>>> -
>>> static CLIENT *clnt_com_create(struct sockaddr_in *, rpcprog_t, =
rpcvers_t,
>>>    int *, u_int, u_int, char *, int);
>>> static SVCXPRT *svc_com_create(int, u_int, u_int, char *);
>>> @@ -147,8 +145,7 @@ clnt_com_create(raddr, prog, vers, sockp, =
sendsz, recvsz, tp, flags)
>>> 	bindaddr.maxlen =3D bindaddr.len =3D  sizeof (struct =
sockaddr_in);
>>> 	bindaddr.buf =3D raddr;
>>>=20
>>> -	if (__binddynport(fd) =3D=3D -1)
>>> -		goto err;
>>> +	bindresvport(fd, NULL);
>>> 	cl =3D clnt_tli_create(fd, nconf, &bindaddr, prog, vers,
>>> 				sendsz, recvsz);
>>> 	if (cl) {
>>> @@ -316,6 +313,7 @@ svc_com_create(fd, sendsize, recvsize, netid)
>>> 	SVCXPRT *svc;
>>> 	int madefd =3D FALSE;
>>> 	int port;
>>> +	struct sockaddr_in sin;
>>>=20
>>> 	if ((nconf =3D __rpc_getconfip(netid)) =3D=3D NULL) {
>>> 		(void) syslog(LOG_ERR, "Could not get %s transport", =
netid);
>>> @@ -332,6 +330,10 @@ svc_com_create(fd, sendsize, recvsize, netid)
>>> 		madefd =3D TRUE;
>>> 	}
>>>=20
>>> +	memset(&sin, 0, sizeof sin);
>>> +	sin.sin_family =3D AF_INET;
>>> +	bindresvport(fd, &sin);
>>> +	listen(fd, SOMAXCONN);
>>=20
>> Why do we need to fix the server API too?
> I thought about this... and I'm thinking there is
> more of an exception of server listening on reserve
> ports than clients using using reserve ports.

Hi Steve-

I think you mean that there are fewer legacy servers
than there are legacy clients? I don't see how that
matters: There's no benefit at all for having a
server listen on a dynamically-assigned privileged
port. Nothing can be broken if the server API uses
an ephemeral port.


> Plus this make us completely backwards compatibility
> which in the long run I think is the right place to be.

Philosophically I agree that backwards compatibility
is good, but I think you're "going to hell with the
joke" as they say.

The point of backwards compatibility is that we don't
want to break applications that depend on some behavior.
There can't be any applications that depend on this
behavior because there's no functional benefit to it,
only a downside, which we have no reason not to fix.

I'm going to firmly object on this one, unless you have
a clearly documented breakage that requires the legacy
server API to use bindresvport(3).

Also, it would be great to get a man page update on the
legacy clnt API that documents the behavior when a root
caller uses that API. That gives some guarantee that it
doesn't get changed again inadvertently.


> steved.
>=20
>>=20
>>=20
>>> 	svc =3D svc_tli_create(fd, nconf, NULL, sendsize, recvsize);
>>> 	(void) freenetconfigent(nconf);
>>> 	if (svc =3D=3D NULL) {
>>> --=20
>>> 2.14.3
>>>=20
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
>> --
>> Chuck Lever

--
Chuck Lever



