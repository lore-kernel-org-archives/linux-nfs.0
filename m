From: Jeff Layton <jlayton@redhat.com>
Subject: Re: list corruption in locks_start_grace with 2.6.28-rc3
Date: Sat, 22 Nov 2008 09:22:37 -0500
Message-ID: <20081122092237.1ab81cdb@tleilax.poochiereds.net>
References: <x498wrokjj8.fsf@segfault.boston.devel.redhat.com>
	<20081120203735.GB30808@fieldses.org>
	<x49ej15gktp.fsf@segfault.boston.devel.redhat.com>
	<20081122005400.GB28094@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jeff Moyer <jmoyer@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51718 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758074AbYKVOWr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Nov 2008 09:22:47 -0500
In-Reply-To: <20081122005400.GB28094@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 21 Nov 2008 19:54:00 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Nov 21, 2008 at 10:28:18AM -0500, Jeff Moyer wrote:
> > "J. Bruce Fields" <bfields@fieldses.org> writes:
> > 
> > > On Wed, Nov 12, 2008 at 11:15:23AM -0500, Jeff Moyer wrote:
> > >> Hi,
> > >> 
> > >> I'm doing some testing which involves roughly the following:
> > >> 
> > >> o mount a file system on the server
> > >> o start the nfs service
> > >> - mount the nfs-exported file system from a client
> > >> - perform a dd from the client
> > >> - umount the nfs-exported file system from a client
> > >> o stop the nfs service
> > >> o unmount the file system on the server
> > >> 
> > >> After several iterations of this, varying the number of nfsd threads
> > >> started, I get the attached backtrace.  I've reproduced it twice, now.
> > >> 
> > >> Let me know if I can be of further help.
> > >
> > > Apologies for the delay, and thanks for the report.  Does the following
> > > help?  (Untested).
> > 
> > I get a new and different backtrace with this patch applied.  ;)
> > I'm testing with 2.6.28-rc5, fyi.
> 
> Thanks for the testing....
> 
> > 
> > static inline void __module_get(struct module *module)
> > {
> >         if (module) {
> >                 BUG_ON(module_refcount(module) == 0);      <------------
> >                 local_inc(&module->ref[get_cpu()].count);
> >                 put_cpu();
> >         }
> > }
> > 
> > Called from net/sunrpc/svcexport.c:svc_recv:687
> 
> You meant svc_xprt.c.  OK.
> 
> > 
> >         } else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
> >                 struct svc_xprt *newxpt;
> >                 newxpt = xprt->xpt_ops->xpo_accept(xprt);
> >                 if (newxpt) {
> >                         /*
> >                          * We know this module_get will succeed because the
> >                          * listener holds a reference too
> >                          */
> 
> So clearly the assumption stated in the comment is wrong.
> 
> I can't see any relationship between this and the previous bug, but
> perhaps it was covering this up somehow.
> 
> >                         __module_get(newxpt->xpt_class->xcl_owner);
> 
> I don't see the problem yet, but I'll look some more....
> 

FWIW, I've noticed some problems with refcounting when starting and
stopping nfsd. When you bring it up and take it back down again
repeatedly (i.e. run "rpc.nfsd 1" and "rpc.nfsd 0"), you'll lose 2
sunrpc module refs on each cycle.

I suspect the problem Jeff is hitting is due to that. Maybe he was just
reliably crashing before it got to 0 before. It's on my to-do list once
I get some other things off my plate. If someone wants to track it down
first, be my guest :)

I have a little more info in this RHBZ, but haven't had time to nail it
down yet:

https://bugzilla.redhat.com/show_bug.cgi?id=464123#c10

-- 
Jeff Layton <jlayton@redhat.com>
