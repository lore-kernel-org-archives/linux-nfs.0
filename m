Return-Path: <SRS0=tdDw=CX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E8C4C433E2
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Sep 2020 20:51:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id F24B120E65
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Sep 2020 20:51:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="hf/EkViU"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726092AbgINUvc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 14 Sep 2020 16:51:32 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40784 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726040AbgINUv2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2020 16:51:28 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 87AA1C06174A
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2020 13:51:28 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id C1A03425E; Mon, 14 Sep 2020 16:51:27 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org C1A03425E
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1600116687;
        bh=5idgfl1lmcW+3sHDuK4jgBzKjBkvtXBh+PxM8EW9BX8=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=hf/EkViUWKeqH44/ULlpBVTgkCmAuqapouUJ0IMWN/y9KSuy0pNxf7rSsPrWcEGiq
         PbCinGHEsci61s91fM3cU5ukn+jcIH89muoJgWvIri0fgsk81OulE7Svm6jeQjvGdK
         f6qJTV4paqGNUN83zuy2leVSH3IwZKU9U3huvsUE=
Date:   Mon, 14 Sep 2020 16:51:27 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     trond.myklebust@primarydata.com, jlayton@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] NFSD: synchronously unhash a file on NFSv4 CLOSE
Message-ID: <20200914205127.GD30007@fieldses.org>
References: <159976711218.1334.14422329830210182280.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <159976711218.1334.14422329830210182280.stgit@klimt.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Sep 10, 2020 at 03:45:12PM -0400, Chuck Lever wrote:
> I recently observed a significant slowdown in a long-running
> test on NFSv4.0 mounts.
> 
> An OPEN for write seems to block the NFS server from offering
> delegations on that file for a few seconds. The problem is that
> when that file is closed, the filecache retains an open-for-write
> file descriptor until the laundrette runs. That keeps the inode's
> i_writecount positive until the cached file is finally unhashed
> and closed.
> 
> Force the NFSv4 CLOSE logic to call filp_close() to eliminate
> the underlying cached open-for-write file as soon as the client
> closes the file.
> 
> This minor change claws back about 80% of the performance
> regression.

That's really useful to know.  But mainly this makes me think that
nfsd4_check_conflicting_opens() is wrong.

I'm trying to determine whether a given file has a non-nfsd writer by
counting the number of write opens nfsd holds on a given file and
subtracting that from i_writecount.

But the way I'm counting write opens probably isn't correct.

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfsd/nfs4state.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 3ac40ba7efe1..0b3059b8b36c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -613,10 +613,14 @@ static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
>  		if (atomic_read(&fp->fi_access[1 - oflag]) == 0)
>  			swap(f2, fp->fi_fds[O_RDWR]);
>  		spin_unlock(&fp->fi_lock);
> -		if (f1)
> +		if (f1) {
> +			nfsd_file_close_inode_sync(locks_inode(f1->nf_file));
>  			nfsd_file_put(f1);
> -		if (f2)
> +		}
> +		if (f2) {
> +			nfsd_file_close_inode_sync(locks_inode(f2->nf_file));
>  			nfsd_file_put(f2);
> +		}
>  	}
>  }
>  
> 
