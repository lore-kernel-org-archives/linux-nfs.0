Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32969 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbcD0Tnv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2016 15:43:51 -0400
Date: Wed, 27 Apr 2016 21:43:47 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Linux MM <linux-mm@kvack.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Dave Chinner <david@fromorbit.com>, "Theodore Ts'o" <tytso@mit.edu>,
        Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>,
        ceph-devel@vger.kernel.org, cluster-devel <cluster-devel@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>, logfs@logfs.org,
        XFS Developers <xfs@oss.sgi.com>, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org,
        reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net,
        linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1.1/2] xfs: abstract PF_FSTRANS to PF_MEMALLOC_NOFS
Message-ID: <20160427194347.GA22544@dhcp22.suse.cz>
References: <1461671772-1269-2-git-send-email-mhocko@kernel.org>
 <1461758075-21815-1-git-send-email-mhocko@kernel.org>
 <04798BA8-2157-4611-B4EA-B8BCBA88AEC3@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <04798BA8-2157-4611-B4EA-B8BCBA88AEC3@dilger.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed 27-04-16 11:41:51, Andreas Dilger wrote:
> On Apr 27, 2016, at 5:54 AM, Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > --- a/fs/xfs/kmem.c
> > +++ b/fs/xfs/kmem.c
> > @@ -80,13 +80,13 @@ kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
> > 	 * context via PF_MEMALLOC_NOIO to prevent memory reclaim re-entering
> > 	 * the filesystem here and potentially deadlocking.
> > 	 */
> > -	if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
> > +	if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
> > 		noio_flag = memalloc_noio_save();
> > 
> > 	lflags = kmem_flags_convert(flags);
> > 	ptr = __vmalloc(size, lflags | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
> > 
> > -	if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
> > +	if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
> > 		memalloc_noio_restore(noio_flag);
> 
> Not really the fault of this patch, but it brings this nasty bit of code into
> the light.  Is all of this machinery still needed given that __vmalloc() can
> accept GFP flags?  If yes, wouldn't it be better to fix __vmalloc() to honor
> the GFP flags instead of working around it in the filesystem code?

This is not that easy. __vmalloc can accept gfp flags but it doesn't
honor __GFP_IO 100%. IIRC some paths like page table allocations are
hardcoded GFP_KERNEL. Besides that I would like to have GFP_NOIO used
via memalloc_noio_{save,restore} API as well for the similar reasons as
GFP_NOFS - it is just easier to explain scope than particular code paths
which might be shared.
-- 
Michal Hocko
SUSE Labs
