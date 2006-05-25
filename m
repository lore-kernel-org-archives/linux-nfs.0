From: Ian Kent <raven@themaw.net>
Subject: Re: [autofs] Re: [NFS] Re: [RFC] Multiple server selection and
	replicated mount failover
Date: Thu, 25 May 2006 11:56:26 +0800
Message-ID: <1148529386.2704.22.camel@raven.themaw.net>
References: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
	 <Pine.LNX.4.64.0605241240200.3730@raven.themaw.net>
	 <1148488156.5872.42.camel@lade.trondhjem.org>
	 <x49ac97cnja.fsf@segfault.boston.redhat.com>
	 <1148495501.11732.8.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jeff Moyer <jmoyer@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	autofs mailing list <autofs@linux.kernel.org>,
	nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1148495501.11732.8.camel@lade.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2006-05-24 at 14:31 -0400, Trond Myklebust wrote:
> On Wed, 2006-05-24 at 13:58 -0400, Jeff Moyer wrote:
> > ==> Regarding [autofs] Re: [NFS] Re: [RFC] Multiple server selection and replicated mount failover; Trond Myklebust <trond.myklebust@fys.uio.no> adds:
> > 
> > trond.myklebust> On Wed, 2006-05-24 at 13:05 +0800, Ian Kent wrote:
> > >> > 4) How does NFS v4 fit into this picture as I believe that some
> > >> >    of this functionality is included within the protocol.
> > >> 
> > >> And this.
> > >> 
> > >> NFS v4 appears quite different so should I be considering this for v2 and 
> > >> v3 only?
> > 
> > trond.myklebust> NFSv4 has full support for migration/replication in the
> > trond.myklebust> protocol. If a filesystem fails on a given server, then
> > trond.myklebust> the server itself will tell the client where it can find
> > trond.myklebust> the replicas. There should be no need to provide that
> > trond.myklebust> information at mount time.
> > 
> > And what happens when the server disappears?
> 
> There are 2 strategies for dealing with that:
> 
> Firstly, we can maintain a cache of the list of replica volumes (we can
> request the list of replicas when we mount the original volume).
> 
> Secondly, there are plans to add a backup list of failover servers in a
> specialised DNS record. This strategy could be made to work for NFSv2/v3
> too.
> 

I see. That would work fine.

Personally, I'm not keen on using DNS for this as it adds another
source, separate from the original source, that needs to be kept up to
date.

Unfortunately, in many environments it's not possible to deploy new
services, often for several years after they become available. So there
is a need to do this for v2 and v3 in the absence of v4. We at least
need to support the mount syntax used in other industry OSs to round out
the v2 and v3 implementation, so using mount seems the logical thing to
do. I think this would also fit in well with v4 in that, as you mention
above, the replica information needs to be gathered at mount time.

I have the opportunity to spend some time on this now.

Ideally I would like to fit in with the work that is being done for v4
as much as possible. For example I noticed references to a struct
nfs_fs_locations in you patch set which may be useful for the
information I need. However, I haven't spotted anything that relates to
fail detection and fail over itself (ok I know you said your working on
it) so perhaps I can contribute to this in a way that could help your v4
work. So what's you plan for this?

Ian


