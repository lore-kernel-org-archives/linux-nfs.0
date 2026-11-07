Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.229.6
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794020817;
	b=ZlevMO+WBNhAbCQdcBqK5ZBNP50tfVxXgdNqY2UQmhQ/74sSzmPKPvBqAJlrQNulnsT6
	 o3HqkfdSHCFBjfZI5TqvTtNU+oq4fRP0E6qwAY1EEDLdEhh23zw/8oOmSQ1Vh+oj7g7NC
	 7Tk1pwjm6eQdYnN0Rw2/SsuvP+nDHqqGq9LGIq8hTHz5VdvD2h1qKXf1xohW7HOXs7a7x
	 wMdmKmV0lm72e+GWIlGL/rGPeVTYv/sY9S1cOcD6swyXlcQvE7rKK2C6Lq/DEH7FlOwaw
	 PJ40m0og/zzCUG/rrv3xI/bJjAohndXTLmHDxFVqmUWpYvcZDlVTXA5vJaRH22PKbMg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794020817;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:Content-Type:
	 Content-Transfer-Encoding:Mime-Version:Subject:Message-Id:Date:Cc:To:
	 X-Mailer;
	bh=Xs9oCjjqQQnawAC4dbSe2dkYXjaO/ew8g3Tmh9DPaSM=;
	b=gqsmhAmOhXeLEFAg6a2U//FTWPsNUWuZuvwnm0wjtwmBTT4CmyZkViJQVSFhrsquMEkF
	 OTDeeCr6QWCOEw51bmsB3YH2HaxtzSUglhfEx8OGEgXpdSszqpFY1maqyx8JKXlCga/I2
	 WcmqYZZ9Du5ltSZsq5fINnkSgB2BTlADIz3UcIdJKoGCYoX5zWSWYc+6TLQvkHVtrJ62n
	 0jEL6tIwBZxTdOAe1hIjyuHytqoM9hqGNTiR1a+Fip571Ur2/sqxJ0zkp14kxex2L1Vpr
	 rIWDZeaNqV9IxucqaxkeQB7HtoVsoicKYQXOIvThVM+ENyZYvHk0jPLatiU0Wdh2zMA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=obgB8bMp;
	arc=none smtp.remote-ip=74.125.229.6
Received: from mail-dy2-f6.google.com (mail-dy2-f6.google.com [74.125.229.6])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DBA2E606A326
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 03:06:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DBA2E606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=obgB8bMp
Received: by mail-dy2-f6.google.com with SMTP id 5a478bee46e88-35adc681e1aso1567811eec.0
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2026 19:06:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794020816; x=1794625616; darn=vger.kernel.org;
        h=to:cc:date:message-id:subject:mime-version
         :content-transfer-encoding:content-type:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Xs9oCjjqQQnawAC4dbSe2dkYXjaO/ew8g3Tmh9DPaSM=;
        b=obgB8bMp0Fy59o84TGAAkYtUnssbZN+C4l1iBEt0rMT18MyKkhpmF+/3b3YC4E7ua0
         sxsQQEfcyoP+PdiTBMVeJQx5W9L00l8PD2mhfWA9ky5GBN/h03+xGabIfDH8B9m+XvGV
         MeB0c8bWx3ZTnR1A9/9p2XTwWq4Oi8x6Ygh6ROXrzpyyFhHftIFDCHtRNb/Wlo+z1s4J
         2i2i8Bkp4BPfhuM9LhvB+lRzp/mHTA/v3tbJ+kHKthaKis/pRjeqvO1T8/oDcixHw/20
         23AKftPL/WcrAYLLdbj/bYIBlxMelCI87Ez4hsBoo9nrfpBzLWMFtU77mdze0pOerR46
         +3aw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794020816; x=1794625616;
        h=to:cc:date:message-id:subject:mime-version
         :content-transfer-encoding:content-type:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Xs9oCjjqQQnawAC4dbSe2dkYXjaO/ew8g3Tmh9DPaSM=;
        b=N+rkiRe+05xoz0pd2IMSnyokMS2pWb1xYakIxLlaKSmP4l9XGi25biZ3V/uata2UP/
         Kw8cztSN/WaBJT64xP3+CilOUhtC9slTf1QE1m6rbeIQX6B1MXQyG3ghm5nx8zo8aQV3
         znsG/njGzGdfWT6J8JPPgahoFVed3ko7hAESMkKISjx5QlKrHJ+saWkHf1vQNuqqx7EY
         CZFSYfMpcvAnpf48w3xmtAlRlEGhVikdxy3ijT1z5ltxK7SbGqtJiPS868di/wvFBSbB
         7w4BZXEe9Qy2rV4hJoIOEthB1XP6zz1pTkaUN1wZrpJFr3iWCSF1VcEmG5YrDifwwXe+
         wP0Q==
X-Gm-Message-State: APuU4Z+qbRXnHM8ougAnwb0WXlbxdryfcOf5q4wIfJwdOG98SBeS0zWn
	DQjSPrKLRwsN8m4fCH3H7fiRKnc4oX03vV/Ta1k24EUXruK4aeCDvUS0uKguOs43
