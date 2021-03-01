Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.8 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9C5EC433E6
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Mar 2021 13:32:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id BE80764E62
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Mar 2021 13:32:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235707AbhCANbx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 1 Mar 2021 08:31:53 -0500
Received: from us-smtp-delivery-124.mimecast.com ([170.10.133.124]:43814 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S235700AbhCANbu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Mar 2021 08:31:50 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1614605423;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=CrGiDuiEl2Ly6tBW0cAMgxIDaJs1D1fkCgNkCNLSH9U=;
        b=aMLKAnDXOqnOgsdNN0PfUu0i3WEJLjAL6sd2p88JVTF+dVu27ZrsSX8UkOFKqbW0kwE1Qx
        ytdo27zrPe4UjKez5FQbBo5uFTmwSsmeURFCCXRyTMVJRDoz5Q5bvHtXfmqbohMzJgipnh
        If7VWrDGZh07RN2akdisAa42+L5FjGE=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-42-DukgsvghNdWornkJcpJfMA-1; Mon, 01 Mar 2021 08:30:18 -0500
X-MC-Unique: DukgsvghNdWornkJcpJfMA-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 45440905416;
        Mon,  1 Mar 2021 13:29:58 +0000 (UTC)
Received: from firesoul.localdomain (unknown [10.40.208.7])
        by smtp.corp.redhat.com (Postfix) with ESMTP id DCCAE60C94;
        Mon,  1 Mar 2021 13:29:43 +0000 (UTC)
Received: from [192.168.42.3] (localhost [IPv6:::1])
        by firesoul.localdomain (Postfix) with ESMTP id B270E30736C73;
        Mon,  1 Mar 2021 14:29:42 +0100 (CET)
Subject: [PATCH RFC V2 net-next 0/2] Use bulk order-0 page allocator API for
 page_pool
From:   Jesper Dangaard Brouer <brouer@redhat.com>
To:     Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org
Cc:     Jesper Dangaard Brouer <brouer@redhat.com>, chuck.lever@oracle.com,
        netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date:   Mon, 01 Mar 2021 14:29:42 +0100
Message-ID: <161460522573.3031322.15721946341157092594.stgit@firesoul>
In-Reply-To: <20210224102603.19524-1-mgorman@techsingularity.net>
References: <20210224102603.19524-1-mgorman@techsingularity.net>
User-Agent: StGit/0.19
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This is a followup to Mel Gorman's patchset:
 - Message-Id: <20210224102603.19524-1-mgorman@techsingularity.net>
 - https://lore.kernel.org/netdev/20210224102603.19524-1-mgorman@techsingularity.net/

Showing page_pool usage of the API for alloc_pages_bulk().

Maybe Mel Gorman will/can carry these patches?
(to keep it together with the alloc_pages_bulk API)

---

Jesper Dangaard Brouer (2):
      net: page_pool: refactor dma_map into own function page_pool_dma_map
      net: page_pool: use alloc_pages_bulk in refill code path


 net/core/page_pool.c |  102 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 63 insertions(+), 39 deletions(-)

--

