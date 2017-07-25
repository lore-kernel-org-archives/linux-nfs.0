Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44542 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752186AbdGYPTU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Jul 2017 11:19:20 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id B8F28C0D473F
        for <linux-nfs@vger.kernel.org>; Tue, 25 Jul 2017 15:19:20 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] systemd: add a blurb about masking rpc-gssd to the man page
Date: Tue, 25 Jul 2017 11:19:20 -0400
Message-Id: <20170725151920.21760-1-smayhew@redhat.com>
In-Reply-To: <87a83wyi00.fsf@notabene.neil.brown.name>
References: <87a83wyi00.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is helpful for users that have a krb5.keytab but do not want to use
secure NFS.  Also fixed a typo that appears earlier on the page.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 systemd/nfs.systemd.man | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/systemd/nfs.systemd.man b/systemd/nfs.systemd.man
index 01801eb..46b476a 100644
--- a/systemd/nfs.systemd.man
+++ b/systemd/nfs.systemd.man
@@ -79,7 +79,7 @@ unit should be enabled.
 Several other units which might be considered to be optional, such as
 .I rpc-gssd.service
 are careful to only start if the required configuration file exists.
-.I rpc-gsdd.service
+.I rpc-gssd.service
 will not start if the
 .I krb5.keytab
 file does not exist (typically in
@@ -120,10 +120,11 @@ be needed to reduce system load to an absolute minimum, or to reduce
 attack surface by not running daemons that are not absolutely
 required.
 .PP
-Two particular services which this can apply to are
-.I rpcbind
+Three particular services which this can apply to are
+.IR rpcbind ,
+.IR idmapd ,
 and
-.IR idmapd .
+.IR rpc-gssd .
 .I rpcbind
 is not part of the
 .I nfs-utils
@@ -155,6 +156,15 @@ is not needed and not wanted, it can be masked with
 .RS
 .B systemctl mask idmapd
 .RE
+.I rpc-gssd
+is assumed to be needed if the
+.I krb5.keytab
+file is present.  If a site needs this file present but does not want
+.I rpc-gssd
+running, it can be masked with
+.RS
+.B systemctl mask rpc-gssd
+.RE
 .SH FILES
 /etc/nfs.conf
 .br
-- 
2.9.4

