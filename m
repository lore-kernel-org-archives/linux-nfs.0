From: Michael Buesch <fsdeveloper@yahoo.de>
Subject: Re: [NFS] processes stuck in D state
Date: Tue, 6 May 2003 19:32:29 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200305061932.39828.fsdeveloper@yahoo.de>
References: <200305061652.13280.fsdeveloper@yahoo.de> <200305061830.25417.fsdeveloper@yahoo.de> <16055.59608.512121.756564@charged.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net,
	linux kernel mailing list <linux-kernel@vger.kernel.org>,
	Zeev Fisher <Zeev.Fisher@il.marvell.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: trond.myklebust@fys.uio.no
In-Reply-To: <16055.59608.512121.756564@charged.uio.no>
List-ID: <nfs.lists.sourceforge.net>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Tuesday 06 May 2003 18:54, Trond Myklebust wrote:
> >>>>> " " =3D=3D Michael Buesch <fsdeveloper@yahoo.de> writes:
>     >> kill -9 all the processes.  kill -9 rpciod.
>     >>
>      > kill -9 doesn't work for me to kill the app.
>
> I didn't say kill the app. I said signal it with -9, then signal
> rpciod.

Ah, I understand. :)

> Cheers,
>   Trond

- --=20
Regards Michael B=FCsch
http://www.8ung.at/tuxsoft
 19:31:20 up  3:22,  2 users,  load average: 1.23, 1.09, 1.04
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE+t/G3oxoigfggmSgRAq5BAJ0SezM+y1LFnwglArReHERXb2VJZQCeKKd0
Sx6RqCkOvm4FvgTCVyx2gCE=3D
=3DK8c7
-----END PGP SIGNATURE-----
