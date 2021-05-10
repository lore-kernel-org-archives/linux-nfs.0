Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.9 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 414EDC433ED
	for <linux-nfs@archiver.kernel.org>; Mon, 10 May 2021 17:37:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 128776146E
	for <linux-nfs@archiver.kernel.org>; Mon, 10 May 2021 17:37:16 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231638AbhEJRiT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 May 2021 13:38:19 -0400
Received: from us-smtp-delivery-124.mimecast.com ([170.10.133.124]:25873 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S231749AbhEJRiT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 May 2021 13:38:19 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1620668233;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding;
        bh=Sm1pkQ7WXXdYnA7F0baYBQ4U5HDxkf+ESKZAu3JqiJE=;
        b=f3CWYcDzZ/zzDnPPcdd8Qrdlu5IQj5e0g2eoGckjk9+Kt7F8Sz5zF5mK4unyPyWYnVYeZw
        RUqkaaf2FO4Ck7hBLFd7hiJ06ftIRj//GP336OLRpFjiURVXUuk6QHI3X/on6Wx0+VblJZ
        0VpV6JJdE0uZ+wZeWPz8OKytRkjhRRw=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-576-jzJryW2YNWmlv9No0_Pi5A-1; Mon, 10 May 2021 13:37:11 -0400
X-MC-Unique: jzJryW2YNWmlv9No0_Pi5A-1
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 86F2B107ACC7;
        Mon, 10 May 2021 17:37:10 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-112-61.phx2.redhat.com [10.3.112.61])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 3E8685D6D1;
        Mon, 10 May 2021 17:37:10 +0000 (UTC)
From:   Steve Dickson <SteveD@RedHat.com>
Subject: ANNOUNCE: rpcbind-1.2.6 released.
To:     libtirpc <libtirpc-devel@lists.sourceforge.net>
Cc:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <46244710-44ac-8979-3c2a-3413cee359cf@RedHat.com>
Date:   Mon, 10 May 2021 13:39:37 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.8.1
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This is basically baseline release... 
to clean up some old bugs and configuration changes

See the 1.2.6-ChangeLog for more details.  

Both the tarball and change log can be found at
  http://sourceforge.net/projects/rpcbind

The git tree was moved to:
   git://linux-nfs.org/~steved/rpcbind.git

Please send comments/bugs to linux-nfs@vger.kernel.org and/or
libtirpc-devel@lists.sourceforge.net

steved.

