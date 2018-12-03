Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B424EC04EB8
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:59:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8395C20881
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:59:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8395C20881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725874AbeLCA7E (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:59:04 -0500
Received: from mx2.suse.de ([195.135.220.15]:43104 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725785AbeLCA7E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:59:04 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 7CD66AD3B;
        Mon,  3 Dec 2018 00:58:58 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Steve Dickson <SteveD@RedHat.com>
Date:   Mon, 03 Dec 2018 11:58:25 +1100
Subject: [PATCH 3/3] systemd: run statd-notify even when nfs-client isn't
 enabled.
Cc:     Justin Mitchell <jumitche@rehat.com>, linux-nfs@vger.kernel.org
Message-ID: <154379870500.3215.3980663938514502057.stgit@noble>
In-Reply-To: <154379862296.3215.11174339731963464375.stgit@noble>
References: <154379862296.3215.11174339731963464375.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When NFS filesytems are mounted, nfs-client.target really should
be enabled.  However it is possible to mount NFS filesystems
without this (providing gss isn't used) and it mostly works.

One aspect that doesn't work is that sm-notify isn't run, so the server
isn't told to drop any locks from the previous client instance.
This can result in confusing failures: if a client crashes while
holding a lock, it won't be able to get the same lock after a reboot.

While this isn't a complete solution (nfs-client really should be
enabled), adding a dependency from rpc-statd to rpc-statd-notify is
easy, has no down sides, and could help avoid confusion.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 systemd/rpc-statd.service |    1 +
 1 file changed, 1 insertion(+)

diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
index 1f4e6a8b92ab..3e92cf71add0 100644
--- a/systemd/rpc-statd.service
+++ b/systemd/rpc-statd.service
@@ -4,6 +4,7 @@ DefaultDependencies=no
 Conflicts=umount.target
 Requires=nss-lookup.target rpcbind.socket
 Wants=network-online.target
+Wants=rpc-statd-notify.service
 After=network-online.target nss-lookup.target rpcbind.socket
 
 PartOf=nfs-utils.service


