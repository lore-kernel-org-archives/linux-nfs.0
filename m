From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: why do i get "Stale NFS file handle" for hours?
Date: Sat, 04 Sep 2004 22:02:24 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1094349744.13791.128.camel@lade.trondhjem.org>
References: <chdp06$e56$1@sea.gmane.org>
	 <1094348385.13791.119.camel@lade.trondhjem.org>  <413A7119.2090709@upb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S265909AbUIECCc@vger.kernel.org>
To: Sven =?ISO-8859-1?Q?K=F6hler?= <skoehler@upb.de>
In-Reply-To: <413A7119.2090709@upb.de>
List-ID: <nfs.lists.sourceforge.net>

P=E5 lau , 04/09/2004 klokka 21:51, skreiv Sven K=F6hler:

> I agree, but you simply admit that the NFS client doesn't seem to kno=
w,=20
> when the server was restart. The simpliest thing i can imagine, is th=
at=20
> the NFS server generates a random integer-value at start, and transmi=
ts=20
> it along with ESTALE. If the integer-value is different from the=20
> integer-value the server send while mounting the FS, than the kernel =
has=20
> to remount it transparently. This is a simple thing so that a client =
can=20
> safely determine, if the server has been restarted, or not, and it on=
ly=20
> adds 4 byte to some nfs-packets.

No.... The simplest thing is for the server to actually abide by the
RFCs and not generate filehandles that change on reboot.

NFSv4 is the ONLY version of the protocol that actually supports the
concept of filehandles that have a finite lifetime.

> In my case, if the nfs directory is mounted to /mnt/nfs, i can't even=
 do=20
> a simple "cd /mnt/nfs" without getting the "stale nfs handle" - even =
if=20
> i use a different shell. I always thought, that the "cd /mnt/nfs" sho=
uld=20
> work, since the shell will aquire a new handle, but it doesn't work :=
-(

It won't if the root filehandle is broken too. That is the standard way
of telling the NFS client that the administrator has revoked our access
to the filesystem.

The solution is simple here: fix the broken server...

Cheers,
   Trond
