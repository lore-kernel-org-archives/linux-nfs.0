Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:45080 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754848AbaFYWlV convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2014 18:41:21 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Trond Myklebust'" <trond.myklebust@primarydata.com>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
References: <029301cf90c0$4fabe660$ef03b320$@mindspring.com>	<CAHQdGtSdQ3keA2UgiAbtWWUMvheWQ8oanpAt_evAY2DSkr+y+Q@mail.gmail.com>	<029c01cf90c4$ebae6b60$c30b4220$@mindspring.com> <CAHQdGtRxORG5kn-9D1Bp7WZ80yF6jGL_M8yT+0KeJ7x-jyVojg@mail.gmail.com>
In-Reply-To: <CAHQdGtRxORG5kn-9D1Bp7WZ80yF6jGL_M8yT+0KeJ7x-jyVojg@mail.gmail.com>
Subject: RE: Execute only permission issue with client
Date: Wed, 25 Jun 2014 15:41:04 -0700
Message-ID: <029f01cf90c6$8ce1db10$a6a59130$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Wed, Jun 25, 2014 at 6:29 PM, Frank Filz <ffilzlnx@mindspring.com>
> wrote:
> >> On Wed, Jun 25, 2014 at 5:56 PM, Frank Filz <ffilzlnx@mindspring.com>
> >> wrote:
> >> > Back a year ago or so, I ran the following test against Ganesha:
> >> >
> >> > http://www.tuxera.com/community/posix-test-suite/
> >> >
> >> > On NFS v4, one of the issues it tripped over was execute only files.
> >> > Apparently the Linux v4 client doesn't make ACCESS calls in
> >> > conjunction with an open system call, with the result that you can
> >> > open an execute only file (per RFC 3530bis, the server is allowing
> >> > such to allow clients to execute executables).
> >>
> >> That information is outdated. A wireshark dump should show that
> >> recent Linux kernels include an ACCESS operation as part of the
> >> open() COMPOUND and that it uses that information to distinguish
> >> between executable and read access permissions.
> >
> > Oh, cool, do you know when that went in? I'll go look and see if I can find
> it...
> >
> 
> It should be a feature of Linux 3.7 (Dec 2012) and newer kernels.

Ah, of course we're trying on Fedora 18 with 3.6.10 kernel...

Frank


