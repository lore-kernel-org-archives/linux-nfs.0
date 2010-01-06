From: Peter Staubach <staubach@redhat.com>
Subject: Re: Difference between v2.6.31 and v2.6.32 spikes READs
Date: Wed, 06 Jan 2010 13:04:20 -0500
Message-ID: <4B44D0A4.2020509@redhat.com>
References: <20100105232342.GA22969@yahoo-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755992Ab0AFSEV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 13:04:21 -0500
In-Reply-To: <20100105232342.GA22969@yahoo-inc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quentin Barnes wrote:
> I moved from v2.6.31.3 to v2.6.32.2 and noticed a huge spike in the
> number of NFSv3 READs issued for the application I'm porting.  The
> app has a mixed load of short NFS I/O operations, but about 50% of
> the time the app is doing an open(2), append to the file a small
> amount of data (~300 bytes), then closes the file.  On v2.6.31.3,
> this resulted in a LOOKUP, ACCESS, and a WRITE of 300 bytes.  Now
> for the append operations with v2.6.32.2, I see LOOKUP, ACCESS,
> READ, and WRITE.
> 
> Here's the network trace for an append with 2.6.31.3:
> ===========
> LOOKUP Call, DH:0x0308031e/scr2
> LOOKUP Reply, FH:0x29f0b5d0
> ACCESS Call, FH:0x29f0b5d0
> ACCESS Reply
> WRITE Call, FH:0x29f0b5d0 Offset:17284 Len:300 UNSTABLE
> WRITE Reply Len:300 UNSTABLE
> COMMIT Call, FH:0x29f0b5d0
> COMMIT Reply
> ===========
> 
> And for 2.6.32.2:
> ===========
> LOOKUP Call, DH:0x0308031e/scr2
> LOOKUP Reply, FH:0x29f0b5d0
> ACCESS Call, FH:0x29f0b5d0
> ACCESS Reply
> READ Call, FH:0x29f0b5d0 Offset:16384 Len:900
> READ Reply Len:900
> WRITE Call, FH:0x29f0b5d0 Offset:16384 Len:1200 UNSTABLE
> WRITE Reply Len:1200 UNSTABLE
> COMMIT Call, FH:0x29f0b5d0
> COMMIT Reply
> ===========
> 
> My think the behavior change is due to "read-modify-write page
> updating" patch with adding the nfs_want_read_modify_write()
> function, but that's just a guess.
> 
> Even with the additional READs, in some modes of the app performance
> has gone up with v2.6.32 by 4.0%.  (Good!)  However, in other modes,
> it has dropped 22%.  (Not good!)
> 
> If my guess is right, I'm wondering if the read-modify-write
> updating patch accounted for files opened read-write, but only
> written to or appended to before closing.
> 
> Can the read-modify-write page updating be altered to better handle
> opens in read-write (O_RDWR) that only end up writing before
> closing?
> 

I believe that your analysis is correct.  The additional
READ operation is probably coming from the client expecting
to do a read-modify-write cycle instead of a modify-write-
read cycle.

I suspect that the heuristic used could be augmented to be
more clever, but the cost for normal operations would go
up.

Instead of doing this, could you modify the application to
open the file for writing only when just appending these
small amounts of data?

		ps
