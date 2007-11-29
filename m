From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] nfs-utils crossmnt/fsid bug
Date: Thu, 29 Nov 2007 14:59:21 +1100
Message-ID: <18254.14617.710446.759398@notabene.brown>
References: <20070905204628.GD29582@fieldses.org>
	<18246.16373.177320.570040@notabene.brown>
	<20071126223954.GX5960@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxaYh-0004Wn-E3
	for nfs@lists.sourceforge.net; Wed, 28 Nov 2007 19:59:27 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IxaYm-0001S8-BO
	for nfs@lists.sourceforge.net; Wed, 28 Nov 2007 19:59:33 -0800
In-Reply-To: message from J. Bruce Fields on Monday November 26
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Monday November 26, bfields@fieldses.org wrote:
> > When exported a filesystems with option inherited (by the crossmnt
> > option) from a higherlevel filesystem, ignore filesystem specific
> > options like FSID and explicit UUID.
> 
> Looks right to me.  I'm confused about uuid's--how does the non-explicit
> UUID case work?

Thanks, though on reflection I don't think we need to do the
'stat's. Just checking the path names should be sufficient, but I will
double check.

non-explicit UUIDs are derived using libblkid, typically a UUID out of
the filesystem that is being exported.
The only problem is that it appears that libblkid isn't as efficient
as one might like and if you have hundreds of mounts, mountd can slow
down.  I still need to look into that.

NeilBrown

-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

