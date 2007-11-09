From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [NFS] [PATCH 3/7] SUNRPC: Allow the client to detect if the
	TCP connection	is closed
Date: Fri, 09 Nov 2007 10:32:49 -0500
Message-ID: <1194622369.7459.52.camel@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003950.13713.24126.stgit@heimdal.trondhjem.org>
	<EXNANE01OMyQlmLFQG100000900@exnane01.hq.netapp.com>
	<1194618806.7459.44.camel@heimdal.trondhjem.org>
	<EXNANE01prR0E6faZWZ00000903@exnane01.hq.netapp.com>
	<1194619730.7459.48.camel@heimdal.trondhjem.org>
	<EXNANE01CIFoPkG0rm300000904@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Chuck Lever <Chuck.Lever@oracle.com>,
	nfsv4@linux-nfs.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <EXNANE01CIFoPkG0rm300000904@exnane01.hq.netapp.com>
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


On Fri, 2007-11-09 at 10:25 -0500, Talpey, Thomas wrote:
> At 09:48 AM 11/9/2007, Trond Myklebust wrote:
> > The state change occurs while we're
> >inside the call to ->shutdown(), so there is no delay.
> 
> I don't think so, in the case that the network is disconnected and
> there is some data pending in the TCP output queue. The FIN won't
> be sent until the window advances to allow it, and this could happen
> much later. In the meantime, the xprt isn't even marked CLOSING.

Oh, I see what you mean. So, correction: the TCP_FIN_WAIT1 state means
that the FIN has been _queued_ by the TCP layer. It may or may not have
hit the wire yet.

Cheers
  Trond
