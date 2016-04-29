Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42043 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751932AbcD2C7P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Apr 2016 22:59:15 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 29 Apr 2016 12:59:07 +1000
Cc: NFS List <linux-nfs@vger.kernel.org>
Subject: [PATCH nfs-utils] systemd unit files: fix up dependencies on rpcbind.
Message-ID: <8760v1unlw.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


The dependencies on rpcbind have been changed a few times and I think
they are still wrong.  So I'll go into some detail to justify this change.

Firstly: rpcbind.target rpcbind.socket or rpcbind.service?

The systemd documentation talks about targets as "synchronization
points" and likens them to SysV init run levels.  Run levels are about
ordering but not dependencies.

The systemd.special man page describes rpcbind.target as intended
explicitly for ordering sysvinit scripts, with "After=3D" dependencies.

So while I think it is valid to use rpcbind.target for ordering
(before/after) it shouldn't be used for dependencies (Wants/Requires).
The rpcbind.target file included in systemd does not "Require" the
actual service, so requiring rpcbind.target itself is pointless.

I think we shouldn't use rpcbind.target at all.  Leave it for sysvinit
synchronization.

So: .socket or .service?

I think nfs only needs the socket to be active.  On first connection
the service will be started.  But nfs does not need to wait for the
service to start, only the socket.  So I think we should exclusively
use rpcbind.socket.

Next: Wants or Requires.

rpc.statd definitely Requires rpcbind.  It needs to register to be
useful, and without rpcbind it cannot register.

nfs-server does not necesarily require rpcbind.  Specifically if
configured for NFSv4 only, nfs-server will work quite happily without
rpcbind.

Someone with an NFSv4 only setup who wants rpcbind to not run can use
  systemctl mask rpcbind.socket
to ensure it never runs.
So nfs-server should only "Wants: rpcbind.socket".
I think
 Commit: 4fabfcd08206 ("systemd: Decouple the starting and stopping of rpcb=
ind/nfs-server")
should have changed "Requires" to "Wants" rather than "server" to "target"
to fix the dependency problem.

Finally: After?

It only makes sense to declare an ordering relation as "After:"
something that will actually be started.  If "foo.service" is not part
of the systemd transaction, then "After: foo.service" has no effect.
So having:
  Requires: rpcbind.target
  After: rpcbind.socket

doesn't make much sense unless there is some relationship between
rpcbind.target and rpcbind.socket, and there is no general guarantee
of that (though what individual distros do, I don't know).
So the "After" should match the "Wants" or "Requires".

It might make sense to
  Requires: rpcbind.socket
  After: rpcbind.target

as it is reasonable to assume that rpcbind.target will be ordered with
rpcbind.socket, but as we can use rpcbind.socket explictly, that is
clearer.

So my conclusion is that nfs-server should:
  Wants: rpcbind.socket
  After: rpcbind.socket

and rpc-statd should
  Requires: rpcbind.socket
  After: rpcbind.socket

which is what this patch puts into effect.

Signed-off-by: NeilBrown <neilb@suse.com>

diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 317e5d689767..2ccdc6344cd5 100644
=2D-- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -1,13 +1,14 @@
 [Unit]
 Description=3DNFS server and services
 DefaultDependencies=3Dno
=2DRequires=3D network.target proc-fs-nfsd.mount rpcbind.target
+Requires=3D network.target proc-fs-nfsd.mount
 Requires=3D nfs-mountd.service
+Wants=3Drpcbind.socket
 Wants=3Drpc-statd.service nfs-idmapd.service
 Wants=3Drpc-statd-notify.service
=20
 After=3D local-fs.target
=2DAfter=3D network.target proc-fs-nfsd.mount rpcbind.service nfs-mountd.se=
rvice
+After=3D network.target proc-fs-nfsd.mount rpcbind.socket nfs-mountd.servi=
ce
 After=3D nfs-idmapd.service rpc-statd.service
 Before=3D rpc-statd-notify.service
=20
diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
index f16ea425dc77..a02f5c41a424 100644
=2D-- a/systemd/rpc-statd.service
+++ b/systemd/rpc-statd.service
@@ -2,8 +2,8 @@
 Description=3DNFS status monitor for NFSv2/3 locking.
 DefaultDependencies=3Dno
 Conflicts=3Dumount.target
=2DRequires=3Dnss-lookup.target rpcbind.target
=2DAfter=3Dnetwork.target nss-lookup.target rpcbind.service
+Requires=3Dnss-lookup.target rpcbind.socket
+After=3Dnetwork.target nss-lookup.target rpcbind.socket
=20
 PartOf=3Dnfs-utils.service
=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXIs37AAoJEDnsnt1WYoG5XL4QAIdN2D1NdNdnSmloTF3Mz+OP
VMXzH2a2i23mgzXP47V5mT557UIH2/tLRtbQNSxckjdwbo56EU9N6yg6VVloKhhS
f+4QkklzCkxukvqaRsA4avNfGuB5WE4BFeSG41qQFaBSe3+1MA7yZZoCddhdUet0
GkF02gUbEoFru3gMfJOdoSquPmONRVSATSSrVW66AMQQMprQ2cHId01Twtto2spx
EKO7MUcaPl3MgTOJZSbkBgVNky2azdX7VUURdFO6zdT9AFucrce7U4L3oOJ2RSSA
Zl8qJO6XHpczEQTQZMAy4hkiESXEXGMlaBGAkiy3VQLogEgbT0vNR1IFRCgw3ih7
+EDiejoiz5c344dgx9d94fRV7+wnmxflnSgKi/mE4wwZu0MZYxJgSvYtLtVQIOh6
8TsY6JHGvTLtbqfkAoxB3BBjEGy8vlZcvighHsFIoRqvmeJV4ocT0UoSY/Yzxymx
Uo+5HF1ziyKIK74IwvFRioGWR1ev5Ut8oJ1TxumwhrIP3stlJ015XIHBiolqNxf6
aSjsFi9mssS+sEmvK6fvm/aX3UYGNXU4oqQMpz2PH/C1yX/xAUKr9ap+xrEg58XG
NmjphhUbFHVfXkpmybgFotN5IpBCnGZcJw+ghoYsLdJBweHQu6PuY885WSEy2H/K
fJA4DSuQ0KLdTxuuqmFX
=8ldy
-----END PGP SIGNATURE-----
--=-=-=--
