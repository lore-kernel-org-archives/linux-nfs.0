From: Dennis Nezic <dennisn-YN8wfZw00oOZ9vWoFJJngh2eb7JE58TQ@public.gmane.org>
Subject: Re: nfs: server not responding, timed out
Date: Wed, 31 Mar 2010 11:59:26 -0400
Message-ID: <20100331115926.dff817c1.dennisn@dennisn.dyndns.org>
References: <20100318170603.f6a7f188.dennisn@dennisn.dyndns.org>
	<4BA2DFC5.1010400@cn.fujitsu.com>
	<20100319002720.0e93411e.dennisn@dennisn.dyndns.org>
	<20100319181038.c94fa3c4.dennisn@dennisn.dyndns.org>
	<20100330144438.GE11545@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:38954 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757140Ab0CaP7n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Mar 2010 11:59:43 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Nx0KS-0004OV-6c
	for linux-nfs@vger.kernel.org; Wed, 31 Mar 2010 17:59:40 +0200
Received: from 67.55.58.4 ([67.55.58.4])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 31 Mar 2010 17:59:40 +0200
Received: from dennisn by 67.55.58.4 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 31 Mar 2010 17:59:40 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 30 Mar 2010 10:44:38 -0400, J. Bruce Fields wrote:
> On Fri, Mar 19, 2010 at 06:10:38PM -0400, Dennis Nezic wrote:
> > On Fri, 19 Mar 2010 00:27:20 -0400, Dennis Nezic wrote:
> > > 
> > > Both the patches mentioned in that thread already seem to have
> > > been applied to my kernels. So, although the problem seems
> > > related, it wasn't that bug in particular. The person in that
> > > thread was talking about mounts dying after 5-15minutes, which
> > > doesn't happen with me -- my problem only seems to occur under
> > > intense activity.
> > 
> > Hrm. I just noticed that my scp transfers are stalling -- which also
> > didn't used to happen before with my old kernel. No error messages.
> > Ftp transfers work fine. Eek. :S. (Despite the freezing/stalling, my
> > *actual* network connection works perfectly.)
> 
> That also suggests some network problem....  Is the scp problem
> reproduceable?  Are packets getting dropped?

The scp problem is quite reproduceable -- when it decides to act up, it
quite consistently freezes/stalls at the same point (+/- a few (dozen)
MB) -- at least when testing roughly at the same time. I usually give
up after about 10 attempts. Sometimes, when it's a full moon, it will
work after ten attempts. (Restarting sshd has no effect.)

I haven't done any tcpdump yet.

I suspect the nfs stalls are also similarly reproduceable -- except
it's harder to tell since it doesn't display the progress as nicely as
scp :b. However, I did notice that nfs transfers very often stall at the
very beginning (I'm not sure if it's at byte 0, or a few MB in) -- as
well as at various points in the middle. (It "feels" like a bursting
buffer problem -- I remember maany times mplayer playing songs over
nfs, and having it stall before beginning the next song -- it buffered
about 32KB, but was waiting for a few more before it could start
playing. Very annoying :|.)


> 
> Also: is the kernel dumping any backtraces into the server's logs?

Nothing suspicious in the system logs, nor in verbose mode.


I'll try a different wifi driver soon, and see if the problem persists.

