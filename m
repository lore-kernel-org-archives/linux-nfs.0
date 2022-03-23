Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F275EC433EF
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Mar 2022 20:19:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S239639AbiCWUUd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Mar 2022 16:20:33 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50150 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230070AbiCWUUb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2022 16:20:31 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTP id 4D5751CB3A
        for <linux-nfs@vger.kernel.org>; Wed, 23 Mar 2022 13:18:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1648066736;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding;
        bh=r9DM7KdeBVmGdNxX9PfXT/9FIxRf1UEJk03YmRqY/R8=;
        b=ZLbVAQGhuFvnE9V3UWjwzPfTzL0HVYMTQfPBRjKpz0OOvcvHvX8FrKwe+aTkq3EjJmrEW1
        l5IsFtn1H7EAwGtVkYXM39O7cyOCTsjVzB8UQ4JE1ndlR/vCkN/tqzP4gKOdHkEqMC04Hp
        LwFJY5dZN/FSapGJfE58bTAVrPIXiJA=
Received: from mimecast-mx02.redhat.com (mx3-rdu2.redhat.com
 [66.187.233.73]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 us-mta-22-8xJWh2b6Ou-arjZEZZFDuw-1; Wed, 23 Mar 2022 16:18:54 -0400
X-MC-Unique: 8xJWh2b6Ou-arjZEZZFDuw-1
Received: from smtp.corp.redhat.com (int-mx10.intmail.prod.int.rdu2.redhat.com [10.11.54.10])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 6C69E2800F60;
        Wed, 23 Mar 2022 20:18:54 +0000 (UTC)
Received: from nyarly.redhat.com (ovpn-116-121.gru2.redhat.com [10.97.116.121])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id D49CD401E2A;
        Wed, 23 Mar 2022 20:18:50 +0000 (UTC)
From:   Thiago Becker <tbecker@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     steved@redhat.com, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, kolga@netapp.com,
        Thiago Becker <tbecker@redhat.com>
Subject: [PATCH RFC v3 0/6] Intruduce nfsrahead
Date:   Wed, 23 Mar 2022 17:18:35 -0300
Message-Id: <20220323201841.4166549-1-tbecker@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.85 on 10.11.54.10
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Recent changes in the linux kernel caused NFS readahead to default to
128 from the previous default of 15 * rsize. This causes performance
penalties to some read-heavy workloads, which can be fixed by
tuning the readahead for that given mount.

Specifically, the read troughput on a sec=krb5p mount drops by 50-75%
when comparing the default readahead with a readahead of 15360.

Previous discussions:
https://lore.kernel.org/linux-nfs/20210803130717.2890565-1-trbecker@gmail.com/
I attempted to add a non-kernel option to mount.nfs, and it was
rejected.

https://lore.kernel.org/linux-nfs/20210811171402.947156-1-trbecker@gmail.com/
Attempted to add a mount option to the kernel, rejected as well.

I had started a separate tool to set the readahead of BDIs, but the
scope is specifically for NFS, so I would like to get the community
feeling for having this in nfs-utils.

This patch series introduces nfs-readahead-udev, a utility to
automatically set NFS readahead when NFS is mounted. The utility is
triggered by udev when a new BDI is added, returns to udev the value of
the readahead that should be used.

The tool currently supports setting read ahead per mountpoint, nfs major
version, or by a global default value.

v2:
    - explain the motivation

v3:
    - adopt already available facilities
    - nfsrahead is now configured in nfs.conf

Thiago Becker (6):
  Create nfsrahead
  nfsrahead: configure udev
  nfsrahead: only set readahead for nfs devices.
  nfsrahead: add logging
  hfsrahead: get the information from the config file.
  nfsrahead: User documentation

 .gitignore                          |   2 +
 configure.ac                        |   1 +
 systemd/nfs.conf.man                |  11 ++
 tools/Makefile.am                   |   2 +-
 tools/nfsrahead/99-nfs_bdi.rules.in |   1 +
 tools/nfsrahead/Makefile.am         |  15 +++
 tools/nfsrahead/main.c              | 179 ++++++++++++++++++++++++++++
 tools/nfsrahead/nfsrahead.man       |  72 +++++++++++
 8 files changed, 282 insertions(+), 1 deletion(-)
 create mode 100644 tools/nfsrahead/99-nfs_bdi.rules.in
 create mode 100644 tools/nfsrahead/Makefile.am
 create mode 100644 tools/nfsrahead/main.c
 create mode 100644 tools/nfsrahead/nfsrahead.man

-- 
2.35.1

