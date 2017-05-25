Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35395 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755860AbdEYHAm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 May 2017 03:00:42 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Thu, 25 May 2017 17:00:32 +1000
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: ensure correct error is reported by
 xs_tcp_setup_socket()
Message-ID: <871srdifov.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If you attempt a TCP mount from an host that is unreachable in a way
that triggers an immediate error from kernel_connect(), that error
does not propagate up, instead EAGAIN is reported.

This results in call_connect_status receiving the wrong error.

A case that it easy to demonstrate is to attempt to mount from an
address that results in ENETUNREACH, but first deleting any default
route.
Without this patch, the mount.nfs process is persistently runnable
and is hard to kill.  With this patch it exits as it should.

The problem is caused by the fact that xs_tcp_force_close() eventually
calls
      xprt_wake_pending_tasks(xprt, -EAGAIN);
which causes an error return of -EAGAIN.  so when xs_tcp_setup_sock()
calls
      xprt_wake_pending_tasks(xprt, status);
the status is ignored.

Fixes: 4efdd92c9211 ("SUNRPC: Remove TCP client connection reset hack")
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/xprtsock.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 16aff8ddc16f..d5b54c020dec 100644
=2D-- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2432,7 +2432,12 @@ static void xs_tcp_setup_socket(struct work_struct *=
work)
 	case -ENETUNREACH:
 	case -EADDRINUSE:
 	case -ENOBUFS:
=2D		/* retry with existing socket, after a delay */
+		/*
+		 * xs_tcp_force_close() wakes tasks with -EIO.
+		 * We need to wake them first to ensure the
+		 * correct error code.
+		 */
+		xprt_wake_pending_tasks(xprt, status);
 		xs_tcp_force_close(xprt);
 		goto out;
 	}
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlkmgRIACgkQOeye3VZi
gbnEMRAAs2Zm1xmPKgbuJr12f0RXtOHG+nG42SeEN7xZ7CJCTSr4MDbBOk0jgvzA
8ipzyqKuYkO0Bqf2WhVCthjGSlAtF7or7GiKiaaGl3A7fFAw47TG2joeZrNb3Zqq
ZsGPoPb2J1frBIWWHJAaA9+lCjlAzgsf4kpy3VMhJXNr50cJi6cJsj+KHQ44PGGj
iur8u+S/oNP24PtqquA3FCmgEpGxYHs1aR4pEXoKxpUTaG71toU/ROynyeJE8n6E
h6fO7RC/BAAzBR5res2+LbKGxJdovYBEAGmhKPaRQMsaoqgyIcLg1gm2Oi8nA6Va
81CcROczggOfuYyKJ7m+qO6/L5Hn2yYAY9L+VnVB8jMqpfiWIyVgOeF39FgY2lvY
3lt3j1FatEHvEJ6LTQun8lF0hrO/3foI4PoaI2zctOlm7j0rdz+haiFO8yNeJcM+
KzYVI5PS1laIJ8+UBX+Jo4lPalmAMnj6OmuaZzjw5uGHiRudEmfgENbec7ce5OwT
Mb7W3b7Spl0DbrNyxytQG37j9b56FE5ahqEwxPJf9nd3+H0oOo3yw+M0QYSDGdQr
4XtJfNtfBZ+4UX6YR/Hvhoj/GfngEgrsoBY4v5SHab7jrQgbOOaSbFKrwdaVqlL0
rarBStkzRdBcKvcgD85XqoA7t0XPGUlh6t3ilwe4OPOqLDTb6mE=
=hdTc
-----END PGP SIGNATURE-----
--=-=-=--
