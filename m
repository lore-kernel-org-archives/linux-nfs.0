Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ms.lwn.net ([45.79.88.28]:43764 "EHLO ms.lwn.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750987AbdEPPPh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 May 2017 11:15:37 -0400
Date: Tue, 16 May 2017 09:15:35 -0600
From: Jonathan Corbet <corbet@lwn.net>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "mhocko@kernel.org" <mhocko@kernel.org>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "n.borisov.lkml@gmail.com" <n.borisov.lkml@gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client fixes for 4.12
Message-ID: <20170516091535.04e3d188@lwn.net>
In-Reply-To: <1494508201.3207.5.camel@primarydata.com>
References: <1494434821.4764.1.camel@primarydata.com>
        <be16be57-235c-fdf9-f708-3898aeeeb5aa@gmail.com>
        <20170511075910.GD26782@dhcp22.suse.cz>
        <1494504995.3207.1.camel@primarydata.com>
        <20170511122613.GJ26782@dhcp22.suse.cz>
        <1494506698.3207.3.camel@primarydata.com>
        <20170511125612.GK26782@dhcp22.suse.cz>
        <1494508201.3207.5.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 11 May 2017 13:10:03 +0000
Trond Myklebust <trondmy@primarydata.com> wrote:

> If we suspect the existence of a load of potential time bombs in the
> kernel due to missing checks, then the status quo is not good enough.
> We should be working on tools to identify these code paths.
> 
> Quite frankly, I'd love to see a fuzzer-like tool that can randomly
> fail allocations.

The fault injection framework at least used to work quite nicely for this;
I used it to test out the failure paths in the OLPC drivers years ago.
Documentation/fault-injection/fault-injection.txt.

jon
