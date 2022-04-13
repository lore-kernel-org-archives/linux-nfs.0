Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F5A1C433EF
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Apr 2022 13:32:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234057AbiDMNfC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 Apr 2022 09:35:02 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:44694 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233587AbiDMNfC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Apr 2022 09:35:02 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTP id 379D95D5F1
        for <linux-nfs@vger.kernel.org>; Wed, 13 Apr 2022 06:32:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1649856760;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:content-type:content-type;
        bh=QOJfmSn0xFjav4bRpembNH2O8F44yNE+X3MVGo4gMgI=;
        b=VMO9uLoLl5M+ZnAsxYYfOs5U0M51hfJJcZ3M9oaQdg8YL7qbkEWzHbFrM9W2/Rg+W/O8iB
        /aCk0vGpJiiAwUN280/LA6cXOJA/Nurd/0gsVdNybBsiXyCvWSnxVwZfxMOqdh6wBiJ3IS
        8n61zkaI9AOV05lZbTouqcABzRI3F2E=
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-178-bys5NBM3OliHpiR_xy9imQ-1; Wed, 13 Apr 2022 09:32:38 -0400
X-MC-Unique: bys5NBM3OliHpiR_xy9imQ-1
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 9C64C803B22
        for <linux-nfs@vger.kernel.org>; Wed, 13 Apr 2022 13:32:38 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-64-66.rdu2.redhat.com [10.10.64.66])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 8B3BE9D4C
        for <linux-nfs@vger.kernel.org>; Wed, 13 Apr 2022 13:32:38 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     linux-nfs <linux-nfs@vger.kernel.org>
Subject: Patches from the list with Content-Type: application/octet-stream
Date:   Wed, 13 Apr 2022 09:32:37 -0400
Message-ID: <1EBC0B18-2233-4467-89E7-4351B4047E95@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.11.54.5
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Anyone know why the linux-nfs list is setting

Content-Type: application/octet-stream

mail header for patches?  It seems to have started sometime last week, and
makes it difficult for me to quickly read patches.

Ben

