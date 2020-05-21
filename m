Return-Path: <SRS0=L+CW=7D=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3433BC433E0
	for <linux-nfs@archiver.kernel.org>; Thu, 21 May 2020 07:44:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 066B52065F
	for <linux-nfs@archiver.kernel.org>; Thu, 21 May 2020 07:44:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="cZ+tiaDt"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728358AbgEUHoa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 May 2020 03:44:30 -0400
Received: from us-smtp-2.mimecast.com ([205.139.110.61]:55663 "EHLO
        us-smtp-delivery-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1728354AbgEUHo3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 May 2020 03:44:29 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1590047068;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=E3GyhKojXVNo0Mooki74/Av48EK9IfzgPCl8v5tu8BM=;
        b=cZ+tiaDt2SKjgkJKzVGaJpahOhaB2+9+m8AvgTpIys60nCSEPq011FK1Ik6rsBxau9IfEG
        4YFpSVruaTCTTsHiqZ1vPZ7+/8bLWUuDQMvO5466oY0G2eSOO7A6hKW/LPUw/V0JFtq62M
        U1FlTHCRFbujDth6rBK+PLPlzIVSJqs=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-290-M92JCxb1Oi-ciaPgtC3hqA-1; Thu, 21 May 2020 03:44:24 -0400
X-MC-Unique: M92JCxb1Oi-ciaPgtC3hqA-1
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 6D59A835B42;
        Thu, 21 May 2020 07:44:20 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-112-138.rdu2.redhat.com [10.10.112.138])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 1D7135C1B0;
        Thu, 21 May 2020 07:44:11 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
From:   David Howells <dhowells@redhat.com>
In-Reply-To: <20200520195509.2215098-30-hch@lst.de>
References: <20200520195509.2215098-30-hch@lst.de> <20200520195509.2215098-1-hch@lst.de>
To:     Christoph Hellwig <hch@lst.de>
Cc:     dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
        Jakub Kicinski <kuba@kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        linux-nvme@lists.infradead.org, linux-sctp@vger.kernel.org,
        target-devel@vger.kernel.org, linux-afs@lists.infradead.org,
        drbd-dev@lists.linbit.com, linux-cifs@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-rdma@vger.kernel.org,
        cluster-devel@redhat.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        ceph-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        linux-kernel@vger.kernel.org, Jon Maloy <jmaloy@redhat.com>,
        Ying Xue <ying.xue@windriver.com>, ocfs2-devel@oss.oracle.com
Subject: Re: [PATCH 29/33] rxrpc: add rxrpc_sock_set_min_security_level
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <71190.1590047051.1@warthog.procyon.org.uk>
Date:   Thu, 21 May 2020 08:44:11 +0100
Message-ID: <71191.1590047051@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Christoph Hellwig <hch@lst.de> wrote:

> Add a helper to directly set the RXRPC_MIN_SECURITY_LEVEL sockopt from
> kernel space without going through a fake uaccess.
> 
> Thanks to David Howells for the documentation updates.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: David Howells <dhowells@redhat.com>

