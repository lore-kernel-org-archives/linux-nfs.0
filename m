From: =?ISO-8859-1?Q?Sven_K=F6hler?= <skoehler@upb.de>
Subject: Re: why do i get "Stale NFS file handle" for hours?
Date: Sun, 05 Sep 2004 15:18:19 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <413B121B.2070101@upb.de>
References: <chdp06$e56$1@sea.gmane.org>	 <1094348385.13791.119.camel@lade.trondhjem.org>  <413A7119.2090709@upb.de>	 <1094349744.13791.128.camel@lade.trondhjem.org>  <413A789C.9000501@upb.de> <1094353267.13791.156.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S266663AbUIENVs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094353267.13791.156.camel@lade.trondhjem.org>
List-ID: <nfs.lists.sourceforge.net>

> So, there are 3 possibilities:
> 
>  1) You are exporting a non-supported filesystem, (e.g. FAT). See the
> FAQ on http://nfs.sourceforge.org.

I'm exporting a reiserfs.

>  2) A bug in your initscripts is causing the table of exports to be
> clobbered. Running "exportfs" in legacy 2.4 mode (without having the
> nfsd filesystem mounted on /proc/fs/nfsd) appears to be broken for me at
> least...

So there should be a filesystem mounted to /proc/fs/nfsd? This isn't the 
case on my machine. Should the init-script do a simple "mount -t nfsd 
none /proc/fs/nfsd"? Than this would be a Bug of my distribution (Gentoo).
