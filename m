Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EE1AC77B73
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Apr 2023 02:05:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229461AbjDQCFU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 16 Apr 2023 22:05:20 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:41274 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229588AbjDQCFT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Apr 2023 22:05:19 -0400
Received: from out28-82.mail.aliyun.com (out28-82.mail.aliyun.com [115.124.28.82])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 157D12132
        for <linux-nfs@vger.kernel.org>; Sun, 16 Apr 2023 19:05:17 -0700 (PDT)
X-Alimail-AntiSpam: AC=CONTINUE;BC=0.1613221|-1;CH=green;DM=|CONTINUE|false|;DS=CONTINUE|ham_regular_dialog|0.0277373-0.000616635-0.971646;FP=0|0|0|0|0|-1|-1|-1;HT=ay29a033018047208;MF=wangyugui@e16-tech.com;NM=1;PH=DS;RN=6;RT=6;SR=0;TI=SMTPD_---.SHuJhJS_1681697111;
Received: from 192.168.2.112(mailfrom:wangyugui@e16-tech.com fp:SMTPD_---.SHuJhJS_1681697111)
          by smtp.aliyun-inc.com;
          Mon, 17 Apr 2023 10:05:12 +0800
Date:   Mon, 17 Apr 2023 10:05:12 +0800
From:   Wang Yugui <wangyugui@e16-tech.com>
To:     "NeilBrown" <neilb@suse.de>
Subject: Re: [PATCH nfs-utils] mountd: don't advertise krb5 for v4root when not configured.
Cc:     Steve Dickson <steved@redhat.com>, Petr Vorel <pvorel@suse.cz>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Dave Jones <davej@codemonkey.org.uk>, bfields@redhat.com
In-Reply-To: <168169080542.24821.1095959058130927513@noble.neil.brown.name>
References: <168169080542.24821.1095959058130927513@noble.neil.brown.name>
Message-Id: <20230417100511.9131.409509F4@e16-tech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Mailer: Becky! ver. 2.81.04 [en]
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

> 
> If /etc/krb5.keytab does not exist, then krb5 cannot work, so
> advertising it as an option for v4root is pointless.
> Since linux commit 676e4ebd5f2c ("NFSD: SECINFO doesn't handle
> unsupported pseudoflavors correctly") this can result in an unhelpful
> warning if the krb5 code is not built, or built as a module which is not
> installed.
> 
> [  161.668635] NFS: SECINFO: security flavor 390003 is not supported
> [  161.668655] NFS: SECINFO: security flavor 390004 is not supported
> [  161.668670] NFS: SECINFO: security flavor 390005 is not supported
> 
> So avoid advertising krb5 security options when krb5.keytab cannot be
> found.
> 
> Link: https://lore.kernel.org/linux-nfs/20170104190327.v3wbpcbqtfa5jy7d@codemonkey.org.uk/
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  support/export/v4root.c         |  2 ++
>  support/include/pseudoflavors.h |  1 +
>  support/nfs/exports.c           | 14 +++++++-------
>  3 files changed, 10 insertions(+), 7 deletions(-)
> 
> diff --git a/support/export/v4root.c b/support/export/v4root.c
> index fbb0ad5f5b81..3e049582d7c1 100644
> --- a/support/export/v4root.c
> +++ b/support/export/v4root.c
> @@ -66,6 +66,8 @@ set_pseudofs_security(struct exportent *pseudo)
>  
>  		if (!flav->fnum)
>  			continue;
> +		if (flav->need_krb5 && !access("/etc/krb5.keytab", F_OK))
> +			continue;

Could we replace "/etc/krb5.keytab" with krb5_kt_default_name()?

Best Regards
Wang Yugui (wangyugui@e16-tech.com)
2023/04/17


