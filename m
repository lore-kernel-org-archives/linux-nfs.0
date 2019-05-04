Return-Path: <SRS0=DkbA=TE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2C25C43219
	for <linux-nfs@archiver.kernel.org>; Sat,  4 May 2019 04:10:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B209C206DF
	for <linux-nfs@archiver.kernel.org>; Sat,  4 May 2019 04:10:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725801AbfEDEKs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 4 May 2019 00:10:48 -0400
Received: from shards.monkeyblade.net ([23.128.96.9]:55786 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725796AbfEDEKs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 4 May 2019 00:10:48 -0400
Received: from localhost (unknown [75.104.87.19])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 0F1A014D84551;
        Fri,  3 May 2019 21:10:29 -0700 (PDT)
Date:   Sat, 04 May 2019 00:10:25 -0400 (EDT)
Message-Id: <20190504.001025.1191902881190952783.davem@davemloft.net>
To:     wenbin.zeng@gmail.com
Cc:     viro@zeniv.linux.org.uk, bfields@fieldses.org, jlayton@kernel.org,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        wenbinzeng@tencent.com, dsahern@gmail.com,
        nicolas.dichtel@6wind.com, willy@infradead.org,
        edumazet@google.com, jakub.kicinski@netronome.com,
        tyhicks@canonical.com, chuck.lever@oracle.com, neilb@suse.com,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] netns: add netns_evict into netns_operations
From:   David Miller <davem@davemloft.net>
In-Reply-To: <1556692945-3996-3-git-send-email-wenbinzeng@tencent.com>
References: <1556692945-3996-1-git-send-email-wenbinzeng@tencent.com>
        <1556692945-3996-3-git-send-email-wenbinzeng@tencent.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Fri, 03 May 2019 21:10:47 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Wenbin Zeng <wenbin.zeng@gmail.com>
Date: Wed,  1 May 2019 14:42:24 +0800

> The newly added netns_evict() shall be called when the netns inode being
> evicted. It provides another path to release netns refcounts, previously
> netns_put() is the only choice, but it is not able to release all netns
> refcount, for example, a rpc client holds two netns refcounts, these
> refcounts are supposed to be released when the rpc client is freed, but
> the code to free rpc client is normally triggered by put() callback only
> when netns refcount gets to 0, specifically:
>     refcount=0 -> cleanup_net() -> ops_exit_list -> free rpc client
> But netns refcount will never get to 0 before rpc client gets freed, to
> break the deadlock, the code to free rpc client can be put into the newly
> added netns_evict.
> 
> Signed-off-by: Wenbin Zeng <wenbinzeng@tencent.com>

Acked-by: David S. Miller <davem@davemloft.net>
