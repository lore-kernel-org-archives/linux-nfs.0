Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58708 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726250AbeIZJgk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Sep 2018 05:36:40 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6E8D03DE35
        for <linux-nfs@vger.kernel.org>; Wed, 26 Sep 2018 03:25:55 +0000 (UTC)
From: Zhi Li <yieli@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com, Zhi Li <yieli@redhat.com>
Subject: [PATCH-V2] [libtirpc] getnetconfig.c: fix a BAD_FREE (CWE-763)
Date: Wed, 26 Sep 2018 11:25:51 +0800
Message-Id: <1537932352-19537-1-git-send-email-yieli@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Zhi Li <yieli@redhat.com>
---
