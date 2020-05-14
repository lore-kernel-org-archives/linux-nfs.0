Return-Path: <SRS0=i0EC=64=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FB93C433E1
	for <linux-nfs@archiver.kernel.org>; Thu, 14 May 2020 06:26:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 359DA206B6
	for <linux-nfs@archiver.kernel.org>; Thu, 14 May 2020 06:26:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726066AbgENG02 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 May 2020 02:26:28 -0400
Received: from verein.lst.de ([213.95.11.211]:50202 "EHLO verein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725818AbgENG01 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 May 2020 02:26:27 -0400
Received: by verein.lst.de (Postfix, from userid 2407)
        id 8B05468B05; Thu, 14 May 2020 08:26:22 +0200 (CEST)
Date:   Thu, 14 May 2020 08:26:22 +0200
From:   Christoph Hellwig <hch@lst.de>
To:     David Howells <dhowells@redhat.com>
Cc:     Christoph Hellwig <hch@lst.de>,
        "David S. Miller" <davem@davemloft.net>,
        Jakub Kicinski <kuba@kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        linux-nvme@lists.infradead.org, linux-sctp@vger.kernel.org,
        target-devel@vger.kernel.org, linux-afs@lists.infradead.org,
        drbd-dev@lists.linbit.com, linux-cifs@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-rdma@vger.kernel.org,
        cluster-devel@redhat.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        linux-block@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        linux-kernel@vger.kernel.org, Jon Maloy <jmaloy@redhat.com>,
        Ying Xue <ying.xue@windriver.com>, ocfs2-devel@oss.oracle.com
Subject: Re: [PATCH 21/33] ipv4: add ip_sock_set_mtu_discover
Message-ID: <20200514062622.GA8564@lst.de>
References: <20200513062649.2100053-22-hch@lst.de> <20200513062649.2100053-1-hch@lst.de> <3123898.1589375861@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3123898.1589375861@warthog.procyon.org.uk>
User-Agent: Mutt/1.5.17 (2007-11-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, May 13, 2020 at 02:17:41PM +0100, David Howells wrote:
> Christoph Hellwig <hch@lst.de> wrote:
> 
> > +		ip_sock_set_mtu_discover(conn->params.local->socket->sk,
> > +				IP_PMTUDISC_DONT);
> 
> Um... The socket in question could be an AF_INET6 socket, not an AF_INET4
> socket - I presume it will work in that case.  If so:

Yes, the implementation of that sockopt, including the inet_sock
structure where these options are set is shared between ipv4 and ipv6.
