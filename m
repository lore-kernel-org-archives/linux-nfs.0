From: Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>
Subject: Re: atimes not updated over NFS
Date: Wed, 9 Jan 2008 23:37:48 +0100
Message-ID: <20080109223748.GH9212@aym.net2.nerim.net>
References: <20080109101313.GG9212@aym.net2.nerim.net> <1199892437.11141.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-103-wednesday.noc.nerim.net ([62.4.17.103]:3608 "EHLO
	mallaury.nerim.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752162AbYAIWhv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jan 2008 17:37:51 -0500
In-Reply-To: <1199892437.11141.2.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2008-01-09 10:27 -0500, Trond Myklebust wrote:
> On Wed, 2008-01-09 at 11:13 +0100, Andre Majorel wrote:
>
> > After upgrading an NFS server from kernel 2.6.12 to 2.6.23, the
> > atime of files is not updated any more when clients read them :
> >=20
> >   client$ ll -u --time-style +%Y-%m-%d_%H:%M:%S /nfsmnt/zz
> >   -rw-r--r-- 1 xxx xxx 0 2007-12-21_14:58:11 /nfsmnt/zz
> >   client$ md5sum /nfsmnt/zz
> >   d41d8cd98f00b204e9800998ecf8427e  /nfsmnt/zz
> >   client$ date +%Y-%m-%d_%H:%M:%S
> >   2007-12-21_15:00:28
> >   client$ ll -u --time-style +%Y-%m-%d_%H:%M:%S /nfsmnt/zz
> >   -rw-r--r-- 1 xxx xxx 0 2007-12-21_14:58:11 /nfsmnt/zz
> >=20
> > Reading the file locally, i.e. on the NFS server, does update the
> > atime :
> >=20
> >   server$ ll -u --time-style +%Y-%m-%d_%H:%M:%S /nfsmnt/zz
> >   -rw-r--r-- 1 xxx xxx 0 2007-12-21_14:58:11 /nfsmnt/zz
> >   serveur$ md5sum /nfsmnt/zz
> >   d41d8cd98f00b204e9800998ecf8427e  /nfsmnt/zz
> >   serveur$ date +%Y-%m-%d_%H:%M:%S
> >   2007-12-21_15:04:00
> >   serveur$ ll -u --time-style +%Y-%m-%d_%H:%M:%S /nfsmnt/zz
> >   -rw-r--r-- 1 xxx xxx 0 2007-12-21_15:03:57 /nfsmnt/zz
> >=20
> > /nfsmnt is mounted with options :
> > - server : rw,noexec,nosuid,nodev,nodiratime
> > - client : rw,user=3Droot,nosuid,nodev,nodiratime,intr,rsize=3D8192=
,wsize=3D8192
> >=20
> > Any ideas ?
>=20
> The file is probably entirely in cache on the client. When this happe=
ns,
> no READ rpc calls need to be made to the server and so the atime will
> not change either.

The client has 512 MB of RAM. A 513-MB file cannot possibly be
cached so let's try with that.

  atc5:/aym/etc$ time dd if=3D/dev/zero bs=3D1M count=3D513 >/nfsmnt/zz
  513+0 records in
  513+0 records out

  real    0m50.412s
  user    0m0.004s
  sys     0m8.905s
  atc5:/aym/etc$ ls -l --time-style +%Y-%m-%d_%H:%M:%S -u /nfsmnt/zz
  -rw-r--r-- 1 aym aym 537919488 2007-12-21_13:46:54 /nfsmnt/zz
  atc5:/aym/etc$ time wc /nfsmnt/zz
          0         0 537919488 /nfsmnt/zz

  real    1m30.743s
  user    0m47.091s
  sys     0m22.369s
  atc5:/aym/etc$ date +%Y-%m-%d_%H:%M:%S
  2008-01-09_23:21:06
  atc5:/aym/etc$ ls -l --time-style +%Y-%m-%d_%H:%M:%S -u /nfsmnt/zz
  -rw-r--r-- 1 aym aym 537919488 2007-12-21_13:46:54 /nfsmnt/zz

As the times show, the file is not in cache. And yet the atime is
still not updated.

> This has always been the case, BTW...

I'll take your word for it. However, let me assure you that atimes
somehow used to work over NFS, even for files small enough to fit
in the cache. Had they been broken, I would have known. I use Mutt.

Thanks.

--=20
Andr=E9 Majorel <URL:http://www.teaser.fr/~amajorel/>
Do not use this account for regular correspondence.
See the URL above for contact information.
