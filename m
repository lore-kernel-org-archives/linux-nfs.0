Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:48394 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755270Ab1EPNi2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 09:38:28 -0400
Received: by iwn34 with SMTP id 34so3918654iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 16 May 2011 06:38:28 -0700 (PDT)
Date: Mon, 16 May 2011 15:38:27 +0200
Message-ID: <BANLkTinSoHVQH1meHMwCtxEp8Mku1gJv0Q@mail.gmail.com>
Subject: [PATCH] rpc.idmapd dies with 'I/O possible'
From: Luca Giuzzi <luca.giuzzi@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Dear All,
 we have had problems on some of our machines (all Fedora 14), where
rpc.idmapd used to die with an `I/O possible' message at (basically)
random times. A strace suggested the issue being in nfsopen() where a
signal type is reset before notification is disabled; a signal at just
the right time might be the cause of the problem; see
https://bugzilla.redhat.com/show_bug.cgi?id=684308
I am now proposing the (trivial) patch to the list as well.

Best Regards,
  luca giuzzi

--- nfs-utils-1.2.3/utils/idmapd/idmapd.c.orig	2011-05-13
16:27:08.000000000 +0200
+++ nfs-utils-1.2.3/utils/idmapd/idmapd.c	2011-05-13 16:27:16.000000000 +0200
@@ -778,8 +778,8 @@ nfsopen(struct idmap_client *ic)
 	} else {
 		event_set(&ic->ic_event, ic->ic_fd, EV_READ, nfscb, ic);
 		event_add(&ic->ic_event, NULL);
-		fcntl(ic->ic_dirfd, F_SETSIG, 0);
 		fcntl(ic->ic_dirfd, F_NOTIFY, 0);
+		fcntl(ic->ic_dirfd, F_SETSIG, 0);
 		if (verbose > 0)
 			xlog_warn("Opened %s", ic->ic_path);
 	}
