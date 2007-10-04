From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] What's slated for inclusion in 2.6.24-rc1 from the NFS
	client git tree...
Date: Thu, 04 Oct 2007 15:16:03 -0400
Message-ID: <1191525363.6739.12.camel@heimdal.trondhjem.org>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>
	<20071004085206.0a8e37b5@poseidon.drzeus.cx>
	<1191506450.6685.17.camel@heimdal.trondhjem.org>
	<20071004184304.6e71ab6d@poseidon.drzeus.cx>
	<20071004114243.3161af16.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, Pierre Ossman <drzeus-list@drzeus.cx>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20071004114243.3161af16.akpm@linux-foundation.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, 2007-10-04 at 11:42 -0700, Andrew Morton wrote:
> On Thu, 4 Oct 2007 18:43:04 +0200
> Pierre Ossman <drzeus-list@drzeus.cx> wrote:
> 
> > On Thu, 04 Oct 2007 10:00:50 -0400
> > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > 
> > > On Thu, 2007-10-04 at 08:52 +0200, Pierre Ossman wrote:
> > > > On Wed, 03 Oct 2007 19:41:16 -0400
> > > > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > > > 
> > > > > 
> > > > > We also have the 64-bit inode support from RedHat/Peter Staubach.
> > > > > 
> > > > 
> > > > As has been pointed[1] out[2], this will cause regressions for
> > > > non-LFS applications (of which there are still lots and lots). This
> > > > change should be in feature-removal (the "feature" being removed is
> > > > legacy support for non-LFS applications using NFS servers that make
> > > > full use of the protocol) and preferably accompanied with
> > > > appropriate user space changes (e.g. compatibility option in glibc).
> > > > 
> > > > [1] https://bugzilla.redhat.com/show_bug.cgi?id=241348
> > > > [2] http://marc.info/?l=linux-nfs&m=118701088726477&w=2
> > > > 
> > > > Rgds
> > > 
> > > How about a boot/module parameter to turn it on or off?
> > > 
> > 
> > That would be perfect. It can even be in non-legacy mode by default,
> > just as long as you can go back to the old behaviour when/if you run
> > into a non-LFS application.
> > 
> 
> Wouldn't a mount option be better?

I suppose that might be OK if you know that the 32-bit legacy
applications will only touch one or two servers, but that sounds like a
niche thing.

On the downside, forcing all those people who have portable 64-bit aware
applications to upgrade their version of mount just in order to have
stat64() work correctly seems unnecessarily complicated. I'd prefer not
to have to do that unless someone comes up with a good reason why we
must.

Cheers
  Trond
