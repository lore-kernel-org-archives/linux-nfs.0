From: Kalin KOZHUHAROV <kalin@thinrope.net>
Subject: Re: why do i get "Stale NFS file handle" for hours?
Date: Mon, 06 Sep 2004 16:47:14 +0900
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <chh4m7$scm$1@sea.gmane.org>
References: <chdp06$e56$1@sea.gmane.org>	 <1094348385.13791.119.camel@lade.trondhjem.org>  <413A7119.2090709@upb.de>	 <1094349744.13791.128.camel@lade.trondhjem.org>  <413A789C.9000501@upb.de>	 <1094353267.13791.156.camel@lade.trondhjem.org>  <413B121B.2070101@upb.de> <1094415006.8081.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S267561AbUIFHrr@vger.kernel.org>
To: linux-kernel@vger.kernel.org
In-Reply-To: <1094415006.8081.6.camel@lade.trondhjem.org>
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust wrote:
>>So there should be a filesystem mounted to /proc/fs/nfsd? This isn't the 
>>case on my machine. Should the init-script do a simple "mount -t nfsd 
>>none /proc/fs/nfsd"? Than this would be a Bug of my distribution (Gentoo).
Well, I am on Gentoo as well, and it seems that it is mounted on /proc/fs/nfs.

However `cat /proc/fs/nfs/exports` showed only one of 5 exported dirs on my server.
It has been a few weeks since last restart (and NFS restart).
`/etc/init.d/nfs restart` or `exportfs -a` fixed it.

> Yes... See the manpage for "exportfs".

Had a (first) look at it, but I still cannod understand what is the difference
between the "-r" and "-a" option...
The output on my system from both `exportfs -rv` and `exportfs -av` is the same.

Kalin.

-- 
 || ~~~~~~~~~~~~~~~~~~~~~~ ||
(  ) http://ThinRope.net/ (  )
 || ______________________ ||
