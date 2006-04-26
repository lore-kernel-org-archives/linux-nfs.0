From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Wed, 26 Apr 2006 11:44:10 -0400
Message-ID: <1146066250.8474.18.camel@lade.trondhjem.org>
References: <444EC96B.80400@RedHat.com>
	 <1146056601.8177.34.camel@lade.trondhjem.org> <444F7250.2070200@redhat.com>
	 <1146060112.8177.72.camel@lade.trondhjem.org> <444F8096.2070308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <444F8096.2070308@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2006-04-26 at 10:15 -0400, Peter Staubach wrote:
> >
> >What situations? AFAIA the number of processes in a typical setup are
> >almost always far smaller than the number of cached inodes.
> >
> >  
> >
> 
> The situation that doesn't scale is one where there are many different
> users on the system.  It is the situation where there are more then just
> a few users per file.  This can happen on compute servers or systems
> used for timesharing sorts of purposes.

Yes, but the number of users <= number of processes which even on those
systems is almost always much, much less than the number of cached
inodes.

> >For instance on my laptop, I'm currently running 146 processes, but
> >according to /proc/slabinfo I'm caching 330000 XFS inodes + 141500 ext3
> >inodes.
> >If I were to assume that a typical nfsroot system will show roughly the
> >same behaviour, then it would mean that a typical bucket in Steve's 256
> >hash entry table will contain at least 2000 entries that I need to
> >search through every time I want to do an access call.
> >
> 
> For such a system, there needs to be more than 256 hash buckets.  The number
> of the access cache hash buckets needs to be on scale with the number of 
> hash
> buckets used for similarly sized caches and tables.

The inode cache is the only similarly sized cache I can think of.

That is set either by the user, or it takes a default value of (total
memory size) / 2^14 buckets (see alloc_large_system_hash). On a 1Gb
system, that makes the default hash table size ~ 65536 entries. I can't
see people wanting to put up with a 256K static hash table for access
caching too.

Furthermore, note that the inode cache is only searched when
initialising a dentry. It is not searched on _every_ traversal of a path
element.

Cheers,
  Trond

