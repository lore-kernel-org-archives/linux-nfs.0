Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fw5a.wadns.net ([196.220.39.47]:11640 "EHLO fw5a.wadns.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840AbaKYHJf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Nov 2014 02:09:35 -0500
Message-ID: <547419D6.40905@swiftspirit.co.za>
Date: Tue, 25 Nov 2014 07:55:34 +0200
From: Brendan Hide <brendan@swiftspirit.co.za>
MIME-Version: 1.0
To: Omar Sandoval <osandov@osandov.com>
CC: Filipe David Manana <fdmanana@gmail.com>, David Sterba <dsterba@suse.cz>,
        linux-btrfs@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>,
        Josef Bacik <jbacik@fb.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 5/5] btrfs: enable swap file support
References: <cover.1416563833.git.osandov@osandov.com> <afd3c1009172a4a1cfa10e73a64caf35c631a6d4.1416563833.git.osandov@osandov.com> <20141121180045.GF8568@twin.jikos.cz> <20141122200357.GA15189@mew> <20141124220302.GA5785@mew.dhcp4.washington.edu>
In-Reply-To: <20141124220302.GA5785@mew.dhcp4.washington.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2014/11/25 00:03, Omar Sandoval wrote:
> [snip]
>
> The snapshot issue is a little tricker to resolve. I see a few options:
>
> 1. Just do the COW and hope for the best
> 2. As part of btrfs_swap_activate, COW any shared extents. If a snapshot
> happens while a swap file is active, we'll fall back to 1.
> 3. Clobber any swap file extents which are in a snapshot, i.e., always use the
> existing extent.
>
> I'm partial to 3, as it's the simplest approach, and I don't think it makes
> much sense for a swap file to be in a snapshot anyways. I'd appreciate any
> comments that anyone might have.
>
Personally, 3 seems pragmatic - but not necessarily "correct". :-/

-- 
__________
Brendan Hide
http://swiftspirit.co.za/
http://www.webafrica.co.za/?AFF1E97

