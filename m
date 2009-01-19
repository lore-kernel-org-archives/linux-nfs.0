From: Jason Baron <jbaron@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Mon, 19 Jan 2009 14:49:58 -0500
Message-ID: <20090119194958.GA3108@redhat.com>
References: <49711BDF.3010605@melbourne.sgi.com> <x49ab9ntlpp.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>,
	Steve Dickson <SteveD@redhat.com>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: Jeff Moyer <jmoyer@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59273 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751843AbZASTur (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jan 2009 14:50:47 -0500
In-Reply-To: <x49ab9ntlpp.fsf-RRHT56Q3PSP4kTEheFKJxxDDeQx5vsVwAInAS/Ez/D0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 19, 2009 at 09:27:30AM -0500, Jeff Moyer wrote:
> Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org> writes:
> 
> > Steve Dickson wrote:
> >> So the ultimate goal would be to replace all the dprintks with trace points
> >> but still be able to enable them through the rpcdebug command
> > I have a patch which changes the definition of the dprintk() macro (but
> > *not* dprintk() callsites) to allow enabling and disabling individual
> > dprintk() statements through a /proc/ interface.  Would you be
> > interested in that?
> 
> That sounds like duplicated work.  How does it differ from Jason Baron's
> dynamic printk patches (which I believe are now upstream)?
> 
> Cheers,
> Jeff

indeed. I've implemented a solution in a very similar problem space
which is now upstream, see:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=346e15beb5343c2eb8216d820f2ed8f150822b08;hp=33376c1c043c05077b4ac79c33804266f6c45e49

One of the core fundamental differences that I see is that 'dprintk'
checks a global variable per dprintk line. Whereas, 'dynamic printk'
assigns each module a set of bits in a *single* global variable. The
idea was that if you have thousands of these debug lines throughout the
kernel, I wanted to have a small footprint.

The per-dprintk granularity could be implemented on top of the
per-module approach that i've taken. That is, each dprintk statement
could activate the module that its associated with when its activated.
Then, a further per-line variable could be checked.

We should probably move this discussion to lkml, since this probably
should involve a wider audience. Perhaps, you can re-post your patchset
there?

thanks,

-Jason



