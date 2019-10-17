Return-Path: <SRS0=AtwM=YK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B464ECE58E
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Oct 2019 15:08:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1CA9320820
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Oct 2019 15:08:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2440392AbfJQPIo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 17 Oct 2019 11:08:44 -0400
Received: from mx1.redhat.com ([209.132.183.28]:45278 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2440394AbfJQPIo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Oct 2019 11:08:44 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 82E8330860DA
        for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2019 15:08:44 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-120-158.rdu2.redhat.com [10.10.120.158])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 6833719C77;
        Thu, 17 Oct 2019 15:08:44 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 186D920836; Thu, 17 Oct 2019 11:08:44 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     steved@redhat.com
Cc:     linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v3] gssd: daemonize earlier
Date:   Thu, 17 Oct 2019 11:08:44 -0400
Message-Id: <20191017150844.21045-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 17 Oct 2019 15:08:44 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

daemon_init() calls closeall() which closes all fd's >= 4.  This causes
rpc.gssd to fail when it's configured to use the gssproxy interposer
plugin (via "use-gss-proxy=1" in nfs.conf or GSS_USE_PROXY="yes" in the
environment) *and* libtirpc debugging is enabled (i.e. at least one
"-r" on the command line):

1. During startup if rpc debugging is enabled then libtirpc_set_debug()
   is called, which calls openlog() which consumes fd 3.
2. If the gssproxy interposer plugin is enabled then when
   gssd_check_mechs() is called, a socket is created (fd 4) and
   connected to /var/lib/gssproxy/default.sock.  The fd is stored
   internally in a struct gpm_ctx.
3. daemon_init() runs and closes all fd's >= 4.
4. event_init() runs which calls epoll_create() which returns an epoll
   fd of 4.
5. Later when handling an upcall, gssd calls gssd_acquire_krb5_cred()
   which winds up closing the gpm_ctx->fd which was 4.
6. event_dispatch() calls epoll_wait() with epfd=4, and -EBADF is
   returned.  gssd logs the message ""ERROR: event_dispatch() returned!"
   and exits.

The solution is to call daemon_init() earlier.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/gssd/gssd.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 19ad4da..c38dedb 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -1020,11 +1020,11 @@ main(int argc, char *argv[])
 			    "support setting debug levels\n");
 #endif
 
+	daemon_init(fg);
+
 	if (gssd_check_mechs() != 0)
 		errx(1, "Problem with gssapi library");
 
-	daemon_init(fg);
-
 	event_init();
 
 	pipefs_dir = opendir(pipefs_path);
-- 
2.17.2

