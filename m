Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mrout2-b.corp.re1.yahoo.com ([69.147.107.21]:26826 "EHLO
	mrout2-b.corp.re1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751836Ab0AUBZN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jan 2010 20:25:13 -0500
Date: Wed, 20 Jan 2010 19:22:31 -0600
From: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
To: Peter Staubach <staubach@redhat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Difference between v2.6.31 and v2.6.32 spikes READs
Message-ID: <20100121012231.GB30642@yahoo-inc.com>
References: <20100105232342.GA22969@yahoo-inc.com> <4B44D0A4.2020509@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B44D0A4.2020509@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 06, 2010 at 10:04:20AM -0800, Peter Staubach wrote:
> Quentin Barnes wrote:
> > I moved from v2.6.31.3 to v2.6.32.2 and noticed a huge spike in the
> > number of NFSv3 READs issued for the application I'm porting.  The
> > app has a mixed load of short NFS I/O operations, but about 50% of
> > the time the app is doing an open(2), append to the file a small
> > amount of data (~300 bytes), then closes the file.  On v2.6.31.3,
> > this resulted in a LOOKUP, ACCESS, and a WRITE of 300 bytes.  Now
> > for the append operations with v2.6.32.2, I see LOOKUP, ACCESS,
> > READ, and WRITE.
> > 
> > Here's the network trace for an append with 2.6.31.3:
> > ===========
> > LOOKUP Call, DH:0x0308031e/scr2
> > LOOKUP Reply, FH:0x29f0b5d0
> > ACCESS Call, FH:0x29f0b5d0
> > ACCESS Reply
> > WRITE Call, FH:0x29f0b5d0 Offset:17284 Len:300 UNSTABLE
> > WRITE Reply Len:300 UNSTABLE
> > COMMIT Call, FH:0x29f0b5d0
> > COMMIT Reply
> > ===========
> > 
> > And for 2.6.32.2:
> > ===========
> > LOOKUP Call, DH:0x0308031e/scr2
> > LOOKUP Reply, FH:0x29f0b5d0
> > ACCESS Call, FH:0x29f0b5d0
> > ACCESS Reply
> > READ Call, FH:0x29f0b5d0 Offset:16384 Len:900
> > READ Reply Len:900
> > WRITE Call, FH:0x29f0b5d0 Offset:16384 Len:1200 UNSTABLE
> > WRITE Reply Len:1200 UNSTABLE
> > COMMIT Call, FH:0x29f0b5d0
> > COMMIT Reply
> > ===========
> > 
> > My think the behavior change is due to "read-modify-write page
> > updating" patch with adding the nfs_want_read_modify_write()
> > function, but that's just a guess.
> > 
> > Even with the additional READs, in some modes of the app performance
> > has gone up with v2.6.32 by 4.0%.  (Good!)  However, in other modes,
> > it has dropped 22%.  (Not good!)
> > 
> > If my guess is right, I'm wondering if the read-modify-write
> > updating patch accounted for files opened read-write, but only
> > written to or appended to before closing.
> > 
> > Can the read-modify-write page updating be altered to better handle
> > opens in read-write (O_RDWR) that only end up writing before
> > closing?
> > 
> 
> I believe that your analysis is correct.  The additional
> READ operation is probably coming from the client expecting
> to do a read-modify-write cycle instead of a modify-write-
> read cycle.
> 
> I suspect that the heuristic used could be augmented to be
> more clever, but the cost for normal operations would go
> up.
> 
> Instead of doing this, could you modify the application to
> open the file for writing only when just appending these
> small amounts of data?

I asked the app maintainer.  Luckily, in this case, he is able to go
ahead and make the change to his Linux port.

I brought this up here for two reasons.  1) To let people know that
if they are only writing/appending to a file that it's a good idea
to make sure they open the file with O_WRONLY instead of O_RDWR so
that they might see a performance boost they otherwise might not
know about on 2.6.32 kernels and later.  2) To let the NFS mailing
list know that a lot of people won't think to either change their
app, or can't for some reason and be stuck, so we might think about
fixing this performance issue at some point making the algorithm
more clever.

I haven't yet looked at the algorithm to know how difficult it
might be to fix.  If someone knows a way to make the tweak to the
algorithm, I'm willing to test it.

> 		ps
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Quentin
