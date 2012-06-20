Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51087 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754165Ab2FTRjj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 13:39:39 -0400
Message-ID: <4FE20A8C.6000207@redhat.com>
Date: Wed, 20 Jun 2012 13:38:20 -0400
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
Subject: Re: [PATCH 10/12] nfs: enable swap on NFS
References: <1340185081-22525-1-git-send-email-mgorman@suse.de> <1340185081-22525-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1340185081-22525-11-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/20/2012 05:37 AM, Mel Gorman wrote:
> Implement the new swapfile a_ops for NFS and hook up ->direct_IO. This
> will set the NFS socket to SOCK_MEMALLOC and run socket reconnect
> under PF_MEMALLOC as well as reset SOCK_MEMALLOC before engaging the
> protocol ->connect() method.
>
> PF_MEMALLOC should allow the allocation of struct socket and related
> objects and the early (re)setting of SOCK_MEMALLOC should allow us
> to receive the packets required for the TCP connection buildup.
>
> [dfeng@redhat.com: Fix handling of multiple swap files]
> [a.p.zijlstra@chello.nl: Original patch]
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Acked-by: Rik van Riel<riel@redhat.com>

