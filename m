From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: why do i get "Stale NFS file handle" for hours?
Date: Sat, 04 Sep 2004 21:39:45 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1094348385.13791.119.camel@lade.trondhjem.org>
References: <chdp06$e56$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S265900AbUIEBkH@vger.kernel.org>
To: Sven =?ISO-8859-1?Q?K=F6hler?= <skoehler@upb.de>
In-Reply-To: <chdp06$e56$1@sea.gmane.org>
List-ID: <nfs.lists.sourceforge.net>

P=E5 lau , 04/09/2004 klokka 21:06, skreiv Sven K=F6hler:
> Hi,
>=20
> i think i know what's going an, and why i get the "stale nfs handle"=20
> error-message when the NFS server is restartet (real reboot, or a sim=
ply=20
> /etc/init.d/nfs restart) but what i don't understand is, why the NFS=20
> client doesn't "remount" the filesystem autmatically. In case of NFS=20
> over tcp, the NFS client could easily detect a restart of the NFS ser=
ver=20
> (the tcp-connection was aborted) or are there other factors that keep=
=20
> the NFS client from recognizing such stuff?

Sigh. This question keeps coming up again and again and again. Why can'=
t
you people search the archives?

Of course we could "fix" things for the user so that we just look up al=
l
those filehandles again transparently.

  The real question is: how do we know that is the right thing to do?

The NFS client wouldn't know the difference between your /etc/passwd
file and a javascript pop-up ad. If it gets an ESTALE error, then that
tells it that the original filehandle is invalid, but it does not know
WHY that is the case. The file may have been deleted and replaced by a
new one. It may be that your server is broken, and is actually losing
filehandles on reboot (as appears to be the case in your setup),...

Reopening the file, and then continuing to write from the same position
may be the right thing to do, but then again it may cause you to
overwrite a bunch of freshly written password entries.

So we bounce the error up to userland where these issues can actually b=
e
resolved.

Cheers,
  Trond
