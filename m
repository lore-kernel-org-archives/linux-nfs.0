From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: have string-based mount options default to "intr"
	mounts
Date: Wed, 25 Jul 2007 22:44:00 -0400
Message-ID: <1185417840.6585.143.camel@localhost>
References: <20070725145614.e17ca721.jlayton@redhat.com>
	<46A7A632.2050900@oracle.com>	<20070725154107.063c3b9a.jlayton@redhat.com>
	<1185394617.6585.135.camel@localhost>  <46A7B450.3060304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	Jeff Layton <jlayton@redhat.com>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <46A7B450.3060304@redhat.com>
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

On Wed, 2007-07-25 at 16:36 -0400, Peter Staubach wrote:

> It sounds like the sync to disk on close() needs to be done in a
> separate context and have the process in close() wait on it?  That
> way, the process which received the signal could abort and return
> without waiting on all of the data to get flushed, but the data
> would still get flushed in a timely fashion?

We could do that, but what kind of extra guarantees would that provide?
The whole question is what you mean by "timely fashion" here. Normally,
I'd expect that to mean "before any locks are freed", in which case I
don't see how a separate flush context will help here...

> I suspect that as soon as you throw in a close() which returns
> EINTR, then all assumptions about close-to-open become null and
> void.

Exactly. Byte range locks will be automatically freed as part of the
POSIX close() process, and the application itself may still survive for
long enough to release other locks (dotlocks etc...) that it may hold.

Trond
