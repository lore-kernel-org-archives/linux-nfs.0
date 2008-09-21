From: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Sun, 21 Sep 2008 05:53:32 -0700 (PDT)
Message-ID: <614333.44648.qm@web32604.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>,
	linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Peter zijlstra <a.p.zijlstra@chello.nl>
To: Peter Staubach <staubach@redhat.com>,
	Chuck Lever <chucklever@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web32604.mail.mud.yahoo.com ([68.142.207.231]:44352 "HELO
	web32604.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751479AbYIUMxd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Sep 2008 08:53:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> >
> > I agree that a mount option would allow more fine-grained control over
> > readahead.  A system wide parameter controlling readahead has always
> > been a weakness.  Readahead, as implemented in the VFS, has a
> > *per-file descriptor* context, however, which operates automatically
> > (and can be tuned at run-time by an application with [mf]advise(2).
> >
> > As a future feature, this might work in better combination with the
> > per-mount bdi changes proposed by Peter to provide maximal flexibility
> > without exposing yet another confusing knob that could help some
> > workloads but hurt others.
> 
> And perhaps add some dynamic tuning capabilities to the NFS client
> code to just make it do "the right thing".  This would be better
> than any tunables and would help to serve in other situations, such
> as high bandwidth/latency networks, overloaded servers who don't
> need more read-ahead READ requests piled on, etc...
> 

 this goes over my capabilities, but would certainly help the situation. But then I would hate to see Sun/Linux going off the hook, because Linux just played nice :-)

Cheers
Martin

