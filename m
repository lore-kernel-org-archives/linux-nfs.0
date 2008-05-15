From: Jeff Layton <jlayton@redhat.com>
Subject: Re: NFS+GD issues on kernel 2.6.24, but not 2.6.22
Date: Thu, 15 May 2008 08:46:10 -0700
Message-ID: <20080515084610.4e5161bc@tupile.poochiereds.net>
References: <2473b43f0805150706g5be9918cu3c77d9135cded912@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "Adam Olsen" <arolsen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755506AbYEOPqq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 May 2008 11:46:46 -0400
In-Reply-To: <2473b43f0805150706g5be9918cu3c77d9135cded912-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 15 May 2008 08:06:29 -0600
"Adam Olsen" <arolsen@gmail.com> wrote:

> Hello,
> 
> I'm having an issue with perl and libgd reading TrueType fonts over an
> NFS mount.
> 
> The NFS server is an Isilon cluster (I believe they are based on FreeBSD 6.1?)
> The client is a machine that's just been updated to Hardy.
>   * Kernel 2.6.24-16-server
>   * libgd-gd2-perl 2.35-1
>   * libgd2-xpm 2.0.35
> 
> The issue is this:  using libgd via a perl script, I try writing text
> to an image in a font, specified by a file name (the font is located
> on the remote NFS server).  The script says that it cannot locate the
> font.  The client machine does not have any other known problems with
> the NFS share, it can read and write other files just fine.   We have
> several other machines that are reading this same share, though they
> are running kernel 2.6.22 from Gutsy (I confirmed that a downgrade to
> 2.6.22 on Hardy resolves the issue).
> 
> Here is a link to a script that can duplicate the problem 100% of the
> time:  http://soc.ath.cx/testfont.pl.txt
> 
> An strace using the kernel that doesn't work looks like this:
> 
> access("/mnt/isilon/fonts/arial.ttf", R_OK) = 0
> open("/mnt/isilon/fonts/arial.ttf", O_RDONLY) = 3
> fcntl64(3, F_SETFD, FD_CLOEXEC)         = 0
> fstat64(3, {st_mode=S_IFREG|0666, st_size=48784, ...}) = 0
> close(3)                                = 0
> 
> And the strace on the system that *does* work looks like this:
> 
> access("/mnt/isilon/fonts/arial.ttf", R_OK) = 0
> open("/mnt/isilon/fonts/arial.ttf", O_RDONLY) = 3
> fcntl64(3, F_SETFD, FD_CLOEXEC)         = 0
> fstat64(3, {st_mode=S_IFREG|0666, st_size=48784, ...}) = 0
> mmap2(NULL, 48784, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb79cd000
> close(3)                                = 0
> 

> Everything looks the same except the missing "mmap2" section.  Again,
> a note, this same machine *can* access other shares and read fonts
> just fine.  It appears to just be the connection to the Isilon
> machine.  Everything worked before the upgrade, and a downgrade to
> 2.6.22 works.  Any information would be helpful.
> 


It really depends on the program, but I'd guess that it saw something
in the fstat64() call that it didn't like. You might want to use strace
with '-v -s 256' or something and look for differences in the info
returned by the fstat64 call.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
