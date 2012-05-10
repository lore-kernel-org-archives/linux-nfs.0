Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:46828 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097Ab2EJOZw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2012 10:25:52 -0400
Received: by qcro28 with SMTP id o28so1141810qcr.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 May 2012 07:25:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1336658065-24851-3-git-send-email-mgorman@suse.de>
References: <1336658065-24851-1-git-send-email-mgorman@suse.de>
	<1336658065-24851-3-git-send-email-mgorman@suse.de>
Date: Thu, 10 May 2012 10:25:51 -0400
Message-ID: <CACLa4punzEWjxQ79GF2o5h-up5A43oBuP-LEXGiA-kKQxcG1iQ@mail.gmail.com>
Subject: Re: [PATCH 02/12] selinux: tag avc cache alloc as non-critical
From: Eric Paris <eparis@parisplace.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
        Linux-Netdev <netdev@vger.kernel.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Mike Christie <michaelc@cs.wisc.edu>,
        Eric B Munson <emunson@mgebm.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 10, 2012 at 9:54 AM, Mel Gorman <mgorman@suse.de> wrote:
> Failing to allocate a cache entry will only harm performance not
> correctness.  Do not consume valuable reserve pages for something
> like that.
>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Eric Paris <eparis@redhat.com>

> ---
>  security/selinux/avc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/security/selinux/avc.c b/security/selinux/avc.c
> index 8ee42b2..75c2977 100644
> --- a/security/selinux/avc.c
> +++ b/security/selinux/avc.c
> @@ -280,7 +280,7 @@ static struct avc_node *avc_alloc_node(void)
>  {
>        struct avc_node *node;
>
> -       node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC);
> +       node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC|__GFP_NOMEMALLOC);
>        if (!node)
>                goto out;
>
> --
> 1.7.9.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
