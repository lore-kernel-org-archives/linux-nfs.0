Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:45338 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753282AbaI2Apb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 28 Sep 2014 20:45:31 -0400
Date: Mon, 29 Sep 2014 10:45:05 +1000
From: NeilBrown <neilb@suse.de>
To: netdev@vger.kernel.org
Cc: lkml <linux-kernel@vger.kernel.org>, NFS <linux-nfs@vger.kernel.org>,
        Benjamin ESTRABAUD <be@mpstor.com>
Subject: Connection timeout problem - keepalives or USER_TIMEOUT not
 working.
Message-ID: <20140929104505.0b1ff172@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/ms1jjF.y7Ch+q5roUwibdzy"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ms1jjF.y7Ch+q5roUwibdzy
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Suppose I have a TCP connection to a remote machine and have configured TCP
keep-alive and the new TCP_USER_TIMEOUT so that the connection should close
after a few minutes of not being able to contact the server.

Suppose further that I change my local IP address and then write to the TCP
connection.

What should happen?


My first thought was that the keep-alive mechanism would not see a reply and
would close the connection.
TCP_KEEPIDLE and TCP_KEEPINTVL are both 60 seconds, KEEPCNT is 3.
So 3/4 minute should be all I have to wait ... but no.

Due to

	/* It is alive without keepalive 8) */
	if (tp->packets_out || tcp_send_head(sk))
		goto resched;

in tcp_keepalive_timer(), and due to tcp_send_head(sk) being non-NULL,
no keep-alives are sent (which is reasonable) and we never check if packets
have been received recently (which I'm less sure is reasonable).
I tried the patch below and it made a difference, but not quite the
difference I wanted ... I'll get back to that.

Then I found the TCP_USER_TIMEOUT socket opt.  That seemed to be exactly wh=
at
I wanted.  After all keep-alive is for keeping the connection alive when
nothing is being written.  I want to make it die even when something is..

So I tried setting TCP_USER_TIMEOUT to 60*3 as milliseconds, so 180,000.
No luck.

There are two places where icsk_user_timeout is considered.
One is in the keep-alive processing which, as discussed above, is disabled
when then it a packet on the way out.
The other is in tcp_write_timeout from tcp_retransmit_timer().  I don't know
why that isn't being called .. maybe the packet isn't being transmitted
because there is no local interface associated with that flow any more???
(tcp_write_wakeup returns -113: EHOSTUNREACH)

The connection eventually breaks after about 20 minutes thanks, I think, to
tcp_retries2.

Is there a bug here?  Where is it?  How can I get the connection to break?

This was discovered by mounting an NFSv3 filesystem (via tcp, the default),
changing the local IP address, and writing to an open file.
NFS sets the keep-alive to match the timeo and retrans option.
I added code to set TCP_USER_TIMEOUT as well.
+		unsigned int keeptotal =3D
+			jiffies_to_msecs(xprt->timeout->to_initval)
+			* keepcnt;
...
+		kernel_setsockopt(sock, SOL_TCP, TCP_USER_TIMEOUT,
+				  (char *)&keeptotal, sizeof(keeptotal));


Now I was going to tell you why this patch didn't do what I wanted.
With this patch, we don't bother sending a keep-alive if there are outstand=
ing packets,
but it still triggers a timeout after the appropriate number of probes.
However icsk_probes_out increments much more quickly, thanks to tcp_send_pr=
obe0().
So this makes the timeout happen too soon.  I guess the confirms that the k=
eep-alive timeout
should be considered irrelevant when there are pending outgoing packets??

Ahh.. Just had another thought.  I've added another patch at the end which =
might
be a bit closer to the "right" approach. Maybe.

Thanks,
NeilBrown

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index df90cd1ce37f..51e8a89c7619 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -597,12 +597,6 @@ static void tcp_keepalive_timer (unsigned long data)
 	if (!sock_flag(sk, SOCK_KEEPOPEN) || sk->sk_state =3D=3D TCP_CLOSE)
 		goto out;
=20
-	elapsed =3D keepalive_time_when(tp);
-
-	/* It is alive without keepalive 8) */
-	if (tp->packets_out || tcp_send_head(sk))
-		goto resched;
-
 	elapsed =3D keepalive_time_elapsed(tp);
=20
 	if (elapsed >=3D keepalive_time_when(tp)) {
@@ -618,7 +612,9 @@ static void tcp_keepalive_timer (unsigned long data)
 			tcp_write_err(sk);
 			goto out;
 		}
-		if (tcp_write_wakeup(sk) <=3D 0) {
+		if (tp->packets_out =3D=3D 0 &&
+		    tcp_send_head(sk) =3D=3D NULL &&
+		    tcp_write_wakeup(sk) <=3D 0) {
 			icsk->icsk_probes_out++;
 			elapsed =3D keepalive_intvl_when(tp);
 		} else {
@@ -634,7 +630,6 @@ static void tcp_keepalive_timer (unsigned long data)
=20
 	sk_mem_reclaim(sk);
=20
-resched:
 	inet_csk_reset_keepalive_timer (sk, elapsed);
 	goto out;
=20



Other patch to extend effect of USER_TIMEOUT

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index df90cd1ce37f..3158cc115a60 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -303,7 +303,8 @@ static void tcp_probe_timer(struct sock *sk)
 			return;
 	}
=20
-	if (icsk->icsk_probes_out > max_probes) {
+	if (icsk->icsk_probes_out > max_probes ||
+	    (icsk->icsk_user_timeout && icsk->icsk_user_timeout < keepalive_time_=
elapsed(tp))) {
 		tcp_write_err(sk);
 	} else {
 		/* Only send another probe if we didn't close things up. */

--Sig_/ms1jjF.y7Ch+q5roUwibdzy
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCirkTnsnt1WYoG5AQIDyw//RWrL+U5ea/TlzsuEdZYjgmjt9LGGECuX
AlwHsEea3v/fhMtujpXMh75fdKNVQkwgjd+znqOnxFgL0gWpOVbC2u3EpmraOJzy
5TZ4yqjvUx7bBDNrwPBKpWBtDXLteYZGMn1XebX1VyASDINbr5Dn5kMpiwap7eE/
weQ0Nj0r7THnBI56It8mWOiS0ywhRj1PUItVJQt+WvG7q4ujkZKFrR+Ol3eUyE3r
vBBsoPm54mW3i8C0Q6kpKzhpyWRhqTQKq+MToNwydid0w0jJqb7aJ3smjuOeVk3O
YjN/uUgxcHpoSyrYUzS6fvkzz0yDmMKVlbB9FRdXtHmi34aoR8512L+TbHpUkee5
pDveeecwHvj/vMPntNN2PW+42dw4dqk7QYu3ZxtVPWWj9DMyPNLqn80SEj29eUMj
Fp644MWMoYb4aoEdZfc7MDb1xuaegwP6oCtqACsuOfPj7/OruLie6i9aaVJykBNn
t+ExNb2HCso3GokaRi6mBmxuDvCsBjnjzpwj5Ej5qF3Fz7VkVxcwXetVTQrwt68H
uSZ/TboqFFy6qyvph5q0FBKTM3so6dZN5CBTisSS77orIXtyyQYcSoDyEO+QKc01
D1lX7N2xCyRVO0MxLNdusbaK2CFQhkY5sGQDRfg8ViViSDcyktS5RgQ2D/VPp8sR
gh5av7mD4MU=
=JeG9
-----END PGP SIGNATURE-----

--Sig_/ms1jjF.y7Ch+q5roUwibdzy--
