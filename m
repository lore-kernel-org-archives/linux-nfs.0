Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lithops.sigma-star.at ([195.201.40.130]:42754 "EHLO
        lithops.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750766AbeDXWSt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Apr 2018 18:18:49 -0400
From: Richard Weinberger <richard@nod.at>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
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
        Mikulas Patocka <mpatocka@redhat.com>,
        linux-mtd@lists.infradead.org, linux-ext4@vger.kernel.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: vmalloc with GFP_NOFS
Date: Wed, 25 Apr 2018 00:18:40 +0200
Message-ID: <3894056.cxOY6eVYVp@blindfold>
In-Reply-To: <20180424192803.GT17484@dhcp22.suse.cz>
References: <20180424162712.GL17484@dhcp22.suse.cz> <3732370.1623zxSvNg@blindfold> <20180424192803.GT17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am Dienstag, 24. April 2018, 21:28:03 CEST schrieb Michal Hocko:
> > Also only for debugging.
> > Getting rid of vmalloc with GFP_NOFS in UBIFS is no big problem.
> > I can prepare a patch.
> 
> Cool!
> 
> Anyway, if UBIFS has some reclaim recursion critical sections in general
> it would be really great to have them documented and that is where the
> scope api is really handy. Just add the scope and document what is the
> recursion issue. This will help people reading the code as well. Ideally
> there shouldn't be any explicit GFP_NOFS in the code.

So in a perfect world a filesystem calls memalloc_nofs_save/restore and
always uses GFP_KERNEL for kmalloc/vmalloc?

Thanks,
//richard


