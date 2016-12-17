Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.trendhosting.net ([195.8.117.5]:50920 "EHLO
        mail1.trendhosting.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752729AbcLQLAx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Dec 2016 06:00:53 -0500
Received: from localhost (localhost [127.0.0.1])
        by mail1.trendhosting.net (Postfix) with ESMTP id 897A7150C7
        for <linux-nfs@vger.kernel.org>; Sat, 17 Dec 2016 11:00:49 +0000 (GMT)
Received: from mail1.trendhosting.net ([127.0.0.1])
        by localhost (thp003.trendhosting.net [127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id guU1GhL5bHa0 for <linux-nfs@vger.kernel.org>;
        Sat, 17 Dec 2016 11:00:47 +0000 (GMT)
To: linux-nfs@vger.kernel.org
From: Daniel Pocock <daniel@pocock.pro>
Subject: [PATCH] nfs-utils: start-statd script using incompatible file
 descriptor
Message-ID: <70eeb75e-e48f-fb0a-a690-1c6c8cb0ede4@pocock.pro>
Date: Sat, 17 Dec 2016 12:00:47 +0100
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------E1D7F492ABF1DC936D592659"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------E1D7F492ABF1DC936D592659
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit



The current script uses fd 200, doesn't work for every possible shell as
reported[1] in Debian bug #848277

We are including a patch for it in the 1.3.4-2 package, it would be good
to incorporate this patch upstream too.

Regards,

Daniel


1. https://bugs.debian.org/848277

--------------E1D7F492ABF1DC936D592659
Content-Type: text/x-patch;
 name="29-start-statd-fd-9.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="29-start-statd-fd-9.patch"

diff --git a/utils/statd/start-statd b/utils/statd/start-statd
index 2fd6039..82715b4 100755
--- a/utils/statd/start-statd
+++ b/utils/statd/start-statd
@@ -7,8 +7,8 @@
 PATH=3D"/sbin:/usr/sbin:/bin:/usr/bin"
=20
 # Use flock to serialize the running of this script
-exec 200> /var/run/rpc.statd.lock
-flock -e 200
+exec 9> /var/run/rpc.statd.lock
+flock -e 9
=20
 if [ -s /var/run/rpc.statd.pid ] &&
        [ 1`cat /var/run/rpc.statd.pid` -gt 1 ] &&

--------------E1D7F492ABF1DC936D592659--
