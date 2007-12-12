From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.24-rc3-git4 NFS crossmnt regression [SOLVED]
Date: Tue, 11 Dec 2007 18:15:59 -0800
Message-ID: <20071211181559.fe21687a.akpm@linux-foundation.org>
References: <fa4052ef0712062045o743a2666u3562a3569c1aa989@mail.gmail.com>
	<200712101705.30428.maximlevitsky@gmail.com>
	<20071210130305.d8983fdc.akpm@linux-foundation.org>
	<200712120401.57128.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bfields@fieldses.org, neilb@suse.de, rjw@sisk.pl,
	trond.myklebust@fys.uio.no, gnome42@gmail.com,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	den@openvz.org, linux-nfs@vger.kernel.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56088 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751334AbXLLCQs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 21:16:48 -0500
In-Reply-To: <200712120401.57128.maximlevitsky@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 12 Dec 2007 04:01:56 +0200 Maxim Levitsky <maximlevitsky@gmail.com> wrote:

> > 
> > argh, this is getting bad.
> > 
> > Can you please test the below patch asap? Against 2.6.24-rc4 or latest-linus.
> > 
> > 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > Revert
> > 
> >     commit 2b1e300a9dfc3196ccddf6f1d74b91b7af55e416
> >     Author: Eric W. Biederman <ebiederm@xmission.com>
> >     Date:   Sun Dec 2 00:33:17 2007 +1100
> > 
> 
> Hi,
> 
> I finally solved this.
> There is no need to revert 2b1e300a9dfc3196ccddf6f1d74b91b7af55e416.
> 
> It was actually a deadly mixture of 3 bugs:
> 
> 1) Stale handles - Trond's patch fixes it, but I somehow missed it.

What is "Trond's patch" and where is it now?

> 2) Empty /proc/fs/nfsd (which causes nfs4 failures, and masks the bug #1, since with it the subfolders are just empty)
> 	[PATCH 2.6.24-rc4] proc: Remove/Fix proc generic d_revalidate fixes it

That patch was merged into Linus's tree just prior to 2.6.24-rc5.

> 3) And as I expected, a userspace bug, which believe me or not has exactly the same symptoms
> like #2 (and doesn't depend on others)
> 
> It is a wrong boot script in BLFS that starts nfs daemons in wrong order.
> So there are 3 bugs and each masks the former one :-) .
> 
> I revised boot script to use recommended order like in nfs-utils.
> And finally everything works....
> 

Well...  It's relatively common that insufficiently-robust userspace works
OK under kernel N and then stops working under kernel N+1.  Even though the
fault lies with userspace, we prefer that it continues to work.

But it doesn't sounds like that'll be a concern here.

Thanks for the followup.
