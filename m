Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:35106 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754836AbaGAU3V convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jul 2014 16:29:21 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Trond Myklebust'" <trond.myklebust@primarydata.com>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
References: <029301cf90c0$4fabe660$ef03b320$@mindspring.com>	<CAHQdGtSdQ3keA2UgiAbtWWUMvheWQ8oanpAt_evAY2DSkr+y+Q@mail.gmail.com>	<029c01cf90c4$ebae6b60$c30b4220$@mindspring.com>	<CAHQdGtRxORG5kn-9D1Bp7WZ80yF6jGL_M8yT+0KeJ7x-jyVojg@mail.gmail.com>	<012801cf9560$29ede7d0$7dc9b770$@mindspring.com> <CAHQdGtSMEGvsKt-k+LJM9w-PNu6dTOQABocX-u=10Uyj1tehwg@mail.gmail.com>
In-Reply-To: <CAHQdGtSMEGvsKt-k+LJM9w-PNu6dTOQABocX-u=10Uyj1tehwg@mail.gmail.com>
Subject: RE: Execute only permission issue with client
Date: Tue, 1 Jul 2014 13:28:55 -0700
Message-ID: <013101cf956b$1e6b9500$5b42bf00$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Tue, Jul 1, 2014 at 3:10 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:
> > Ok, got another question related...
> >
> > I am running a test that does make the following system call:
> >
> > open("/mnt/foo", O_CREAT | O_TRUNC | O_RDWR, 0);
> >
> > This fails (at least when run from my Fedora 20 client, against either
> Ganesha OR knfsd).
> 
> The test fails, or the open() fails?

The open fails (with EACCESS).

> > When I look at a wireshark trace, I see that the sequence of ops in the
> COMPOUND is:
> >
> > OPEN, ACCESS
> >
> > I would expect the ACCESS to fail since the created file has mode 000.
> 
> According to POSIX, the above open() system call should succeed if a file
> /mnt/foo already exists and that file's ACL/mode is compatible with the
> requested O_RDWR access pattern. The open() should also succeed if a file
> /mnt/foo does not exist, and your process has valid file create permissions
> for the directory /mnt (it will create a file /mnt/foo with the mode bits set to
> 0).
> 
> In both cases, the result should be a valid file descriptor that can be used for
> reading and writing.

Right, and I see that the ACCESS MUST be called AFTER the OPEN (to capture the situation where the file already exists), however, if the file did not exist, the ACCESS fails.

Hmm, the poor client actually has no way to handle this...

And we need the ACCESS call in case the file already existed and was execute only.

I'm not sure the protocol actually allows a proper implementation of this variant of the open system call...

Life would have been a bit easier if the protocol had an ACCESS4_EXECUTE flag for OPEN... But there might still be issues of how to accomplish the permission check and create atomically...

Frank

> --
> Trond Myklebust
> 
> Linux NFS client maintainer, PrimaryData
> 
> trond.myklebust@primarydata.com

