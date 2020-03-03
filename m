Return-Path: <SRS0=F3kk=4U=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AC97C3F2C6
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Mar 2020 16:54:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3741520863
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Mar 2020 16:54:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727311AbgCCQyj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 3 Mar 2020 11:54:39 -0500
Received: from fieldses.org ([173.255.197.46]:37338 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727070AbgCCQyj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Mar 2020 11:54:39 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 1B27D1C22; Tue,  3 Mar 2020 11:54:39 -0500 (EST)
Date:   Tue, 3 Mar 2020 11:54:39 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     madhuparnabhowmik10@gmail.com
Cc:     chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, joel@joelfernandes.org,
        frextrite@gmail.com,
        linux-kernel-mentees@lists.linuxfoundation.org, paulmck@kernel.org
Subject: Re: [PATCH] fs: nfsd: nfs4state.c: Use built-in RCU list checking
Message-ID: <20200303165439.GC19140@fieldses.org>
References: <20200213150331.5727-1-madhuparnabhowmik10@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200213150331.5727-1-madhuparnabhowmik10@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Applying for 5.7, thanks.--b.

On Thu, Feb 13, 2020 at 08:33:31PM +0530, madhuparnabhowmik10@gmail.com wrote:
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
>  fs/nfsd/nfs4state.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 369e574c5092..3a80721fe53d 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4295,7 +4295,8 @@ find_file_locked(struct knfsd_fh *fh, unsigned int hashval)
>  {
>  	struct nfs4_file *fp;
>  
> -	hlist_for_each_entry_rcu(fp, &file_hashtbl[hashval], fi_hash) {
> +	hlist_for_each_entry_rcu(fp, &file_hashtbl[hashval], fi_hash,
> +				lockdep_is_held(&state_lock)) {
>  		if (fh_match(&fp->fi_fhandle, fh)) {
>  			if (refcount_inc_not_zero(&fp->fi_ref))
>  				return fp;
> -- 
> 2.17.1
