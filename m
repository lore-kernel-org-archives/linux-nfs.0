Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56122 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1731429AbeGQNXd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Jul 2018 09:23:33 -0400
Date: Tue, 17 Jul 2018 14:50:59 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
        Artem Bityutskiy <dedekind1@gmail.com>,
        Richard Weinberger <richard@nod.at>,
        David Woodhouse <dwmw2@infradead.org>,
        Brian Norris <computersforpeace@gmail.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        Marek Vasut <marek.vasut@gmail.com>,
        Cyrille Pitchen <cyrille.pitchen@wedev4u.fr>,
        Theodore Ts'o <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
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
Message-ID: <20180717125059.GC30926@dhcp22.suse.cz>
References: <20180424162712.GL17484@dhcp22.suse.cz>
 <ce42f323-870c-21df-ac27-1bec6aa7e5d1@redhat.com>
 <20180424200927.GU17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180424200927.GU17484@dhcp22.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue 24-04-18 14:09:27, Michal Hocko wrote:
> On Tue 24-04-18 20:26:23, Steven Whitehouse wrote:
> [...]
> > It would be good to fix this, and it has been known as an issue for a long
> > time. We might well be able to make use of the new API though. It might be
> > as simple as adding the calls when we get & release glocks, but I'd have to
> > check the code to be sure,
> 
> Yeah, starting with annotating those locking contexts and how document
> how their are used in the reclaim is the great first step. This has to
> be done per-fs obviously.

Any chance of progress here?
-- 
Michal Hocko
SUSE Labs
