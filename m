Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.kundenserver.de ([212.227.126.131]:58296 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbaFBSw1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 14:52:27 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>, Chuck Lever <chuck.lever@oracle.com>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        Dave Chinner <david@fromorbit.com>,
        LKML Kernel <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org,
        joseph@codesourcery.com, john.stultz@linaro.org,
        Christoph Hellwig <hch@infradead.org>, tglx@linutronix.de,
        geert@linux-m68k.org, lftan@altera.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, xfs@oss.sgi.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC 11/32] xfs: convert to struct inode_time
Date: Mon, 02 Jun 2014 20:50:55 +0200
Message-ID: <4548598.6TTMEpKtuS@wuerfel>
In-Reply-To: <538CB085.5000502@zytor.com>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de> <20140602153124.GH30598@thunk.org> <538CB085.5000502@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 02 June 2014 10:12:37 H. Peter Anvin wrote:
> On 06/02/2014 08:31 AM, Theodore Ts'o wrote:
> > 
> > I wonder if it would make sense to try to promulgate via the Austin
> > group, and possibly the C standards committee the concept of a bit
> > pattern (that might commonly be INT_MAX or UINT_MAX) that means "time
> > unknown", or "time indefinite" or "we couldn't encode the time".
> > 
> 
> (time_t)-1 already has this meaning for some calls (e.g. time(2)).
> However, this also means Wed Dec 31 23:59:59 UTC 1969, and unfortunately
> something similar applies to all possible bit patterns, certainly within
> the range of an int.

Worse than Wed Dec 31 23:59:59 UTC 1969, on NFSv3 it also means
"Sun Feb  7 07:28:15 CET 2106", and that is much harder to distinguish
from a real future date.

If we had the choice, I'd go for something like 1, i.e.
"Thu Jan  1 01:00:01 CET 1970".

> > We would then teach gmtime(3) and asctime(3) to print some appropriate
> > message, and we could teach programs like find (with the -mtime)
> > option, make, tmpwatch, et. al., that they can't make any presumption
> > about the comparibility of any timestamp which has a value of
> > TIME_UNDEFINIED.
> > 
> > It would be problematic for time(2) or gettimeofday(2) to return
> > TIME_UNDEFINED, since there are programs that care about time ticking
> > forward, but I could imagine a new interface which would be permitted
> > to return a flag indicating that we don't know the current time
> > (because the CMOS battery had run down, etc.) so instead we're going
> > to be counting the number of seconds since the system was booted.
> 
> This assumes that we actually know that that is the case, which may be
> an aggressive assumption.

It's harder for time(2), but for the inode case, we can definitely
detect when the file system specific representation overflows
or underflows, which may be be at a number of very different points
of time.

	Arnd
