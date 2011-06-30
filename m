Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36527 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751046Ab1F3LKh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2011 07:10:37 -0400
Date: Thu, 30 Jun 2011 21:10:26 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Prem Karat <prem.karat@linux.vnet.ibm.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] nfs-utils: Don't hard code source and destination
 args
Message-ID: <20110630211026.66f1b7b4@notabene.brown>
In-Reply-To: <4E0C56BC.7010606@RedHat.com>
References: <20110628104138.GB6600@d6fc318.ibm.com>
	<4E0B3687.6060209@RedHat.com>
	<20110630090932.10caeca6@notabene.brown>
	<4E0C56BC.7010606@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 30 Jun 2011 06:58:04 -0400 Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 06/29/2011 07:09 PM, NeilBrown wrote:
> > On Wed, 29 Jun 2011 10:28:23 -0400 Steve Dickson <SteveD@redhat.com> wrote:
> > 
> >>
> >>
> >> On 06/28/2011 06:41 AM, Prem Karat wrote:
> >>>
> >>> Currently souce and destination parameters should be passed as first and 
> >>> second paramter while using mount.nfs. This patch allows them to be passed 
> >>> anywhere while mounting.
> >>>
> >>> Current functionality is
> >>> 	mount.nfs source destn -o <options>
> >>> This patch will allow to do this
> >>> 	mount.nfs -o <options> source destn
> >>> 		or
> >>> 	mount.nfs -o <options> source -o <options> destn
> >>>
> >>> Signed-off-by: Prem Karat <prem.karat@linux.vnet.ibm.com>
> >> Committed...
> > 
> > Uhmm... that's unfortunate because the patch is badly broken.
> > 
> > With the patch in place, argv[2] gets destroyed.
> > i.e. mount cannot possibly work correctly now.
> > 
> > And that is just the start of the problems.
> > 
> > This patch has clearly never been tested.
> Hmm... well this is not true... I have 1.2.4 running
> on a number of machines and without a problem...

I'm guessing you used --enable-libmount-mount which causes the patched code
to not be compiled.  So while you did test nfs-utils, I don't think you
tested the patch :-(

> 
> But I will looking what you are saying...
> 
Thanks,

NeilBrown
