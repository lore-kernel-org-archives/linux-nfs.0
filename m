Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39198 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753875Ab2KWRXi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Nov 2012 12:23:38 -0500
Date: Fri, 23 Nov 2012 12:23:33 -0500
To: "dE ." <de.techno@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Slow NFS loop performance.
Message-ID: <20121123172333.GB8776@fieldses.org>
References: <50AF57A3.3090000@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50AF57A3.3090000@gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 23, 2012 at 04:31:55PM +0530, dE . wrote:
> Humm... The last thing I expected was no response even in the mailing list.
> 
> So I'm filing a bug on this.
> 
> On Oct 23, 2012 2:19 PM, "dE ." <de.techno@gmail.com> wrote:
> > Hi!
> >
> > Great job with NFS server, it surely is fast, but not on loop devices.
> >
> > If I loop mount a file and share the mount point over NFS3 or NFS4, the
> > write performance of the client on the loop mounted share is pretty bad.
> >
> > On a 100 Mbps (or 12.5MBps) full duplex Ethernet link, I get ~8MBps
> > speeds, whereas on the loop mounted device, I get at best 6MBps.

What exactly is your test?

--b.

> >
> > Any ideas why?
> >
> > My server configuration (NFS4) --
> > anonuid=1000,anongid=1000,**secure,no_subtree_check,rw,**fsid=0,crossmnt
> >
> > My client mount options --
> > rsize=1048576,wsize=1048576,**async,hard,timeo=60,retrans=2,**
> > actimeo=900,retry=2,**lookupcache=pos,nfsvers=4,**
> > nolock,intr,noacl,rdirplus
> >
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
