Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43685 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845AbaBTG4n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 01:56:43 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 20 Feb 2014 17:55:30 +1100
Subject: [PATCH 4/6] systemd: remove @localstatedir@ marking.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140220065530.7320.89196.stgit@notabene.brown>
In-Reply-To: <20140220065345.7320.49992.stgit@notabene.brown>
References: <20140220065345.7320.49992.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This isn't used so currently is inconvenient.
Once we decide how to handle this sort of thing we can apply
the change uniformly.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 systemd/rpc-svcgssd.service |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
index 32b786ec5c7d..f7424b0b1085 100644
--- a/systemd/rpc-svcgssd.service
+++ b/systemd/rpc-svcgssd.service
@@ -6,7 +6,7 @@ PartOf=nfs-server.service
 PartOf=nfs-utils.service
 
 After=gssproxy.service
-ConditionPathExists=|!@localstatedir@/run/gssproxy.pid
+ConditionPathExists=|!/run/gssproxy.pid
 ConditionPathExists=|!/proc/net/rpc/use-gss-proxy
 ConditionPathExists=/etc/krb5.keytab
 


