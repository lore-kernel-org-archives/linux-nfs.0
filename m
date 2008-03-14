From: Neil Brown <neilb@suse.de>
Subject: Re: [opensuse] nfs_update_inode: inode X mode changed, Y to Z
Date: Fri, 14 Mar 2008 15:58:05 +1100
Message-ID: <18394.1501.991087.80264@notabene.brown>
References: <47CF0829.4020502@m2000.com>
	<1204752463.5035.34.camel@heimdal.trondhjem.org>
	<47CF157B.1010908@m2000.com>
	<18383.24847.381754.517731@notabene.brown>
	<47CF62C5.7000908@m2000.com>
	<18384.50909.866848.966192@notabene.brown>
	<9a8748490803121513w285cd45rb6b26a3d842cac1b@mail.gmail.com>
	<20080312221511.GC31632@fieldses.org>
	<9a8748490803121516u36395872i70cc88b0439adc74@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Adam Schrotenboer" <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	"Trond Myklebust" <Trond.Myklebust@netapp.com>,
	lkml@vger.kernel.org, linux-nfs@vger.kernel.org,
	"Thomas Daniel" <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
To: "Jesper Juhl" <jesper.juhl@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:46730 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779AbYCNE6S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Mar 2008 00:58:18 -0400
In-Reply-To: message from Jesper Juhl on Wednesday March 12
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday March 12, jesper.juhl@gmail.com wrote:
> On 12/03/2008, J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > What was the exported filesystem?
> >
> XFS
> 

It's a bit of along shot, but could you try mounting the XFS file
system with
   -o ikeep

and see if it makes a difference.

When you have "ikeep", I can find the code that increments the
generation number between different uses of the one inode number.

When you have "noikeep" (which I think is the default) it doesn't keep
the inode of disk when deleted and so (presumably) needs generate a
random generation number for each use.  But I cannot find the code
that does that.  I'm probably not looking in the right place, but I
don't think it can hurt to try "-o ikeep".

NeilBrown
