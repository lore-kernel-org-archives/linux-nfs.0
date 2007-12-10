From: Shane <gnome42@gmail.com>
Subject: Re: 2.6.24-rc3-git4 NFS crossmnt regression
Date: Mon, 10 Dec 2007 14:51:46 -0500
Message-ID: <fa4052ef0712101151ka962076q24d1bd624f2373f5@mail.gmail.com>
References: <fa4052ef0712062045o743a2666u3562a3569c1aa989@mail.gmail.com>
	 <200712090220.44543.maximlevitsky@gmail.com>
	 <18268.51342.353887.178014@notabene.brown>
	 <200712101619.12522.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Neil Brown" <neilb@suse.de>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	linux-kernel@vger.kernel.org, bfields@fieldses.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Denis V. Lunev" <den@openvz.org>, linux-nfs@vger.kernel.org
To: "Maxim Levitsky" <maximlevitsky@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:25146 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbXLJTvs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 14:51:48 -0500
Received: by wa-out-1112.google.com with SMTP id v27so3532153wah
        for <linux-nfs@vger.kernel.org>; Mon, 10 Dec 2007 11:51:47 -0800 (PST)
In-Reply-To: <200712101619.12522.maximlevitsky@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 10, 2007 9:19 AM, Maxim Levitsky <maximlevitsky@gmail.com> wrote:
> ...
> > It is best not to use nohide - we should probably mark it as
> > 'legacy'.
> >
> > Simply export the top level mountpoint as 'crossmnt'  and everything
> > below there will be exported.
> >
> > > Where should I put those options in root file-system export or in submount export?
> >
> > crossmnt goes at the top.  nohide goes in the submount.  Both have
> > the same general effect though with subtle differences.
> > You don't need both (though that doesn't hurt).
> > Just use crossmnt at the top,  Then you don't need to mention the
> > lower level filesystems at all.
> >
> > >
> ...
> > > (I decided to switch to NFS4 only due to the lack of ability to see underlying mounts)
> > >
> >
> > All of this should work fine with v3.  Once you have the right patch
> > for the crossmnt bug applied, if you have further problems post them
> > to linux-nfs-u79uwXL29TaiAVqoAR/hOA@public.gmane.org
> >
> > NeilBrown
> >
>
> Big thanks,
>
> Still NFS server just don't want to accept the connection
> I noticed that if I first mount with
> -tnfs, unmount,  and then mount with -tnfs4, it works
>
>
> Assuming that
> [PATCH 2.6.24-rc4] proc: Remove/Fix proc generic d_revalidate
> is the fix for crossmnt bug, I applied it to both client and server,
> but no luck.

I'm using NFSv3, but I applied two patches. The one you mention
from Eric and the patch Trond posted in this thread.

>
> Still see empty folders.

That was the symptom I had without Trond's patch.

Shane
