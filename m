Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33194 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755580AbcHSVNP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 17:13:15 -0400
Date: Fri, 19 Aug 2016 17:02:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
Subject: Re: [PATCH 1/2] systemd: improve ordering between nfs-server and
 various mounts
Message-ID: <20160819210223.GQ32329@fieldses.org>
References: <147157095612.26568.14161646901346011334.stgit@noble>
 <147157115637.26568.2867884353016441810.stgit@noble>
 <20160819173830.GK32329@fieldses.org>
 <87r39kh4li.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87r39kh4li.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 20, 2016 at 06:43:37AM +1000, NeilBrown wrote:
> On Sat, Aug 20 2016, J. Bruce Fields wrote:
> 
> > On Fri, Aug 19, 2016 at 11:45:56AM +1000, NeilBrown wrote:
> >> Commit: 1e41488f428c ("systemd: Order NFS server before client")
> >> 
> >> added an ordering dependency between network mounts and nfs-server.
> >> This is good for loop-back NFS mounts as it ensures the server
> >> will remain until after the mountpoint is unmounted.
> >> 
> >> However is is bad for _net mounts (such as those via iSCSI) which
> >> are being NFS exported.
> >> 
> >> nfs-server needs to be start *after* exported filesystems are mounted,
> >> and *before* NFS filesystems are mounted.  systemd isn't able to make
> >> this distinction natively, so we need to help it.
> >> 
> >> This patch adds a systemd generator which creates a drop-in for
> >> nfs-server.services so that it is started "After" any "nfs" or "nfs4"
> >
> > s/After/Before/ ?
> 
> Yes.  I suspect this was caused by the fact that my goal was for
> nfs-server to stop After nfs mounts.  The concepts start to blur.
> It is a bit like doing a git-bisect to find out where some bug was
> fixed.  good==bad, bad==good
> 
> >
> > The code's right:
> 
> I remember fixing the code....
> 
> Steve: if there are no other revisions, would you still like me to
> resend to fix this, or will you just correct it when you eventually
> commit it?

(ACK to the patch from me, that one changelog nit aside.)

--b.

> 
> Thanks,
> NeilBrown
> 
> 
> >
> >> +	fstab = setmntent("/etc/fstab", "r");
> >> +	while ((mnt = getmntent(fstab)) != NULL) {
> >> +		if (strcmp(mnt->mnt_type, "nfs") != 0 &&
> >> +		    strcmp(mnt->mnt_type, "nfs4") != 0)
> >> +			continue;
> >> +		fprintf(f, "Before= ");
> >> +		systemd_escape(f, mnt->mnt_dir);
> >> +		fprintf(f, ".mount\n");
> >
> > --b.


