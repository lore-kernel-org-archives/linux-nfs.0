Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C45EE18A6D4
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 13:39:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790257200; cv=none; b=gWT119WlDr75jZjP+YVTmdAPkvLvMldsMw2abNOzeu43t5EygAmrkvRxn5UqTlHc4fQ8oGqm+wWrXGetMnw/alnI0fHEtpPtJmiM7CQLGjaFXwgX7h9rMb6NBbAuudv4IgTNaEURg20n+QshOYfX9Xr+5jjsS/7mI+hyGOeddKQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790257200; c=relaxed/simple;
	bh=2va5Nb1wjUWQDPI4WE4o6Vdt684X72FBnAdiBKg4pDc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=OY2q2cSuVs4sXZwC9CezNTbnrnZ7o8o+jv4C/TYuJkRgNCo4iiQC5GzXhNKLZBmPvAT2Ea6B8t8p1JUMOtDRg/xhpWIU9rBVov+TAG4AvJV1fast8Te8Om45w9Wmp/NtAjbybYNnaJTL+jZF6Lb8H1kBS4tWDJOpEgq3Uy7UMIQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kUfQTtY4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kUfQTtY4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2D7D61F000FF;
	Thu, 24 Sep 2026 13:39:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790257190;
	bh=zsKhoY3otHgt2UKDMWDUqqk9/lTAwq0VNG2vv1T+gk4=;
	h=From:Date:Subject:To:Cc;
	b=kUfQTtY4lrLR5pwOeP1XbiEoXjj8ahF/AP4IQcB+Q+bsbPEwaKWEeznuOVzeOSbef
	 5cIzTPeQ8fTX35vrf3oKo3s31Gq8SR+NhUd5hMMIw8j6j3/gr8w/9gSlpe9ygSZyLd
	 p8/P8G2UyOlFCT8VDdpxziBgacxN5rth4ZmO0JE0yyFLW2/uv3HvYS3efdpxSLGYr9
	 4ICLcDCzZrS61yNAopxlU9VRo1TkQJ32tp9ss+6JblJxks7NwXvHiQOt5eOca1XT0O
	 CCgzymZnKV3Op3OgBOA83pLha6LF9wTrn6ziz43YJjwgIMBNUsfZ0LmXNsMYSZAdd/
	 q3s/D03Jksb8w==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 24 Sep 2026 09:39:45 -0400
Subject: [PATCH pynfs v2] RPLY14: reconnect before retransmitting the call
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260924-rply14-v2-1-7a6a9e33e878@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/12MywrDIBBFfyXMuhZfsdhV/6NkkSZjIg0axhIqw
 X+vuOzy3Hs4JyQkjwnu3QmEh08+hgry0sG0jmFB5ufKILk03ErFaN+y0GyW+qWUnmbjRqjyTuj
 8t4WesOfgEgx1Xn36RMotf4h2/pcOwQRzpld9f7Pcju7xRgq4XSMtMJRSfmyXWvKkAAAA
X-Change-ID: 20260923-rply14-d24b334cd6fa
To: Calum Mackay <calum.mackay@oracle.com>
Cc: Chuck Lever <chuck.lever@vger.kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3999; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=2va5Nb1wjUWQDPI4WE4o6Vdt684X72FBnAdiBKg4pDc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqtSglK0VdP/wmL6Gnd6oB1F3DuAfZYY5VVoCkK
 g7e3q/K6XmJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarUoJQAKCRAADmhBGVaC
 FWg5D/4uA0rPjxt0Rq0zEYQOgbyo/NcBO5etTTo7VgZC/O5aDvpwlKzBNoAN/jVozox3N2EPhUX
 YZXmoMv0jrN+MXB+nenmh6/J+BiL7RukYFu8OOA9Ir4H10GHD+szQejNEvMvj3SWEHDGB8TVLL4
 E52DzdvKmCzhgE9+5sBvWbFGri5p7MGyhyjgcC4LPaD5z6Y7HR49z44QrMumpvqPQ69Jy6acUfn
 MxxfGmfwnZK8g/yy0YUhYXHcOWiGiHNxhbHMK7XbuenUxRXC9VYVcjSaKf1TEYchNFrZJW5PeVj
 iAliXo3HnNmkBE/3P6vyOfQfcB906RFgtdtkwu3DnZz3nQ0599WH8JtAsmIMBlyoTKbYp8/3KoW
 t0VV8XNZpmztV7LbD3i90PpyGTgqyHVNrBjBhkEmwLBn3qSPMS/sRRlip/p+f3lVQzPyv2MsrsW
 g5Zgclu4uPgeaefhPq2u3Az8/9yBeuGkr6QbuXkpG5oTUv2PE/qHE/Rlb/KcvwysP9sw/wl8Nje
 jwOglKw4J9Iu7ZU35+Km/eCc/KFCiR9ylybrp8JsKtVwr+Q7ZQfy3kwdZV2GC7pvm3VfQO0Pwy4
 7Mt2/WkR6UhaN2pgQ/T8BFrvDCAL8ZAqxAPy9/UDCeiunxYoy2kWBDI6chYZkzYmKOrHmfPvxWP
 IKEfLLNnaOtcQUw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This test recently started failing with a change to the Linux kernel,
