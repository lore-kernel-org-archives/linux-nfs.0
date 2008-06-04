From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/4] knfsd: Replace lock_kernel with a mutex for nfsd
	thread startup/shutdown locking.
Date: Wed, 4 Jun 2008 18:41:20 -0400
Message-ID: <20080604224120.GI10362@fieldses.org>
References: <1212591796-22144-1-git-send-email-jlayton@redhat.com> <1212591796-22144-2-git-send-email-jlayton@redhat.com> <20080604210235.GC10362@fieldses.org> <20080604172752.31686797@tleilax.poochiereds.net> <20080604215815.GF10362@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39946 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751945AbYFDWlW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2008 18:41:22 -0400
In-Reply-To: <20080604215815.GF10362@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 04, 2008 at 05:58:15PM -0400, bfields wrote:
> On Wed, Jun 04, 2008 at 05:27:52PM -0400, Jeff Layton wrote:
> > On Wed, 4 Jun 2008 17:02:35 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Wed, Jun 04, 2008 at 11:03:13AM -0400, Jeff Layton wrote:
> > > > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > > > index 5ac00c4..d601a77 100644
> > > > --- a/fs/nfsd/nfsctl.c
> > > > +++ b/fs/nfsd/nfsctl.c
> > > ...
> > > > @@ -566,14 +574,13 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size)
> > > >  	return len;
> > > >  }
> > > >  
> > > > -static ssize_t write_ports(struct file *file, char *buf, size_t size)
> > > > +static ssize_t __write_ports(struct file *file, char *buf, size_t size)
> > > >  {
> > > >  	if (size == 0) {
> > > >  		int len = 0;
> > > > -		lock_kernel();
> > > > +
> > > >  		if (nfsd_serv)
> > > >  			len = svc_xprt_names(nfsd_serv, buf, 0);
> > > > -		unlock_kernel();
> > > 
> > > svc_xprt_names() has to be prepared to accept NULL as a first parameter
> > > (since we've got nothing here any longer to guarantee that nfsd_serv
> > > won't change after we've checked it).  And, indeed, it does check for
> > > that (with its local copy, which won't change.  So that's OK.  But then
> > > could we just ditch this redundant check here?  It's confusing.
> > > 
> > > Oops, but: what happens if something like this races with svc_destroy,
> > > so svc_xprt_names() is passed a pointer to freed memory?
> > > 
> > 
> > We do have a guarantee that nfsd_serv won't change after it's checked
> > here. The new nfsd_mutex protects it. write_ports has been renamed to
> > __write_ports, and write_ports has been turned into a wrapper that runs
> > the entire original function under the nfsd_mutex. We also have nfsd
> > hold the nfsd_mutex when svc_exit_thread is called, so svc_destroy
> > should also be called while holding it. That should serialize access
> > to the nfsd_serv.
> 
> Of course, you're right; thanks for setting me straight!

One more random point of confusion: is write_versions racy?  It assigns
to nfsd_versions, which is used in svc_process() to decide whether a
version is supported or not, without doing the adjustment of rq_argp and
rq_resp which a comment in write_versions() says is necessary.  And
there's no locking around the nfsd_serv check there.  So in theory could
a write_versions() at the wrong time result in an nfsd that accepted nfs
versions that it shouldn't (and hence could overflow some buffer)?

That'd be a preexisting problem, nothing to do with your work--I was
just grepping for uses of nfsd_serv....

--b.
