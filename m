Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9152 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762111Ab3DBTcf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 15:32:35 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r32JWZCr021653
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 15:32:35 -0400
Received: from willson.li.ssimo.org.com (ovpn-113-117.phx2.redhat.com [10.3.113.117])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r32JWXuq021784
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 15:32:34 -0400
From: Simo Sorce <simo@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] Document new -z/-Z options
Date: Tue,  2 Apr 2013 15:32:29 -0400
Message-Id: <1364931149-18484-3-git-send-email-simo@redhat.com>
In-Reply-To: <515B2F8D.3030302@RedHat.com>
References: <515B2F8D.3030302@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Options are not in alphabetical order but -z/-Z clearly always come last.

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 utils/gssd/gssd.man |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 79d9bf91ac6b976c57d167e60d07f828a3ff5b1f..7918c2a0ff76c3918449cf3e1420f0a289929ac1 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -8,7 +8,7 @@
 rpc.gssd \- RPCSEC_GSS daemon
 .SH SYNOPSIS
 .B rpc.gssd
-.RB [ \-fMnlvr ]
+.RB [ \-fMnlvrzZ ]
 .RB [ \-k
 .IR keytab ]
 .RB [ \-p
@@ -266,6 +266,17 @@ new kernel contexts to be negotiated after
 seconds, which allows changing Kerberos tickets and identities frequently.
 The default is no explicit timeout, which means the kernel context will live
 the lifetime of the Kerberos service ticket used in its creation.
+.TP
+.B -z
+This option tries to avoid DNS Reverse (PTR) lookups for determining the 
+server name to pass to GSSAPI if the name passed at mount point is not an IP 
+address. Currently off by default for compatibility reasons.
+.TP
+.B -Z
+This is the inverse of 
+.B -z
+and forces the use of DNS Reverse resolution of the server's IP address to
+retrieve the server name to use in GSAPI authentication.
 .SH SEE ALSO
 .BR rpc.svcgssd (8),
 .BR kerberos (1),
-- 
1.7.1

