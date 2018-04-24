Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40939 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751760AbeDXQ1U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Apr 2018 12:27:20 -0400
Date: Tue, 24 Apr 2018 10:27:12 -0600
From: Michal Hocko <mhocko@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Artem Bityutskiy <dedekind1@gmail.com>,
        Richard Weinberger <richard@nod.at>,
        David Woodhouse <dwmw2@infradead.org>,
        Brian Norris <computersforpeace@gmail.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        Marek Vasut <marek.vasut@gmail.com>,
        Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>,
        Theodore Ts'o <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Bob Peterson <rpeterso@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Adrian Hunter <adrian.hunter@intel.com>,
        Philippe Ombredanne <pombredanne@nexb.com>,
        Kate Stewart <kstewart@linuxfoundation.org>,
        Mikulas Patocka <mpatocka@redhat.com>,
        linux-mtd@lists.infradead.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, linux-mm@kvack.org
Subject: vmalloc with GFP_NOFS
Message-ID: <20180424162712.GL17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
it seems that we still have few vmalloc users who perform GFP_NOFS
allocation:
drivers/mtd/ubi/io.c
fs/ext4/xattr.c
fs/gfs2/dir.c
fs/gfs2/quota.c
fs/nfs/blocklayout/extent_tree.c
fs/ubifs/debug.c
fs/ubifs/lprops.c
fs/ubifs/lpt_commit.c
fs/ubifs/orphan.c

Unfortunatelly vmalloc doesn't suppoer GFP_NOFS semantinc properly
because we do have hardocded GFP_KERNEL allocations deep inside the
vmalloc layers. That means that if GFP_NOFS really protects from
recursion into the fs deadlocks then the vmalloc call is broken.

What to do about this? Well, there are two things. Firstly, it would be
really great to double check whether the GFP_NOFS is really needed. I
cannot judge that because I am not familiar with the code. It would be
great if the respective maintainers (hopefully get_maintainer.sh pointed
me to all relevant ones). If there is not reclaim recursion issue then
simply use the standard vmalloc (aka GFP_KERNEL request).

If the use is really valid then we have a way to do the vmalloc
allocation properly. We have memalloc_nofs_{save,restore} scope api. How
does that work? You simply call memalloc_nofs_save when the reclaim
recursion critical section starts (e.g. when you take a lock which is
then used in the reclaim path - e.g. shrinker) and memalloc_nofs_restore
when the critical section ends. _All_ allocations within that scope
will get GFP_NOFS semantic automagically. If you are not sure about the
scope itself then the easiest workaround is to wrap the vmalloc itself
with a big fat comment that this should be revisited.

Does that sound like something that can be done in a reasonable time?
I have tried to bring this up in the past but our speed is glacial and
there are attempts to do hacks like checking for abusers inside the
vmalloc which is just too ugly to live.

Please do not hesitate to get back to me if something is not clear.

Thanks!
-- 
Michal Hocko
SUSE Labs
