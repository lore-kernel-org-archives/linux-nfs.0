Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:45965 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751371AbaGATKv convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jul 2014 15:10:51 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Trond Myklebust'" <trond.myklebust@primarydata.com>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
References: <029301cf90c0$4fabe660$ef03b320$@mindspring.com>	<CAHQdGtSdQ3keA2UgiAbtWWUMvheWQ8oanpAt_evAY2DSkr+y+Q@mail.gmail.com>	<029c01cf90c4$ebae6b60$c30b4220$@mindspring.com> <CAHQdGtRxORG5kn-9D1Bp7WZ80yF6jGL_M8yT+0KeJ7x-jyVojg@mail.gmail.com>
In-Reply-To: <CAHQdGtRxORG5kn-9D1Bp7WZ80yF6jGL_M8yT+0KeJ7x-jyVojg@mail.gmail.com>
Subject: RE: Execute only permission issue with client
Date: Tue, 1 Jul 2014 12:10:45 -0700
Message-ID: <012801cf9560$29ede7d0$7dc9b770$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok, got another question related...

I am running a test that does make the following system call:

open("/mnt/foo", O_CREAT | O_TRUNC | O_RDWR, 0);

This fails (at least when run from my Fedora 20 client, against either Ganesha OR knfsd).

When I look at a wireshark trace, I see that the sequence of ops in the COMPOUND is:

OPEN, ACCESS

I would expect the ACCESS to fail since the created file has mode 000.

Has this been resolved differently in a more recent kernel?

Thanks

Frank

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Trond Myklebust
> Sent: Wednesday, June 25, 2014 3:34 PM
> To: Frank Filz
> Cc: Linux NFS Mailing List
> Subject: Re: Execute only permission issue with client
> 
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
> 
> Cheers
>   Trond
> 
> --
> Trond Myklebust
> 
> Linux NFS client maintainer, PrimaryData
> 
> trond.myklebust@primarydata.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

