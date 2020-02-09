Return-Path: <SRS0=42je=35=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DD8AC35250
	for <linux-nfs@archiver.kernel.org>; Sun,  9 Feb 2020 12:11:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D638F2080C
	for <linux-nfs@archiver.kernel.org>; Sun,  9 Feb 2020 12:11:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Ra2czyPz"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727695AbgBIMLK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 9 Feb 2020 07:11:10 -0500
Received: from us-smtp-1.mimecast.com ([207.211.31.81]:46510 "EHLO
        us-smtp-delivery-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1727340AbgBIMLK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Feb 2020 07:11:10 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1581250269;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding;
        bh=HDb4ELOWsxX4YZ3C08sivI7+AKsg7J2RPHSD7L3ekKc=;
        b=Ra2czyPzxdsa9YKFgjQ9BKqwB8AxrUKulUtoP5I2sJgqvLSveiKj0f3XOUCote160/Nc0r
        n9v93pnb9U2KxWinEavF36chpMSUvf8moLwN9M/Z4g1b+R+YNsQ4DkZQDsLK4fnC8tillY
        bsM8DzOlPJ2kwyYouskiaGceFEJp9EA=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-187-4b7fyvK9NuikpKCYaL3MAg-1; Sun, 09 Feb 2020 07:11:04 -0500
X-MC-Unique: 4b7fyvK9NuikpKCYaL3MAg-1
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id D9D4E13E5
        for <linux-nfs@vger.kernel.org>; Sun,  9 Feb 2020 12:11:03 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.76.1.7])
        by smtp.corp.redhat.com (Postfix) with ESMTP id D8E877FB60;
        Sun,  9 Feb 2020 12:11:02 +0000 (UTC)
From:   Kenneth D'souza <kdsouza@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     steved@redhat.com
Subject: [PATCH] mountstats.man: Fix a typo in man page.
Date:   Sun,  9 Feb 2020 17:40:59 +0530
Message-Id: <20200209121059.19048-1-kdsouza@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
---
 tools/mountstats/mountstats.man | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/mountstats/mountstats.man b/tools/mountstats/mountstat=
s.man
index ff2f8ba3..d5595fc7 100644
--- a/tools/mountstats/mountstats.man
+++ b/tools/mountstats/mountstats.man
@@ -35,7 +35,7 @@ mountstats \- Displays various NFS client per-mount sta=
tistics
 .RI [ count ]
 .RI [ mountpoint ] ...
 .P
-.B mounstats nfsstat
+.B mountstats nfsstat
 .RB [ \-h | \-\-help ]
 .RB [ \-v | \-\-version ]
 .RB [ \-f | \-\-file
--=20
2.21.1

