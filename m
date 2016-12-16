Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34325 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756550AbcLPWAc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Dec 2016 17:00:32 -0500
Date: Fri, 16 Dec 2016 23:00:28 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Dave Chinner <david@fromorbit.com>, "Theodore Ts'o" <tytso@mit.edu>,
        Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>,
        Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org,
        linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org,
        reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net,
        linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH 5/9 v2] xfs: use memalloc_nofs_{save,restore} instead of
 memalloc_noio*
Message-ID: <20161216220028.GB7645@dhcp22.suse.cz>
References: <20161215140715.12732-1-mhocko@kernel.org>
 <20161215140715.12732-6-mhocko@kernel.org>
 <20161216163811.GG8447@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161216163811.GG8447@bfoster.bfoster>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri 16-12-16 11:38:11, Brian Foster wrote:
> On Thu, Dec 15, 2016 at 03:07:11PM +0100, Michal Hocko wrote:
[...]
> > @@ -459,7 +459,7 @@ _xfs_buf_map_pages(
> >  				break;
> >  			vm_unmap_aliases();
> >  		} while (retried++ <= 1);
> > -		memalloc_noio_restore(noio_flag);
> > +		memalloc_noio_restore(nofs_flag);
> 
> memalloc_nofs_restore() ?

Ups, you are right of course. Fixed.
---
