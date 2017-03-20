Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from karr.yath.de ([144.76.4.50]:57726 "EHLO karr.yath.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755439AbdCTWte (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Mar 2017 18:49:34 -0400
Date: Mon, 20 Mar 2017 23:42:14 +0100
From: Sebastian Schmidt <yath@yath.de>
To: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
Subject: Re: Infinite loop when connecting to unreachable NFS servers
Message-ID: <20170320224214.kksu3dd2lhmz6mhr@marax.lan.yath.de>
References: <20170314221525.u7e6fjfmh2qurhtx@marax.lan.yath.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="5u7zfcav4zc6cw5s"
In-Reply-To: <20170314221525.u7e6fjfmh2qurhtx@marax.lan.yath.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--5u7zfcav4zc6cw5s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Mar 14, 2017 at 11:15:25PM +0100, Sebastian Schmidt wrote:
> I was debugging some mysterious high CPU usage and tracked it down to
> monitoring daemon regularly calling stat*() on an NFS automount
> directory. The problem is triggered when mount.nfs passes mount() an
> addr=3D that points to an unreachable address (i.e. connecting fails
> immediately).

I looked further into the busy-reconnect issue and I want to share what
I believe happens.

My initial report called mount.nfs with "2001:4860:4860:0:0:0:0:8888:/"=20
which is, as Jeff pointed out, incorrect, but it caused mount(2) to be=20
called with addr=3D0.0.7.209. In reality, I'm losing my default route and=
=20
an actually valid addr=3D is getting passed to mount(), but both cases hit
the same code.

In xs_tcp_setup_socket(), xs_tcp_finish_connecting() returns an error.=20
For my made-up test case (0.0.7.209) it's EINVAL, in real life
ENETUNREACH. The third trigger is passing a valid IPv6 addr=3D and setting
net.ipv6.conf.all.disable_ipv6 to 1, thereby causing an EADDRNOTAVAIL.

Interestingly, the EADDRNOTAVAIL branch has this comment:
        /* We're probably in TIME_WAIT. Get rid of existing socket,
         * and retry
         */
        xs_tcp_force_close(xprt);
        break;

whereas the EINVAL and ENETUNREACH case carries this one:
        /* retry with existing socket, after a delay */
        xs_tcp_force_close(xprt);
        goto out;

So both calls to xs_tcp_force_close() claim to retry, but one reuses the
socket and the other doesn't? The only code skipped by the "goto out"=20
for the second case is "status =3D -EAGAIN", and this apparently does not
cause any delayed retries either.

That second case got changed in=20
4efdd92c921135175a85452cd41273d9e2788db3, where the call to=20
xs_tcp_force_close() was added initially. That call, however, causes an=20
autoclose call via xprt_force_disconnect(), eventually invalidating=20
transport->sock.

That transport->sock, however, is being checked in xs_connect() for=20
!NULL and, in that case only, a delayed reconnect is scheduled. If=20
disable_ipv6=3D1 would already have caused connect() to return=20
EADDRNOTAVAIL, rather than ENETUNREACH as with 3.19-ish, that same=20
busy-reconnect loop would have also been triggered in that case, even=20
before 4efdd92c.

So apparently the (only?) code that's responsible for delaying a=20
reconnect is in xs_connect(), and due to the fact that=20
xs_tcp_force_close() is called on every connection error,=20
transport->sock gets NULLed due to autoclose and that delay code is=20
never run.=20

Here I'm stuck at figuring out what the code is intented to do and would
appreciate any help.

Thanks,

Sebastian

--5u7zfcav4zc6cw5s
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEdExETVib0Dz3caHc+HHcS2EGWqMFAljQWsIACgkQ+HHcS2EG
WqN6oxAAsfgD0hieP+g+k01CoxsG2RUla+CgMoqoNgS8mBEPNODLH4NadNJ4qIZI
pdY9VKPg5Bl8ut48o2uFoGjp0RTlTFoMXm8lR9HPPwZc2ilfx5x6JmiQSllf8VmL
ggzzZVdsUNokqepi+qIreYRpyZYsquWoIUR5o+Kry2dDBSvyi2AXyyv2XpQ0UUpE
JZDB/XgSdfvabXRzafR5IudImk/J5k053LT5TrNrNFOCz1mQSZ6QrCEUu/r2/4et
43JvkjHarBg4jAc8Ucy1G42q3OZUZ+lJbup+hEx2tCItNLCPK5oJD+8HlxAPMprO
Q/E5aaBZQ69vxSCfU6wfQZxLpGQObeR7ye31QnAEu1vnJKFIAqkbHYf7fUBNSVAn
DXTeLEdaxUnGO0ev89HAs56ORw6AFZpv6o/nH2oxDW5BIHgzXYydflMbNRbT4dgv
CqUeXppmcBK/xrMSOzXvypWHaC9WskxGfY+gitwL3nm512oXTPDj2uDa+meQFrmR
xd1pZrydzy5KPN7ib5sZDomgxcmDUAl92PCLS2YW/aU/ROs5VDP13E71uRVApHXi
UcvSJ6vk71Exr6q6/xAOsRieUxybqidFXuEwTK2ttL4VvwQQJQ0wa9vALWJHRTq0
DKpoDp7uuOTe+HKpu1xGCOdb4lT1u2zrTe3KU/JXVNSmYwA+iNs=
=19Eh
-----END PGP SIGNATURE-----

--5u7zfcav4zc6cw5s--
