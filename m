Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754435Ab2FTRQQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 13:16:16 -0400
Message-ID: <4FE20501.3080004@redhat.com>
Date: Wed, 20 Jun 2012 13:14:41 -0400
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
Subject: Re: [PATCH 08/12] nfs: teach the NFS client how to treat PG_swapcache
 pages
References: <1340185081-22525-1-git-send-email-mgorman@suse.de> <1340185081-22525-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1340185081-22525-9-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/20/2012 05:37 AM, Mel Gorman wrote:
> Replace all relevant occurences of page->index and page->mapping in
> the NFS client with the new page_file_index() and page_file_mapping()
> functions.
>
> Signed-off-by: Peter Zijlstra<a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Acked-by: Rik van Riel<riel@redhat.com>

