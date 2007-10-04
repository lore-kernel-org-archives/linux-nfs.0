From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] What's slated for inclusion in 2.6.24-rc1 from the NFS
	client git tree...
Date: Thu, 04 Oct 2007 10:00:50 -0400
Message-ID: <1191506450.6685.17.camel@heimdal.trondhjem.org>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org>
	<20071004085206.0a8e37b5@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Andrew Morton <akpm@linux-foundation.org>,
	nfsv4@linux-nfs.org, linux-kernel@vger.kernel.org
To: Pierre Ossman <drzeus-list@drzeus.cx>, Peter Staubach <staubach@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20071004085206.0a8e37b5@poseidon.drzeus.cx>
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

On Thu, 2007-10-04 at 08:52 +0200, Pierre Ossman wrote:
> On Wed, 03 Oct 2007 19:41:16 -0400
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
> > 
> > We also have the 64-bit inode support from RedHat/Peter Staubach.
> > 
> 
> As has been pointed[1] out[2], this will cause regressions for non-LFS
> applications (of which there are still lots and lots). This change
> should be in feature-removal (the "feature" being removed is legacy
> support for non-LFS applications using NFS servers that make full use
> of the protocol) and preferably accompanied with appropriate user space
> changes (e.g. compatibility option in glibc).
> 
> [1] https://bugzilla.redhat.com/show_bug.cgi?id=241348
> [2] http://marc.info/?l=linux-nfs&m=118701088726477&w=2
> 
> Rgds

How about a boot/module parameter to turn it on or off?

I don't see any point in having a sysctl for something like this: either
you have legacy applications or you don't. It is not something that you
switch off as you go off to lunch.
A compile parameter, OTOH, would be too restrictive since it would force
distros to choose just one behaviour (which would mean they would have
to choose the most conservative).

Trond
