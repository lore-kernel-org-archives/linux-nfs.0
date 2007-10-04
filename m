From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [NFS] What's slated for inclusion in 2.6.24-rc1 from the NFS
	client git tree...
Date: Thu, 4 Oct 2007 12:59:16 -0700
Message-ID: <20071004125916.dbe4fd13.akpm@linux-foundation.org>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>
	<20071004085206.0a8e37b5@poseidon.drzeus.cx>
	<1191506450.6685.17.camel@heimdal.trondhjem.org>
	<20071004184304.6e71ab6d@poseidon.drzeus.cx>
	<20071004114243.3161af16.akpm@linux-foundation.org>
	<1191525363.6739.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, drzeus-list@drzeus.cx
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1191525363.6739.12.camel@heimdal.trondhjem.org>
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

On Thu, 04 Oct 2007 15:16:03 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> > > 
> > > That would be perfect. It can even be in non-legacy mode by default,
> > > just as long as you can go back to the old behaviour when/if you run
> > > into a non-LFS application.
> > > 
> > 
> > Wouldn't a mount option be better?
> 
> I suppose that might be OK if you know that the 32-bit legacy
> applications will only touch one or two servers, but that sounds like a
> niche thing.
> 
> On the downside, forcing all those people who have portable 64-bit aware
> applications to upgrade their version of mount just in order to have
> stat64() work correctly seems unnecessarily complicated. I'd prefer not
> to have to do that unless someone comes up with a good reason why we
> must.

Confused.  You don't need to modify mount(8) when adding a new mount option?
