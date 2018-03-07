Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:39277 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933487AbeCGRA3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Mar 2018 12:00:29 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 37BE3280486
        for <linux-nfs@vger.kernel.org>; Wed,  7 Mar 2018 18:00:28 +0100 (CET)
Date: Wed, 7 Mar 2018 18:00:23 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-ID: <2006405521.11212710.1520442023186.JavaMail.zimbra@desy.de>
In-Reply-To: <20180307064756.GA15922@infradead.org>
References: <1569515727.10818617.1520288819283.JavaMail.zimbra@desy.de> <20180307064756.GA15922@infradead.org>
Subject: Re: Kernel ops with flexfiles
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After some digging I found that the number of increments and decrements for
lo->plh_refcoun't doesn't match. While the number of pnfs_get_layout_hdr matches
to the number of pnfs_put_layout_hdr calls, pnfs_layout_remove_lseg does yet
another decrement. Something like this fixes the issue:

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c13e826614b5..a7b01cd87e6a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -490,7 +490,7 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
        WARN_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
        list_del_init(&lseg->pls_list);
        /* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
-       refcount_dec(&lo->plh_refcount);
+       refcount_dec_not_one(&lo->plh_refcount);
        if (test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
                return;
        if (list_empty(&lo->plh_segs) &&


Or may be we don't need refcount_dec(&lo->plh_refcount) at all.
Can someone comment on it?

Thanks,
   Tigran.


----- Original Message -----
> From: "Christoph Hellwig" <hch@infradead.org>
> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>, "Trond Myklebust" <trond.myklebust@primarydata.com>
> Sent: Wednesday, March 7, 2018 7:47:56 AM
> Subject: Re: Kernel ops with flexfiles

> FYI, I see very similar issues with blocklayout, also caused by the
> refcount changes.  But I didn't really didn't have any time to dig
> into it yet.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
