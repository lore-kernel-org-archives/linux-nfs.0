Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42328 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750719AbaBJGD2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Feb 2014 01:03:28 -0500
Date: Mon, 10 Feb 2014 17:03:15 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: xprt_wait_for_buffer_space changes causes a hang.
Message-ID: <20140210170315.33dfc621@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Sjf07ES_F1gAV4lJJlgAlu/"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Sjf07ES_F1gAV4lJJlgAlu/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi,
 We have a customer who reports occasional but reproducible hangs on our 3.0
 based kernel.
 I managed to deduce that=20

commit a9a6b52ee1baa865283a91eb8d443ee91adfca56
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Feb 22 14:57:57 2013 -0500

    SUNRPC: Don't start the retransmission timer when out of socket space
=20
was to blame (it got into our kernel through -stable ... not sure why it
deserved to be in -stable). Reverting that patch fixes the problem.  Howeve=
r I
don't fully understand why.

Analysing the logs suggests that the NFS client had tried to write a request
to the socket, failed as the transmit queue was temporarily full, and never
got the call-back when the queue emptied.  All other requests piled up behi=
nd
this one and all traffic stopped.

With the above commit reverted, the client will timeout and retry the
transmit even if the call-back hasn't arrived.  With the patch, it waits
indefinitely.

This suggests that there is a race in the SOCK_ASYNC_NOSPACE handling.

The most obvious place for a race would be in xs_nospace() between

		if (test_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags)) {

and before
			xprt_wait_for_buffer_space(task, xs_nospace_callback);

However xprt->transport_lock is held here, and xprt_write_space() will wait
for the lock before calling rpc_wake_up_queued_task(), so the wakeup cannot
happen before the task is put on the pending list.

My only remaining theory is that the space is freed before SOCK_NOSPACE is
set in xs_nospace().  I think this would mean that the callback never happe=
ns.

In net/ipv4/tcp.c, in tcp_poll() there is code:

			if (sk_stream_is_writeable(sk)) {
				mask |=3D POLLOUT | POLLWRNORM;
			} else {  /* send SIGIO later */
				set_bit(SOCK_ASYNC_NOSPACE,
					&sk->sk_socket->flags);
				set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);

				/* Race breaker. If space is freed after
				 * wspace test but before the flags are set,
				 * IO signal will be lost.
				 */
				if (sk_stream_is_writeable(sk))
					mask |=3D POLLOUT | POLLWRNORM;
			}


which suggests there is room for a race, and seems to suggest that it is
safest to test sk_stream_is_writeable() after setting SOCK_NOSPACE.
This is what the sunrpc server side does for udp (svc_udp_has_wspace).
For tcp it doesn't something which I don't really understand, so maybe  I'm
missing something.

Any thoughts?  I could try asking the customer to test with an extra check
for sk_stream_is_writeable before calling xprt_wait_for_buffer_space(), but=
 I
wouldn't be surprised if they'd rather not given they have a working soluti=
on.
Does someone understand this code enough to be confident that such a test
would be correct?

Thanks,
NeilBrown

--Sig_/Sjf07ES_F1gAV4lJJlgAlu/
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvhroznsnt1WYoG5AQJ8Mg/+Pk4oktqSa7AGxRkRldDngQmiOwMwJnsE
O1Pi52HqHpMN8+W4CqAfFirMTmND2Pl/G+LX94Igbpk3X2lxUQRPoAByt7L3rJyT
4gPMn5jH+gVlPCSqj2Y80QWEtMVQQE0bOWDkkLRlwLUt+2N2nl4+TVc1MrE5/TkL
JUw6dKSXiRg+fgLg4rlhOOKdgm+m05KXKQqNAfXkxomssO89/HUpgFgPmS5k9A55
jPk+CVolLimO/PhSmMLyK8CBcn54Qn2PxprVg9GRc+asPr9Z8FhcdVxVjmY2vSbW
vIGx25Vy86TpYBq1AW88Eub+53yScXEfzFksDhfyG14SK15WznPfGWqt2N2PpnYB
Vkf6XSukdsKQradkBXKewZ5eL0CLeQbk/69VmJbNSdQPM9fR0xBHOj1B2NrIhoZm
zXkw/Rqk1QR0xwr9u+hKUWIBHs4JVqju5ka/wItd0jJu0R3nGBxKSqmbXM6+BBZt
QtU1bU0VjQmfE/G/b4qJEt7ag8bSTEQD8uq992fDUfLN+isXz9FXgOr/gdzDr7Rw
99A/EJ7m4USQrIqqjZfDBN3xH+9Pf1cmwZd/wcLflGithNufw3nSrkz9kv5heJM1
73Lb1AqhPCyFg/quSysLSGkisKTOqp3Ut8TLJm9vt767w4m8bknvIvBTBeiDoeMc
tAcfQvir9dU=
=34HU
-----END PGP SIGNATURE-----

--Sig_/Sjf07ES_F1gAV4lJJlgAlu/--
