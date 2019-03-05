Return-Path: <SRS0=HPA/=RI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 413E3C43381
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 21:25:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 10ADB20652
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 21:25:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726744AbfCEVZS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Mar 2019 16:25:18 -0500
Received: from fieldses.org ([173.255.197.46]:40536 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726214AbfCEVZR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Mar 2019 16:25:17 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id CC51A1C81; Tue,  5 Mar 2019 16:25:16 -0500 (EST)
Date:   Tue, 5 Mar 2019 16:25:16 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Paul Moore <paul@paul-moore.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Eric Paris <eparis@parisplace.org>
Cc:     selinux@vger.kernel.org, Scott Mayhew <smayhew@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] security/selinux: fix SECURITY_LSM_NATIVE_LABELS on
 reused superblock
Message-ID: <20190305212516.GB27437@fieldses.org>
References: <20190305211758.GA27437@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190305211758.GA27437@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Whoops, probably should have cc'd linux-nfs as well.--b.

On Tue, Mar 05, 2019 at 04:17:58PM -0500, bfields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> In the case when we're reusing a superblock, selinux_sb_clone_mnt_opts()
> fails to set set_kern_flags, with the result that
> nfs_clone_sb_security() incorrectly clears NFS_CAP_SECURITY_LABEL.
> 
> The result is that if you mount the same NFS filesystem twice, NFS
> security labels are turned off, even if they would work fine if you
> mounted the filesystem only once.
> 
> ("fixes" may be not exactly the right tag, it may be more like
> "fixed-other-cases-but-missed-this-one".)
> 
> Cc: Scott Mayhew <smayhew@redhat.com>
> Cc: stable@vger.kernel.org
> Fixes: 0b4d3452b8b4 "security/selinux: allow security_sb_clone_mnt_opts..."
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  security/selinux/hooks.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index f0e36c3492ba..5e9304567233 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -959,8 +959,11 @@ static int selinux_sb_clone_mnt_opts(const struct super_block *oldsb,
>  	BUG_ON(!(oldsbsec->flags & SE_SBINITIALIZED));
>  
>  	/* if fs is reusing a sb, make sure that the contexts match */
> -	if (newsbsec->flags & SE_SBINITIALIZED)
> +	if (newsbsec->flags & SE_SBINITIALIZED) {
> +		if ((kern_flags & SECURITY_LSM_NATIVE_LABELS) && !set_context)
> +			*set_kern_flags |= SECURITY_LSM_NATIVE_LABELS;
>  		return selinux_cmp_sb_context(oldsb, newsb);
> +	}
>  
>  	mutex_lock(&newsbsec->lock);
>  
> -- 
> 2.20.1
> 
