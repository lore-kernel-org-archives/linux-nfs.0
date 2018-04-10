Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:46890 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754337AbeDJW3h (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Apr 2018 18:29:37 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH 2/2] Restore creating listening connection to server
 connections
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180410213043.5545-2-steved@redhat.com>
Date: Tue, 10 Apr 2018 16:29:24 -0600
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <AEE2F42D-04C5-45AA-BC4B-773ED41B238E@oracle.com>
References: <20180410213043.5545-1-steved@redhat.com>
 <20180410213043.5545-2-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Apr 10, 2018, at 3:30 PM, Steve Dickson <steved@redhat.com> wrote:
>=20
> Commit 46e04a73 changed svc_com_create() to avoid using
> reserve ports but removed the listen() call which
> could break, undocumented expectations, of legacy
> server apps.
>=20
> Reserve ports are not needed for listening ports, so
> the new  __binddynport() is used to avoid squatting
> on ports that are assigned to other network services,
> but it is important to say backwards compatible
> with the legacy glibc code so the the listen()
> call is added back.

svc_tli_create should already perform a call to __binddynport()
and to listen(2). That's why those calls were removed from
svc_com_create().

 222         if (madefd || !__rpc_sockisbound(fd)) {
 223                 if (bindaddr =3D=3D NULL) {
 224                         if (__binddynport(fd) =3D=3D -1) {
 225                                 warnx(
 226                         "svc_tli_create: could not bind to =
anonymous port");
 227                                 goto freedata;
 228                         }
 229                         listen(fd, SOMAXCONN);
 230                 } else {
 231                         if (bind(fd,
 232                             (struct sockaddr *)bindaddr->addr.buf,
 233                             (socklen_t)si.si_alen) < 0) {
 234                                 warnx(
 235                 "svc_tli_create: could not bind to requested =
address");
 236                                 goto freedata;
 237                         }
 238                         listen(fd, (int)bindaddr->qlen);
 239                 }
 240                        =20
 241         }

I expect that __rpc_sockisbound(fd) should be false
if svc_tli_create() is called from svc_com_create().
Can you tell why it isn't?


> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> src/rpc_soc.c | 7 +++++++
> 1 file changed, 7 insertions(+)
>=20
> diff --git a/src/rpc_soc.c b/src/rpc_soc.c
> index f32a27c..cf15216 100644
> --- a/src/rpc_soc.c
> +++ b/src/rpc_soc.c
> @@ -331,6 +331,13 @@ svc_com_create(fd, sendsize, recvsize, netid)
> 		madefd =3D TRUE;
> 	}
>=20
> +	if (__binddynport(fd) =3D=3D -1) {
> +		if (madefd)
> +			(void)close(fd);
> +		(void) syslog(LOG_ERR,
> +			"svc%s_create: could not bind connection: %m", =
netid);
> +	}
> +	listen(fd, SOMAXCONN);
> 	svc =3D svc_tli_create(fd, nconf, NULL, sendsize, recvsize);
> 	(void) freenetconfigent(nconf);
> 	if (svc =3D=3D NULL) {
> --=20
> 2.14.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



