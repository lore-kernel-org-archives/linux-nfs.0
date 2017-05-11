Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48800 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755816AbdEKNyp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 May 2017 09:54:45 -0400
Date: Thu, 11 May 2017 15:54:43 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "n.borisov.lkml@gmail.com" <n.borisov.lkml@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client fixes for 4.12
Message-ID: <20170511135443.GN26782@dhcp22.suse.cz>
References: <1494434821.4764.1.camel@primarydata.com>
 <be16be57-235c-fdf9-f708-3898aeeeb5aa@gmail.com>
 <1494510068.6968.0.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1494510068.6968.0.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu 11-05-17 13:41:12, Trond Myklebust wrote:
> On Thu, 2017-05-11 at 10:53 +0300, Nikolay Borisov wrote:
> > 
> > On 10.05.2017 19:47, Trond Myklebust wrote:
> > > Hi Linus,
> > > 
> > > The following changes since commit
> > > 4f7d029b9bf009fbee76bb10c0c4351a1870d2f3:
> > > 
> > >   Linux 4.11-rc7 (2017-04-16 13:00:18 -0700)
> > > 
> > > are available in the git repository at:
> > > 
> > >   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-
> > > for-4.12-1
> > > 
> > > for you to fetch changes up to
> > > 76b2a303384e1d6299c3a0249f0f0ce2f8f96017:
> > > 
> > >   pNFS/flexfiles: Always attempt to call layoutstats when flexfiles
> > > is enabled (2017-05-09 16:02:57 -0400)
> > > 
> > > ----------------------------------------------------------------
> > > NFS client updates for Linux 4.12
> > > 
> > > Highlights include:
> > > 
> > > Stable bugfixes:
> > > - Fix use after free in write error path
> > > - Use GFP_NOIO for two allocations in writeback
> > > - Fix a hang in OPEN related to server reboot
> > > - Check the result of nfs4_pnfs_ds_connect
> > > - Fix an rcu lock leak
> > > 
> > > Features:
> > > - Removal of the unmaintained and unused OSD pNFS layout
> > > - Cleanup and removal of lots of unnecessary dprintk()s
> > > - Cleanup and removal of some memory failure paths now that
> > >   GFP_NOFS is guaranteed to never fail.
> > 
> > What guarantees that? Since if this is the case then this can result
> > in
> > a lot of opportunities for cleanup across the whole kernel tree.
> > After
> > discussing with mhocko (cc'ed) it seems that in practice everything
> > below COSTLY_ORDER which are not GFP_NORETRY will never fail. But
> > this
> > semantic is not the same as GFP_NOFAIL. E.g. nothing guarantees that
> > this will stay like that in the future?
> > 
> 
> Actually, going back to the code with coffee: it's the fact we have
> mempools, with direct reclaim that guarantee this.

Mempools are a different story, of course. They do the their own loop on
top of the underlying allocator.
-- 
Michal Hocko
SUSE Labs
