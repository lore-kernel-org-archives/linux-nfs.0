From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: 2.6.24-rc3-git4 NFS crossmnt regression
Date: Mon, 10 Dec 2007 20:22:00 +0200
Message-ID: <200712102022.00803.maximlevitsky@gmail.com>
References: <fa4052ef0712062045o743a2666u3562a3569c1aa989@mail.gmail.com> <200712101705.30428.maximlevitsky@gmail.com> <20071210154747.GB17209@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Neil Brown <neilb@suse.de>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	gnome42@gmail.com, linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Denis V. Lunev" <den@openvz.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:56574 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519AbXLJSWa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 13:22:30 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1602978ugc
        for <linux-nfs@vger.kernel.org>; Mon, 10 Dec 2007 10:22:28 -0800 (PST)
In-Reply-To: <20071210154747.GB17209@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 10 December 2007 17:47:47 J. Bruce Fields wrote:
> On Mon, Dec 10, 2007 at 05:05:30PM +0200, Maxim Levitsky wrote:
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
> > Best regards,
> > 	Maxim Levitsky
> > 
> > PS: I am unfamiliar with nfs/nfs4, so this could be just a 
> > configuration/compilation issue.
> 
> What do
> 	ls /proc/fs/nfs
> 	ls /proc/fs/nfsd
> 
> report?
> 
> --b.
> 

On both client and server:

maxim [~]$ ls /proc/fs/nfs
exports
maxim [~]$ ls /proc/fs/nfsd
exports     max_block_size  nfsv4recoverydir  portlist  versions
filehandle  nfsv4leasetime  pool_threads      threads
maxim [~]$


Best regards,
	Maxim Levitsky

