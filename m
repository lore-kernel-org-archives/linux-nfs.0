From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: flush signals before taking down callback thread
Date: Tue, 19 Feb 2008 17:43:30 -0500
Message-ID: <1203461010.13265.12.camel@heimdal.trondhjem.org>
References: <1203443495-7854-1-git-send-email-jlayton@redhat.com>
	<20080219222226.GA10656@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080219222226.GA10656@infradead.org>
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


On Tue, 2008-02-19 at 17:22 -0500, Christoph Hellwig wrote:
> Wouldn't it be better to not allow for signals to this thread at all?
> The code really begs for a similar kthread conversion as the lockd one.

I'd tend to prefer that solution too.

Cheers
  Trond
