Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41915 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458AbaBGQVf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Feb 2014 11:21:35 -0500
Date: Fri, 7 Feb 2014 16:21:31 +0000
From: Mel Gorman <mgorman@suse.de>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, trond.myklebust@primarydata.com,
        jstancek@redhat.com, jlayton@redhat.com, riel@redhat.com,
        linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
        linux-mm@kvack.org
Subject: Re: [PATCH] mm: fix page leak at nfs_symlink()
Message-ID: <20140207162131.GY6732@suse.de>
References: <f4b3dc07dfa55bf7931de36b03aa9ef7e3ff0490.1391785222.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
In-Reply-To: <f4b3dc07dfa55bf7931de36b03aa9ef7e3ff0490.1391785222.git.aquini@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 07, 2014 at 01:19:54PM -0200, Rafael Aquini wrote:
> Changes committed by "a0b8cab3 mm: remove lru parameter from
> __pagevec_lru_add and remove parts of pagevec API" have introduced
> a call to add_to_page_cache_lru() which causes a leak in nfs_symlink() 
> as now the page gets an extra refcount that is not dropped.
> 
> Jan Stancek observed and reported the leak effect while running test8 from
> Connectathon Testsuite. After several iterations over the test case,
> which creates several symlinks on a NFS mountpoint, the test system was
> quickly getting into an out-of-memory scenario.
> 
> This patch fixes the page leak by dropping that extra refcount 
> add_to_page_cache_lru() is grabbing. 
> 
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Rafael Aquini <aquini@redhat.com>

Thanks.

Acked-by: Mel Gorman <mgorman@suse.de>

It should be cc'd for stable for 3.11 and later kernels.

-- 
Mel Gorman
SUSE Labs
