From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: why do i get "Stale NFS file handle" for hours?
Date: Sat, 04 Sep 2004 23:01:07 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1094353267.13791.156.camel@lade.trondhjem.org>
References: <chdp06$e56$1@sea.gmane.org>
	 <1094348385.13791.119.camel@lade.trondhjem.org>  <413A7119.2090709@upb.de>
	 <1094349744.13791.128.camel@lade.trondhjem.org>  <413A789C.9000501@upb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S266139AbUIEDB1@vger.kernel.org>
To: Sven =?ISO-8859-1?Q?K=F6hler?= <skoehler@upb.de>
In-Reply-To: <413A789C.9000501@upb.de>
List-ID: <nfs.lists.sourceforge.net>

P=E5 lau , 04/09/2004 klokka 22:23, skreiv Sven K=F6hler:

> Sorry? Why is my server broken? I'm using kernel 2.6.8.1 with nfs-uti=
ls=20
> 1.0.6 on my server, and i don't see, what should be broken.

When your server fails to work as per spec, then it is said to be
"broken" no matter what kernel/nfs-utils combination you are using.
The spec is that reboots are not supposed to clobber filehandles.

So, there are 3 possibilities:

 1) You are exporting a non-supported filesystem, (e.g. FAT). See the
=46AQ on http://nfs.sourceforge.org.
 2) A bug in your initscripts is causing the table of exports to be
clobbered. Running "exportfs" in legacy 2.4 mode (without having the
nfsd filesystem mounted on /proc/fs/nfsd) appears to be broken for me a=
t
least...
 3) There is some other bug in knfsd that nobody else appears to be
seeing.

Cheers,
  Trond
