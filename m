Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1456CC77B7E
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Jun 2023 19:47:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229781AbjFATrB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Jun 2023 15:47:01 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36174 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229651AbjFATrA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jun 2023 15:47:00 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4A37C18F
        for <linux-nfs@vger.kernel.org>; Thu,  1 Jun 2023 12:46:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1685648779;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding;
        bh=qy882A9HszTkqI39S5cagaiGzUiq/MUTSxzvjh9P2qY=;
        b=Ku9wDUv9Q9kfOsYt6Xa+dphN15T1ttbK0DaXrPXaEG6w4HRbqaA3uKl33ae7cFmbBzFFjm
        yYJir0QyXs8PO0j3S/C60q0+2rJBTk1ScDPmoS58ZzCWCVGj+rFbLod2+42S9ipl7j8bka
        n5n6bQ7AZX5/YpaA/GflazpwByXCyew=
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-135-Tc3IW27jNBaMWgO9keWlNg-1; Thu, 01 Jun 2023 15:46:17 -0400
X-MC-Unique: Tc3IW27jNBaMWgO9keWlNg-1
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 8018F8007D9
        for <linux-nfs@vger.kernel.org>; Thu,  1 Jun 2023 19:46:17 +0000 (UTC)
Received: from aion.usersys.redhat.com (unknown [10.22.32.208])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 71BBB2166B25;
        Thu,  1 Jun 2023 19:46:17 +0000 (UTC)
Received: by aion.usersys.redhat.com (Postfix, from userid 1000)
        id 12E061A27F5; Thu,  1 Jun 2023 15:46:17 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     steved@redhat.com
Cc:     linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 0/3] Add docs for some mount options missing from nfs(5)
Date:   Thu,  1 Jun 2023 15:46:14 -0400
Message-Id: <20230601194617.2174639-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.1 on 10.11.54.6
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Scott Mayhew (3):
  nfs(5): Document the softerr mount option.
  nfs(5): Document the write=lazy|eager|wait mount option.
  nfs(5): Document the trunkdiscovery/notrunkdiscovery mount option.

 utils/mount/nfs.man | 84 +++++++++++++++++++++++++++++++++------------
 1 file changed, 63 insertions(+), 21 deletions(-)

-- 
2.39.2

