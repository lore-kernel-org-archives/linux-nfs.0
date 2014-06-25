Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:42292
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753864AbaFYW3r convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2014 18:29:47 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Trond Myklebust'" <trond.myklebust@primarydata.com>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
References: <029301cf90c0$4fabe660$ef03b320$@mindspring.com> <CAHQdGtSdQ3keA2UgiAbtWWUMvheWQ8oanpAt_evAY2DSkr+y+Q@mail.gmail.com>
In-Reply-To: <CAHQdGtSdQ3keA2UgiAbtWWUMvheWQ8oanpAt_evAY2DSkr+y+Q@mail.gmail.com>
Subject: RE: Execute only permission issue with client
Date: Wed, 25 Jun 2014 15:29:24 -0700
Message-ID: <029c01cf90c4$ebae6b60$c30b4220$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Wed, Jun 25, 2014 at 5:56 PM, Frank Filz <ffilzlnx@mindspring.com>
> wrote:
> > Back a year ago or so, I ran the following test against Ganesha:
> >
> > http://www.tuxera.com/community/posix-test-suite/
> >
> > On NFS v4, one of the issues it tripped over was execute only files.
> > Apparently the Linux v4 client doesn't make ACCESS calls in
> > conjunction with an open system call, with the result that you can
> > open an execute only file (per RFC 3530bis, the server is allowing
> > such to allow clients to execute executables).
> 
> That information is outdated. A wireshark dump should show that recent
> Linux kernels include an ACCESS operation as part of the open() COMPOUND
> and that it uses that information to distinguish between executable and read
> access permissions.

Oh, cool, do you know when that went in? I'll go look and see if I can find it...

> > We tripped over this issue again in some of our testing.
> >
> > One bit that I don't actually understand is how the kernel
> > differentiates between bash (etc) issuing an open system call to load
> > a script and vi trying to browse same script...
> >
> > I had done some testing executing shell scripts and such and saw some
> > inconsistency. Now, trying things, I can't seem to run a bash script
> > that is execute only (local, v3, or v4), but can run a compiled binary
> > that is execute only (local, v3, and v4), so I'm not sure what the deal is...
> 
> The deal is that shell scripts require read permissions because the shell needs
> to be able to open and read them.

Ok, that does actually make sense. I could have sworn I used to be able to run execute only shell scripts from non-root user, but my memory has been known to be faulty.

> [trondmy@leira ~]$ cat >script.sh
> #!/bin/bash
> #
> echo "foo"
> [trondmy@leira ~]$ chmod 0111 script.sh
> [trondmy@leira ~]$ ./script.sh
> /bin/bash: ./script.sh: Permission denied [trondmy@leira ~]$ chmod 0555
> script.sh [trondmy@leira ~]$ ./script.sh foo

Thanks

Frank


