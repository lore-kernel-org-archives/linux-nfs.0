Return-Path: <SRS0=L+CW=7D=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE167C433DF
	for <linux-nfs@archiver.kernel.org>; Thu, 21 May 2020 13:57:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D0D20206F6
	for <linux-nfs@archiver.kernel.org>; Thu, 21 May 2020 13:57:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729597AbgEUN52 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 May 2020 09:57:28 -0400
Received: from verein.lst.de ([213.95.11.211]:54753 "EHLO verein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728060AbgEUN52 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 May 2020 09:57:28 -0400
Received: by verein.lst.de (Postfix, from userid 2407)
        id 955B468BEB; Thu, 21 May 2020 15:57:23 +0200 (CEST)
Date:   Thu, 21 May 2020 15:57:23 +0200
From:   Christoph Hellwig <hch@lst.de>
To:     Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Cc:     Christoph Hellwig <hch@lst.de>, David Miller <davem@davemloft.net>,
        kuba@kernel.org, edumazet@google.com, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, vyasevich@gmail.com,
        nhorman@tuxdriver.com, jmaloy@redhat.com, ying.xue@windriver.com,
        drbd-dev@lists.linbit.com, linux-kernel@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-nvme@lists.infradead.org,
        target-devel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-cifs@vger.kernel.org, cluster-devel@redhat.com,
        ocfs2-devel@oss.oracle.com, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, ceph-devel@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 31/33] sctp: add sctp_sock_set_nodelay
Message-ID: <20200521135723.GA12368@lst.de>
References: <20200520195509.2215098-1-hch@lst.de> <20200520195509.2215098-32-hch@lst.de> <20200520231001.GU2491@localhost.localdomain> <20200520.162355.2212209708127373208.davem@davemloft.net> <20200520233913.GV2491@localhost.localdomain> <20200521083442.GA7771@lst.de> <20200521133348.GX2491@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200521133348.GX2491@localhost.localdomain>
User-Agent: Mutt/1.5.17 (2007-11-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, May 21, 2020 at 10:33:48AM -0300, Marcelo Ricardo Leitner wrote:
> With the patch there are now two ways of enabling nodelay.

There is exactly one way to do for user applications, and one way
for kernel drivers.  (actually they could just set the field directly,
which no one does for sctp, but for ipv4 a few do just that).
