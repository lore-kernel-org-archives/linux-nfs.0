Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36454 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbcD0NHQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2016 09:07:16 -0400
Date: Wed, 27 Apr 2016 15:07:12 +0200
From: Michal Hocko <mhocko@kernel.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Dave Chinner <david@fromorbit.com>, "Theodore Ts'o" <tytso@mit.edu>,
        Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>,
        ceph-devel@vger.kernel.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, logfs@logfs.org, xfs@oss.sgi.com,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org,
        linux-ntfs-dev@lists.sourceforge.net,
        linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1.2/2] mm: introduce memalloc_nofs_{save,restore} API
Message-ID: <20160427130712.GK2179@dhcp22.suse.cz>
References: <1461671772-1269-2-git-send-email-mhocko@kernel.org>
 <1461758075-21815-1-git-send-email-mhocko@kernel.org>
 <1461758075-21815-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1461758075-21815-2-git-send-email-mhocko@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed 27-04-16 13:54:35, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 

Ups missed Dave's note about:

> GFP_NOFS context is used for the following 4 reasons currently
> 	- to prevent from deadlocks when the lock held by the allocation
> 	  context would be needed during the memory reclaim
> 	- to prevent from stack overflows during the reclaim because
> 	  the allocation is performed from a deep context already
> 	- to prevent lockups when the allocation context depends on
> 	  other reclaimers to make a forward progress indirectly
> 	- just in case because this would be safe from the fs POV

	- silence lockdep false positives
-- 
Michal Hocko
SUSE Labs
