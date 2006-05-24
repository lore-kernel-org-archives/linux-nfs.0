From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Re: [RFC] Multiple server selection and replicated mount
	failover
Date: Wed, 24 May 2006 12:29:16 -0400
Message-ID: <1148488156.5872.42.camel@lade.trondhjem.org>
References: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
	 <Pine.LNX.4.64.0605241240200.3730@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	autofs mailing list <autofs@linux.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Ian Kent <raven@themaw.net>
In-Reply-To: <Pine.LNX.4.64.0605241240200.3730@raven.themaw.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2006-05-24 at 13:05 +0800, Ian Kent wrote:

> It seems to me that there are two similar ways to do this:
> 
> 1) Pass a list of address and path entries to NFS at mount time and 
> intercept errors, identify if the host is down and if it is select and 
> mount another server.
> 
> 2) Mount each member of the list with the best one on top and intercept 
> errors, identify if the host is down and if it is select another from the 
> list of mounts and put it atop the mounts. Maintaining the ordering with 
> this approach could be difficult.

Solaris has implemented option (1). To me, that is the approach that
makes the most sense: why add the overhead of maintaining all these
redundant mounts?

> With either of these approaches handling open files and held locks appears 
> to be the the difficult part.

Always has been, and always will. We're working on this problem, but
progress is slow. In any case, we'll be concentrating on solving it for
NFSv4 first (since that has native support for migrated/replicated
volumes).

> Anyone have anything to contribute on how I could handle this or problems 
> that I will encounter?
> 
> 
> snip ..
> 
> > 
> > 3) Is there any existing work available that anyone is aware
> >    of that could be used as a reference.
> 
> Still wondering about this.
> 
> > 
> > 4) How does NFS v4 fit into this picture as I believe that some
> >    of this functionality is included within the protocol.
> 
> And this.
> 
> NFS v4 appears quite different so should I be considering this for v2 and 
> v3 only?

NFSv4 has full support for migration/replication in the protocol. If a
filesystem fails on a given server, then the server itself will tell the
client where it can find the replicas. There should be no need to
provide that information at mount time.

Cheers,
  Trond

