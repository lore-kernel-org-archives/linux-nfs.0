Return-Path: <SRS0=ZwDk=DB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9244FC4363D
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Sep 2020 18:07:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 3A0BA22208
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Sep 2020 18:07:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728592AbgIXSHz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 24 Sep 2020 14:07:55 -0400
Received: from smtprelay0224.hostedemail.com ([216.40.44.224]:60986 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1728577AbgIXSHz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2020 14:07:55 -0400
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay01.hostedemail.com (Postfix) with ESMTP id 4FBFD100E7B4A;
        Thu, 24 Sep 2020 18:07:54 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: flesh53_541162527161
X-Filterd-Recvd-Size: 2054
Received: from XPS-9350.home (unknown [47.151.133.149])
        (Authenticated sender: joe@perches.com)
        by omf03.hostedemail.com (Postfix) with ESMTPA;
        Thu, 24 Sep 2020 18:07:51 +0000 (UTC)
Message-ID: <734165bbee434a920f074940624bcef01fcd9d60.camel@perches.com>
Subject: Re: [PATCH v3] nfs: remove incorrect fallthrough label
From:   Joe Perches <joe@perches.com>
To:     Nick Desaulniers <ndesaulniers@google.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>
Cc:     "Gustavo A . R . Silva" <gustavo@embeddedor.com>,
        "Gustavo A . R . Silva" <gustavoars@kernel.org>,
        Miaohe Lin <linmiaohe@huawei.com>,
        Nathan Chancellor <natechancellor@gmail.com>,
        Hongxiang Lou <louhongxiang@huawei.com>,
        linux-nfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        clang-built-linux <clang-built-linux@googlegroups.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mark Brown <broonie@kernel.org>
Date:   Thu, 24 Sep 2020 11:07:50 -0700
In-Reply-To: <ca629208707903da56823dd57540d677df2da283.camel@perches.com>
References: <ce28bb9bc25cb3f1197f75950a0cfe14947f9002.camel@perches.com>
         <20200917214545.199463-1-ndesaulniers@google.com>
         <CAKwvOdnziDJbRAP77K+V885SCuORfV4SmHDnSLUxhUGSSLMq_Q@mail.gmail.com>
         <ca629208707903da56823dd57540d677df2da283.camel@perches.com>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.36.4-0ubuntu1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 2020-09-24 at 10:40 -0700, Joe Perches wrote:
> On Thu, 2020-09-24 at 10:19 -0700, Nick Desaulniers wrote:
> > Hello maintainers,
> > Would you mind please picking up this patch?  KernelCI has been
> > erroring for over a week without it.
> 
> As it's trivial and necessary, why not go through Linus directly?
[]
> Fixes: 2a1390c95a69 ("nfs: Convert to use the preferred fallthrough macro")

Real reason why not:

the commit to be fixed is not in Linus' tree.

> https://lore.kernel.org/patchwork/patch/1307549/


