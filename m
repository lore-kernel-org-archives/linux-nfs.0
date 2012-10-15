Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53989 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753733Ab2JOSCw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 14:02:52 -0400
Date: Mon, 15 Oct 2012 14:02:47 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Larry McVoy <lm@bitmover.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Message-ID: <20121015180246.GB26840@fieldses.org>
References: <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDED5@SACEXCMBX04-PRD.hq.netapp.com>
 <20121013023147.GJ23247@bitmover.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FE478@SACEXCMBX04-PRD.hq.netapp.com>
 <20121013025600.GL23247@bitmover.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9091FFA38@SACEXCMBX04-PRD.hq.netapp.com>
 <20121014014215.GO23247@bitmover.com>
 <20121015004302.GF32420@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA909236E9E@SACEXCMBX04-PRD.hq.netapp.com>
 <20121015143456.GA28502@bitmover.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121015143456.GA28502@bitmover.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 15, 2012 at 07:34:56AM -0700, Larry McVoy wrote:
> On Mon, Oct 15, 2012 at 04:38:02AM +0000, Myklebust, Trond wrote:
> > On Sun, 2012-10-14 at 20:43 -0400, Bruce Fields wrote:
> > > On Sat, Oct 13, 2012 at 06:42:15PM -0700, Larry McVoy wrote:
> > > > > PS: you are presumably running NFSv2 on your Macs. Odd that they should
> > > > > default to that...
> > > > 
> > > > I dunno if they default to that or we force that.  We have had lots of
> > > > problems with Linux NFS, we export our home directories but they are
> > > > more or less read only.
> > > > 
> > > > Maybe things have gotten better but back in the day I could crash the
> > > > kernel with a bk clone to a NFS directory.
> > > 
> > > Bug reports welcomed if any of those bugs are still around.
> > 
> > The other thing to note is that at this point, NFSv2 has been legacy
> > code for more than 10 years on Linux and is starting to suffer big time
> > from bit rot. We should probably aim to remove it entirely in the next
> > 1-2 years. There is no place in today's world for a protocol that can
> > only deal with a 2GB maximum file size...
> 
> Well, we support ancient machines (why?  damn good question) that only
> speak NFSv2 so it would sorta suck for us if you pulled it.

At least on the server side, I'd prefer to be more conservative about
removing NFSv2 support.

--b.
