Return-Path: <SRS0=F3kk=4U=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C950BC3F2C6
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Mar 2020 16:54:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A4B0020863
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Mar 2020 16:54:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727077AbgCCQyv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 3 Mar 2020 11:54:51 -0500
Received: from fieldses.org ([173.255.197.46]:37344 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727070AbgCCQyu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Mar 2020 11:54:50 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 628351C22; Tue,  3 Mar 2020 11:54:50 -0500 (EST)
Date:   Tue, 3 Mar 2020 11:54:50 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     madhuparnabhowmik10@gmail.com
Cc:     chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, joel@joelfernandes.org,
        frextrite@gmail.com,
        linux-kernel-mentees@lists.linuxfoundation.org, paulmck@kernel.org
Subject: Re: [PATCH] fs: nfsd: fileache.c: Use built-in RCU list checking
Message-ID: <20200303165450.GD19140@fieldses.org>
References: <20200213150359.5819-1-madhuparnabhowmik10@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200213150359.5819-1-madhuparnabhowmik10@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Applying for 5.7, thanks.--b.

On Thu, Feb 13, 2020 at 08:33:59PM +0530, madhuparnabhowmik10@gmail.com wrote:
> From: Madhuparna Bhowmik <madhuparnabhowmik10@gmail.com>
> 
> list_for_each_entry_rcu() has built-in RCU and lock checking.
> 
> Pass cond argument to list_for_each_entry_rcu() to silence
> false lockdep warning when  CONFIG_PROVE_RCU_LIST is enabled
> by default.
> 
> Signed-off-by: Madhuparna Bhowmik <madhuparnabhowmik10@gmail.com>
> ---
>  fs/nfsd/filecache.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
> index 32a9bf22ac08..547d2d8bde62 100644
> --- a/fs/nfsd/filecache.c
> +++ b/fs/nfsd/filecache.c
> @@ -736,7 +736,7 @@ nfsd_file_find_locked(struct inode *inode, unsigned int may_flags,
>  	unsigned char need = may_flags & NFSD_FILE_MAY_MASK;
>  
>  	hlist_for_each_entry_rcu(nf, &nfsd_file_hashtbl[hashval].nfb_head,
> -				 nf_node) {
> +				 nf_node, lockdep_is_held(&nfsd_file_hashtbl[hashval].nfb_lock)) {
>  		if ((need & nf->nf_may) != need)
>  			continue;
>  		if (nf->nf_inode != inode)
> -- 
> 2.17.1
