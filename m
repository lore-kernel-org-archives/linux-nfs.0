From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: convert nfs4 callback thread to kthread API
Date: Wed, 20 Feb 2008 10:39:36 -0500
Message-ID: <1203521976.11997.15.camel@heimdal.trondhjem.org>
References: <1203515730-15974-1-git-send-email-jlayton@redhat.com>
	<1203520163.8620.14.camel@heimdal.trondhjem.org>
	<20080220151532.GA30160@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080220151532.GA30160@fieldses.org>
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


On Wed, 2008-02-20 at 10:15 -0500, J. Bruce Fields wrote:
> On Wed, Feb 20, 2008 at 10:09:23AM -0500, Trond Myklebust wrote:
> > 
> > On Wed, 2008-02-20 at 08:55 -0500, Jeff Layton wrote:
> > > There's a general push to convert kernel threads to use the (much
> > > cleaner) kthread API. This patch converts the NFSv4 callback kernel
> > > thread to the kthread API. In addition to being generally cleaner this
> > > also removes the dependency on signals when shutting down the thread.
> > > 
> > > Note that this patch depends on the recent patches to svc_recv() to
> > > make it check kthread_should_stop() periodically. Those patches are
> > > in Bruce's tree at the moment and are slated for 2.6.26 along with
> > > the lockd conversion, so this conversion is probably also appropriate
> > > for 2.6.26.
> > 
> > Since this only touches the callback server, can't we just ask Bruce to
> > pick up this patch and merge it together with the others?
> 
> Yep.  Can I take that as an ACK from you, or do you still need to read
> it over?

Feel free to add an 'acked-by' on my behalf...
