From: David Chinner <dgc@sgi.com>
Subject: Re: [NFS] What's slated for inclusion in 2.6.24-rc1 from the NFS client git tree...
Date: Mon, 8 Oct 2007 08:56:09 +1000
Message-ID: <20071007225609.GQ23367404@sgi.com>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org> <20071004085206.0a8e37b5@poseidon.drzeus.cx> <1191506450.6685.17.camel@heimdal.trondhjem.org> <30494.1191605410@turing-police.cc.vt.edu> <20071005141222.5afbb6b9.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Valdis.Kletnieks@vt.edu, Peter Staubach <staubach@redhat.com>,
	Andrew@sc8-sf-spam2-b.sourceforge.net, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net, Pierre Ossman <drzeus-list@drzeus.cx>,
	Morton <akpm@linux-foundation.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757188AbXJGW4y@vger.kernel.org>
In-Reply-To: <20071005141222.5afbb6b9.jlayton@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Oct 05, 2007 at 02:12:22PM -0400, Jeff Layton wrote:
> On Fri, 05 Oct 2007 13:30:10 -0400
> Valdis.Kletnieks@vt.edu wrote:
> 
> > On Thu, 04 Oct 2007 10:00:50 EDT, Trond Myklebust said:
> > 
> > > How about a boot/module parameter to turn it on or off?
> > > 
> > > I don't see any point in having a sysctl for something like this: either
> > > you have legacy applications or you don't. It is not something that you
> > > switch off as you go off to lunch.
> > 
> > How does Joe Sysadmin tell if he has an affected legacy app or not?
> > 
> > (The obvious "try it and see what breaks" is a non-starter for many places,
> > because you too easily end up in a loop of "enable it, find 4-5 show stoppers,
> > turn it off, fix them, lather rinse repease".  Been there, done that, got
> > the tshirt - a project I got dragged into involves a large storage array that
> > appears to insist on exporting 64-bit stuff, and a large farm of clients that
> > are very 64-bit unclean....)
> > 
> 
> Note that "try it and see what breaks" isn't reliable either. If glibc
> gets back a 64 bit inode number that just happens to fit in the 32-bit
> field, then everything will work. You don't actually get an EOVERFLOW
> until st_ino overflows the field, and that may not happen often enough
> for testing this way to detect it...

There's a damn easy way of testing this.

Use XFS on a 64 bit Linux NFS server, mount is '-o inode64,ino64'
and then export it to you client that is going to have problems.
the "ino64" mount option guarantees that the userspace visible
inode number is always > 32 bits in length....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group
