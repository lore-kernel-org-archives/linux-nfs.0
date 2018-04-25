Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56835 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754552AbeDYQ5C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 25 Apr 2018 12:57:02 -0400
Date: Wed, 25 Apr 2018 10:56:55 -0600
From: Michal Hocko <mhocko@kernel.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Richard Weinberger <richard@nod.at>,
        LKML <linux-kernel@vger.kernel.org>,
        Artem Bityutskiy <dedekind1@gmail.com>,
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
        linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: vmalloc with GFP_NOFS
Message-ID: <20180425165655.GK17484@dhcp22.suse.cz>
References: <20180424162712.GL17484@dhcp22.suse.cz>
 <3732370.1623zxSvNg@blindfold>
 <20180424192803.GT17484@dhcp22.suse.cz>
 <3894056.cxOY6eVYVp@blindfold>
 <20180424230943.GY17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804241911040.19786@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424232517.GC17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804250841230.16455@file01.intranet.prod.int.rdu2.redhat.com>
 <20180425144557.GD17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804251114120.11848@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.LRH.2.02.1804251114120.11848@file01.intranet.prod.int.rdu2.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed 25-04-18 11:25:09, Mikulas Patocka wrote:
> 
> 
> On Wed, 25 Apr 2018, Michal Hocko wrote:
> 
> > On Wed 25-04-18 08:43:32, Mikulas Patocka wrote:
> > > 
> > > 
> > > On Tue, 24 Apr 2018, Michal Hocko wrote:
> > > 
> > > > On Tue 24-04-18 19:17:12, Mikulas Patocka wrote:
> > > > > 
> > > > > 
> > > > > On Tue, 24 Apr 2018, Michal Hocko wrote:
> > > > > 
> > > > > > > So in a perfect world a filesystem calls memalloc_nofs_save/restore and
> > > > > > > always uses GFP_KERNEL for kmalloc/vmalloc?
> > > > > > 
> > > > > > Exactly! And in a dream world those memalloc_nofs_save act as a
> > > > > > documentation of the reclaim recursion documentation ;)
> > > > > > -- 
> > > > > > Michal Hocko
> > > > > > SUSE Labs
> > > > > 
> > > > > BTW. should memalloc_nofs_save and memalloc_noio_save be merged into just 
> > > > > one that prevents both I/O and FS recursion?
> > > > 
> > > > Why should FS usage stop IO altogether?
> > > 
> > > Because the IO may reach loop and loop may redirect it to the same 
> > > filesystem that is running under memalloc_nofs_save and deadlock.
> > 
> > So what is the difference with the current GFP_NOFS?
> 
> My point is that filesystems should use GFP_NOIO too. If 
> alloc_pages(GFP_NOFS) issues some random I/O to some block device, the I/O 
> may be end up being redirected (via block loop device) to the filesystem 
> that is calling alloc_pages(GFP_NOFS).

Talk to FS people, but I believe there is a good reason to distinguish
the two.

-- 
Michal Hocko
SUSE Labs
