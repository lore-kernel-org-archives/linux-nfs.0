From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: possible module refcount leak with auth_gss
Date: Wed, 17 Dec 2008 15:09:35 -0500
Message-ID: <20081217200935.GQ4614@fieldses.org>
References: <4d569c330812091521s6b9405faq910cb94f067f3b@mail.gmail.com>
	<20081210112506.2b2d2c3a@tleilax.poochiereds.net>
	<20081210163136.GB28263@fieldses.org>
	<20081216164532.22cab9d6@tleilax.poochiereds.net>
	<20081216214051.51019f51@tupile.poochiereds.net>
	<20081217192047.GL4614@fieldses.org>
	<20081217143458.080aa9be@tleilax.poochiereds.net>
	<20081217194127.GN4614@fieldses.org>
	<1229543651.7257.107.camel@heimdal.trondhjem.org>
	<20081217200701.GP4614@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org, Trond Myklebust <trond@netapp.com>,
	Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20081217200701.GP4614@fieldses.org>
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

On Wed, Dec 17, 2008 at 03:07:01PM -0500, bfields wrote:
> On Wed, Dec 17, 2008 at 02:54:11PM -0500, Trond Myklebust wrote:
> > On Wed, 2008-12-17 at 14:41 -0500, J. Bruce Fields wrote:
> > > It looks like the CRED_UPTODATE is just being used as a signal to decide
> > > whether the PROC_DESTROY has already been sent; the test_and_clear_bit
> > > ensures that the null call is made just once.  Maybe a separate flag
> > > would be simpler.
> > 
> > Just make a separate gss_destroy_cred() which doesn't call
> > gss_destroying_context() and stick it into gss_nullops.
> 
> Lost you there.  So you're thinking the current end of
> gss_destroy_cred():
> 
> 	rcu_assign_pointer(gss_cred->gc_ctx, NULL);
> 	call_rcu(&cred->cr_rcu, gss_free_cred_callback);
> 	if (ctx)
> 		gss_put_ctx(ctx);
> 	kref_put(&gss_auth->kref,
> 	gss_free_callback);
> 
> should go into a separate gss_nullops.crdestroy, and the real work of
> gss_destroying_context() (rpc_call_null, etc.) should be done
> unconditionally?
  ^^^^^^^^^^^^^^^

(OK, we still do want to skip it in the !UPTODATE case, but no need to
clear UPTODATE as any sort of extra guard against a second call any
more.)

--b.

> 
> (And presumably the rpc code already ensures that ->crdestroy is called
> exactly once?)
> 
> OK, makes sense.
> 
> --b.
