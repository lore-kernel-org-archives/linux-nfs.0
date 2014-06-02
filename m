Return-Path: linux-nfs-owner@vger.kernel.org
Received: from imap.thunk.org ([74.207.234.97]:45729 "EHLO imap.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752132AbaFBPbn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jun 2014 11:31:43 -0400
Date: Mon, 2 Jun 2014 11:31:24 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Nicolas Pitre <nicolas.pitre@linaro.org>,
        "H. Peter Anvin" <hpa@zytor.com>, Dave Chinner <david@fromorbit.com>,
        LKML Kernel <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org,
        joseph@codesourcery.com, john.stultz@linaro.org,
        Christoph Hellwig <hch@infradead.org>, tglx@linutronix.de,
        geert@linux-m68k.org, lftan@altera.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, xfs@oss.sgi.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC 11/32] xfs: convert to struct inode_time
Message-ID: <20140602153124.GH30598@thunk.org>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
 <8618458.1EVJCoVbkH@wuerfel>
 <alpine.LFD.2.11.1406012121430.17310@knanqh.ubzr>
 <4178301.j9kWdGCRLC@wuerfel>
 <6868F108-F0B2-423F-AE31-90DF86A5B7DD@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <6868F108-F0B2-423F-AE31-90DF86A5B7DD@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 02, 2014 at 11:04:23AM -0400, Chuck Lever wrote:
> I’m wondering what should be done about NFS. A solution for NFS should
> match any scheme that is considered for local file systems, IMO.
> 
> An alternative would be to “cap” the timestamps transmitted via NFSv3 by
> Linux, so that a pre-epoch timestamp is transmitted as zero, and a large
> timestamp is transmitted as UINT_MAX.


I wonder if it would make sense to try to promulgate via the Austin
group, and possibly the C standards committee the concept of a bit
pattern (that might commonly be INT_MAX or UINT_MAX) that means "time
unknown", or "time indefinite" or "we couldn't encode the time".

We would then teach gmtime(3) and asctime(3) to print some appropriate
message, and we could teach programs like find (with the -mtime)
option, make, tmpwatch, et. al., that they can't make any presumption
about the comparibility of any timestamp which has a value of
TIME_UNDEFINIED.

It would be problematic for time(2) or gettimeofday(2) to return
TIME_UNDEFINED, since there are programs that care about time ticking
forward, but I could imagine a new interface which would be permitted
to return a flag indicating that we don't know the current time
(because the CMOS battery had run down, etc.) so instead we're going
to be counting the number of seconds since the system was booted.

    	      	      	    	       - Ted
