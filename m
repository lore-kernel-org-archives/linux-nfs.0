Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 30208417D99
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 17:43:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790185441; cv=none; b=pdCG3Qz7LxsBhgPT8tw9vFguancKCiXJ7qUEDYhTLiZ1rdHaD6nC7Dd/sEEDnsZvrc0n09NR3mG1Irn3p+UqA+cifA77SGK5kCwzbt1yKCZQXJDUiMtm35qULHi0uohBzX1rXiiQyWR8b3jqB8iyWvaqNYXuxwtwzh3XNjI51T8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790185441; c=relaxed/simple;
	bh=e36tQPmOsDEkEFsC6u9uJnvNizlNUPahFhu1M9FJ4w4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=bAgWWgIycqNowwbgoasUj7ugyBvt/mtXfaAPstvl7KCBSHaWvnACATpxbnleLCkCocksIESMnOaSgYvSKdEjNaPQQo0eakr1+CSTw6kOXnxD76ZWlq9SJAwiOE+ZMn8qkvj4oU2bz3LUCXU7lJOamCPyHNPgCG56s+enjCGlMCM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nX8aOTwT; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nX8aOTwT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EFF671F000FF;
	Wed, 23 Sep 2026 17:43:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790185439;
	bh=sl0mHZUX1f6qXyKcOLu1E1Y5FefHdkjvgmncc/b6YWY=;
	h=From:Date:Subject:To:Cc;
	b=nX8aOTwTnMGo1JdVyKVwEltartqCGnXEshghnULneM4nij1Mz+33hWmPJMRo5GEww
	 qA/BRMX24DKplt1plaTq5NaHlxL/hbU3GmaEUFUZihj4epmnPOyT9tHuFeZLl8/Ro/
	 ozRyDXNDf73lSafKdaLRyi4qjCMi9eQ3UBZ4QxofGMVkYGRaDViRt5OGg/o1rMSE6X
	 VBf3xlJjVB4ds8lFFmypRdvF5OUNZqp7KpoZ7nDN4BNk/sg1aTfTiDo+n1VtkGsLsl
	 dnBsCzOXx8zkiDEevAbik5EJTnLKyJEvqIW6wm0O+15YJQj5mLJ3WEBpTQ8jDLGZKP
	 5BdannFvA5c3g==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 23 Sep 2026 13:43:48 -0400
Subject: [PATCH pynfs] RPLY14: reconnect before retransmitting the call
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260923-rply14-v1-1-f653557909af@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x3MQQqAIBBA0avIrBNMRairRIvSsQbCRCES8e5Jy
 wefXyFjIswwswoJH8p0h45xYGDPLRzIyXWDFNKISSqe4lVGzZ3Uu1LaOuM36HFM6On9RwvEEny
 GtbUPLr8d4F8AAAA=
X-Change-ID: 20260923-rply14-d24b334cd6fa
To: Calum Mackay <calum.mackay@oracle.com>
Cc: Chuck Lever <chuck.lever@vger.kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3645; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=e36tQPmOsDEkEFsC6u9uJnvNizlNUPahFhu1M9FJ4w4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqtA/b5bGY8XjVy4xTyLR6hayxkUtueAcNt7Pm+
 UD0hiTAtuOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarQP2wAKCRAADmhBGVaC
 FfYWD/9PXu5HhYJ5bq54tf0qdjYpkHxVJSawwN2m5FdD++JAeamGV5+AWB2ihVb7OVes/0szHLt
 OIpaPd+Ra2NXci3lG81/BAP1ehZs2HcQavpy86iZOnRqowNUikFdBVwZXfpwam6Nff7hEphGo8c
 HOHehG2vNxCZbQy4ZBoAk4pi/bvqUaR9tuklrx+84CR5BfD5xFZ0+SWbC1TRqS6GOBZbnMX+Gx2
 dNl0AxyzLUW3SxJUvV4r7krdsNDICmSzkyt2igEDPnqEYHkiAnCYrfQV7sQTSAL0dDRDFOQ1WeQ
 R1i8vItR2iIyHJv88nnNMJqU+l9jJJKugGPWOB4KSYL3hcCbtSpfm2+PJwHjokcZuGJ9URo1srQ
 iGg0SIgn9I4GSH2gD3iTQBO5ocZb0JyH1WjhG4WlHpJSTWc1D7pkw+KkSZ/Uvd4a162xzp/2Pl9
 6L0VhVZNAN47PyqsJVCHe1cvTckkNYFOomZwCdk6So+Ts5fkklUCVi61Yj5E/zj7F2jCqsaULTU
 4HeNWf4uMrEvDDgaLwrHUe6I40GN7Lc/rfJ6NnklDtzhc54nA0A6AW4h5Zhe4miVfTYRZ8pYTJy
 FG/4kYJ1Cs2Yrr+6Z8iFz8HSXJzJkZ+yL9Q8V7UIgc+U+uUvUCzIuv1b5ZVZ7AY+ccseMZdQ7If
 3uLwe8IbCi9rGMA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This test recently started failing with a change to the Linux kernel,
but we believe that the test is wrong. This test replays the same call
with the same XID over the same socket without reconnecting in between.

There is language in RFC1813 that implies that a reconnect is necessary
on a retransmit on a reliable transport like TCP. Change the test to
reconnect the socket before retransmitting.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.0/lib/rpc/rpc.py           | 25 +++++++++++++++++++++++++
 nfs4.0/servertests/st_replay.py | 10 ++++++++--
 2 files changed, 33 insertions(+), 2 deletions(-)

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
index 48e5363432ec..fc8282151909 100644
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
@@ -18,6 +18,12 @@ def _replay(env, c, ops, error=NFS4_OK):
     try:
         c.get_new_xid = lambda : xid
 
+        if newconn:
+            # Reconnect from the same source port before replaying:
+            # servers may drop a retransmit that arrives on the same
+            # connection as the original call.
+            c.reconnect_same_port()
+
         # note: this is really cheesy: we happen to know the current
         # Linux server implementation will drop a replay if it comes
         # "too quickly" (<.02 seconds).
@@ -260,4 +266,4 @@ def testMkdirReplay(t, env):
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

