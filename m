From: "Frank Ch. Eigler" <fche@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Mon, 19 Jan 2009 10:41:33 -0500
Message-ID: <20090119154133.GE1574@redhat.com>
References: <4970B451.4080201@RedHat.com> <49711BDF.3010605@melbourne.sgi.com> <y0mmydpucww.fsf@ton.toronto.redhat.com> <4973B777.2000102@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	SystemTAP
	<public-systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43193 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751843AbZASPll (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jan 2009 10:41:41 -0500
In-Reply-To: <4973B777.2000102-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi -

On Mon, Jan 19, 2009 at 10:12:55AM +1100, Greg Banks wrote:
> [...]
> > It would make more sense to me to turn dprintk's into trace_marks, 
> Umm, ok.  Sorry to be so ignorant but where would I find the doc that
> tells me about adding trace marks ?

Documentation/markers.txt

> The control interface seems a little primitive.  It seems like you
> can only activate and deactivate single printks ?

Or single classes (identical names) per activate/deactivate call.

> I don't see a way to e.g.  activate every trace make in a particular
> function, or in a particular .c file.  I thought both of these were
> useful things to do, so I implemented them.  Below is an extract
> from the doc that accompanies the sgi-dprintk module. [...]

Very clever!

I am not an insider enough to carry much weight in this regard, but it
would make most sense to me if the sgi-dprintk widget were adapted so
that:
- it used trace_mark() as the low-level hook mechanism at the call sites
- it extended the trace_mark structures to track
  __FILE__/__LINE__/__FUNCTION__   values
- it extended the marker activation API to be able to specify queries
  based upon those __FILE__/etc. fields
- as an extension to the proposed marker->ftrace patch, extend the
  option parser the same way as your /proc/dprintk does

The benefits might not be huge, but:
- it would reuse existing functionality (markers for the hooks, other
  ftrace widgets for extra info to gather at each event - like the
  stack traces)
- it could generalize the handling of these dprintks, by not just
  being tied to message printing, but becoming of possible use for
  statistics/health monitoring

- FChE
