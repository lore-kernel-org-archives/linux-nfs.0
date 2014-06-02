Return-Path: linux-nfs-owner@vger.kernel.org
Received: from imap.thunk.org ([74.207.234.97]:46579 "EHLO imap.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036AbaFBWak (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jun 2014 18:30:40 -0400
Date: Mon, 2 Jun 2014 18:29:54 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Arnd Bergmann <arnd@arndb.de>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        Dave Chinner <david@fromorbit.com>,
        LKML Kernel <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org,
        joseph@codesourcery.com, john.stultz@linaro.org,
        Christoph Hellwig <hch@infradead.org>, tglx@linutronix.de,
        geert@linux-m68k.org, lftan@altera.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, xfs@oss.sgi.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC 11/32] xfs: convert to struct inode_time
Message-ID: <20140602222954.GA29690@thunk.org>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
 <8618458.1EVJCoVbkH@wuerfel>
 <alpine.LFD.2.11.1406012121430.17310@knanqh.ubzr>
 <4178301.j9kWdGCRLC@wuerfel>
 <6868F108-F0B2-423F-AE31-90DF86A5B7DD@oracle.com>
 <20140602153124.GH30598@thunk.org>
 <538CB085.5000502@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <538CB085.5000502@zytor.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 02, 2014 at 10:12:37AM -0700, H. Peter Anvin wrote:
> > It would be problematic for time(2) or gettimeofday(2) to return
> > TIME_UNDEFINED, since there are programs that care about time ticking
> > forward, but I could imagine a new interface which would be permitted
> > to return a flag indicating that we don't know the current time
> > (because the CMOS battery had run down, etc.) so instead we're going
> > to be counting the number of seconds since the system was booted.
> 
> This assumes that we actually know that that is the case, which may be
> an aggressive assumption.

We won't know if the RTC clock is wrong, true --- but the kernel will
know if (a) the hardware doesn't have RTC clock at all, or if (b) the
RTC clock is ticking some time that can't be encoded using the current
time_t type.  So in that case, the fallback would be to be for the
kernel to tick starting with time_t == 0 when the system is initially
booted, and the "time indefinite flag" would be set.

Now assume that we have a new system call, gettimestampofday(2), which
returns a new timestamp structure which has a 64-bit ts_sec field, the
ts_nsec field (ala struct timespec), and a ts_flags field, where the
kernel could signal things like "time invalid", or "time can't be
encoded in the legacy time_t type", or "I'm not sure if the time is
correct" --- i.e., because the RTC battery isn't working.

Not all hardware might be able to support the last, of course, but if
the battery is low, or the system has been exposed to very low
temperatures (or large amounts of cosmic radiation, etc.)  the RTC
time may just be plain wrong.  No system is going to be perfect, but
it should be possible to make htings better, at for certain classes of
hardware.

And since we are already returning (time_t) -1 in some cases, we might
as well try to make things a bit more formal.

					- Ted

