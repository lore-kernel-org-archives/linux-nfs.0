Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46442 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751725AbbH1R6f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Aug 2015 13:58:35 -0400
Date: Fri, 28 Aug 2015 13:58:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, hch@lst.de, kinglongmee@gmail.com
Subject: Re: [PATCH v3 14/20] nfsd: close cached files prior to a REMOVE or
 RENAME that would replace target
Message-ID: <20150828175834.GB10468@fieldses.org>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
 <1440069440-27454-15-git-send-email-jeff.layton@primarydata.com>
 <20150826200032.GD4161@fieldses.org>
 <20150826185331.74977119@synchrony.poochiereds.net>
 <20150827133806.GA10468@fieldses.org>
 <20150828081947.37d4f018@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150828081947.37d4f018@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 28, 2015 at 08:19:46AM -0400, Jeff Layton wrote:
> On Thu, 27 Aug 2015 09:38:06 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Aug 26, 2015 at 06:53:31PM -0400, Jeff Layton wrote:
> > > On Wed, 26 Aug 2015 16:00:32 -0400
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > 
> > > > On Thu, Aug 20, 2015 at 07:17:14AM -0400, Jeff Layton wrote:
> > > > > It's not uncommon for some workloads to do a bunch of I/O to a file and
> > > > > delete it just afterward. If knfsd has a cached open file however, then
> > > > > the file may still be open when the dentry is unlinked. If the
> > > > > underlying filesystem is nfs, then that could trigger it to do a
> > > > > sillyrename.
> > > > 
> > > > Possibly worth noting that situation doesn't currently occur upstream.
> > > > 
> > > > (And, another justification worth noting: space used by a file should be
> > > > deallocated on last unlink or close.  People do sometimes notice if it's
> > > > not, especially if the file is large.)
> > > > 
> > > 
> > > Good points.
> > > 
> > > > > On a REMOVE or RENAME scan the nfsd_file cache for open files that
> > > > > correspond to the inode, and proactively unhash and put their
> > > > > references. This should prevent any delete-on-last-close activity from
> > > > > occurring, solely due to knfsd's open file cache.
> > > > 
> > > > Is there anything here to prevent a new cache entry being added after
> > > > nfsd_file_close_inode and before the file is actually removed?
> > > > 
> > > 
> > > No, nothing -- it's strictly best effort.
> > 
> > Unfortunately I think this is something we really want to guarantee.
> > 
> 
> That should be doable.
> 
> One question though -- if we hit this race, what's the right way to
> handle it?
> 
> We don't want to return nfserr_stale or anything since we won't know if
> the inode will really be stale after the remove completes. We could
> just be removing one link from a multiply-linked inode.
> 
> We also don't want to make the caller wait out nfsd_file_acquire, as the
> file could be open via NFSv4 and those references might not get put for
> quite some time.
> 
> What semantics should we be aiming for?

Hm.

The RENAME or REMOVE has to succeed regardless.

If the other operation is an open or something lookup-like, then it has
to succeed or see ENOENT.  If it's a filehandle-based operation like
READ or WRITE then it's got to succeed or get STALE, and if the latter
then it better be really and truly gone.  Continuing to process a READ
or WRITE after the REMOVE continues is fine, I think, it just means some
application on some other v3 client has an open that we're honoring a
moment longer than we're required to.

Now I'd have to look back at your code....  If the caching were just an
optimization, we could just it off temporarily, but I don't think we
can.

Marking the file dead somehow and failing further attempts to use it
might work.  I guess that's equivalent to your suggestion to unhash it
in this case.

--b.
