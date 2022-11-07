Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA5AAC4332F
	for <linux-nfs@archiver.kernel.org>; Mon,  7 Nov 2022 17:28:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232000AbiKGR2f (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 7 Nov 2022 12:28:35 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:41772 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231961AbiKGR2f (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2022 12:28:35 -0500
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 416C91DDC1
        for <linux-nfs@vger.kernel.org>; Mon,  7 Nov 2022 09:28:34 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id EAADCB81608
        for <linux-nfs@vger.kernel.org>; Mon,  7 Nov 2022 17:28:32 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C34AC433C1;
        Mon,  7 Nov 2022 17:28:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1667842111;
        bh=MJN60BuMU0e2RgJu3Ex095D4Xl+RZ4m7O0LXrEE0qQ0=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=O2m0RgF+qE1OYABaHzCbinEgpHtREgFOGcphhpfM5XCFZWcUTz1MKYhvzhLW75AVB
         bKiPxdQWgq+GHNf9r/jW3TDWExRphO3XUrlHrVljZQUV8ZV8CXTYvE5K1Z4iAgnapk
         ypklF/mRYP4cMzjJy7HByPIDnMVB0LqaIWjH8DdNaG29eZd97udFAsM8uC0OM4SG3C
         m1N0qJYbjzTG32+gTCyycW2wqnfzHx1bTrA8OEghDnE/K68fr0UGwzfqGpII5S9w0n
         rMLCSbuzYykkJQyb3QnNVq+p2AHwA+4v+h8pVSg+QiSYyGKcriWRYQMA3xNsALtFMH
         5LyWANRFacYIw==
Message-ID: <61876142ab0115a7bf39556e5caebfd1a635f945.camel@kernel.org>
Subject: Re: [PATCH] nfsd: remove dedicated nfsd_filecache_wq
From:   Jeff Layton <jlayton@kernel.org>
To:     chuck.lever@oracle.com
Cc:     linux-nfs@vger.kernel.org
Date:   Mon, 07 Nov 2022 12:28:29 -0500
In-Reply-To: <20221107171056.64564-1-jlayton@kernel.org>
References: <20221107171056.64564-1-jlayton@kernel.org>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.44.4 (3.44.4-2.fc36) 
MIME-Version: 1.0
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2022-11-07 at 12:10 -0500, Jeff Layton wrote:
> There's no clear benefit to allocating our own over just using the
> system_wq. This also fixes a minor bug in nfsd_file_cache_init(). In the
> current code, if allocating the wq fails, then the nfsd_file_rhash_tbl
> is leaked.
>=20
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfsd/filecache.c | 13 +------------
>  1 file changed, 1 insertion(+), 12 deletions(-)
>=20

I'm playing with this and it seems to be ok, but reading further into
the workqueue doc, it says this:

* A wq serves as a domain for forward progress guarantee
  (``WQ_MEM_RECLAIM``, flush and work item attributes.  Work items
  which are not involved in memory reclaim and don't need to be
  flushed as a part of a group of work items, and don't require any
  special attribute, can use one of the system wq.  There is no
  difference in execution characteristics between using a dedicated wq
  and a system wq.

These jobs are involved in mem reclaim however, due to the shrinker.
OTOH, the existing nfsd_filecache_wq doesn't set WQ_MEM_RECLAIM.

In any case, we aren't flushing the work or anything as part of mem
reclaim, so maybe the above bullet point doesn't apply here?

> diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
> index 1e76b0d3b83a..59e06d68d20c 100644
> --- a/fs/nfsd/filecache.c
> +++ b/fs/nfsd/filecache.c
> @@ -66,8 +66,6 @@ struct nfsd_fcache_disposal {
>  	struct list_head freeme;
>  };
> =20
> -static struct workqueue_struct *nfsd_filecache_wq __read_mostly;
> -
>  static struct kmem_cache		*nfsd_file_slab;
>  static struct kmem_cache		*nfsd_file_mark_slab;
>  static struct list_lru			nfsd_file_lru;
> @@ -564,7 +562,7 @@ nfsd_file_list_add_disposal(struct list_head *files, =
struct net *net)
>  	spin_lock(&l->lock);
>  	list_splice_tail_init(files, &l->freeme);
>  	spin_unlock(&l->lock);
> -	queue_work(nfsd_filecache_wq, &l->work);
> +	queue_work(system_wq, &l->work);
>  }
> =20
>  static void
> @@ -855,11 +853,6 @@ nfsd_file_cache_init(void)
>  	if (ret)
>  		return ret;
> =20
> -	ret =3D -ENOMEM;
> -	nfsd_filecache_wq =3D alloc_workqueue("nfsd_filecache", 0, 0);
> -	if (!nfsd_filecache_wq)
> -		goto out;
> -
>  	nfsd_file_slab =3D kmem_cache_create("nfsd_file",
>  				sizeof(struct nfsd_file), 0, 0, NULL);
>  	if (!nfsd_file_slab) {
> @@ -917,8 +910,6 @@ nfsd_file_cache_init(void)
>  	nfsd_file_slab =3D NULL;
>  	kmem_cache_destroy(nfsd_file_mark_slab);
>  	nfsd_file_mark_slab =3D NULL;
> -	destroy_workqueue(nfsd_filecache_wq);
> -	nfsd_filecache_wq =3D NULL;
>  	rhashtable_destroy(&nfsd_file_rhash_tbl);
>  	goto out;
>  }
> @@ -1034,8 +1025,6 @@ nfsd_file_cache_shutdown(void)
>  	fsnotify_wait_marks_destroyed();
>  	kmem_cache_destroy(nfsd_file_mark_slab);
>  	nfsd_file_mark_slab =3D NULL;
> -	destroy_workqueue(nfsd_filecache_wq);
> -	nfsd_filecache_wq =3D NULL;
>  	rhashtable_destroy(&nfsd_file_rhash_tbl);
> =20
>  	for_each_possible_cpu(i) {

--=20
Jeff Layton <jlayton@kernel.org>