but we believe that the test is wrong. This test replays the same call
with the same XID over the same socket without reconnecting in between.

RFC7530, section 3.1.1 says:

   When processing an NFSv4 request received over a reliable transport
   such as TCP, the NFSv4 server MUST NOT silently drop the request,
   except if the established transport connection has been broken.
   Given such a contract between NFSv4 clients and servers, clients MUST
   NOT retry a request unless one or both of the following are true:

   o  The transport connection has been broken
   o  The procedure being retried is the NULL procedure

Reconnect the socket before retransmitting the request.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v2:
- Drop redundant comment
- Quote RFC7530 in the changelog as justification
- Link to v1: https://lore.kernel.org/r/20260923-rply14-v1-1-f653557909af@kernel.org
---
 nfs4.0/lib/rpc/rpc.py           | 25 +++++++++++++++++++++++++
 nfs4.0/servertests/st_replay.py |  7 +++++--
 2 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/nfs4.0/lib/rpc/rpc.py b/nfs4.0/lib/rpc/rpc.py
index 7a80241aa127..c530847a46d9 100644
--- a/nfs4.0/lib/rpc/rpc.py
+++ b/nfs4.0/lib/rpc/rpc.py
@@ -315,6 +315,31 @@ class RPCClient(object):
         out.settimeout(self.timeout)
         self.lock.release()
         return out
+
+    def reconnect_same_port(self):
+        """Drop the current connection and reconnect from the same local
+        port, so the server sees a new transport with an unchanged
+        (address, port) cache key. Used to test duplicate reply cache
+        behavior across connections.
+
+        The old socket is reset (RST) rather than closed gracefully: a
+        graceful close leaves the 4-tuple unusable until the server
+        also closes, while an RST frees the source port immediately.
+        """
+        t = threading.currentThread()
+        self.lock.acquire()
+        old = self._socket[t]
+        saddr = old.getsockname()
+        old.setsockopt(socket.SOL_SOCKET, socket.SO_LINGER,
+                       struct.pack('ii', 1, 0))
+        old.close()
+        out = self._socket[t] = socket.socket(self.af, socket.SOCK_STREAM)
+        out.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
+        out.bind(saddr)
+        out.connect((self.remotehost, self.remoteport))
+        out.settimeout(self.timeout)
+        self.lock.release()
+        return out
         
     def send(self, procedure, data=b'', program=None, version=None):
         """Send an RPC call to the server
diff --git a/nfs4.0/servertests/st_replay.py b/nfs4.0/servertests/st_replay.py
index 48e5363432ec..dc375bbc78a4 100644
--- a/nfs4.0/servertests/st_replay.py
+++ b/nfs4.0/servertests/st_replay.py
@@ -4,7 +4,7 @@ from xdrdef.nfs4_type import *
 import nfs_ops
 op = nfs_ops.NFS4ops()
 
-def _replay(env, c, ops, error=NFS4_OK):
+def _replay(env, c, ops, error=NFS4_OK, newconn=False):
     # Can send in an error list, but replays must return same error as orig
     if type(error) is list:
         check_funct = check
@@ -18,6 +18,9 @@ def _replay(env, c, ops, error=NFS4_OK):
     try:
         c.get_new_xid = lambda : xid
 
+        if newconn:
+            c.reconnect_same_port()
+
         # note: this is really cheesy: we happen to know the current
         # Linux server implementation will drop a replay if it comes
         # "too quickly" (<.02 seconds).
@@ -260,4 +263,4 @@ def testMkdirReplay(t, env):
     c = env.c1
     c.init_connection()
     ops = c.go_home() + [op.create(createtype4(NF4DIR), t.word(), {})]
-    _replay(env, c, ops)
+    _replay(env, c, ops, newconn=True)

---
base-commit: cd4701827a8261fedbfb4c6e39029fb9671321a6
change-id: 20260923-rply14-d24b334cd6fa

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

