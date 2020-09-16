Return-Path: <SRS0=3Pxj=CZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E354DC2BB84
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Sep 2020 20:13:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 952C421582
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Sep 2020 20:13:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600287185;
	bh=HJTHeTWn53Pu1Qt1ZPPIIpWjMROw4SxePoyDOc2+HWg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=TB7/Y3pN/jE6JQIPnFYyOYr6GGiccubGdlcQHu95+rrX7/W15x0WJ1bq56iEafYID
	 +Oyh//ppJ0Nw8zWkI45mxzvEpICMDknYvcKQcMAHsVJidpAScmHgE8Ty1OvcVZGY2U
	 R8Jw+mpsUBMci0S8gduiMaFEHQnAP6uUCLSFRB3Y=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727288AbgIPUNA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Sep 2020 16:13:00 -0400
Received: from mail.kernel.org ([198.145.29.99]:35138 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726361AbgIPUM5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 16 Sep 2020 16:12:57 -0400
Received: from embeddedor (187-162-31-110.static.axtel.net [187.162.31.110])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id D11BC20936;
        Wed, 16 Sep 2020 20:12:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600287177;
        bh=HJTHeTWn53Pu1Qt1ZPPIIpWjMROw4SxePoyDOc2+HWg=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=IPTBAYXvKLi5j5Lr9NCFHLo2ZiDYa718UzsZTwt31vgOEMk8/olInWW41FJDeIReZ
         dtBFsPzIJ4Q3YkVCfU2lZYOkLamVbqfq4ExmfKDQRUomeDFGoe/+L6dCaigt/Ksm2d
         KgXLgiET43dKAZoi6/y8Fw63CmTQrfoN6QTpbSvI=
Date:   Wed, 16 Sep 2020 15:18:27 -0500
From:   "Gustavo A. R. Silva" <gustavoars@kernel.org>
To:     Nick Desaulniers <ndesaulniers@google.com>
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "Gustavo A . R . Silva" <gustavo@embeddedor.com>,
        Joe Perches <joe@perches.com>,
        Nathan Chancellor <natechancellor@gmail.com>,
        Hongxiang Lou <louhongxiang@huawei.com>,
        Miaohe Lin <linmiaohe@huawei.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, clang-built-linux@googlegroups.com
Subject: Re: [PATCH v2] nfs: remove incorrect fallthrough label
Message-ID: <20200916201827.GA22908@embeddedor>
References: <9441ed0f247d0cac6e85f3847e1b4c32a199dd8f.camel@perches.com>
 <20200916200255.1382086-1-ndesaulniers@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200916200255.1382086-1-ndesaulniers@google.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Sep 16, 2020 at 01:02:55PM -0700, Nick Desaulniers wrote:
> There is no case after the default from which to fallthrough to. Clang
> will error in this case (unhelpfully without context, see link below)
> and GCC will with -Wswitch-unreachable.
> 
> The previous commit should have just replaced the comment with a break
> statement.
> 
> If we consider implicit fallthrough to be a design mistake of C, then
> all case statements should be terminated with one of the following
> statements:
> * break
> * continue
> * return
> * __attribute__(__fallthrough__)
> * goto (plz no)
> * (call of function with __attribute__(__noreturn__))
> 
> Fixes: 2a1390c95a69 ("nfs: Convert to use the preferred fallthrough macro")
> Link: https://bugs.llvm.org/show_bug.cgi?id=47539
> Suggested-by: Joe Perches <joe@perches.com>
> Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>

Acked-by: Gustavo A. R. Silva <gustavoars@kernel.org>
Reviewed-by: Gustavo A. R. Silva <gustavoars@kernel.org>

Thanks
--
Gustavo

> ---
> Changes v2:
> * add break rather than no terminating statement as per Joe.
> * add Joe's suggested by tag.
> * add blurb about acceptable terminal statements.
> 
>  fs/nfs/super.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index d20326ee0475..eb2401079b04 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -889,7 +889,7 @@ static struct nfs_server *nfs_try_mount_request(struct fs_context *fc)
>  		default:
>  			if (rpcauth_get_gssinfo(flavor, &info) != 0)
>  				continue;
> -			fallthrough;
> +			break;
>  		}
>  		dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", flavor);
>  		ctx->selected_flavor = flavor;
> -- 
> 2.28.0.618.gf4bc123cb7-goog
> 
