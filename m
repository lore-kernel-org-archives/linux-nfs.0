From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [PATCH] NFS: have string-based mount options default to
	intr mounts
Date: Wed, 25 Jul 2007 16:13:46 -0400
Message-ID: <1185394426.6585.131.camel@localhost>
References: <200707252005.QAA25492@snowhite.cis.uoguelph.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org, jlayton@redhat.com
To: Rick Macklem <rick@snowhite.cis.uoguelph.ca>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <200707252005.QAA25492@snowhite.cis.uoguelph.ca>
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

On Wed, 2007-07-25 at 16:05 -0400, Rick Macklem wrote:
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> > > I thought "nointr" was the default because it is safest.
> > > 
> 
> I was actually impressed that "intr" mounts work for NFSv4. I would have
> thought interrupting an RPC that has state related (Open, Lock,...) op(s)
> in it would cause grief later. (NFSERR_BADSEQID or similar)
> 
> Do you spin off kernel threads to babysit those outstanding RPCs? rick

Sort of. We run them as independent asynchronous RPC tasks. If the user
interrupts the request, then it is allowed to complete but once it does
then a new RPC call may be sent in order to undo the effects.

Cheers
  Trond
