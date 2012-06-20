Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61177 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753545Ab2FTRJ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 13:09:26 -0400
Message-ID: <4FE20378.70105@redhat.com>
Date: Wed, 20 Jun 2012 13:08:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
To: Mel Gorman <mgorman@suse.de>
CC: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
        Linux-Netdev <netdev@vger.kernel.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Mike Christie <michaelc@cs.wisc.edu>,
        Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 07/12] mm: Add support for direct_IO to highmem pages
References: <1340185081-22525-1-git-send-email-mgorman@suse.de> <1340185081-22525-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1340185081-22525-8-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/20/2012 05:37 AM, Mel Gorman wrote:
> The patch "mm: Add support for a filesystem to activate swap files and
> use direct_IO for writing swap pages" added support for using direct_IO
> to write swap pages but it is insufficient for highmem pages.
>
> To support highmem pages, this patch kmaps() the page before calling the
> direct_IO() handler. As direct_IO deals with virtual addresses an
> additional helper is necessary for get_kernel_pages() to lookup the
> struct page for a kmap virtual address.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Acked-by: Rik van Riel<riel@redhat.com>

