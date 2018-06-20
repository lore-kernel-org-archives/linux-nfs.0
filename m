Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:44798 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751422AbeFTMJr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Jun 2018 08:09:47 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.rdu2.redhat.com [10.11.54.4])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 38108402312B
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jun 2018 12:09:47 +0000 (UTC)
Message-ID: <1529496583.7473.8.camel@redhat.com>
Subject: [PATCH 0/5] nfs-utils: config value setting
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Wed, 20 Jun 2018 13:09:43 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As part of my ongoing efforts to improve storage management integration
with NFS I offer this support for setting configuration file values.

This code only updates a single config entry at a time, it attempts to
preserve the existing structure and style of the comments file, and
takes every precaution that the replacement file is written before using
rename(2) to replace the original.

The cli nfsconf tool is also updated to be the first consumer of this
functionality.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>


