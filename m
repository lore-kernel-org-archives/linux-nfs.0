Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76120C10F02
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:09:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 463202192B
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:09:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388855AbfBOQIw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:08:52 -0500
Received: from mx1.redhat.com ([209.132.183.28]:59314 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388365AbfBOQIw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:08:52 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 43832C7966;
        Fri, 15 Feb 2019 16:08:52 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 603C660C80;
        Fri, 15 Feb 2019 16:08:47 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 09/27] vfs: Allow mounting to other namespaces
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:08:46 +0000
Message-ID: <155024692658.21651.7276705643207668882.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 15 Feb 2019 16:08:52 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Currently sys_move_mount() and sys_mount(MS_MOVE) prevent the caller from
moving a mount into a namespace not their own.  Relax this such that any
mount can be mounted onto any given mountpoint provided that the source
mount is either detached or the same namespace as the destination.

This permits container namespaces to be built from the outside rather than
from the inside.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/namespace.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 22cf4a8f8065..804601b6297c 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2627,12 +2627,10 @@ static int do_move_mount(struct path *old_path, struct path *new_path)
 	ns = old->mnt_ns;
 
 	err = -EINVAL;
-	/* The mountpoint must be in our namespace. */
-	if (!check_mnt(p))
-		goto out;
-
-	/* The thing moved should be either ours or completely unattached. */
-	if (attached && !check_mnt(old))
+	/* The new mount must be either unattached or in the same namespace as
+	 * the mountpoint.
+	 */
+	if (attached && old->mnt_ns != p->mnt_ns)
 		goto out;
 
 	if (!attached && !is_anon_ns(ns))

