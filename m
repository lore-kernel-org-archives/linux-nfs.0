From: Michael Buesch <fsdeveloper@yahoo.de>
Subject: Re: [NFS] processes stuck in D state
Date: Tue, 6 May 2003 17:56:24 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200305061756.36568.fsdeveloper@yahoo.de>
References: <482A3FA0050D21419C269D13989C611312747A@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>,
	linux kernel mailing list <linux-kernel@vger.kernel.org>,
	"Zeev Fisher" <Zeev.Fisher@il.marvell.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611312747A@lavender-fe.eng.netapp.com>
List-ID: <nfs.lists.sourceforge.net>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Tuesday 06 May 2003 17:47, Lever, Charles wrote:
> does the problem persist after you reconnect the network cable?
> what happens when the server becomes available again?

no. If server is available again, the process wakes up from D.

But like man mount says:
[snip] The process cannot be interrupted or killed unless you also spec=
ify intr. [/snip]
The process should be killable while the cable is pulled.
But that's not the case, although intr is in fstab.

> are you mounting with UDP or TCP?

uh. How to find it out? :)

- --=20
Regards Michael B=FCsch
http://www.8ung.at/tuxsoft
 17:53:19 up  1:44,  5 users,  load average: 1.04, 1.05, 1.06
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE+t9s0oxoigfggmSgRAkDPAKCFMeEGvS3KUhwn0bNQngKRK6h2fwCdEcv/
U2ttfZ6Mm8Sazuksfn4UUrY=3D
=3DM5Kh
-----END PGP SIGNATURE-----
