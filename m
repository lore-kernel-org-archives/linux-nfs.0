Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw-k01.its.kfa-juelich.de ([134.94.4.24]:39748 "EHLO
        mailgw-k01.its.kfa-juelich.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752523AbcLTMFZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Dec 2016 07:05:25 -0500
From: Yann Leprince <y.leprince@fz-juelich.de>
To: Steve Dickson <SteveD@redhat.com>
CC: Libtirpc-devel Mailing List
        <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Fix boot dependency in systemd service file
Date: Tue, 20 Dec 2016 12:58:56 +0100
Message-ID: <20161220115856.22467-1-y.leprince@fz-juelich.de>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yann Leprince <yann.leprince@ylep.fr>

This fix ensures that a separate /var partition will be mounted before
rpcbind tries to write its status to /var/run.

Signed-off-by: Yann Leprince <yann.leprince@ylep.fr>
---
 systemd/rpcbind.service.in | 1 +
 1 file changed, 1 insertion(+)

diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
index c173b83..f8cfa9f 100644
--- a/systemd/rpcbind.service.in
+++ b/systemd/rpcbind.service.in
@@ -2,6 +2,7 @@
 Description=3DRPC Bind
 Documentation=3Dman:rpcbind(8)
 DefaultDependencies=3Dno
+RequiresMountsFor=3D@statedir@

 # Make sure we use the IP addresses listed for
 # rpcbind.socket, no matter how this unit is started.
--
2.11.0



---------------------------------------------------------------------------=
---------------------
---------------------------------------------------------------------------=
---------------------
Forschungszentrum Juelich GmbH
52425 Juelich
Sitz der Gesellschaft: Juelich
Eingetragen im Handelsregister des Amtsgerichts Dueren Nr. HR B 3498
Vorsitzender des Aufsichtsrats: MinDir Dr. Karl Eugen Huthmacher
Geschaeftsfuehrung: Prof. Dr.-Ing. Wolfgang Marquardt (Vorsitzender),
Karsten Beneke (stellv. Vorsitzender), Prof. Dr.-Ing. Harald Bolt,
Prof. Dr. Sebastian M. Schmidt
---------------------------------------------------------------------------=
---------------------
---------------------------------------------------------------------------=
---------------------

