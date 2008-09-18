From: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Thu, 18 Sep 2008 04:53:22 -0700 (PDT)
Message-ID: <688309.69831.qm@web32604.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>,
	linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Peter zijlstra <a.p.zijlstra@chello.nl>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web32604.mail.mud.yahoo.com ([68.142.207.231]:27982 "HELO
	web32604.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752513AbYIRLxX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2008 07:53:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message ----

> From: Andrew Morton <akpm@linux-foundation.org>
> To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
> Cc: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>; linux-nfs list <linux-nfs@vger.kernel.org>; linux-kernel@vger.kernel.org; Peter zijlstra <a.p.zijlstra@chello.nl>
> Sent: Thursday, September 18, 2008 10:47:33 AM
> Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
> 
> On Thu, 18 Sep 2008 01:38:57 -0700 (PDT) Martin Knoblauch 
> wrote:
> 
> > > No.  mount(8) will pass unrecognised options straight down into the
> > > filesystem driver.
> > >
> > 
> >  Has that always been the case, or is it a recent change? I have to support 
> RHEL4 userland, which is not really new.
> 
> It's been that way for ever and ever.  It's how all these guys:
> 
> y:/usr/src/25> grep Opt_ fs/*/super.c|wc
>     781    2626   33703
> 
> get handled.

 while that seems to be not to complicated, I seem to have a problem passing the mount options to the kernel. They come down as mount data version "6". Apparently mount(8) or mount.nfs(8) are doing the parsing and send down the legacy data block. So, what is the minimum version of mount or mount.nfs that pass the options down unaltered?

Cheers
Martin

