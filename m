Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from prv3-mh.provo.novell.com ([137.65.250.26]:51936 "EHLO
	prv3-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbcDCD7N (ORCPT
	<rfc822;groupwise-linux-nfs@vger.kernel.org:0:0>);
	Sat, 2 Apr 2016 23:59:13 -0400
From: NeilBrown <nfbrown@novell.com>
To: Richard Laager <rlaager@wiktel.com>, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com
Date: Sun, 03 Apr 2016 13:58:59 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: NFS Client Ignores TCP Resets
In-Reply-To: <56BFE55D.1010509@wiktel.com>
References: <56BFE55D.1010509@wiktel.com>
Message-ID: <87twjjpcl8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, Feb 14 2016, Richard Laager wrote:

> [1.] One line summary of the problem:
>
> NFS Client Ignores TCP Resets
>
> [2.] Full description of the problem/report:
>
> Steps to reproduce:
> 1) Mount NFS share from HA cluster with TCP.
> 2) Failover the HA cluster. (The NFS server's IP address moves from one
>     machine to the other.)
> 3) Access the mounted NFS share from the client (an `ls` is sufficient).
>
> Expected results:
> Accessing the NFS mount works fine immediately.
>
> Actual results:
> Accessing the NFS mount hangs for 5 minutes. Then the TCP connection=20
> times out, a new connection is established, and it works fine again.
>
> After the IP moves, the new server responds to the client with TCP RST=20
> packets, just as I would expect. I would expect the client to tear down=20
> its TCP connection immediately and re-establish a new one. But it=20
> doesn't. Am I confused, or is this a bug?
>
> For the duration of this test, all iptables firewalling was disabled on=20
> the client machine.
>
> I have a packet capture of a minimized test (just a simple ls):
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1542826/+attachment/=
4571304/+files/dovecot-test.upstream-kernel.pcap

I notice that the server sends packets from a different MAC address to
the one it advertises in ARP replies (and the one the client sends to).
This is probably normal - maybe you have two interfaces bonded together?

Maybe it would help to be explicit about the network configuration
between client and server - are there switches?  soft or hard?

Where is tcpdump being run?  On the (virtual) client, or on the
(physical) host or elsewhere?

As you say, everything looks perfect until the server sends an RST and
the client appears to ignore it.  The from/to addresses are all
identical to those on the subsequent SYN/ACK which is not ignored so it
seems unlikely that the SYN/ACK would get through but not the RST.

This bug (it is definitely a bug somewhere) looks suspiciously similar
to the one fixed by
Commit: 7b514a886ba5 ("tcp: accept RST without ACK flag")
but that was fixed 3 years ago - a temporary bug in v3.8.  I cannot see
any evidence that it has crept back.

Can you create a TCP connection to some other port on the server
(telnet? ssh? http?) and see what happens to it on fail-over?
You would need some protocol that the server won't quickly close.
Maybe just "telnet SERVER 2049" and don't type anything until after the
failover.

If that closes quickly, then maybe it is an NFS bug.  If that persists
for a long timeout before closing, then it must be a network bug -
either in the network code or the network hardware.
In that case, netdev@vger.kernel.org might be the best place to ask.

Looking at the debug logs, the most interesting (to me) part is

2016-03-11T03:27:24.897463-06:00 imap1 kernel:
  [  479.708050] RPC:       xs_error_report client ffff88003cfe4000, error=
=3D113...

error 113 is EHOSTUNREACH.  This strongly suggests that the network layer
didn't "see" the RST and has only broken the connection because it isn't
getting a reply from the server for it's GETATTR retransmissions.

If you were up to building your own kernel, I would suggest putting some
printks in tcp_validate_incoming() (in net/ipv4/tcp_input.c).

Print a message if th->rst is ever set, and another if the
tcp_sequence() test causes it to be discarded.  It shouldn't but
something seems to be discarding it somewhere...

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXAJUDAAoJEDnsnt1WYoG5oOcP/26lNRWD5SZ8VTkw0Sielwhp
u2PcQf0Ex0ZKKPYDLfe/DaYrZTqxrkHPQph80Y+Gev9MkHOSEjc2uPeK2x/4vv+r
ET7rNU0DDyzdpfHQcGDOoSpszhxwDluHEsQgxkeJidXc6pY4GmePASOgKS7hguZQ
cktQ5x8JrcGigxLBWQI4H19Jhrrb1dlS/7IacobKcqNpSrsxpmfdSz/EHG8aNPwU
1Xdy21k3WUwpW7GAxCFp69MDnxws5s4rPxAnbSZTQWhhxI6IcGQp2zO6LyX0Zx5I
mC9v8FPM0ydi9J2UUuC28t0HbBgm9HJjXQdTWe1+BhmztlQyH8KIBpRbNpQz0fsE
/H3c/EAVYh+fMNDSifTCCcta4ttuiFX7/LNRCHSkkNWp3kZpfr5hrlaUKbc8OCXa
XANzSCUmX6y/GZ2ASi4lOWntSzPoJoCstsUTqs2t3+30IlAAIo6SX9v6g310cMxL
yu5L1tsmLVhWMbaCWCmW4JKMo9a5c+SYzUEu6hHJ1IVkWg4Kutc2UCGx0E5Jmhna
pfjQ6EZf/pJH4CSKlYLe8GkdutfYu/9jRPwEolQCwe8cnDr/WCEQXVQwrHmegZa9
n05KQ9HSfcjSj6tO1LaImPKGulMnpaO9M4mmQDKaztvGeuU7tfsvBj3gqtTHDj0Y
MWTA+Kydg8xkdUn8ULCt
=4Dup
-----END PGP SIGNATURE-----
--=-=-=--
