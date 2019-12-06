Return-Path: <SRS0=sXPk=Z4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A708BC43603
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Dec 2019 21:03:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7886021835
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Dec 2019 21:03:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726330AbfLFVDB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 6 Dec 2019 16:03:01 -0500
Received: from fieldses.org ([173.255.197.46]:54200 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726325AbfLFVDB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 6 Dec 2019 16:03:01 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 067631C95; Fri,  6 Dec 2019 16:03:01 -0500 (EST)
Date:   Fri, 6 Dec 2019 16:03:00 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Patrick Steinhardt <ps@pks.im>
Cc:     linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2] nfsd: depend on CRYPTO_MD5 for legacy client tracking
Message-ID: <20191206210300.GA17524@fieldses.org>
References: <d411d31bcde3e0221d54ee8bb5af80772a277cad.1575355896.git.ps@pks.im>
 <7af3028bd374451f35e36a6c289c44d9c932ee71.1575439669.git.ps@pks.im>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7af3028bd374451f35e36a6c289c44d9c932ee71.1575439669.git.ps@pks.im>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks, applied your v2.

--b.

On Wed, Dec 04, 2019 at 07:13:22AM +0100, Patrick Steinhardt wrote:
> The legacy client tracking infrastructure of nfsd makes use of MD5 to
> derive a client's recovery directory name. As the nfsd module doesn't
> declare any dependency on CRYPTO_MD5, though, it may fail to allocate
> the hash if the kernel was compiled without it. As a result, generation
> of client recovery directories will fail with the following error:
> 
>     NFSD: unable to generate recoverydir name
> 
> The explicit dependency on CRYPTO_MD5 was removed as redundant back in
> 6aaa67b5f3b9 (NFSD: Remove redundant "select" clauses in fs/Kconfig
> 2008-02-11) as it was already implicitly selected via RPCSEC_GSS_KRB5.
> This broke when RPCSEC_GSS_KRB5 was made optional for NFSv4 in commit
> df486a25900f (NFS: Fix the selection of security flavours in Kconfig) at
> a later point.
> 
> Fix the issue by adding back an explicit dependency on CRYPTO_MD5.
> 
> Fixes: df486a25900f (NFS: Fix the selection of security flavours in Kconfig)
> Signed-off-by: Patrick Steinhardt <ps@pks.im>
> ---
> 
> The only change compared to v1 is in the commit message. As
> pointed out by Chuck, it wasn't actually commit 6aaa67b5f3b9
> which broke it, but the later df486a25900f. I've reworded the
> commit message and fixed the Fixes tag to account for that.
> 
>  fs/nfsd/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> index c4b1a89b8845..f2f81561ebb6 100644
> --- a/fs/nfsd/Kconfig
> +++ b/fs/nfsd/Kconfig
> @@ -73,6 +73,7 @@ config NFSD_V4
>  	select NFSD_V3
>  	select FS_POSIX_ACL
>  	select SUNRPC_GSS
> +	select CRYPTO_MD5
>  	select CRYPTO_SHA256
>  	select GRACE_PERIOD
>  	help
> -- 
> 2.24.0
