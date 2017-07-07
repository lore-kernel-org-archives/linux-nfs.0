Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45047 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753296AbdGGDSF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Jul 2017 23:18:05 -0400
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Date: Fri, 07 Jul 2017 13:17:54 +1000
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
In-Reply-To: <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com>
References: <20170630132120.31578-1-stefanha@redhat.com> <20170630132120.31578-6-stefanha@redhat.com> <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com>
Message-ID: <87wp7lvst9.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Fri, Jun 30 2017, Chuck Lever wrote:
>
> Wouldn't it be nicer if it worked like this:
>
> (guest)$ cat /etc/hosts
> 129.0.0.2  localhyper
> (guest)$ mount.nfs localhyper:/export /mnt
>
> And the result was a working NFS mount of the
> local hypervisor, using whatever NFS version the
> two both support, with no changes needed to the
> NFS implementation or the understanding of the
> system administrator?

Yes. Yes. Definitely Yes.
Though I suspect you mean "127.0.0.2", not "129..."??

There must be some way to redirect TCP connections to some address
transparently through to the vsock protocol.
The "sshuttle" program does this to transparently forward TCP connections
over an ssh connection.  Using a similar technique to forward
connections over vsock shouldn't be hard.

Or is performance really critical, and you get too much copying when you
try forwarding connections?  I suspect that is fixable, but it would be
a little less straight forward.

I would really *not* like to see vsock support being bolted into one
network tool after another.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlle/WMACgkQOeye3VZi
gbk2Ow//Z59h3Oms4SZHQGea6qeLnxrxuZwMHKiFeSaIIQnTcKPZC2ANS3bxkZTj
oyMiMVky9Fwu/BkqYGZUZmYODKUPOkDMQqJ+FEIeQJEfRKn42f/CPjB6f5PtQXOK
P4MZ4KxWX9adAks6h99IZ8o6aFBJSrksT6jhXYU5qYOAvOzv5gFpFOL0HQkBb/RT
YQ1igObfOTDOa5M1iUX1zHwAWuqqrsVQ8C4gBS/11uRAWVDJquvXp1H+EkxHLIl1
gZy4fFcA+eSeRuiOGvPGg8YmjBdMuTnoU+1vNWASjuNx0I2azvGVWOUMfz4RzCo5
b9+pXygsQuSB2GmC94dQRHy94tm8VdkSJ++/1uvIn9X3qML2U07yxGfMJvPLObnn
/qLKDedt2Y6qg44dPoCeWagCJag3I5VMvCjdEipAgnCgxNf8mXFd3Jsau0p2Qb2O
LVapXCLfVJT5LOPPsbxyZ2z46Sl513PDZOu6dczMyHGdgWzoO2qV9GAMHN8+87k3
HXxYbjElycqacwH1/dnFvxs2GttoX7onBpC3Ic0jZimQ8wjvZ5/oAo3kBwErGEWn
4tNKgRENmuce19AcQRYZ/TV216KlF+hYhw9PyPDC5U39IqDtQYi9jAh4MCaUczgK
BN/YOOolJvpOGD/hOr5sc7HA4BOo/SVeHQKfzwEeP3b2pbEhTQ0=
=QGcl
-----END PGP SIGNATURE-----
--=-=-=--
