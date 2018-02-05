Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:44658 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752582AbeBERCd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Feb 2018 12:02:33 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH 0/1] Remote calls don't need to use privilege ports
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180205163647.15822-1-steved@redhat.com>
Date: Mon, 5 Feb 2018 12:02:29 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <16CF8126-7229-4963-B5D1-2AC16BFC000A@oracle.com>
References: <20180205163647.15822-1-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Heya Steve-

> On Feb 5, 2018, at 11:36 AM, Steve Dickson <steved@redhat.com> wrote:
>=20
> Over the weekend I did some experimenting with
> the remote call code in rpcbind. The code does=20
> functionally work but is very antiquated when
> it comes to the latest NFS versions.=20
>=20
> Since only UDP sockets are used to do remote calls
> using the documented interfaces pmap_rmtcall() and callrpc()
> calls to NFS will fail (actual times out) since UDP is no=20
> longer supported.=20
>=20
> The undocumented interface rpc_call() can be used to=20
> call into NFS since the protocol can specified, which=20
> also means the PMAPPROC_CALLIT protocol is not used.
>=20
> It turns out privilege port are not needed to make
> remote calls, at least with my testing.

It's not quite clear what you are claiming here, but
I'm guessing that what you demonstrated is that the
CALLIT _listener_ does not have to be privileged?

I claim that is true for all RPC listeners.


> I'm thinking=20
> the only reason privilege ports were being uses was=20
> a side effect of create_rmtcall_fd() calling=20
> svc_tli_create() with an unbound socket.

Privileged listener ports are being created because
svc_tli_create is using bindresvport when the passed
in socket is not already bound.

svc_tli_create should use bind instead, and it needs
to choose a port higher than 49151.

=
https://www.iana.org/assignments/service-names-port-numbers/service-names-=
port-numbers.xhtml


> So the following patch simply binds the socket
> before calling svc_tli_create() which means a
> non-privilege port will be reserved for remote
> calls.=20
>=20
> I'm thinking this is the simplest way to
> not pollute the privilege port space.=20

This is going in the right direction, but the problem
needs to be addressed in svc_tli_create, not in each
application that calls svc_tli_create.

This is the same issue that Guillem Jover was trying to
address by making bindresvport skip well-known ports.

In other words: this code in src/svc_generic.c is wrong:

218         /*
219          * If the fd is unbound, try to bind it.
220          */
221         if (madefd || !__rpc_sockisbound(fd)) {
222                 if (bindaddr =3D=3D NULL) {
223                         if (bindresvport(fd, NULL) < 0) {
                                ^^^^^^^^^^^^

224                                 memset(&ss, 0, sizeof ss);
225                                 ss.ss_family =3D si.si_af;
226                                 if (bind(fd, (struct sockaddr =
*)(void *)&ss,
227                                     (socklen_t)si.si_alen) < 0) {
228                                         warnx(
229                         "svc_tli_create: could not bind to anonymous =
port");
230                                         goto freedata;
231                                 }
232                         }
233                         listen(fd, SOMAXCONN);
234                 } else {
235                         if (bind(fd,
236                             (struct sockaddr *)bindaddr->addr.buf,
237                             (socklen_t)si.si_alen) < 0) {
238                                 warnx(
239                 "svc_tli_create: could not bind to requested =
address");
240                                 goto freedata;
241                         }
242                         listen(fd, (int)bindaddr->qlen);
243                 }
244=20
245         }


> Steve Dickson (1):
>  rmtcalls: Don't use privileged ports for remote calls.
>=20
> src/rpcb_svc_com.c | 19 ++++++++++++++++++-
> 1 file changed, 18 insertions(+), 1 deletion(-)


--
Chuck Lever



