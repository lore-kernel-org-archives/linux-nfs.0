Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.229.137
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794020911;
	b=RyCCS6RhirYZBafUuyFlIt5+WCUazI+7rRXuaTIfalErogxNd/yvJ+WKx0TN8oi/uyjD
	 QXGAvDyGP4xx+7OL7xgmBYEbH+9IYtqIUHXkAt9wEqL2YTlS0yMoLdKpSlWWxguEHtlJF
	 ilVLoCxb9PLDKKXqbl8LpEZTYXRDcn6SXIosVtzvMiCljKZDIyPRVXJbhWrvhNoiGDMex
	 BPl7DvxygDt6uj3r5prL2ymZUuGvokUoSVNSWK15r695lq2Xh656aYr9+oGDELqdrmSDr
	 /bsNWSutCf30uiOYeuhksg3anA5y4q75dEeE0JEchQc5MmoSHFtBrfoSo4WmJtMVBHA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794020911;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:Content-Type:
	 Content-Transfer-Encoding:Mime-Version:Subject:Message-Id:Date:Cc:To:
	 X-Mailer;
	bh=Q4ukWM7DpgFNrydoMRpyPkCUicGMK+tCe1e4JeuavAw=;
	b=wlxs/Q5o6XeC2vYJwsVmlmg3qNirXIxPvvyIHTL70gxPGE1UuIDt+9E3q9Pdo/1MwHrM
	 N1EP55k4gp1KZ9UGOVD3p/58502V7eF12bVj4dZgPfQOUvnrxyhtz9BBPE4p5h6wDQC/5
	 d6sXw2UMbTcCy1Pp0G2vgESGcEXl9CXLG2KDe4ml3wWPoGJoKtkqVfS1NnHzDJJpWf1GP
	 tIFT3bEdynlNrtEKmRFhGPRuCZnx2ebaO0SdL0mcZZGA4Y///nkDiYVLzRKtknGrtlHmD
	 /6J/vc4s5LVb7MnjjYqyYC/1cGIvduiyEq2Jm6PIaGbMt7h7Q4YWE90+FhPyA2EXwKw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=VrW3faqh;
	arc=none smtp.remote-ip=74.125.229.137
Received: from mail-dl2-f9.google.com (mail-dl2-f9.google.com [74.125.229.137])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57DAA606A326
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 03:08:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 57DAA606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=VrW3faqh
Received: by mail-dl2-f9.google.com with SMTP id a92af1059eb24-19305bcb6d5so318927c88.0
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2026 19:08:31 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794020910; x=1794625710; darn=vger.kernel.org;
        h=to:cc:date:message-id:subject:mime-version
         :content-transfer-encoding:content-type:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Q4ukWM7DpgFNrydoMRpyPkCUicGMK+tCe1e4JeuavAw=;
        b=VrW3faqhRLDiqG665Iz2oKMC3CnRHv91xXTceaFrQD8vZlMHmt1yAA9WGMkW864GvY
         wBZyMq42kp8vIKxhqpD7DewHA/valK+ohNM3mnu6AFeJrxXDbmFuLxFspG32lbwl0dUf
         WSOrL6joEIDFTwr4ZukC/xWa+xg1yDIYx0rrLzu1bJuNtl0KLiATgu53hd1CNReFaNcV
         9RFczwUa1Hw17aqu7rW1dCt8BwWk46u6xuz7+SqKzeV4MbLZLkge5HErujGmc0m2Ydb5
         TijdD0iVAuQozuHFq95rUYtRufzbC6cYJRHVmsjkdQxCruQ7gQGJlfvlz1Ekp6xj6PH0
         v6kw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794020910; x=1794625710;
        h=to:cc:date:message-id:subject:mime-version
         :content-transfer-encoding:content-type:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Q4ukWM7DpgFNrydoMRpyPkCUicGMK+tCe1e4JeuavAw=;
        b=mCA7NvJfOWb7dV2Cgn8aLGZUf8odAkG+36F5R/izhhn5A66O5tkzoMDXZxbw4r5xdn
         /HYH5Nm+o4dxGQC5ajvNi0lb3mPzjERsauCBfCZJco/VnEUbyNh+Oxle8Gf9H1KkyA2K
         XvogaVF5jhTOMvof3LtB9V2evNb1fS1IKNoptTaI1CPeBGPhhTkbvAfaR/9ffK74E5sL
         XLP0pSci3azfzNZ8yZBw6mPmWJqu0kVMkuFfFKkCqlXJb5YzQwpGdJmeC6iA0XPPB8UR
         A3EAVopLeA+apZY7iOYSV0saUyFOzfDWMV56tMxHSbL1C7J9erphJUQG/KkfP4jJcJMK
         yAlw==
