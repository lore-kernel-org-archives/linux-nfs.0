Return-Path: <SRS0=uryC=7C=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 183D2C433DF
	for <linux-nfs@archiver.kernel.org>; Wed, 20 May 2020 23:24:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E5E042070A
	for <linux-nfs@archiver.kernel.org>; Wed, 20 May 2020 23:24:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728697AbgETXYD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 May 2020 19:24:03 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:55346 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728462AbgETXYD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2020 19:24:03 -0400
Received: from shards.monkeyblade.net (shards.monkeyblade.net [IPv6:2620:137:e000::1:9])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0CA3BC061A0E;
        Wed, 20 May 2020 16:24:03 -0700 (PDT)
Received: from localhost (unknown [IPv6:2601:601:9f00:477:9e51:a893:b0fe:602a])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 9CDFF12728305;
        Wed, 20 May 2020 16:23:58 -0700 (PDT)
Date:   Wed, 20 May 2020 16:23:55 -0700 (PDT)
Message-Id: <20200520.162355.2212209708127373208.davem@davemloft.net>
To:     marcelo.leitner@gmail.com
Cc:     hch@lst.de, kuba@kernel.org, edumazet@google.com,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, vyasevich@gmail.com,
        nhorman@tuxdriver.com, jmaloy@redhat.com, ying.xue@windriver.com,
        drbd-dev@lists.linbit.com, linux-kernel@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-nvme@lists.infradead.org,
        target-devel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-cifs@vger.kernel.org, cluster-devel@redhat.com,
        ocfs2-devel@oss.oracle.com, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, ceph-devel@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 31/33] sctp: add sctp_sock_set_nodelay
From:   David Miller <davem@davemloft.net>
In-Reply-To: <20200520231001.GU2491@localhost.localdomain>
References: <20200520195509.2215098-1-hch@lst.de>
        <20200520195509.2215098-32-hch@lst.de>
        <20200520231001.GU2491@localhost.localdomain>
X-Mailer: Mew version 6.8 on Emacs 26.3
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Wed, 20 May 2020 16:23:59 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Wed, 20 May 2020 20:10:01 -0300

> The duplication with sctp_setsockopt_nodelay() is quite silly/bad.
> Also, why have the 'true' hardcoded? It's what dlm uses, yes, but the
> API could be a bit more complete than that.

The APIs are being designed based upon what in-tree users actually
make use of.  We can expand things later if necessary.
