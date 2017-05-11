Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43176 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932651AbdEKM0P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 May 2017 08:26:15 -0400
Date: Thu, 11 May 2017 14:26:13 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "n.borisov.lkml@gmail.com" <n.borisov.lkml@gmail.com>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client fixes for 4.12
Message-ID: <20170511122613.GJ26782@dhcp22.suse.cz>
References: <1494434821.4764.1.camel@primarydata.com>
 <be16be57-235c-fdf9-f708-3898aeeeb5aa@gmail.com>
 <20170511075910.GD26782@dhcp22.suse.cz>
 <1494504995.3207.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1494504995.3207.1.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu 11-05-17 12:16:37, Trond Myklebust wrote:
> On Thu, 2017-05-11 at 09:59 +0200, Michal Hocko wrote:
> > On Thu 11-05-17 10:53:27, Nikolay Borisov wrote:
> > > 
> > > 
> > > On 10.05.2017 19:47, Trond Myklebust wrote:
> > 
> > [...]
> > > > - Cleanup and removal of some memory failure paths now that
> > > >   GFP_NOFS is guaranteed to never fail.
> > > 
> > > What guarantees that? Since if this is the case then this can
> > > result in
> > > a lot of opportunities for cleanup across the whole kernel tree.
> > > After
> > > discussing with mhocko (cc'ed) it seems that in practice everything
> > > below COSTLY_ORDER which are not GFP_NORETRY will never fail. But
> > > this
> > > semantic is not the same as GFP_NOFAIL. E.g. nothing guarantees
> > > that
> > > this will stay like that in the future?
> > 
> > In practice it is hard to change the semantic of small allocations
> > never
> > fail _practically_. But this is absolutely not guaranteed! They can
> > fail
> > e.g. when the allocation context is the oom victim. Removing error
> > paths
> > for allocation failures is just wrong.
> 
> OK, this makes no fucking sense at all.
> 
> Either allocations can fail or they can't.
> 1) If they can't fail, then we don't need the checks.
> 2) If they can fail, then we do need them, and this hand wringing in
> the MM community about GFP_* semantics and how we need to prevent
> failure is fucking pointless.

everything which is not __GFP_NOFAIL might fail. We try hard not to fail
small allocations requests as much as we can in general but you _have_ to
check for failures. There is simply no way to guarantee "never fail"
semantic for all allocation requests. This has been like that basically
since years. And even this try-to-be-nofailing for small allocations has
been PITA for some corner cases.

-- 
Michal Hocko
SUSE Labs