X-Gm-Gg: AYBFou3cFFptETC4JAHwAXdvLtjwyItWesWfzK7LBmBDXHGoQtE39jO0rXf7d2OWkrn
	P8nxpB22Hc7Ef+9a8VcnknleZnKsXEKPtISakH3VTpGBkQdBeGBy1J0ZCxcYmp4FFKg4IhUGFA6
	p8h1mzr6cVz0N9sH+NXFjYdj7uwUHtFtP03Jekb58YHDwtCI6IA8kbtWTJFnYoYsqeNEjP1hbju
	cO6z2Id0Ajz+ifWSadW/biZUP4qvHIWzKXgDCyOn2Xy2WBKuykdhCG1CpSXDCCouULFfAN4Dnh7
	cmi+AT8NsLbLT72amQoZvy+3qoFbEsBcDme62PrkO2+eZDK6T5iA/dS9jzO4Nazvnj2rw/ypS36
	aF447x3xZdmYFeoLv3Pk72LSar3ZcZ1BXrhaNazZqbTDMqPMYwPJ1l3Z643GR70uyGCOra+Siqk
	qqHmZ6WiICJXLLxh2asUADoEuM3GUuIl3KV3l9hQZDquwDQNK0p1Z6kI0uT4kRhzxq6WNTJXuJQ
	pTtusnkk0eRRmcEu9b+xkTffxkhVBZ41tezsXwmpGVM+/HZZeG29YtxqYgUCug+f00e9ouGXPBB
	/espJ41ISTAm3mF41uF9lbasMb5tXuIY5SFHSnDBxEL1Owulhl8/qcyCjJt449j81kPbF1ufoHg
	hISjq5vLhxOOMhmxHrIq3
X-Received: by 2002:a05:701b:2917:b0:1a7:979f:ecc0 with SMTP id a92af1059eb24-1b25d335fd1mr5086704c88.27.1794020815696;
        Fri, 06 Nov 2026 19:06:55 -0800 (PST)
Received: from smtpclient.apple (pa49-196-205-9.pa.vic.optusnet.com.au. [49.196.205.9])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-1b25e4fad14sm8818841c88.22.2026.11.06.19.06.54
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2026 19:06:55 -0800 (PST)
From: Evan Champion <evan.champion31@gmail.com>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3901.200.71.1.16\))
Subject: [PATCH] 4.1 server tests: check the GETATTR result in _testCbGetattr
 before using it
Message-Id: <37505443-B677-43AA-894E-026D4F0B5D5A@gmail.com>
Date: Sat, 7 Nov 2026 11:06:41 +0800
Cc: linux-nfs@vger.kernel.org
To: calum.mackay@oracle.com
X-Mailer: Apple Mail (2.3901.200.71.1.16)

_testCbGetattr read obj_attributes from the GETATTR reply before
checking its status. A server may answer that GETATTR with
NFS4ERR_DELAY while it waits for the CB_GETATTR reply (RFC 8881
section 10.4.3), in which case there are no attributes and the test
fails with an AttributeError rather than a result.

Retry the GETATTR on NFS4ERR_DELAY, as a client would, and check the
result before reading the attributes.

Signed-off-by: Evan Champion <evan.champion31@gmail.com>
---
 nfs4.1/server41tests/st_delegation.py | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/nfs4.1/server41tests/st_delegation.py =
b/nfs4.1/server41tests/st_delegation.py
index 41095b9..26373a3 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -340,17 +340,25 @@ def _testCbGetattr(t, env, change=3D0, size=3D0):
       # create a new client session and do a GETATTR
     sess2 =3D env.c1.new_client_session(b"%s_2" % env.testname(t))
-    slot =3D sess2.compound_async([op.putfh(fh), =
op.getattr(1<<FATTR4_CHANGE | 1<<FATTR4_SIZE |
-                                                          =
1<<FATTR4_TIME_ACCESS | 1<<FATTR4_TIME_MODIFY)])
+    getattr_ops =3D [op.putfh(fh), op.getattr(1<<FATTR4_CHANGE | =
1<<FATTR4_SIZE |
+                                            1<<FATTR4_TIME_ACCESS | =
1<<FATTR4_TIME_MODIFY)]
+    slot =3D sess2.compound_async(getattr_ops)
       # wait for the CB_GETATTR
     completed =3D cb.wait(2)
     res =3D sess2.listen(slot)
-    attrs2 =3D res.resarray[-1].obj_attributes
+    # The server may return NFS4ERR_DELAY until the CB_GETATTR reply is =
in;
+    # retry, as a client would
+    tries =3D 0
+    while res.status =3D=3D NFS4ERR_DELAY and tries < 10:
+        env.sleep(1, "GETATTR returned NFS4ERR_DELAY")
+        res =3D sess2.compound(getattr_ops)
+        tries +=3D 1
     sess1.compound([op.putfh(fh), op.delegreturn(deleg.write.stateid)])
-    check(res, [NFS4_OK, NFS4ERR_DELAY])
+    check(res, msg=3D"GETATTR of a file with a write delegation")
     if not completed:
         fail("CB_GETATTR not received")
+    attrs2 =3D res.resarray[-1].obj_attributes
     return attrs1, attrs2
   def testCbGetattrNoChange(t, env):
--  2.54.0 (Apple Git-157)=
