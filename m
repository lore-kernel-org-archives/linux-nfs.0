From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: 2.6.24-rc3-git4 NFS crossmnt regression
Date: Mon, 10 Dec 2007 16:19:12 +0200
Message-ID: <200712101619.12522.maximlevitsky@gmail.com>
References: <fa4052ef0712062045o743a2666u3562a3569c1aa989@mail.gmail.com> <200712090220.44543.maximlevitsky@gmail.com> <18268.51342.353887.178014@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	gnome42@gmail.com, linux-kernel@vger.kernel.org,
	bfields@fieldses.org, "Eric W. Biederman" <ebiederm@xmission.com>,
	"Denis V. Lunev" <den@openvz.org>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:53432 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756AbXLJOTk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 09:19:40 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1528581ugc
        for <linux-nfs@vger.kernel.org>; Mon, 10 Dec 2007 06:19:38 -0800 (PST)
In-Reply-To: <18268.51342.353887.178014-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...
> It is best not to use nohide - we should probably mark it as
> 'legacy'.
> 
> Simply export the top level mountpoint as 'crossmnt'  and everything
> below there will be exported.
> 
> > Where should I put those options in root file-system export or in submount export?
> 
> crossmnt goes at the top.  nohide goes in the submount.  Both have
> the same general effect though with subtle differences.
> You don't need both (though that doesn't hurt).
> Just use crossmnt at the top,  Then you don't need to mention the
> lower level filesystems at all.
> 
> > 
...
> > (I decided to switch to NFS4 only due to the lack of ability to see underlying mounts)
> > 
> 
> All of this should work fine with v3.  Once you have the right patch
> for the crossmnt bug applied, if you have further problems post them
> to linux-nfs-u79uwXL29TaiAVqoAR/hOA@public.gmane.org
> 
> NeilBrown
> 

Big thanks,

Still NFS server just don't want to accept the connection
I noticed that if I first mount with
-tnfs, unmount,  and then mount with -tnfs4, it works


Assuming that 
[PATCH 2.6.24-rc4] proc: Remove/Fix proc generic d_revalidate 
is the fix for crossmnt bug, I applied it to both client and server,
but no luck.

Still see empty folders.

my /etc/exports file (on old box):

/ *(insecure,rw,fsid=0,crossmnt,async,anonuid=1000,anongid=100)
/dev *(insecure,rw,fsid=1,async,anonuid=1000,anongid=100)
/mnt/disk2 *(insecure,rw,async,anonuid=1000,anongid=100)
	

It is totally insecure, but I have just home network,
and it is behind firewall, and besides I am testing this now.

I am afraid that I am doing something wrong since
I don't know nfs well yet, and especially nfs4
(But I want to make nfs4 work too)

Best regards,
	Maxim Levitsky
