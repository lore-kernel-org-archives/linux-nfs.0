Return-Path: <SRS0=S9kK=CY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F419BC433E2
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Sep 2020 23:29:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B9E52208E4
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Sep 2020 23:29:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727176AbgIOX3p (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Sep 2020 19:29:45 -0400
Received: from smtprelay0240.hostedemail.com ([216.40.44.240]:41866 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1727391AbgIOX3p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2020 19:29:45 -0400
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay08.hostedemail.com (Postfix) with ESMTP id 1864E182CED28;
        Tue, 15 Sep 2020 23:29:44 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: kick55_460a4e627115
X-Filterd-Recvd-Size: 1859
Received: from XPS-9350.home (unknown [47.151.133.149])
        (Authenticated sender: joe@perches.com)
        by omf20.hostedemail.com (Postfix) with ESMTPA;
        Tue, 15 Sep 2020 23:29:42 +0000 (UTC)
Message-ID: <9441ed0f247d0cac6e85f3847e1b4c32a199dd8f.camel@perches.com>
Subject: Re: [PATCH] nfs: remove incorrect fallthrough label
From:   Joe Perches <joe@perches.com>
To:     Nick Desaulniers <ndesaulniers@google.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     "Gustavo A . R . Silva" <gustavo@embeddedor.com>,
        Nathan Chancellor <natechancellor@gmail.com>,
        Miaohe Lin <linmiaohe@huawei.com>,
        Hongxiang Lou <louhongxiang@huawei.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        clang-built-linux@googlegroups.com
Date:   Tue, 15 Sep 2020 16:29:41 -0700
In-Reply-To: <20200915225751.274531-1-ndesaulniers@google.com>
References: <20200915225751.274531-1-ndesaulniers@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.36.4-0ubuntu1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, 2020-09-15 at 15:57 -0700, Nick Desaulniers wrote:
> There is no case after the default from which to fallthrough to. Clang
> will error in this case (unhelpfully without context, see link below)
> and GCC will with -Wswitch-unreachable.
> 
> The previous commit should have just removed the comment.
[]
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
[]
> @@ -889,7 +889,6 @@ static struct nfs_server *nfs_try_mount_request(struct fs_context *fc)
>  		default:
>  			if (rpcauth_get_gssinfo(flavor, &info) != 0)
>  				continue;
> -			fallthrough;

My preference would be to convert the fallthrough
to a break here so if someone ever adds another
label after default: for any reason, the code would
still work as expected.

>  		}
> 

