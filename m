Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B06F3357D0A
	for <linux-nfs@vger.kernel.org>; Thu,  9 Jul 2026 19:02:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783623772; cv=none; b=jAuc8uz8IPBdhSHXCD3DkWK7zxCPt8C+ZY+YVFJ9QoI/WVIK+0ofjCtojKaKAZ1kmsOE6li8z2wu3mm6NatrSZmkoSsxOYFXUboORJ1xeqZ3SYGBAMhIMB9Ee6uXame4Wp1/Bcfdl5gWaJAHjKaBAMvbuciOQ/DQs5iilRTDEXc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783623772; c=relaxed/simple;
	bh=kpExrWiRzroBf18kzIDaLm94tzbqWLmf6PLWdQH8AMM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Acu8HZrlzTTnjI4E3+YB+g+yfvX4XGi0D0jAzlRB5eQJHhigBHKD0zWlGDYNa5W/H6fCmgVePv/KihsfXy+kVwwwllNpBwR2v2FYTa/UKxcYdWXaaiUWap4NV1Uebmn5OtlaQ7L0KZlzxtVa+48h0T33qwHVgROIVZXuxstj+p0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FXguNcVL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FXguNcVL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DD9B21F0155A;
	Thu,  9 Jul 2026 19:02:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783623771;
	bh=rNef8iuvuhn5uECcu6XpIrDsiNDpw6iO9dNEljhGAFc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=FXguNcVLGba61UP0ZM3xPZtShigenHJ6ARCGpxtK4ApOWraoxjwBimnRdPxUtmhv3
	 xbqLFy9oFEQOBKkmAMas9lOvAyainYVKDFYCuk/FykLakK2m2vZiWgF4ptvOcNwoRi
	 yAu/d8ZMXbosab76VvA23mldQkLAKFvuucjSldbyU9UGYobZUY8bhOn0dZTr2EO1wq
	 Jp1KmQXn07RisrIg+ebFH0JeFhhtkaUBGnfdt2l8jg1AZYEcVqLjaTRsHbc0kkKuTR
	 /++/N9032EcLqszisKC6oHYeYgrxItvt8gjUJpAcUoHsnEHhA2x17BQdqD1DLEVt0u
	 Dlcbqjq0rzvZA==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 09 Jul 2026 15:02:34 -0400
Subject: [PATCH pynfs 06/13] server41tests: test COPY with bad source
 stateid
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260709-copy-v1-6-849bf581d7cb@kernel.org>
References: <20260709-copy-v1-0-849bf581d7cb@kernel.org>
In-Reply-To: <20260709-copy-v1-0-849bf581d7cb@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1923; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=kpExrWiRzroBf18kzIDaLm94tzbqWLmf6PLWdQH8AMM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqT/BT2F7vrMKJ8T+0/nCGy9QQwnvc3yQnqvWlm
 yduBMEYhGiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCak/wUwAKCRAADmhBGVaC
 FSUAEACgL8mEqWc1OoTR7DRJhTUkHG3FzQKAzkngcSIYkcINsslEVW9U0baHEU53chZzjINK/VR
 b+8G/6XkOqfRP0SgGB3T8GK27QmXr20WtK/hj/FUXAVhn5XnNbf1h/nN6s3HduESf67mUF7mQc0
 Nv+q89gAlGBIwcMj8rIOSy9CloPQPqUkTJG4n4QDDVOuDD/f5pgtbha2Qyc7WsUoufCaLEjK+sC
 nTztEADenRbJM6e3+lAjSxyUwbfGQVh7UkmjkBQxxUWdBuFw1GUofhY7T+1F2K5IIfmzFDc082y
 WKni1IzJZpzyLqBPejU1oz7HUdKh8K+8HkWLtxHWjtli6vSDjQa9FpHAWBYDMwDel26PUPm7LQh
 kfN+UPutrG9z6/euMooyCKwsJ8rmxRV0cDFkDMgjGyxBYDtdDtgnuu8gRqFDgbASAqb572YPntX
 XXmaWJk/C0WR0qN7CN0Ybn/P2p79eDFGajmg9GThPx0zG0yRSe1Aj9AwEi1lR+wVXWNMRprGufl
 7JluHUbmbqin0yKCZUPtCHvCC7KLeLqXDhT6Nw0zVIW7j67Ui54IjFXNdZoQKKPHXHPs5VqUChR
 sD47h0gLbwDTJemzOXb8AUqh13buKTavV0l9BMGZULzV+mNFM0cv/67EhfX26aJBQlVc6KHGwlg
 BVstwh8whh75z0A==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Add testCopyBadSourceStateid (COPY8) and a _bad_stateid() helper that
returns a fabricated, non-special stateid -- not the all-zero anonymous
or all-one READ-bypass special stateids, which a server legitimately
accepts -- so the server is forced to reject it with NFS4ERR_BAD_STATEID.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 nfs4.1/server41tests/st_copy.py | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/nfs4.1/server41tests/st_copy.py b/nfs4.1/server41tests/st_copy.py
index 897c8c7d3a6c..1918f3da2bdf 100644
--- a/nfs4.1/server41tests/st_copy.py
+++ b/nfs4.1/server41tests/st_copy.py
@@ -38,6 +38,11 @@ def _create_and_open(sess, name):
     stateid = res.resarray[-2].stateid
     return fh, stateid
 
+def _bad_stateid():
+    # A fabricated, non-special stateid (not the all-zero anonymous or
+    # all-one READ-bypass special stateids) the server cannot recognize.
+    return stateid4(1, b'\xde\xad\xbe\xef' * 3)
+
 def _write_data(sess, fh, stateid, data, offset=0):
     """Write data in chunks bounded by the session's max request size."""
     chunk = sess.fore_channel.maxrequestsize - 1024
@@ -253,3 +258,17 @@ def testOffloadCancel(t, env):
     res = sess.compound(ops)
     check(res, [NFS4_OK, NFS4ERR_NOTSUPP, NFS4ERR_COMPLETE_ALREADY],
           msg="OFFLOAD_CANCEL")
+
+def testCopyBadSourceStateid(t, env):
+    """COPY with an invalid source stateid should fail
+
+    FLAGS: copy
+    CODE: COPY8
+    """
+    sess = env.c1.new_client_session(env.testname(t))
+    src_fh, _src_stateid = _create_and_open(sess, env.testname(t))
+    dst_fh, dst_stateid = _create_and_open(sess, env.testname(t) + b"_dst")
+
+    res = _do_copy(sess, src_fh, _bad_stateid(), dst_fh, dst_stateid,
+                   count=1024, synchronous=1)
+    check(res, NFS4ERR_BAD_STATEID, msg="COPY with bad source stateid")

-- 
2.55.0

