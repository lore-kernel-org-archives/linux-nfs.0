From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: [PATCH 3/8] SUNRPC: Set V6ONLY socket option for RPC listener
 sockets
Date: Thu, 21 Aug 2008 14:11:49 +0200
Message-ID: <48AD5B85.4020807@bull.net>
References: <20080813223653.13068.9467.stgit@manray.1015granger.net> <20080813223953.13068.97829.stgit@manray.1015granger.net> <20080814200554.GI23859@fieldses.org> <74E488BD-DB15-41CD-AD30-A8A5213BC140@oracle.com> <20080814203833.GK23859@fieldses.org> <A8AF0C9D-B606-4EA4-9EE0-5367C515BE84@oracle.com> <20080820193126.GB21226@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: trond.myklebust@netapp.com, trond.myklebust@fys.uio.no,
	linux-nfs@vger.kernel.org, Frank S Filz <ffilz@us.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:55301 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbYHUMLx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2008 08:11:53 -0400
In-Reply-To: <20080820193126.GB21226@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields a =E9crit :

>On Thu, Aug 14, 2008 at 04:45:31PM -0400, Chuck Lever wrote:
> =20
>
>>On Aug 14, 2008, at 4:38 PM, J. Bruce Fields wrote:
>>   =20
>>
>>>On Thu, Aug 14, 2008 at 04:34:14PM -0400, Chuck Lever wrote:
>>>     =20
>>>
>>>>On Aug 14, 2008, at 4:05 PM, J. Bruce Fields wrote:
>>>>       =20
>>>>
>>>>>On Wed, Aug 13, 2008 at 06:39:54PM -0400, Chuck Lever wrote:
>>>>>         =20
>>>>>
>>>>>>My plan is to use an AF_INET listener on systems that support onl=
y
>>>>>>IPv4,
>>>>>>and an AF_INET6 listener on systems that can support IPv6. Incomi=
ng
>>>>>>IPv4 packets will be posted to an AF_INET6 listener with a mapped
>>>>>>IPv4
>>>>>>address.
>>>>>>           =20
>>>>>>
>>>>>How will the nfs server choose whether to use AF_INET or AF_INET6?
>>>>>Will
>>>>>we need some new user interface?
>>>>>         =20
>>>>>
>>>>[PATCH 2/8] changes svc_create() to take an additional argument whi=
ch
>>>>specifies the listener's address family.  This value is stored in
>>>>svc_serv.
>>>>       =20
>>>>
>>>Right, but I'm asking about the nfsd server, not the rpc server, and=
 =20
>>>the
>>>user interface, not the in-kernel interface:
>>>     =20
>>>
>>Ah.  That wasn't clear before.
>>
>>   =20
>>
>>>so suppose I'm a server
>>>administrator, and want my nfs server to listen for ipv6 connections=
=2E
>>>Will there be some switch I'll need to flip?
>>>     =20
>>>
>>I don't know how that UI will be designed.  So far, I've focused only=
 on=20
>>the pieces needed for client side IPv6 support.  I figured the Bull t=
eam=20
>>had something figured out for the server, and didn't think any more a=
bout=20
>>it.
>>   =20
>>
>
>I've forgotten who was working on that; Aurelien Charbon?
> =20
>
Hi,
Sorry for not answering before, I am back from vacation.
Aurelien is no longer directly working on that even he can answer any=20
questions.
  It is me now who tess NFSV4 IPV6 with the patches Aurelien delivered=20
to Bruce a few months ago.
But since Chuck has delivered several new patches which affect
the NFS server side about the way nfsd can listen for ipv6 connections.

  To have NFSV4 IPV6 working with those changes, what it would be nice=20
to have a complete list
on what are the changes.
Is there now a complete release for which we can test those latest=20
changes? If not which one will be?
Are there any other changes still planned?


Best Regards

>--b.
>
> =20
>
>>>>>>Max Matveev <makc@sgi.com> says:
>>>>>>Creating a single listener can be dangerous - if =20
>>>>>>net.ipv6.bindv6only
>>>>>>is enabled then it's possible to create another listener in v4
>>>>>>namespace on the same port and steal the traffic from the "unifed=
"
>>>>>>listener. You need to disable V6ONLY explicitly via a sockopt to
>>>>>>stop
>>>>>>that.
>>>>>>
>>>>>>Set appropriate socket option on RPC server listener sockets to
>>>>>>prevent
>>>>>>this.
>>>>>>
>>>>>>Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>>>---
>>>>>>
>>>>>>net/sunrpc/svcsock.c |   13 +++++++++++++
>>>>>>1 files changed, 13 insertions(+), 0 deletions(-)
>>>>>>
>>>>>>diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>>>>>>index 3e65719..f91377c 100644
>>>>>>--- a/net/sunrpc/svcsock.c
>>>>>>+++ b/net/sunrpc/svcsock.c
>>>>>>@@ -1114,6 +1114,7 @@ static struct svc_sock
>>>>>>*svc_setup_socket(struct svc_serv *serv,
>>>>>>	struct svc_sock	*svsk;
>>>>>>	struct sock	*inet;
>>>>>>	int		pmap_register =3D !(flags & SVC_SOCK_ANONYMOUS);
>>>>>>+	int		val;
>>>>>>
>>>>>>	dprintk("svc: svc_setup_socket %p\n", sock);
>>>>>>	if (!(svsk =3D kzalloc(sizeof(*svsk), GFP_KERNEL))) {
>>>>>>@@ -1146,6 +1147,18 @@ static struct svc_sock
>>>>>>*svc_setup_socket(struct svc_serv *serv,
>>>>>>	else
>>>>>>		svc_tcp_init(svsk, serv);
>>>>>>
>>>>>>+	/*
>>>>>>+	 * We start one listener per sv_serv.  We want AF_INET
>>>>>>+	 * requests to be automatically shunted to our AF_INET6
>>>>>>+	 * listener using a mapped IPv4 address.  Make sure
>>>>>>+	 * no-one starts an equivalent IPv4 listener, which
>>>>>>+	 * would steal our incoming connections.
>>>>>>+	 */
>>>>>>+	val =3D 0;
>>>>>>+	if (serv->sv_family =3D=3D AF_INET6)
>>>>>>+		kernel_setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
>>>>>>+					(char *)&val, sizeof(val));
>>>>>>+
>>>>>>	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
>>>>>>				svsk, svsk->sk_sk);
>>>>>>
>>>>>>
>>>>>>           =20
>>>>>>
>>>>--
>>>>Chuck Lever
>>>>chuck[dot]lever[at]oracle[dot]com
>>>>
>>>>
>>>>
>>>>       =20
>>>>
>>--
>>Chuck Lever
>>chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>>--
>>To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>   =20
>>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-nfs" i=
n
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
> =20
>


--=20
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic=20
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
=46ax     : 33 (4) 76.29.75.18
-----------------------------------------------------------------=20

