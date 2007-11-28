From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] sunrpc: don't xprt_complete_rqst on truncated tcp replies
Date: Wed, 28 Nov 2007 14:08:00 -0500
Message-ID: <1196276880.7100.26.camel@heimdal.trondhjem.org>
References: <1196274435-30152-1-git-send-email-bhalevy@panasas.com>
	<7324CF92-34F2-4CC3-B4D6-168C07499F22@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <7324CF92-34F2-4CC3-B4D6-168C07499F22@oracle.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2007-11-28 at 14:04 -0500, Chuck Lever wrote:
> Hi Benny-
> 
> On Nov 28, 2007, at 1:27 PM, Benny Halevy wrote:
> > processing a truncated reply can cause havoc and it is
> > probably better to drop it instead.
> 
> Actually, wouldn't a truncated reply be a sign that the server or  
> client RPC stream has become out of sync?  Perhaps it would be better  
> to drop the connection in this case?

Again no. It could just be a sign of the allocator failing in
xdr_partial_copy_from_skb() for an nfsacl request.

Trond
