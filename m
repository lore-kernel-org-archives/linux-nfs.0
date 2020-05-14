Return-Path: <SRS0=i0EC=64=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FF14C433DF
	for <linux-nfs@archiver.kernel.org>; Thu, 14 May 2020 11:51:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 32F70206DA
	for <linux-nfs@archiver.kernel.org>; Thu, 14 May 2020 11:51:42 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727785AbgENLvf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 May 2020 07:51:35 -0400
Received: from smtprelay0155.hostedemail.com ([216.40.44.155]:44686 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1725955AbgENLve (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 May 2020 07:51:34 -0400
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay02.hostedemail.com (Postfix) with ESMTP id 82BDA2C1F;
        Thu, 14 May 2020 11:51:31 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: soup46_cc3a3aa2090a
X-Filterd-Recvd-Size: 2294
Received: from XPS-9350.home (unknown [47.151.136.130])
        (Authenticated sender: joe@perches.com)
        by omf01.hostedemail.com (Postfix) with ESMTPA;
        Thu, 14 May 2020 11:51:27 +0000 (UTC)
Message-ID: <9992a1fe768a0b1e9bb9470d2728ba25dbe042db.camel@perches.com>
Subject: Re: [PATCH 20/33] ipv4: add ip_sock_set_recverr
From:   Joe Perches <joe@perches.com>
To:     Christoph Hellwig <hch@lst.de>
Cc:     "David S. Miller" <davem@davemloft.net>,
        Jakub Kicinski <kuba@kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Jon Maloy <jmaloy@redhat.com>,
        Ying Xue <ying.xue@windriver.com>, drbd-dev@lists.linbit.com,
        linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-nvme@lists.infradead.org,
        target-devel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-cifs@vger.kernel.org, cluster-devel@redhat.com,
        ocfs2-devel@oss.oracle.com, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, ceph-devel@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-nfs@vger.kernel.org
Date:   Thu, 14 May 2020 04:51:26 -0700
In-Reply-To: <20200514103025.GB12680@lst.de>
References: <20200513062649.2100053-1-hch@lst.de>
         <20200513062649.2100053-21-hch@lst.de>
         <0ee5acfaca4cf32d4efad162046b858981a4dae3.camel@perches.com>
         <20200514103025.GB12680@lst.de>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.36.1-2 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 2020-05-14 at 12:30 +0200, Christoph Hellwig wrote:
> On Wed, May 13, 2020 at 02:00:43PM -0700, Joe Perches wrote:
> > On Wed, 2020-05-13 at 08:26 +0200, Christoph Hellwig wrote:
> > > Add a helper to directly set the IP_RECVERR sockopt from kernel space
> > > without going through a fake uaccess.
> > 
> > This seems used only with true as the second arg.
> > Is there reason to have that argument at all?
> 
> Mostly to keep it symmetric with the sockopt.  I could probably remove
> a few arguments in the series if we want to be strict.

My preference would use strict and add
arguments only when necessary.


