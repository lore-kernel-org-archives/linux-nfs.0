From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS using CacheFS
Date: Mon, 04 Oct 2004 23:53:57 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1096926837.22446.141.camel@lade.trondhjem.org>
References: <4161B664.70109@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net,
	Linux filesystem caching discussion list
	<linux-cachefs@redhat.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268678AbUJDWEt@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4161B664.70109@RedHat.com>
List-ID: <nfs.lists.sourceforge.net>

P=E5 m=E5 , 04/10/2004 klokka 22:45, skreiv Steve Dickson:

> 3) There is no user level support. I realize this is extremely cheesy
>      but I noticed that the NFS posix mount  option (in the 2.6 kerne=
l)
>      was no longer being used, so I high jacked it.  Which means
>      to make NFS to used CacheFS you need to use the posix option:
>=20
>      mount -o posix server:/export/home /mnt/server/home

This is my one and only real gripe about it. The posix mount option is
clearly documented, so we really cannot play around with it. Why can't
you just add a separate cachefs flag?

Otherwise, I'm a bit dubious about the wisdom of putting
nfs_invalidatepage() and nfs_releasepage() into fs/nfs/file.c. These ar=
e
not file operations, but rather pure page cache operations. I would hav=
e
thought that either read.c or possibly nfs-cachefs.c would be more
appropriate.

Please note too that Chuck has made generic functions for copying and
comparing NFS filehandles. They should be used in nfs_cache_fh_match() =
&
co.
I'm a bit worried about the use of the raw IP address in
nfs_cache_server_match(). It seems to me that when we add the NFSv4.1
support for trunking over several different transport mechanisms (RDMA,
IPv4/v6 etc) on the same mountpoint, then we may end up with a problem.
We can probably leave it in for now, but later we may want to consider
switching to using server->hostname or something equivalent.

Otherwise, it looks good. Looking forward to try it out...

Cheers,
  Trond
