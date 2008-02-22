From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: convert nfs4 callback thread to kthread API
Date: Thu, 21 Feb 2008 23:58:58 -0500
Message-ID: <20080222045858.GA12389@fieldses.org>
References: <1203515730-15974-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1203515730-15974-1-git-send-email-jlayton@redhat.com>
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

On Wed, Feb 20, 2008 at 08:55:30AM -0500, Jeff Layton wrote:
> There's a general push to convert kernel threads to use the (much
> cleaner) kthread API. This patch converts the NFSv4 callback kernel
> thread to the kthread API. In addition to being generally cleaner this
> also removes the dependency on signals when shutting down the thread.
> 
> Note that this patch depends on the recent patches to svc_recv() to
> make it check kthread_should_stop() periodically. Those patches are
> in Bruce's tree at the moment and are slated for 2.6.26 along with
> the lockd conversion, so this conversion is probably also appropriate
> for 2.6.26.

Thanks, applied.  (With a slight modification to make it apply against
upstream, by reverting the addition of the flush_signals().  I assume
that's right.)

--b.
