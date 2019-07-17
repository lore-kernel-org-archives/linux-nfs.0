Return-Path: <SRS0=1lTg=VO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2D9DC76192
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Jul 2019 19:04:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A6A7621849
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Jul 2019 19:04:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726085AbfGQTEI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 17 Jul 2019 15:04:08 -0400
Received: from shards.monkeyblade.net ([23.128.96.9]:40914 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725993AbfGQTEI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jul 2019 15:04:08 -0400
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::d71])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 3C8161475AE87;
        Wed, 17 Jul 2019 12:04:07 -0700 (PDT)
Date:   Wed, 17 Jul 2019 12:04:06 -0700 (PDT)
Message-Id: <20190717.120406.1122378175032864724.davem@davemloft.net>
To:     pablo@netfilter.org
Cc:     adobriyan@gmail.com, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        kadlec@netfilter.org, fw@strlen.de, bfields@fieldses.org,
        chuck.lever@oracle.com
Subject: Re: [PATCH 2/2] net: apply proc_net_mkdir() harder
From:   David Miller <davem@davemloft.net>
In-Reply-To: <20190716185220.hnlyiievuucdtn7x@salvia>
References: <20190706165521.GB10550@avx2>
        <20190716185220.hnlyiievuucdtn7x@salvia>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Wed, 17 Jul 2019 12:04:07 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 16 Jul 2019 20:52:20 +0200

> On Sat, Jul 06, 2019 at 07:55:21PM +0300, Alexey Dobriyan wrote:
>> From: "Hallsmark, Per" <Per.Hallsmark@windriver.com>
>> 
>> proc_net_mkdir() should be used to create stuff under /proc/net,
>> so that dentry revalidation kicks in.
>> 
>> See
>> 
>> 	commit 1fde6f21d90f8ba5da3cb9c54ca991ed72696c43
>> 	proc: fix /proc/net/* after setns(2)
>> 
>> 	[added more chunks --adobriyan]
> 
> I don't find this in the tree,

Because there were changes requested.

