Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:51536 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751239AbaIYAcS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2014 20:32:18 -0400
Date: Thu, 25 Sep 2014 10:32:10 +1000
From: NeilBrown <neilb@suse.de>
To: "=?UTF-8?B?U3Ryw7Zzc2VyLA==?= Bodo" <bodo.stroesser@ts.fujitsu.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Subject: Re: rpc.mountd can be blocked by a bad client
Message-ID: <20140925103210.5423676f@notabene.brown>
In-Reply-To: <8B06D1E6480A6747B23FEC34909D2B5EA819D7DCA4@ABGEX70E.FSC.NET>
References: <8B06D1E6480A6747B23FEC34909D2B5EA819D7DCA4@ABGEX70E.FSC.NET>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/fjelDp+bCuy0PTGz5UaNctV"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/fjelDp+bCuy0PTGz5UaNctV
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, 24 Sep 2014 12:57:09 +0200 "Str=C3=B6sser, Bodo"
<bodo.stroesser@ts.fujitsu.com> wrote:

> Hello,
>=20
> a few days ago we had some trouble with a NFS server. The clients most of=
 the time no longer
> could mount any shares, but in rare cases they had success.
>=20
> We found out, that during the times when mounts failed, rpc.mountd hung o=
n a write() to a TCP
> socket. netstat showed, that Send-Q was full and Recv-Q counted up slowly=
. After a long time
> the write ended with an error ("TCP timeout" IIRC) and rpc.mountd worked =
normally for a short
> while until it again hung on write() for the same reason. The problem was=
 caused by a MTU size
> configured wrong. So, one single bad client (or as much clients as the nu=
mber of threads used
> by rpc.mountd) can block rpc.mountd entirely.
>=20
> But what will happen, if someone intentionally sends RPC requests, but do=
esn't read() the
> answers? I wrote a small tool to test this situation. It fires DUMP reque=
sts to rpc.mountd as
> fast as possible, but does not read from the socket. The result is the sa=
me as with the
> problem above: rpc.mountd hangs in write() and no longer responds to othe=
r requests while no
> TCP timeout breaks up this situation.
>=20
> So it's quite easy to intentionally block rpc.mountd from remote.

That's rather nasty.
We could possibly set the socket to be non-blocking, or we could set an ala=
rm
just before handling a request.
Probably rpc_dispatch() in support/nfs/rpcdispatch.c would be the best place
to put the timeout.
 catch SIGALRM (don't set SA_RESTART)
 alarm(10);
 call svc_sendreply
 alarm(0);

if the alarm fires while svc_sendreply is writing to the socket it should g=
et
an error and close the connection.

This would only fix mountd (as it is the only process to use rpc_dispatch).
Is a similar thing needed for statd I wonder??  It isn't so important.

NeilBrown

>=20
> Please CC me, I'm not on the list.
>=20
> Best regards,
> Bodo
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/fjelDp+bCuy0PTGz5UaNctV
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCNiijnsnt1WYoG5AQJ/jQ//e+tm97nPyYF8ezCc8DSIa1ATS7NkzKkC
BrdJI/ewjpm45GURCtZk35/QQU4BVNxMtMCkXJ1YH5YqIaBTCyJmQa0TtJoMZn5g
el33gGRHsngIKe6bRhLn5JFdd2bWTi9sSoag0d85XM/cg5q0hZcMT6q/JPMHyYDo
DpMFtZPamdmyjqVfQyGSVb96SRehp9hGUK4C9jfTjMAS1reRzfMweUY1pp/4CMA7
kq0xTVqtFmR5FPQqcCzf1lf76/OAjHAgYtTXqtVw5BXC30dY1qXWlPETXZq+LBhQ
UesAeUchUafEVSMcdQsE8GTvQLIPxEegdDLG4CuDNbhVqpLpTutmdMD3LT29CjGb
zfzYfoOXydt3iJbLEYFlQ73nZiOXY2p7UtF6kzVpLWQliVkYeOetEUZsdpDOwj1L
ompJzVp/AuE3/mHfy7xws88NL3zVV8mkjzClNwlfwMsC5afagUaL5sHJMvF3uqyr
1bfcCoDsdjBPHyG1Cwiy9EIQlWXfiRF/IqcWMEHC+dnMKonRfgU0uaMuUK5KCGvF
kIyw5Pq0KDSdRiDAWHpJ3RdPuhhST3QoY7CwfVDVV3rCSQ7Oj3pAe3oIX4LdMcbr
nKDq7pXXTw49QSbp2NPVZK+Fj23eY7lKJ13+21BG4fWWTBaACISEse1RxpBntfGp
wjFt+49uuqY=
=dk42
-----END PGP SIGNATURE-----

--Sig_/fjelDp+bCuy0PTGz5UaNctV--
