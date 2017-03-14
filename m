Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from karr.yath.de ([144.76.4.50]:53218 "EHLO karr.yath.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750984AbdCNW0X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 18:26:23 -0400
Date: Tue, 14 Mar 2017 23:15:25 +0100
From: Sebastian Schmidt <yath@yath.de>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
Subject: Infinite loop when connecting to unreachable NFS servers
Message-ID: <20170314221525.u7e6fjfmh2qurhtx@marax.lan.yath.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="gxdjayzebdau5y5k"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--gxdjayzebdau5y5k
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I was debugging some mysterious high CPU usage and tracked it down to
monitoring daemon regularly calling stat*() on an NFS automount
directory. The problem is triggered when mount.nfs passes mount() an
addr= that points to an unreachable address (i.e. connecting fails
immediately).

One way to reproduce is by trying to mount Google's DNS server, whose
IPv6 address isn't properly parsed or rejected by nfs-utils, causing an
invalid addr= to be passed to mount():

# strace -vf mount.nfs -v 2001:4860:4860:0:0:0:0:8888:/ /mnt
write(1, "mount.nfs: timeout set for Tue Mar 14 22:57:49 2017", ...
[...]
socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP) = 3
bind(3, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
connect(3, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("0.0.7.209")}, 16) = -1 EINVAL (Invalid argument)
close(3)                                = 0
write(1, "mount.nfs: trying text-based options 'vers=4.2,addr=0.0.7.209,clientaddr=0.0.0.0'", ...
mount("2001:4860:4860:0:0:0:0:8888:/", "/mnt", "nfs", 0, "vers=4.2,addr=0.0.7.209,clientad"...) = ?
+++ killed by SIGKILL +++

While this is certainly a bug in mount.nfs, too, the bug can also be
triggered with net.conf.ipv6.all.disable_ipv6=1 and using a hostname that
resolves to an IPv6 address only (/etc/hosts works) with mount.nfs.

<4>[ 6564.082853] RPC:     8 sleep_on(queue "xprt_pending" time 4296533344)
<4>[ 6564.082855] RPC:     8 added to queue ffff8a673b146a18 "xprt_pending"
<4>[ 6564.082858] RPC:     8 setting alarm for 180000 ms
<4>[ 6564.082860] RPC:       xs_connect scheduled xprt ffff8a673b146800
<4>[ 6564.082863] RPC:     8 sync task going to sleep
<4>[ 6564.082868] RPC:       xs_bind 0000:0000:0000:0000:0000:0000:0000:0000:784: ok (0)
<4>[ 6564.082870] RPC:       worker connecting xprt ffff8a673b146800 via tcp to 2001:4860:4860::8888 (port 2049)
<4>[ 6564.082874] RPC:       ffff8a673b146800 connect status 99 connected 0 sock state 7
<4>[ 6564.082876] RPC:     8 __rpc_wake_up_task (now 4296533344)
<4>[ 6564.082878] RPC:     8 disabling timer
<4>[ 6564.082880] RPC:     8 removed from queue ffff8a673b146a18 "xprt_pending"
<4>[ 6564.082883] RPC:       __rpc_wake_up_task done
<4>[ 6564.082885] RPC:       xs_tcp_state_change client ffff8a673b146800...
<4>[ 6564.082887] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
<4>[ 6564.082889] RPC:       disconnected transport ffff8a673b146800
<4>[ 6564.082893] RPC:       wake_up_first(ffff8a673b146970 "xprt_sending")
<4>[ 6564.082897] RPC:     8 sync task resuming
<4>[ 6564.082899] RPC:     8 xprt_connect_status: retrying
<4>[ 6564.082901] RPC:     8 call_connect_status (status -11)
<4>[ 6564.082903] RPC:     8 call_timeout (minor)
<4>[ 6564.082905] RPC:     8 call_bind (status 0)
<4>[ 6564.082907] RPC:     8 call_connect xprt ffff8a673b146800 is not connected
<4>[ 6564.082909] RPC:     8 xprt_connect xprt ffff8a673b146800 is not connected
<4>[ 6564.082912] RPC:     8 sleep_on(queue "xprt_pending" time 4296533344)
<4>[ 6564.082913] RPC:     8 added to queue ffff8a673b146a18 "xprt_pending"
<4>[ 6564.082914] RPC:     8 setting alarm for 180000 ms
<4>[ 6564.082914] RPC:       xs_connect scheduled xprt ffff8a673b146800
<4>[ 6564.082916] RPC:     8 sync task going to sleep
<4>[ 6564.082919] RPC:       xs_bind 0000:0000:0000:0000:0000:0000:0000:0000:938: ok (0)
<4>[ 6564.082920] RPC:       worker connecting xprt ffff8a673b146800 via tcp to 2001:4860:4860::8888 (port 2049)
<4>[ 6564.082923] RPC:       ffff8a673b146800 connect status 99 connected 0 sock state 7
<4>[ 6564.082924] RPC:     8 __rpc_wake_up_task (now 4296533344)
<4>[ 6564.082924] RPC:     8 disabling timer
(and so on, until mount() times out)

Similar for the IPv6-literal test case, where it's failing to connect to
0.0.7.209, so it's affecting IPv4, too. While grepping around I found a
comment saying "If a UDP socket connect fails, the delay behavior here
prevents retry floods (hard mounts)." for xs_connect(), but I haven't
figured out how to trigger the UDP connection code.

Sebastian

--gxdjayzebdau5y5k
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEdExETVib0Dz3caHc+HHcS2EGWqMFAljIa3kACgkQ+HHcS2EG
WqPEJhAAtp5++8PqYt/ewfihSOor34/73CzhZn6lVG25KE1UtFxJL+BgQbW/d52+
UjptXgZDKSKn8/wTtKALGqGceCrxFhM0Vx2pEHgy4kTg3h6ep6LYqlwSYz9FCNls
SPXf4LxjzZcT+dFobWMTwliGlU5eCVkOs2aG7mIG3/8nP0uGAEOsp2cG+SNH6okf
dWVmd6mLhlzb9HZumRrd5QVed0i8BsEmnAA+OZLT6v9aaL9yxZaIKSvK3OUJ0/I2
Bt2sow62BzbJvh35AZEFxaPgpWFDsty9+qXPGPs36h4St0qL6lvOo3ABPWcq/r1/
ryWb30Z2xzdoiYPE5SqBPxisY9mlBp2wdpudr7nKFyKM5QCEi/evrxAgi49aV3mz
3CfeOBkmbnsILoKU5H0W6vL3ixwt7YPVDpd4bXf5lqRMXbMxgjI+dqnwvnXiwChA
n4qSJjRnnct5jV5lceAm0eKrLLdJsxjyKrzDpkm47K95njxyqgt1UZeaLmodKDKy
nc4nfLqgkpORTKNJc/qbCxVry1i9U4LRRoO1zISxoUml71/rBr543EIvsOzyX1MR
64GLi4cdLt8jy3sxXjcPXolegqshLOjnsHor3EF3Yl47rZvZO1czUC5nEeXDvslA
+8SwRfYfamMTr5MdInMPx89XWmLriTERvJIdQs/1SB4h9LsC/4g=
=U7FT
-----END PGP SIGNATURE-----

--gxdjayzebdau5y5k--
