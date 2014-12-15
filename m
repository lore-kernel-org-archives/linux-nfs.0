Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:40906 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbaLOGRk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2014 01:17:40 -0500
Date: Mon, 15 Dec 2014 06:17:34 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Omar Sandoval <osandov@osandov.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, David Sterba <dsterba@suse.cz>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 6/8] nfs: don't dirty ITER_BVEC pages read through direct
 I/O
Message-ID: <20141215061734.GU22149@ZenIV.linux.org.uk>
References: <cover.1418618044.git.osandov@osandov.com>
 <e5240b33c30d147588d0cdd285d8d95463b3de18.1418618044.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <e5240b33c30d147588d0cdd285d8d95463b3de18.1418618044.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 14, 2014 at 09:27:00PM -0800, Omar Sandoval wrote:
> As with the generic blockdev code, kernel pages shouldn't be dirtied by
> the direct I/O path.

This really asks for an inlined helper (iter_is_bvec(iter) or something like
that)
