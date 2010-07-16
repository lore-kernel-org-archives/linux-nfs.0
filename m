Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:54941 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965352Ab0GPNcP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jul 2010 09:32:15 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended file stats available [ver #6]
Date: Fri, 16 Jul 2010 15:32:02 +0200
Cc: Mark Harris <mhlk@osj.us>, Steve French <smfrench@gmail.com>,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org
References: <201007161302.35775.arnd@arndb.de> <8527.1279275842@redhat.com> <10677.1279283886@redhat.com>
In-Reply-To: <10677.1279283886@redhat.com>
Content-Type: Text/Plain;
  charset="iso-8859-15"
Message-Id: <201007161532.02210.arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Friday 16 July 2010, David Howells wrote:
> Arnd Bergmann <arnd@arndb.de> wrote:
> 
> > You could also define the tv_gran_units to be power-of-ten nanoseconds,
> > making it a decimal floating point number like 
> > 
> > enum {
> >       XSTAT_NANOSECONDS_GRANULARITY = 0,
> >       XSTAT_MICROSECONDS_GRANULARITY = 3,
> >       XSTAT_MILLISECONDS_GRANULARITY = 6,
> >       XSTAT_SECONDS_GRANULARITY = 9,
> > };
> 
> Are you thinking, then, of having tv_nsec be in terms of those units?

No, just tv_granularity. Most users won't need to care that this
is not a regular timespec then.

> > That would make it easier to define an xstat_time_before() function, though
> > it means that you could no longer do XSTAT_MINUTES_GRANULARITY and
> > higher directly other than { .tv_gran_units = 10, .tv_granularity = 6, }.
> 
> So you're thinking of indicating time (in)equality based on overlapping time
> granules?

Yes, for example rsync could use this to determine wether a local (e.g. FAT)
and a remote (e.g. NFS) file are identical or not. Right now, you can pass
the granularity in seconds as a command line argument, but it would be nice
to have rsync do this automatically if possible.

> Your suggestion would suffice, I think.  With a 2:2 split between exponent
> (tv_gran_units) and mantissa (tv_granularity), you can do:
> 
>         UNIT            SECONDS/UNIT    EXPONENT        MANTISSA
>         nanoseconds     0.000000001     -9              1
>         microseconds    0.000001        -6              1
>         millseconds     0.001           -3              1
>         seconds         1               0               1
>         minutes         60              1               6
>         hours           3600            2               36
>         days            86400           2               864
>         weeks           604800          2               6048
> 
> Any units beyond that are variable length and not worth considering, IMO.

right.
 
> And if you don't want negative numbers in your exponent, you can make the base
> unit nS instead of S.

either way works fine for me.

> Is it worth allowing a filesystem to indicate that it has granularity smaller
> than nS, even if the resolution can't be handled here?  We could even have:
> 
>         struct xstat_time {
>                 signed long long        tv_sec;         /* seconds */
>                 unsigned int            tv_nsec;        /* nanoseconds */
>                 unsigned char           tv_psec4;       /* picoseconds/4 */
>                 signed char             tv_gran_exp;    /* exponent */
>                 unsigned short          tv_gran_mant;   /* mantissa */
>         };
> 
> Though it's probably still an unnecessary extravagance to have the pS field.
> It's probably best left as padding for now; we can always change our minds
> later...

There are also two extra bits in tv_nsec ;-). No, I don't think we
need picoseconds any time soon.

One byte padding might not be the worst thing to have in here, like

        struct xstat_time {
                signed long long        tv_sec;         /* seconds */
                unsigned int            tv_nsec;        /* nanoseconds */
                unsigned short          tv_gran_mant;   /* mantissa */
                signed char             tv_gran_exp;    /* exponent */
                unsigned char           unused;
        };

	Arnd
