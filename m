From: =?ISO-8859-1?Q?Sven_K=F6hler?= <skoehler@upb.de>
Subject: Re: why do i get "Stale NFS file handle" for hours?
Date: Sun, 05 Sep 2004 03:51:21 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <413A7119.2090709@upb.de>
References: <chdp06$e56$1@sea.gmane.org> <1094348385.13791.119.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S265910AbUIEBys@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094348385.13791.119.camel@lade.trondhjem.org>
List-ID: <nfs.lists.sourceforge.net>

> Of course we could "fix" things for the user so that we just look up all
> those filehandles again transparently.
> 
>   The real question is: how do we know that is the right thing to do?
> 
> The NFS client wouldn't know the difference between your /etc/passwd
> file and a javascript pop-up ad. If it gets an ESTALE error, then that
> tells it that the original filehandle is invalid, but it does not know
> WHY that is the case. The file may have been deleted and replaced by a
> new one. It may be that your server is broken, and is actually losing
> filehandles on reboot (as appears to be the case in your setup),...

I agree, but you simply admit that the NFS client doesn't seem to know, 
when the server was restart. The simpliest thing i can imagine, is that 
the NFS server generates a random integer-value at start, and transmits 
it along with ESTALE. If the integer-value is different from the 
integer-value the server send while mounting the FS, than the kernel has 
to remount it transparently. This is a simple thing so that a client can 
safely determine, if the server has been restarted, or not, and it only 
adds 4 byte to some nfs-packets.

> Reopening the file, and then continuing to write from the same position
> may be the right thing to do, but then again it may cause you to
> overwrite a bunch of freshly written password entries.

In my case, if the nfs directory is mounted to /mnt/nfs, i can't even do 
a simple "cd /mnt/nfs" without getting the "stale nfs handle" - even if 
i use a different shell. I always thought, that the "cd /mnt/nfs" should 
work, since the shell will aquire a new handle, but it doesn't work :-(

So i'm not really talking about restoring all file-handles. The 
filehandles that were still open while the server restarted may stay 
broken, but i'd like to be abled to open new ones at last.

> So we bounce the error up to userland where these issues can actually be
> resolved.

This is a good thing to do in general, but i think this needs improvement.