X-Gm-Message-State: APuU4Z9GcJ2SQH9dPAyVWErPHZxRBmmA42N/sYadUA+Yky2I1ZgqsqhM
	4vGVdmxFX5XCImbLYisoCdTYgBUJVrfGktuPDf1bOSqVE807QhR8kmfu
X-Gm-Gg: AYBFou2Vsa0KRbicI4wmpZWbxsqLIOZBoFu+rIeAwBmcvnavmW7CwVz1xw0Sjog3bh+
	/KWqXxgXkEt5+eZpFkWrN474u5gppxUM2BX+FNqKFv0k2QABD51pQoE4ZEjMIM2HgXLXwU836l6
	NW2/I2H8N2DH8TBEVzwVF4zKeUJE5aIQ9sLBJ4fyv+26D1aCecf3N6FODktAO/PLAZ28iL8GTGd
	AWfq0gTxjiV/Nv+095nTNzspg1+1M92gX2yu9zUuw5t/P3NaHyJb6MnFBmeYbApumc4AvSYEE2/
	XdfgAm6CelXGUIGsCcoS/BKPxr+dUsiB1LlEhADBZ9ZnhioHCb1YLSYCa1Gde1H3Hpr06qj2DLr
	eAupNqnsytaB8adj/yZzEY09PyKFfc4lzn5BYrCXZi9NN7Pl/2/8BEXg5puEXHf0zDmtNYXDZuj
	o8TFEX1jNfC4iCJ44+CDaFiZ6UuDtj8GEbSyrihCrllykw1sWaw9L4krQ4lzVCBw6+pl183CLbP
	hP1Lwut36mTIR+v9dTx0fi7HsgLGvdG7IonLA/O5WeLwiPFc4OsWaoW9T4FfqGUEf7dommYAkyx
	tpVSgpd/T3dTPLqi2cLeRiyHtsEYv9hDNgWg/EuZDQHBtCJINlFHuEO1HF5aEhNDkXlqs43KaDi
	mg0OR5pVodUctXzeQt4fw7A==
X-Received: by 2002:a05:701b:424c:10b0:195:1a77:85cb with SMTP id a92af1059eb24-1b25d28c302mr5621868c88.1.1794020910303;
        Fri, 06 Nov 2026 19:08:30 -0800 (PST)
Received: from smtpclient.apple (pa49-196-205-9.pa.vic.optusnet.com.au. [49.196.205.9])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-1b25e4e079esm11197751c88.19.2026.11.06.19.08.28
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2026 19:08:30 -0800 (PST)
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
Subject: [PATCH] 4.1 server tests: check the BACKCHANNEL_CTL result in
 _testDeleg
Message-Id: <CF4E8861-DE6A-4895-B333-7C67E8142F79@gmail.com>
Date: Sat, 7 Nov 2026 11:08:16 +0800
Cc: linux-nfs@vger.kernel.org
To: calum.mackay@oracle.com
X-Mailer: Apple Mail (2.3901.200.71.1.16)

_testDeleg ignored the result of BACKCHANNEL_CTL. If the server
doesn't support it (it is REQUIRED in RFC 8881), the test carries on
with the original callback security, and later fails or passes for
reasons unrelated to what DELEG7 tests.

Check the result, so such a server fails DELEG7 at BACKCHANNEL_CTL.

Signed-off-by: Evan Champion <evan.champion31@gmail.com>
---
 nfs4.1/server41tests/st_delegation.py | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/nfs4.1/server41tests/st_delegation.py =
b/nfs4.1/server41tests/st_delegation.py
index 26373a3..295401d 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -42,7 +42,8 @@ def _testDeleg(t, env, openaccess, want, breakaccess, =
sec =3D None, sec2 =3D None):
     sess1.client.cb_pre_hook(OP_CB_RECALL, pre_hook)
     sess1.client.cb_post_hook(OP_CB_RECALL, post_hook)
     if sec2:
-        sess1.compound([op.backchannel_ctl(env.c1.prog, sec2)])
+        res =3D sess1.compound([op.backchannel_ctl(env.c1.prog, sec2)])
+        check(res, msg=3D"BACKCHANNEL_CTL")
     fh =3D _create_file_with_deleg(sess1, env.testname(t), openaccess | =
want)
     sess2 =3D env.c1.new_client_session(b"%s_2" % env.testname(t))
     claim =3D open_claim4(CLAIM_NULL, env.testname(t))
--  2.54.0 (Apple Git-157)=
