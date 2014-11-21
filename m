Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59149 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbaKUKTS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Nov 2014 05:19:18 -0500
Date: Fri, 21 Nov 2014 02:19:14 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>,
        Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 0/5] btrfs: implement swap file support
Message-ID: <20141121101914.GA380@infradead.org>
References: <cover.1416563833.git.osandov@osandov.com>
 <20141121101531.GB21814@mew>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141121101531.GB21814@mew>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 21, 2014 at 02:15:31AM -0800, Omar Sandoval wrote:
> Sorry for the noise, looks like Christoph got back to me on the previous RFC
> just before I sent this out -- disregard this for now.

If the NFS people are fine with this version I'd certainly welcome it as
a first step.  Additional improvements are of course always welcome.
