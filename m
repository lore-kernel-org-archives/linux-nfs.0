From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/6] SUNRPC: Break up __svc_create_thread and make
	svc_create_kthread
Date: Thu, 13 Dec 2007 16:18:58 -0500
Message-ID: <20071213161858.4bf8b770@tleilax.poochiereds.net>
References: <1197578428-26815-1-git-send-email-jlayton@redhat.com>
	<1197578428-26815-2-git-send-email-jlayton@redhat.com>
	<1197578428-26815-3-git-send-email-jlayton@redhat.com>
	<20071213210643.GA28117@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20071213210643.GA28117@infradead.org>
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

On Thu, 13 Dec 2007 21:06:44 +0000
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Dec 13, 2007 at 03:40:24PM -0500, Jeff Layton wrote:
> > Move the initialization that happens prior to thread creation to a
> > new function (svc_prepare_thread) so that we can call it from a new
> > thread creation routine. Add a new function svc_create_kthread that
> > spawns svc threads using kthread API.
> > 
> > We should be able to eventually convert all of the callers to the
> > kthread API, at which point we can drop __svc_create_thread.
> 
> > +static struct svc_rqst *
> > +svc_prepare_thread(svc_thread_fn func, struct svc_serv *serv,
> > +		   struct svc_pool *pool)
> 
> Could you just export this helper? I'd rather have callers have full
> control over how they create their threads and call into a helper to
> initialize the sunrpc state.
> 

Sure, sounds reasonable. Once I collect comments on this patch and do a
respin, I'll plan to export that symbol.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
