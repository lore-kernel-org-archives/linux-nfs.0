Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58642 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935400AbdGTUYX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Jul 2017 16:24:23 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id F196D6574B
        for <linux-nfs@vger.kernel.org>; Thu, 20 Jul 2017 20:24:22 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v4] systemd: add instructions for disabling gssd to nfs.systemd.man
Date: Thu, 20 Jul 2017 16:24:22 -0400
Message-Id: <20170720202422.14153-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've had several users complain about gssd automatically starting.  Not
everyone who has a krb5.keytab want to use secure NFS; the instructions
for disabling gssd ought to be on the man page in addition to the README
(which may not even be included in a distro's nfs-utils package).

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 systemd/nfs.systemd.man | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/systemd/nfs.systemd.man b/systemd/nfs.systemd.man
index 01801eb..7675320 100644
--- a/systemd/nfs.systemd.man
+++ b/systemd/nfs.systemd.man
@@ -79,11 +79,26 @@ unit should be enabled.
 Several other units which might be considered to be optional, such as
 .I rpc-gssd.service
 are careful to only start if the required configuration file exists.
-.I rpc-gsdd.service
+.I rpc-gssd.service
 will not start if the
 .I krb5.keytab
 file does not exist (typically in
 .IR /etc ).
+.B rpc.gssd
+is assumed to be needed if the
+.I krb5.keytab
+file is present.  If a site needs this file present but does not want
+.B rpc.gssd
+running, it should create
+.B /etc/systemd/system/rpc-gssd.service.d/01-disable.conf
+containing
+.RS
+.nf
+[Unit]
+ConditionNull=false
+.fi
+.RE
+
 .SS Restarting NFS services
 Most NFS daemons can be restarted at any time.  They will reload any
 state that they need, and continue servicing requests.  This is rarely
-- 
2.9.4

