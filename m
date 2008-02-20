From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NFS: convert nfs4 callback thread to kthread API
Date: Wed, 20 Feb 2008 10:13:25 -0500
Message-ID: <20080220101325.30c9a039@barsoom.rdu.redhat.com>
References: <1203515730-15974-1-git-send-email-jlayton@redhat.com>
	<1203520163.8620.14.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1203520163.8620.14.camel@heimdal.trondhjem.org>
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

On Wed, 20 Feb 2008 10:09:23 -0500
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Wed, 2008-02-20 at 08:55 -0500, Jeff Layton wrote:
> > There's a general push to convert kernel threads to use the (much
> > cleaner) kthread API. This patch converts the NFSv4 callback kernel
> > thread to the kthread API. In addition to being generally cleaner
> > this also removes the dependency on signals when shutting down the
> > thread.
> > 
> > Note that this patch depends on the recent patches to svc_recv() to
> > make it check kthread_should_stop() periodically. Those patches are
> > in Bruce's tree at the moment and are slated for 2.6.26 along with
> > the lockd conversion, so this conversion is probably also
> > appropriate for 2.6.26.
> 
> Since this only touches the callback server, can't we just ask Bruce
> to pick up this patch and merge it together with the others?
> 

Sounds reasonable to me.

-- 
Jeff Layton <jlayton@redhat.com>
