From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Make NFS userspace and server directories cookies independant
	[patch, fc3, 2.6.10-1.766_FC3]
Date: Mon, 21 Mar 2005 12:46:58 -0500
Message-ID: <1111427218.10508.27.camel@lade.trondhjem.org>
References: <20050321162142.GB46055@dspnet.fr.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Hack inc." <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
To: Olivier Galibert <galibert@pobox.com>
In-Reply-To: <20050321162142.GB46055@dspnet.fr.eu.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

m=E5 den 21.03.2005 Klokka 17:21 (+0100) skreiv Olivier Galibert:

> Patch is against a fedora core 3 2.6.10, it requires minor
> modifications (context change, not contents) in the nfs_do_filldir pa=
r
> of the dir.c change to account for the dirent addition to apply to
> 2.6.11.  I can update it if useful.
>=20

If you could please update it for 2.6.12-rc1, then I'll be able to queu=
e
it up for testing and possible inclusion in 2.6.13.

Cheers,
  Trond

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>
