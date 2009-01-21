From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 15:04:01 -0200
Message-ID: <20090121170401.GD4394@ghostprotocols.net>
References: <49711BDF.3010605@melbourne.sgi.com> <x49ab9ntlpp.fsf@segfault.boston.devel.redhat.com> <20090121101329.GA4876@in.ibm.com> <49774FDC.5090307@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: prasad@linux.vnet.ibm.com,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40597 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752381AbZAUREJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jan 2009 12:04:09 -0500
In-Reply-To: <49774FDC.5090307-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Em Wed, Jan 21, 2009 at 11:39:56AM -0500, Steve Dickson escreveu:
> K.Prasad wrote:
> > On Mon, Jan 19, 2009 at 09:27:30AM -0500, Jeff Moyer wrote:
> >> Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org> writes:
> >>
> >>> Steve Dickson wrote:
> >>>> So the ultimate goal would be to replace all the dprintks with trace points
> >>>> but still be able to enable them through the rpcdebug command
> >>> I have a patch which changes the definition of the dprintk() macro (but
> >>> *not* dprintk() callsites) to allow enabling and disabling individual
> >>> dprintk() statements through a /proc/ interface.  Would you be
> >>> interested in that?
> >> That sounds like duplicated work.  How does it differ from Jason Baron's
> >> dynamic printk patches (which I believe are now upstream)?
> >>
> >> Cheers,
> >> Jeff
> > 
> > Introducing/converting one of the accepted methods of static
> > instrumentation - like tracepoints would help more users (whether
> > in-kernel or otherwise) harness them.
> > 
> > Steve,
> > 	Would it help convert the systemtap script (nfs_mount.stp) in
> > Patch - 5 into a kernel module (perhaps in samples/ directory) to bring
> > an in-kernel user of these tracepoints?
> Well nfs_mount.stp was just an example of how to pull the information
> from the kernel.. I just wanted to complete the loop... but as 
> Christoph pointed out it probably shouldn't been included in the posting.
> 
> I'm not sure moving the nfs_mount.stp script into kernel 
> would make sense. One of the advantages of trace point and system
> scripts (depending on what is passed up) it allows users to define
> exactly what they need to see.. 
> 
> For example, a kernel guy might be interested in a particular bit in a flag 
> field which would be meaningless to an IT guy. On the other hand, the IT guy 
> would be interested in the error code. One trace point could supply all the
> information but different systemtap scripts would be need to show the 
> desired information.
> 
> My point being, if we move things down into the kernel, I think we would
> lose this type of flexibly...

I suggest you provide an ftrace plugin, just like I'm doing with
blktrace, see:

http://lkml.org/lkml/2009/1/20/190

- Arnaldo
