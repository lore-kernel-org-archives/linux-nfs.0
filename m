From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: nfs-utils 1.1.2 + knfsd 2.6.27 (.5) breaks fsid= option
Date: Sun, 16 Nov 2008 21:29:35 +0100
Message-ID: <20081116202935.GA13533@janus>
References: <20081112104811.GA15011@janus> <491ADEBF.80900@RedHat.com> <20081116200211.GK21551@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:33980 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752084AbYKPU3h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Nov 2008 15:29:37 -0500
In-Reply-To: <20081116200211.GK21551@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 16, 2008 at 03:02:11PM -0500, J. Bruce Fields wrote:
> On Wed, Nov 12, 2008 at 08:48:47AM -0500, Steve Dickson wrote:
> > Frank van Maarseveen wrote:
> > > Tested on Debian lenny with nfs-kernel-server 1:1.1.2-6lenny1 and a
> > > 2.6.27.5 kernel. /etc/exports says:
> > > 
> > > 	/mp @general(rw,sync,no_root_squash,no_subtree_check,mp,fsid=2886795869)
> > > 
> > > After actually using it /proc/fs/nfsd/exports says:
> > > 
> > > 	/mp @general(rw,no_root_squash,sync,wdelay,no_subtree_check,fsid=-1408171427,uuid=db4387a6:bed949d0:8f5ef6a2:6a0c
> > > 
> > > (yes, 2886795869 == (ulong)-1408171427)
> > > However, file handles over the wire now seem to have fsid_type=6
> > > (FSID_UUID16) instead of 1 (FSID_NUM) due to this.
> > 
> > This is a known problem... The kernel checks UUIDs before FSIDS which cause
> > FSIDS to be ignored. There are two outstanding proposals to fix this problem.
> >    1) Move two lines in the kernel so FSIDs are checked before UUIDS
> >    2) Change mountd to only send down  the FSID or the UUID but
> >       not both as it does today.
> >  
> > Neither proposal has been accepted... yet...
> 
> I'd have a mild preference for the 2nd, but I'd first like to understand
> why the new behavior is a problem for Frank.

I'm using a patch originally developed by Wendy Cheng for a per-fsid
grace period. It could be triggered by:

	echo fsid >/proc/fs/nfsd/nlm_grace_fsid

where the mentioned fsid is the same as in /etc/exports. I'm not
particularly fond of using fsids for this and AFAIK a similar patch for
per-mountpoint grace period is underway. Correct?

-- 
Frank
