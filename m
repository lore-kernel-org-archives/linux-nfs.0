Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58066C47083
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jun 2021 17:51:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 39F7061D9C
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jun 2021 17:51:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229752AbhFBRx1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jun 2021 13:53:27 -0400
Received: from us-smtp-delivery-124.mimecast.com ([170.10.133.124]:47917 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S229489AbhFBRx1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jun 2021 13:53:27 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1622656303;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding;
        bh=3f0wiwmHIsd3tCq2s+LcQbe7cmKqxxYZlobXuMianns=;
        b=YzCLaZoUnuPmt46DKgm9BCqfbA0V5eIl/svgTv5DoyXyWwb4XFd9akbVakeClYqEVYydZv
        ntestodX7WpvdJLmXRs8gv8MJnV1crazrsRfODG+7ovX7G+dDU22WGBAJTD+8z2YJlN3Ci
        WRG4zvXUh5lbT3QrRs8uRMu1s0L9X5g=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-528-NTZ0QVptNRiAQu6LzNWeNw-1; Wed, 02 Jun 2021 13:51:41 -0400
X-MC-Unique: NTZ0QVptNRiAQu6LzNWeNw-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 94A22801106;
        Wed,  2 Jun 2021 17:51:40 +0000 (UTC)
Received: from f34-node1.dwysocha.net (dhcp145-42.rdu.redhat.com [10.13.145.42])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 43C5460E3A;
        Wed,  2 Jun 2021 17:51:40 +0000 (UTC)
From:   Dave Wysochanski <dwysocha@redhat.com>
To:     Bruce Fields <bfields@fieldses.org>,
        Chuck Lever III <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/1] Add callback address and state to nfsd4 client info
Date:   Wed,  2 Jun 2021 13:51:38 -0400
Message-Id: <20210602175139.436357-1-dwysocha@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Changes since v2
- start with v1 patch
- fix case statement indents, run checkpatch (Chuck Lever)
- rename cb_state_str to cb_state2str

Dave Wysochanski (1):
  nfsd4: Expose the callback address and state of each NFS4 client

 fs/nfsd/nfs4state.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

-- 
2.31.1

