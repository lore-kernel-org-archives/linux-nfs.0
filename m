Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:41605 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751654AbcK0G1c (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Nov 2016 01:27:32 -0500
From: Tom Haynes <loghyr@primarydata.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH pynfs 04/12] Get rid of the client records as well as the session records
Date: Sat, 26 Nov 2016 22:26:33 -0800
Message-ID: <1480228001-64821-5-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
References: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 nfs4.1/nfs4client.py                | 5 ++++-
 nfs4.1/server41tests/environment.py | 5 +++++
 nfs4.1/testmod.py                   | 1 +
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 0a25bcf..2e22695 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -40,6 +40,7 @@ class NFS4Client(rpc.Client, rpc.Server):
         self.server_address =3D (host, port)
         self.c1 =3D self.connect(self.server_address)
         self.sessions =3D {} # XXX Really, this should be per server
+        self.clients =3D {} # XXX Really, this should be per server
         self.ctrl_proc =3D ctrl_proc
         self.summary =3D summary
=20
@@ -313,7 +314,9 @@ class NFS4Client(rpc.Client, rpc.Server):
                             cred)
         nfs4lib.check(res, expect)
         if expect =3D=3D NFS4_OK:
-            return ClientRecord(res.resarray[0], self, cred, protect)
+            client_rec =3D ClientRecord(res.resarray[0], self, cred, prote=
ct)
+            self.clients[client_rec.clientid] =3D client_rec
+            return client_rec
         else:
             return None
=20
diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/env=
ironment.py
index 7384b3c..a910a69 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -257,6 +257,11 @@ class Environment(testmod.Environment):
         for sessionid in self.c1.sessions.keys():
             self.c1.compound([op.destroy_session(sessionid)])
=20
+    def clean_clients(self):
+        """Destroy client name env.c1"""
+        for clientid in self.c1.clients.keys():
+            self.c1.compound([op.destroy_clientid(clientid)])
+
 #########################################
 debug_fail =3D False
=20
diff --git a/nfs4.1/testmod.py b/nfs4.1/testmod.py
index ce25974..c5ca0fe 100644
--- a/nfs4.1/testmod.py
+++ b/nfs4.1/testmod.py
@@ -222,6 +222,7 @@ class Test(object):
             self.runtest(self, environment)
             self.result =3D self._pass_result
 =09    environment.clean_sessions()
+=09    environment.clean_clients()
         except KeyboardInterrupt:
             raise
         except TestException, e:
--=20
2.3.6

