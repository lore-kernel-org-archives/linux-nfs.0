Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CDC2C4338F
	for <linux-nfs@archiver.kernel.org>; Sun,  1 Aug 2021 10:42:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 14CFE610A2
	for <linux-nfs@archiver.kernel.org>; Sun,  1 Aug 2021 10:42:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231645AbhHAKmW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 1 Aug 2021 06:42:22 -0400
Received: from out20-98.mail.aliyun.com ([115.124.20.98]:40906 "EHLO
        out20-98.mail.aliyun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231518AbhHAKmV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Aug 2021 06:42:21 -0400
X-Alimail-AntiSpam: AC=CONTINUE;BC=0.07972568|-1;CH=green;DM=|CONTINUE|false|;DS=CONTINUE|ham_system_inform|0.0544785-0.000554709-0.944967;FP=0|0|0|0|0|-1|-1|-1;HT=ay29a033018047203;MF=guan@eryu.me;NM=1;PH=DS;RN=3;RT=3;SR=0;TI=SMTPD_---.Ktose30_1627814532;
Received: from localhost(mailfrom:guan@eryu.me fp:SMTPD_---.Ktose30_1627814532)
          by smtp.aliyun-inc.com(10.147.43.230);
          Sun, 01 Aug 2021 18:42:12 +0800
Date:   Sun, 1 Aug 2021 18:42:11 +0800
From:   Eryu Guan <guan@eryu.me>
To:     Jeffle Xu <jefflexu@linux.alibaba.com>
Cc:     fstests@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] common/rc: only force nfs4.2 non-default SEEK_HOLE
 behaviour
Message-ID: <YQZ6g6ZszcMzVlt4@desktop>
References: <20210729044758.63219-1-jefflexu@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210729044758.63219-1-jefflexu@linux.alibaba.com>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

[cc nfs list]

On Thu, Jul 29, 2021 at 12:47:58PM +0800, Jeffle Xu wrote:
> Only NFSv4.2 supports non-defautl SEEK_HOLE behaviour. Thus default
> SEEK_HOLE behaviour shall be allowed for NFSv4.0/4.1, or it will fail
> generic/285, generic/448, generic/490 on NFSv4.0/4.1, complaining they
> should support non-default SEEK_HOLE behaviour.
> 
> The *.full log is like:
> 	File system supports the default behavior.
> 	Default behavior is not allowed. Aborting.
> 
> Signed-off-by: Jeffle Xu <jefflexu@linux.alibaba.com>

Looks correct to me, but I'd like nfs folks to take a look as well, to
conform if only nfsv4.2 supports SEEK_DATA/SEEK_HOLE non-default
behavior.

Thanks,
Eryu

P.S.
Please cc the corresponding filesystem list next time if patch affects
the specific fs.

> ---
>  common/rc | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/common/rc b/common/rc
> index 25a838a3..9be6f89d 100644
> --- a/common/rc
> +++ b/common/rc
> @@ -2495,10 +2495,10 @@ _fstyp_has_non_default_seek_data_hole()
>  		return 0
>  		;;
>  	nfs*)
> -		# NFSv2 and NFSv3 only support default behavior of SEEK_HOLE,
> -		# while NFSv4 supports non-default behavior
> -		local nfsvers=`_df_device $TEST_DEV | $AWK_PROG '{ print $2 }'`
> -		[ "$nfsvers" = "nfs4" ]
> +		# NFSv2, NFSv3, and NFSv4.0/4.1 only support default behavior of SEEK_HOLE,
> +		# while NFSv4.2 supports non-default behavior
> +		local nfsvers=`_mount() | grep $TEST_DEV | sed -n 's/^.*vers=\([0-9.]*\).*$/\1/p'`
> +		[ "$nfsvers" = "4.2" ]
>  		return $?
>  		;;
>  	overlay)
> -- 
> 2.27.0
