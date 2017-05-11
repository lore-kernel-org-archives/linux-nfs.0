Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46904 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755481AbdEKN1O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 May 2017 09:27:14 -0400
Date: Thu, 11 May 2017 15:27:12 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "n.borisov.lkml@gmail.com" <n.borisov.lkml@gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client fixes for 4.12
Message-ID: <20170511132712.GL26782@dhcp22.suse.cz>
References: <1494434821.4764.1.camel@primarydata.com>
 <be16be57-235c-fdf9-f708-3898aeeeb5aa@gmail.com>
 <20170511075910.GD26782@dhcp22.suse.cz>
 <1494504995.3207.1.camel@primarydata.com>
 <20170511122613.GJ26782@dhcp22.suse.cz>
 <1494506698.3207.3.camel@primarydata.com>
 <20170511125612.GK26782@dhcp22.suse.cz>
 <1494508201.3207.5.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1494508201.3207.5.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu 11-05-17 13:10:03, Trond Myklebust wrote:
> On Thu, 2017-05-11 at 14:56 +0200, Michal Hocko wrote:
[...]
> > I do not see any explicit documentation which would encourage users
> > to not check for the allocation failure. Only __GFP_NOFAIL is
> > documented it _must_ retry for ever. Of course I am open for any
> > documentation improvements.
> 
> As I said, the problem has been the discussion, and how it focusses on
> "must not fail".

I would strongly suggest cc linux-mm ML when doing this kind of changes.
-- 
Michal Hocko
SUSE Labs
