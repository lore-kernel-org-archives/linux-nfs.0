Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:42709 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756Ab3LBTYb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 14:24:31 -0500
Received: by mail-ie0-f169.google.com with SMTP id e14so22329987iej.28
        for <linux-nfs@vger.kernel.org>; Mon, 02 Dec 2013 11:24:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <F7935E11-E648-49C5-B100-B5A624BFFDF3@primarydata.com>
References: <CAEEMktPamgjSHA_OmHj73ti5G01DcC_ykYb=-_bfOYqy4nW8BA@mail.gmail.com>
	<5B7CDA5C-C3F1-4CFD-9A72-013523068FBB@primarydata.com>
	<CAHnbEG+cJGjx7o=+ZASNo7ddc0O9hYG4fE0EAQ2hoh688nBBeQ@mail.gmail.com>
	<F7935E11-E648-49C5-B100-B5A624BFFDF3@primarydata.com>
Date: Mon, 2 Dec 2013 20:24:29 +0100
Message-ID: <CALXu0UcDdbOfD3DFH8b4_ppDnBc+o7bcu5Rm6Ojbg5e1zGzH-Q@mail.gmail.com>
Subject: Re: Linux client access to NFSv4 Alternate Data Streams (O_XATTR)?
From: Cedric Blancher <cedric.blancher@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Sebastian Feld <sebastian.n.feld@gmail.com>,
        Joshuah Hurst <joshhurst@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2 December 2013 17:07, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
>
> On Dec 2, 2013, at 9:27, Sebastian Feld <sebastian.n.feld@gmail.com> wrote:
>
>> On Mon, Dec 2, 2013 at 2:29 PM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>>
>>> On Dec 2, 2013, at 7:13, Joshuah Hurst <joshhurst@gmail.com> wrote:
>>>
>>>> We need to access NFSv4 Alternate Data Streams (what Solaris,
>>>> NexentaOS, Omnios and SmartOS can openat() with the O_XATTR flag) from
>>>> a (Suse) Linux client.
>>>>
>>>> OS is Suse Linux 12.3, x86-64, 64bit
>>>>
>>>> Does anyone know how to archive this?
>>>
>>> Why can’t you access Solaris-specific extensions from a Solaris client?
>>
>> This isn't a Solaris-specific extension, its part of the original Sun
>> NFSv4 spec. Unfortunately the ARC/ARchitecture Cases from
>> Opensolaris.org are no longer available, otherwise the background,
>> e.g. feature parity with CIFS/NTFS, and the overall usefulness of such
>> a feature, would be clearer.
>
> The open(O_XATTR) _is_ a Solaris specific extension. It isn’t something that we have been planning to support on Linux.

When NFS version 4 was conceived by SUN long ago it was already
decided that Alternate Data Streams should be a mandatory core
feature. Alternate Data Streams were officially supported in Solaris 9
(with most kernel parts already added with Solaris 8 updates, minus
implementations in the various file systems; a custom filesystem
however can use ADS on S8 using the S9 includes) and NFSv4 development
ran in parallel, together with the spec which would've introduced that
feature as part of the next Single Unix Standard.
The SUS spec itself was more or less "grounded" when SUN's POSIX team
was laid off (the sad day of Fri, Jan 23, 2009) as a desperate measure
to save money, but that didn't invalidate the valid concept or idea of
Alternate Data Streams.

What's *sad* is that there is a lot of FUD spread related to Alternate
Data Streams, usually from the camp which wishes to promote Extended
Attributes - which are not even closely related nor a competition -
both serve different purposes and should be able to exist happily
alongside each other.

>
>> There are many many applications coming from either the Windows world
>> or the HPC camp (like nih.org or GE Healthcare) who mandatory rely on
>> the existence of this feature (well, at least enough so that AT&T
>> cloud services and the related toolchain (e.g. AST, including ksh93)
>> now have extensive support for O_XATTR).
>
> What do they use it for?

Usually to provide per-file context data, stuff like cookies (like
Internet Explorer does), tags or per application index files. That
doesn't mean they are small - as you can read in
http://permalink.gmane.org/gmane.os.freebsd.devel.hackers/51891 such
files can be in the TB range (OK, that's CERN for you, but the usage
in the nih.gov toolchain can easily hit a few dozens GB as well if the
parent germ database file is a few hundred GB).

> Last I heard, Microsoft was deprecating the use of streams. I’m assuming that means they plan to get rid of it.

Could you please give me an URL for this? The comments we (Institute
Pasteur) got from Microsoft and what's behind their support paywall
indicate that they intend to extend that feature with more support in
tools and applications. This matches the recent flurry of new
developments from AT&T Research, CERN and others in that direction. I
think Microsoft would be clubbed to death by their own customers if
they try to EOF that feature...

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
