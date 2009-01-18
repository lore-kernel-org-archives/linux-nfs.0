From: "Frank Ch. Eigler" <fche@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Sun, 18 Jan 2009 12:47:41 -0500
Message-ID: <20090118174741.GC1574@redhat.com>
References: <4970B451.4080201@RedHat.com> <49711BDF.3010605@melbourne.sgi.com> <y0mmydpucww.fsf@ton.toronto.redhat.com> <4972A8F5.7070806@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks
	<public-gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>,
	Steve Dickson
	<public-SteveD-H+wXaHxf7aLQT0dZR+AlfA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>,
	Linux NFSv4 mailing list
	<public-nfsv4-6DNke4IJHB0gsBAKwltoeQ-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>,
	Linux NFS Mailing list
	<public-linux-nfs-u79uwXL29TY76Z2rM5mHXA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>,
	SystemTAP
	<public-systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from blaine.gmane.org ([80.91.229.8]:46381 "EHLO hugh.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933588AbZARRsP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 18 Jan 2009 12:48:15 -0500
Received: from public by hugh.gmane.org with local (Exim 4.63)
	(envelope-from <public-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>)
	id 1LObkk-00056O-E4
	for linux-nfs@vger.kernel.org; Sun, 18 Jan 2009 18:48:06 +0100
In-Reply-To: <4972A8F5.7070806@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi -

On Sat, Jan 17, 2009 at 09:58:45PM -0600, Tom Tucker wrote:
> [...]
> >>I have a patch which changes the definition of the dprintk() macro
> >>(but *not* dprintk() callsites) to allow enabling and disabling
> >>individual dprintk() statements through a /proc/ interface.  Would
> >>you be interested in that?
> >
> >It would make more sense to me to turn dprintk's into trace_marks, then
> >use http://lkml.org/lkml/2008/12/30/297 to control transmission of the
> >data to ftrace.

> [...]
> That said, and sorry for my ignorance on trace markers, but:
> 
> - Could you describe how we would define "classes" of trace markers. I 
> certainly don't want to have to turn on and off each call-site 
> individually. How would these classes be different than adding more bits 
> to the current rpc_debug mechanism?

You're well prepared to reuse the classes you already have - see below.


> - From Steve's patches, it's not obvious to me how we would convert 
> dprintk to trace markers without visiting every single call site. Can 
> the current macros be munged to use the trace marker interfaces without 
> losing debug information?

The minimal possibility is to just do something like this:

    #define dprintk(format...) trace_mark(nfs_message, format)

Or for the dfprintk that includes the facility symbol:

    #define dfprintk(facility,format...) trace_mark (nfs_#facility, format)

The result would be to have one marker family for each
{RPC,NFS,...}DBG_* type - or any other "facility" symbol you invent on
the spot.  All members of each family can be enabled by attaching a
marker handler to the "nfs_FACILITY" name.  With Lai's markers->ftrace
proposed patch, this would be done from user-space by something like:

   echo -n 'nfs_FACILITY' > /debugfs/tracing/tracing_markers

(You can take away the nfs_ prefix if you like.)

> - What is the overhead of an "inactive" trace marker in data size
> and execution time relative to a dprintk?

It should be similar.  The global {nfs,rpc,...}_debug numbers could go
away and just rely on the marker's built-in on/off control API.

> - What is the overhead of an "active" trace marker in data size and 
> execution time relative to a dprintk?

If the markers end up being channeled to the ftrace buffers, it should
be significantly lighter-weight than sending them to printk.  If some
other marker consumer connects also or instead, it depends on what
that does.


- FChE

