From: Bernd Schubert <bernd-schubert@web.de>
Subject: heartbeat nfs stop problem
Date: Sun, 23 May 2004 21:14:19 +0200
Sender: linux-ha-bounces@lists.linux-ha.org
Message-ID: <200405232114.25983.bernd-schubert@web.de>
Reply-To: General Linux-HA mailing list <linux-ha@lists.linux-ha.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1824020240=="
Cc: nfs@lists.sourceforge.net, Chip Salzenberg <chip@pobox.com>
Return-path: <linux-ha-bounces@lists.linux-ha.org>
To: General Linux-HA mailing list <linux-ha@lists.linux-ha.org>
List-Unsubscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=unsubscribe>
List-Archive: <http://lists.community.tummy.com/pipermail/linux-ha>
List-Post: <mailto:linux-ha@lists.linux-ha.org>
List-Help: <mailto:linux-ha-request@lists.linux-ha.org?subject=help>
List-Subscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=subscribe>
Errors-To: linux-ha-bounces@lists.linux-ha.org
List-ID: <nfs.lists.sourceforge.net>


--===============1824020240==
Content-Type: multipart/signed; protocol="application/pgp-signature";
	micalg=pgp-sha1; boundary="Boundary-02=_RgPsAiiR9VjHuVv";
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit


--Boundary-02=_RgPsAiiR9VjHuVv
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello,

I'm currently fighting a very obscur problem: when the kernel nfs-server is=
=20
started from heartheat, it can't be stopped the usual way from the=20
debian-nfs-kernel-server script.
As long as I manually run '/etc/init.d/nfs-kernel-server start', stopping=20
works by running '/etc/init.d/nfs-kernel-server stop'. But when the same=20
commands are called from heartbeat, the nfsd-processes simply won't be=20
killed. Running '/etc/ini.d/nfs-kernel-server stop' manually also doesn't=20
work then.

Well, from the debian script the nfsd is killed with signal 2, killing it=20
manually with signal 1 or signal 9 works, though sometimes the kernel will=
=20
log "rpciod: active tasks at shutdown?!".

Any ideas what might be the differences between starting nfs from heartbeat=
=20
and starting it as root? I already tried to trace this down and first I=20
thought heartbeat might start the services in the wrong order, but finally =
I=20
created an absolut identical environment so that heartbeat only starts and=
=20
tries to stop nfs.

Is signal 2 anyway sufficient to kill the nfsd's? From the Suse-7.3 nfsserv=
er=20
script I see that those daemons are killed there by default with=20
signal KILL (9).

System configuration:=20
	- linux-2.4.26 on dual opteron
	- debian woody + several packages from sarge
	- nfs-utils-1.0.6-3


Thanks for any help,
	Bernd

--Boundary-02=_RgPsAiiR9VjHuVv
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBAsPgRC8BUnAF+ydYRAou/AJ4kjbmjwgIVbVOAm7H8IAk8Z0uWBACaA2PE
um7KNLnORM8kk8u6FDS6WgE=
=e54n
-----END PGP SIGNATURE-----

--Boundary-02=_RgPsAiiR9VjHuVv--

--===============1824020240==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linux-HA mailing list
Linux-HA@lists.linux-ha.org
http://lists.linux-ha.org/mailman/listinfo/linux-ha

--===============1824020240==--
