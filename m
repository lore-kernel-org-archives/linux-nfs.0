Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44945 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932070AbaBUPAA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Feb 2014 10:00:00 -0500
Date: Fri, 21 Feb 2014 09:59:56 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <SteveD@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        NFS <linux-nfs@vger.kernel.org>, Carsten Ziepke <kieltux@gmail.com>
Subject: Re: [PATCH - nfs-utils] Fix fallback from tcp to udp
Message-ID: <20140221145956.GE13433@fieldses.org>
References: <20140218104307.34205fc8@notabene.brown>
 <53064057.70703@RedHat.com>
 <20140220203701.GA13433@fieldses.org>
 <20140221142641.20e72abe@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140221142641.20e72abe@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 21, 2014 at 02:26:41PM +1100, NeilBrown wrote:
> On Thu, 20 Feb 2014 15:37:02 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> > Any NFS server has to support either tcp or rpcbind.  But it's OK for a
> > server to support only of those two.  So the only way to handle both
> > cases while continuing to retry after ECONNREFUSED is to alternate
> > between trying nfs4/tcp and rpcbind until you can connect to one or the
> > other.
> > 
> > If it's the rpcbind call that succeeds first then I think we want to do
> > one more try of nfs4/tcp just to make sure it didn't just come up,
> > before falling back to v3.
> > 
> > The rpcbind call is done in userspace, if I understand right, so I think
> > this is doable.  Looking at utils/mount/ I don't understand the mount
> > process well enough to understand exactly how to do it.  Maybe
> > everything but the final nfs_sys_mount needs to be moved out of
> > nfs_do_mount_v3v2 into a new nfs_do_probe_v3v2 and nfs_autonegotiate
> > should alternate between nfs_try_mount_v4 and nfs_do_probe_v3v2 as long
> > as both return ECONNREFUSED, calling nfs_try_mount_v3v2 only if
> > nfs_try_mount_v4 has failed after a succesful nfs_do_probe_v3v2?
> > 
> > Except the v3v2 mount logic seems to actually modify the mount_options,
> > so probably that doesn't quite work.
> 
> I had come to much the same conclusion after reading Steve's mail:  when TCP
> fails we need rpcbind to be sure what to do.
> I suspect it should be fairly straight forward to implement (I'm less
> pessimistic than you).  I'll have a go on Monday.

OK, great!

Yeah, the mount code looked like a maze for me but I probably spent less
than an hour trying to trace through it, I'm sure it's not that bad.

--b.
