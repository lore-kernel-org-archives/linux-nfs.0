Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:39948 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750791AbeDXXRR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Apr 2018 19:17:17 -0400
Date: Tue, 24 Apr 2018 19:17:12 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
cc: Richard Weinberger <richard@nod.at>,
        LKML <linux-kernel@vger.kernel.org>,
        Artem Bityutskiy <dedekind1@gmail.com>,
        David Woodhouse <dwmw2@infradead.org>,
        Brian Norris <computersforpeace@gmail.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        Marek Vasut <marek.vasut@gmail.com>,
        Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>,
        "Theodore Ts'o" <tytso@mit.edu>,
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
In-Reply-To: <20180424230943.GY17484@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804241911040.19786@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180424162712.GL17484@dhcp22.suse.cz> <3732370.1623zxSvNg@blindfold> <20180424192803.GT17484@dhcp22.suse.cz> <3894056.cxOY6eVYVp@blindfold> <20180424230943.GY17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Tue, 24 Apr 2018, Michal Hocko wrote:

> On Wed 25-04-18 00:18:40, Richard Weinberger wrote:
> > Am Dienstag, 24. April 2018, 21:28:03 CEST schrieb Michal Hocko:
> > > > Also only for debugging.
> > > > Getting rid of vmalloc with GFP_NOFS in UBIFS is no big problem.
> > > > I can prepare a patch.
> > > 
> > > Cool!
> > > 
> > > Anyway, if UBIFS has some reclaim recursion critical sections in general
> > > it would be really great to have them documented and that is where the
> > > scope api is really handy. Just add the scope and document what is the
> > > recursion issue. This will help people reading the code as well. Ideally
> > > there shouldn't be any explicit GFP_NOFS in the code.
> > 
> > So in a perfect world a filesystem calls memalloc_nofs_save/restore and
> > always uses GFP_KERNEL for kmalloc/vmalloc?
> 
> Exactly! And in a dream world those memalloc_nofs_save act as a
> documentation of the reclaim recursion documentation ;)
> -- 
> Michal Hocko
> SUSE Labs

BTW. should memalloc_nofs_save and memalloc_noio_save be merged into just 
one that prevents both I/O and FS recursion?

memalloc_nofs_save allows submitting bios to I/O stack and the bios 
created under memalloc_nofs_save could be sent to the loop device and the 
loop device calls the filesystem...

Mikulas
