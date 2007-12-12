From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: 2.6.24-rc3-git4 NFS crossmnt regression [SOLVED]
Date: Wed, 12 Dec 2007 04:01:56 +0200
Message-ID: <200712120401.57128.maximlevitsky@gmail.com>
References: <fa4052ef0712062045o743a2666u3562a3569c1aa989@mail.gmail.com> <200712101705.30428.maximlevitsky@gmail.com> <20071210130305.d8983fdc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: bfields@fieldses.org, neilb@suse.de, rjw@sisk.pl,
	trond.myklebust@fys.uio.no, gnome42@gmail.com,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	den@openvz.org, linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.187]:60871 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000AbXLLCCd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 21:02:33 -0500
Received: by mu-out-0910.google.com with SMTP id i10so75145mue.5
        for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2007 18:02:31 -0800 (PST)
In-Reply-To: <20071210130305.d8983fdc.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 10 December 2007 23:03:05 Andrew Morton wrote:
> On Mon, 10 Dec 2007 17:05:30 +0200
> Maxim Levitsky <maximlevitsky@gmail.com> wrote:
> 
> > On Monday 10 December 2007 16:36:09 J. Bruce Fields wrote:
> > > On Mon, Dec 10, 2007 at 04:19:12PM +0200, Maxim Levitsky wrote:
> > > > ...
> > > > > It is best not to use nohide - we should probably mark it as
> > > > > 'legacy'.
> > > > > 
> > > > > Simply export the top level mountpoint as 'crossmnt'  and everything
> > > > > below there will be exported.
> > > > > 
> > > > > > Where should I put those options in root file-system export or in submount export?
> > > > > 
> > > > > crossmnt goes at the top.  nohide goes in the submount.  Both have
> > > > > the same general effect though with subtle differences.
> > > > > You don't need both (though that doesn't hurt).
> > > > > Just use crossmnt at the top,  Then you don't need to mention the
> > > > > lower level filesystems at all.
> > > > > 
> > > > > > 
> > > > ...
> > > > > > (I decided to switch to NFS4 only due to the lack of ability to see underlying mounts)
> > > > > > 
> > > > > 
> > > > > All of this should work fine with v3.  Once you have the right patch
> > > > > for the crossmnt bug applied, if you have further problems post them
> > > > > to linux-nfs-u79uwXL29TaiAVqoAR/hOA@public.gmane.org
> > > > > 
> > > > > NeilBrown
> > > > > 
> > > > 
> > > > Big thanks,
> > > > 
> > > > Still NFS server just don't want to accept the connection
> > > > I noticed that if I first mount with
> > > > -tnfs, unmount,  and then mount with -tnfs4, it works
> > > 
> > > OK, in that case, that's definitely the bug Eric sent out the patch for;
> > > you may want to try applying his patch.
> > You mean
> > "[PATCH 2.6.24-rc4] proc: Remove/Fix proc generic d_revalidate" ?
> > 
> > I did apply it (on both kernel and server), and it doesn't help.
> 
> argh, this is getting bad.
> 
> Can you please test the below patch asap? Against 2.6.24-rc4 or latest-linus.
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Revert
> 
>     commit 2b1e300a9dfc3196ccddf6f1d74b91b7af55e416
>     Author: Eric W. Biederman <ebiederm@xmission.com>
>     Date:   Sun Dec 2 00:33:17 2007 +1100
> 

Hi,

I finally solved this.
There is no need to revert 2b1e300a9dfc3196ccddf6f1d74b91b7af55e416.

It was actually a deadly mixture of 3 bugs:

1) Stale handles - Trond's patch fixes it, but I somehow missed it.
2) Empty /proc/fs/nfsd (which causes nfs4 failures, and masks the bug #1, since with it the subfolders are just empty)
	[PATCH 2.6.24-rc4] proc: Remove/Fix proc generic d_revalidate fixes it

3) And as I expected, a userspace bug, which believe me or not has exactly the same symptoms
like #2 (and doesn't depend on others)

It is a wrong boot script in BLFS that starts nfs daemons in wrong order.
So there are 3 bugs and each masks the former one :-) .

I revised boot script to use recommended order like in nfs-utils.
And finally everything works....

Best regards,
	Maxim Levitsky
