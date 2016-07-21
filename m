Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49018 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753639AbcGURYx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2016 13:24:53 -0400
Date: Thu, 21 Jul 2016 13:24:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/8] mountd: remove 'dev_missing' checks
Message-ID: <20160721172452.GC27148@fieldses.org>
References: <20160714021310.5874.22953.stgit@noble>
 <20160714022643.5874.84409.stgit@noble>
 <20160718200121.GC12304@fieldses.org>
 <878twx9ra3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <878twx9ra3.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 20, 2016 at 08:50:12AM +1000, NeilBrown wrote:
> On Tue, Jul 19 2016, J. Bruce Fields wrote:
> 
> > On Thu, Jul 14, 2016 at 12:26:43PM +1000, NeilBrown wrote:
> >> I now think this was a mistaken idea.
> >> 
> >> If a filesystem is exported with the "mountpoint" or "mp" option, it
> >> should only be exported if the directory is a mount point.  The
> >> intention is that if there is a problem with one filesystem on a
> >> server, the others can still be exported, but clients won't
> >> incorrectly see the empty directory on the parent when accessing the
> >> missing filesystem, they will see clearly that the filesystem is
> >> missing.
> >> 
> >> It is easy to handle this correctly for NFSv3 MOUNT requests, but what
> >> is the correct behavior if a client already has the filesystem mounted
> >> and so has a filehandle?  Maybe the server rebooted and came back with
> >> one device missing.  What should the client see?
> >> 
> >> The "dev_missing" code tries to detect this case and causes the server
> >> to respond with silence rather than ESTALE.  The idea was that the
> >> client would retry and when (or if) the filesystem came back, service
> >> would be transparently restored.
> >> 
> >> The problem with this is that arbitrarily long delays are not what
> >> people would expect, and can be quite annoying.  ESTALE, while
> >> unpleasant, it at least easily understood.  A device disappearing is a
> >> fairly significant event and hiding it doesn't really serve anyone.
> >
> > It could also be a filesystem disappearing because it failed to mount in
> > time on a reboot.
> 
> I don't think "in time" is really an issue.  Boot sequencing should not
> start nfsd until everything in /etc/fstab is mounted, has failed and the
> failure has been deemed acceptable.
> That is why nfs-server.services has "After= local-fs.target"

Yeah, I agree, that's the right way to do it.  I believe the old
behavior would be forgiving of misconfiguration here, though, which
means there's a chance somebody would witness a failure on upgrade.
Maybe the chance is small.

--b.
