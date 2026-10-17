Received: from mail-ej1-f46.google.com (mail-ej1-f46.google.com [209.85.218.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE1713B71A7
	for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2026 17:01:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.46
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792256507; cv=pass; b=SmAlWLIUNS4FossnJNRxPfDe7lCOd+p1c3cBoCE8pfz02WHjaI5BToQJrYaUWldDCHF9pZtSJmAunyQmJhqX8laA791TGhNrT/V5zXMymiC8EsUnUp04OEvE+3q+eOM2lKduVe+e3zc1ji2idze41wPUlyJ6SyTRf5r3QdU3lFM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792256507; c=relaxed/simple;
	bh=U+6k4tHlCud8+uUSxkQ4oc7bHvr6VbuB6EP3jJQcORo=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=CUziPwX2cG9wM4ThWXYryCdCWtzZCq23PwmO9L3o9KW/3qSB7g7rtNHRhkewQIg/pA5sUDJyeSeBi1IqcNtKdRNNx9GPDiQTmtQEz5pedMWmXfGTNDwK5jIXqHvayWaS5pSLrSdb94UUorzMWCPvnl0IQJiS1hN4PaXMCMa5cuU=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=grlab.org; spf=pass smtp.mailfrom=grlab.org; dkim=pass (2048-bit key) header.d=grlab.org header.i=@grlab.org header.b=F73hsA0a; arc=pass smtp.client-ip=209.85.218.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=grlab.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=grlab.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=grlab.org header.i=@grlab.org header.b="F73hsA0a"
Received: by mail-ej1-f46.google.com with SMTP id a640c23a62f3a-c2dc63f8d8aso135936066b.0
        for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2026 10:01:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1792256504; cv=none;
        d=google.com; s=arc-20260327;
        b=KPRRMK4NFXdBYq7t9ZEnZYprjFBDBPVyrZF8J7grnmJANvAQe0OeU6TiEbkCHHTk5+
         If4Mq/f1Ygd+xOhmz9NHbujsaXFiLZvaLi0DE2lm7VowF2IiBA4ZwCwsXZ++D/W22GWp
         UpL3dbGxNyBUgNHIGo4MwSCkXMrKQt6IZutnj8DUdhAR2Abzf9+WmLEmFZpP+5i/JIWc
         Tsod6qsH5TYdsP6EmG+tBPlbQ8okA3CwutaFFDlOROCu8/ZUdk3iFEJhCamuVed7L3/T
         zG7cH/fL/TdyVbGfK3zxy0kB9QOmT76TgA8pMFRtFD9z6YkONxuu0M4IPsSVgIIWkvCW
         jugA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=CNLbLgDfaJhkepNzIqsjX6bsMXnjXdo1KXiQco00KUE=;
        fh=Mys3y4MwsHRytUQMpdfGBn3oGRYLcLloxNwkFYMYMmg=;
        b=pUatLPPuhU7GemUWWttdkLMD+PpMzvTOPT3JLdq8dUILKZ8dUuKcHm7htg3ksgfqnE
         We9THzlDG9TeTyJ6EfaR2qcBCgu9K6iqdLUB7eectJjZtXq/oWfUSzWb0EGSmtHM4hRn
         OTiN9whHlu4ducY4rSxdulzwZ5cUOGNLTtjzXpcagVIecEhHJGJiagcbtGY382jxhARG
         HcQxKVZbZXQvzRBphV2qT2RzrEJbI6g0fN1sR9E8BX2I7+wq8gE6AoBqXuG1gM5r89HK
         Oo02DVrXB7vYnxEKAY/CHSO/vSKLczv1M8FCMGGKrFYyQ+gU5pkay/OG9WShF/V/AKcr
         DPjg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=grlab.org; s=google; t=1792256504; x=1792861304; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:mime-version:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=CNLbLgDfaJhkepNzIqsjX6bsMXnjXdo1KXiQco00KUE=;
        b=F73hsA0aGwchjJfTtVj+1N7/uQBqu2uIC0nSzKFkiEvGH8xi/aRTATImoOdaqBTAxB
         BAwKvXlmETImCaPIxQUdx0R2q0kOMagIVk4GAL7vat6aeFGO9U8QSC2NH8F6HHQa3qBr
         dgNC0SuGIrx7iDDVu7ytd5A1WkNG1bkma3UtZrBiAhStEQtqGuvBySp5qhcYLWy9u3C2
         7gTlVuSobda/AP80pc+VMYu7gv1icQb0Q1L5vTgOXIdQ+B4Wzyp1NX/NeHBJD/kJy4j+
         kEWvp1nkC3jSkAotUQpfNpDGymd3crkkjxp3OSaXNqag/AdJpH/2lZBFD8EZTeyTRhg6
         uZFA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792256504; x=1792861304;
        h=content-type:to:subject:message-id:date:from:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=CNLbLgDfaJhkepNzIqsjX6bsMXnjXdo1KXiQco00KUE=;
        b=aeoDiDTmXV23J31iTxNFgp5Ab3cSn/XSVCDppHEqn0eUfqIOOM424H1eyFjYXu+KAV
         h6Y1MK1RZvRnEjWZzlWoeNlSuJHEY5rS4BDr+BKZy2CVmuJK+poV5zEvyU+DS8gEREgK
         nNiBtwwKPJHcJajQE9eH72LuQjnxIIa9AcUXasXxn4KgSFjJXMVrjEY/+8FN+VImmjN0
         rCje0vKaBk83Hme2nx9qzJPmoXT5B7oe2tFWWHsFgSziZS4zdrl7+5X8NnnOfKBL2V5R
         1tv9Ynr4kzh9uMsB/kSglp3F7rk6Z6PeDa4IqQbxuAgB9viCyOh1iCWVYag3Vy4LwQht
         6QlA==
X-Gm-Message-State: AFq9FYJQzUeSw5NYLEqpQs3ihuAWdjWeDrq5vGM9Yb4Vd6arWBWwmymk
	RXAK/0bsOs4pWpPrt3Fvd+pTIk+T1glhKBy0rrqrx5bLmXt831uJ7w2PHe1GscoQ8dvKQDg0FCz
	lKT7eTNs+epZ5GItaV3hyI0wI1ohBUqMHHkUombRg2dEtvMbSH7B86cg=
X-Gm-Gg: AYBFou0CDeWRdD4gbMVI/bLwuQrSedq96KkM8xPTXmx3VEvnWyaxxCAmzuMbQoe/wmZ
	NVpxRa3kpsLfrQ/ENG42SP6E1/TKuufed/R1Kah5QOk53BPMmQKu8vbAHbiWi4EW9iYpVsIfJHA
	B+EglnL0sGtYcjIG9wgWviapr8KhptOTXz7z+6xqrsXsRqW8qcfSA5KKZdfkPkgh5rVpXccw2E6
	gV880g3mswKP2HLH4aFYi32ZlMFBXiT4qQDgjodI/QTx13Q70lTkGvsdywI5oNgAw9WeDbZo7ji
	ISq2YovQFWiDpRafTtEVjmQBFYk6Ljg8aJifzKazv85mOgKPm2/ZOEO1ENTX3xXoln2H6W4kbFP
	AKEJ95DXRDG3E/GTBl24Mw2djmuueWRPN74NGRw9VBI2pARwJBglMiC+RfYIn00CBhedtYXQcgi
	M9IrFlwhlMV+A3uZPt901T0Jq0/w==
X-Received: by 2002:a17:907:6e9f:b0:c41:1750:59a2 with SMTP id
 a640c23a62f3a-c419d54062cmr241711366b.12.1792256503305; Sat, 17 Oct 2026
 10:01:43 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Oleksandr Kulkov <oleksandr.kulkov@grlab.org>
Date: Sat, 17 Oct 2026 19:01:31 +0200
X-Gm-Features: AclHuK-OM1hc9D7V-wQq9ImfOewio5rgQDcrsinx7bD9_Z275xRA1Aqdji8f9wk
Message-ID: <CAL57+vDpROMWjN7QuPbm2CQd=B0hZPTM6h7Cv6q-Gd_rQSTSMg@mail.gmail.com>
Subject: nfs-utils: temporary NSS errors cached as empty group lists
To: linux-nfs@vger.kernel.org
Content-Type: multipart/mixed; boundary="0000000000003a26d6065e0c3c27"

--0000000000003a26d6065e0c3c27
Content-Type: text/plain; charset="UTF-8"

Hello,

With --manage-gids, auth_unix_gid() in support/export/cache.c treats a
getpwuid() failure like an unknown user: it replies with an empty group
list and the normal cache expiry, without checking errno. This can prolong
access denial after a directory-service outage ends.

Could distinguishable lookup errors use a bounded retry or shorter cache
lifetime, while still denying access until group membership is known?

The attached reproducer uses the unchanged handler from commit
5090e0bb662c53b4552b28b121ac2c2c434adb2e, with synthetic NSS responses,
time=100000 and TTL=1800:

  known user:        200001 101800 2 200001 200002
  unknown user:      200001 101800 0
  lookup error/EIO:  200001 101800 0

Run:
  cc -Wall -O0 nfs-cache-reproducer.c -o nfs-cache-reproducer
  ./nfs-cache-reproducer

This tests the procfs handler, not full daemon/kernel integration or the
netlink path. We also found a separate nss_ldap bug that hides the error;
its proposed fix is https://github.com/PADL/nss_ldap/pull/16.

Thanks,
Oleksandr

--0000000000003a26d6065e0c3c27
Content-Type: text/x-csrc; charset="US-ASCII"; name="nfs-cache-reproducer.c"
Content-Disposition: attachment; filename="nfs-cache-reproducer.c"
Content-Transfer-Encoding: base64
Content-ID: <f_mvcn6zzd0>
X-Attachment-Id: f_mvcn6zzd0

LyoKICogTWluaW1hbCBsb2NhbCByZXByb2R1Y3Rpb24gZm9yIG5mcy11dGlscyBhdXRoX3VuaXhf
Z2lkIGVycm9yIGNhY2hpbmcuCiAqIFRoZSBhdXRoX3VuaXhfZ2lkIGZ1bmN0aW9uIGlzIGNvcGll
ZCB1bmNoYW5nZWQgZnJvbSBuZnMtdXRpbHMgY29udHJpYnV0b3JzOgogKiBodHRwczovL2dpdGh1
Yi5jb20vbGludXgtbmZzL25mcy11dGlscy9ibG9iLzUwOTBlMGJiNjYyYzUzYjQ1NTJiMjhiMTIx
YWMyYzJjNDM0YWRiMmUvc3VwcG9ydC9leHBvcnQvY2FjaGUuYwogKiBEaXN0cmlidXRlZCB1bmRl
ciB0aGUgbmZzLXV0aWxzIHByb2plY3QncyBHUEwgdGVybXM7IHNlZSBpdHMgQ09QWUlORyBmaWxl
LgogKiBPdGhlciBmdW5jdGlvbnMgYmVsb3cgYXJlIHN5bnRoZXRpYyB0ZXN0IGZpeHR1cmVzLiBO
byByZWFsIHVzZXJzIG9yIHNlY3JldHMuCiAqLwojaW5jbHVkZSA8c3lzL3NvY2tldC5oPgojaW5j
bHVkZSA8dW5pc3RkLmg+CiNpbmNsdWRlIDxwd2QuaD4KI2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNs
dWRlIDxzdGRsaWIuaD4KI2luY2x1ZGUgPHN0cmluZy5oPgojaW5jbHVkZSA8dGltZS5oPgojaW5j
bHVkZSA8ZXJybm8uaD4KI2luY2x1ZGUgPGFzc2VydC5oPgojZGVmaW5lIFJQQ19DSEFOX0JVRl9T
SVpFIDgxOTIKI2RlZmluZSBJTklUSUFMX01BTkFHRURfR1JPVVBTIDEwMAojZGVmaW5lIExfRVJS
T1IgMAojZGVmaW5lIHhsb2coLi4uKSBhYm9ydCgpCnN0YXRpYyBpbnQgZGVmYXVsdF90dGw9MTgw
MCwgbW9kZTsKc3RhdGljIHN0cnVjdCBwYXNzd2QgZml4dHVyZT17LnB3X25hbWU9InRlc3R1c2Vy
IiwucHdfdWlkPTIwMDAwMSwucHdfZ2lkPTIwMDAwMX07CnN0YXRpYyBzdHJ1Y3QgcGFzc3dkICpt
b2NrX2dldHB3dWlkKHVpZF90IHVpZCl7YXNzZXJ0KHVpZD09MjAwMDAxKTtlcnJubz0obW9kZT09
Mj9FSU86MCk7cmV0dXJuIG1vZGU9PTA/JmZpeHR1cmU6TlVMTDt9CnN0YXRpYyBpbnQgbW9ja19n
ZXRncm91cGxpc3QoY29uc3QgY2hhciAqbmFtZSxnaWRfdCBnaWQsZ2lkX3QgKmdyb3VwcyxpbnQg
Km4peyh2b2lkKW5hbWU7YXNzZXJ0KCpuPj0yKTtncm91cHNbMF09Z2lkO2dyb3Vwc1sxXT0yMDAw
MDI7Km49MjtyZXR1cm4gMjt9CnN0YXRpYyB0aW1lX3QgbW9ja190aW1lKHRpbWVfdCAqcCl7aWYo
cCkqcD0xMDAwMDA7cmV0dXJuIDEwMDAwMDt9CnN0YXRpYyBpbnQgcXdvcmRfZ2V0X3VpbnQoY2hh
ciAqKnAsdW5zaWduZWQgKm4pe2NoYXIgKmVuZDsqbj1zdHJ0b3VsKCpwLCZlbmQsMTApO2lmKGVu
ZD09KnApcmV0dXJuIC0xOypwPWVuZDtyZXR1cm4gMDt9CnN0YXRpYyB2b2lkIHF3b3JkX2FkZHVp
bnQoY2hhciAqKnAsaW50ICpsZWZ0LHVuc2lnbmVkIG4pe2ludCBjb3VudD1zbnByaW50ZigqcCwq
bGVmdCwiJXUgIixuKTthc3NlcnQoY291bnQ+MCYmY291bnQ8KmxlZnQpOypwKz1jb3VudDsqbGVm
dC09Y291bnQ7fQpzdGF0aWMgdm9pZCBxd29yZF9hZGRlb2woY2hhciAqKnAsaW50ICpsZWZ0KXth
c3NlcnQoKmxlZnQ+MSk7KigqcCkrKz0nXG4nOy0tKmxlZnQ7fQojZGVmaW5lIGdldHB3dWlkIG1v
Y2tfZ2V0cHd1aWQKI2RlZmluZSBnZXRncm91cGxpc3QgbW9ja19nZXRncm91cGxpc3QKI2RlZmlu
ZSB0aW1lIG1vY2tfdGltZQpzdGF0aWMgdm9pZCBhdXRoX3VuaXhfZ2lkKGludCBmKQp7CgkvKiBS
ZXF1ZXN0IGFyZQoJICogIHVpZAoJICogcmVwbHkgaXMKCSAqICB1aWQgZXhwaXJ5IGNvdW50IGxp
c3Qgb2YgZ3JvdXAgaWRzCgkgKi8KCXVpZF90IHVpZDsKCXN0cnVjdCBwYXNzd2QgKnB3OwoJc3Rh
dGljIGdpZF90ICpncm91cHMgPSBOVUxMOwoJc3RhdGljIGludCBncm91cHNfbGVuID0gMDsKCWdp
ZF90ICptb3JlX2dyb3VwczsKCWludCBuZ3JvdXBzOwoJaW50IHJ2LCBpOwoJY2hhciBidWZbUlBD
X0NIQU5fQlVGX1NJWkVdLCAqYnA7CglpbnQgYmxlbjsKCglpZiAoZ3JvdXBzX2xlbiA9PSAwKSB7
CgkJZ3JvdXBzID0gbWFsbG9jKHNpemVvZihnaWRfdCkgKiBJTklUSUFMX01BTkFHRURfR1JPVVBT
KTsKCQlpZiAoIWdyb3VwcykKCQkJcmV0dXJuOwoKCQlncm91cHNfbGVuID0gSU5JVElBTF9NQU5B
R0VEX0dST1VQUzsKCX0KCgluZ3JvdXBzID0gZ3JvdXBzX2xlbjsKCglibGVuID0gcmVhZChmLCBi
dWYsIHNpemVvZihidWYpKTsKCWlmIChibGVuIDw9IDAgfHwgYnVmW2JsZW4tMV0gIT0gJ1xuJykg
cmV0dXJuOwoJYnVmW2JsZW4tMV0gPSAwOwoKCWJwID0gYnVmOwoJaWYgKHF3b3JkX2dldF91aW50
KCZicCwgJnVpZCkgIT0gMCkKCQlyZXR1cm47CgoJcHcgPSBnZXRwd3VpZCh1aWQpOwoJaWYgKCFw
dykKCQlydiA9IC0xOwoJZWxzZSB7CgkJcnYgPSBnZXRncm91cGxpc3QocHctPnB3X25hbWUsIHB3
LT5wd19naWQsIGdyb3VwcywgJm5ncm91cHMpOwoJCWlmIChydiA9PSAtMSAmJiBuZ3JvdXBzID49
IGdyb3Vwc19sZW4pIHsKCQkJbW9yZV9ncm91cHMgPSByZWFsbG9jKGdyb3Vwcywgc2l6ZW9mKGdp
ZF90KSpuZ3JvdXBzKTsKCQkJaWYgKCFtb3JlX2dyb3VwcykKCQkJCXJ2ID0gLTE7CgkJCWVsc2Ug
ewoJCQkJZ3JvdXBzID0gbW9yZV9ncm91cHM7CgkJCQlncm91cHNfbGVuID0gbmdyb3VwczsKCQkJ
CXJ2ID0gZ2V0Z3JvdXBsaXN0KHB3LT5wd19uYW1lLCBwdy0+cHdfZ2lkLAoJCQkJCQkgIGdyb3Vw
cywgJm5ncm91cHMpOwoJCQl9CgkJfQoJfQoKCWJwID0gYnVmOyBibGVuID0gc2l6ZW9mKGJ1Zik7
Cglxd29yZF9hZGR1aW50KCZicCwgJmJsZW4sIHVpZCk7Cglxd29yZF9hZGR1aW50KCZicCwgJmJs
ZW4sIHRpbWUoMCkgKyBkZWZhdWx0X3R0bCk7CglpZiAocnYgPj0gMCkgewoJCXF3b3JkX2FkZHVp
bnQoJmJwLCAmYmxlbiwgbmdyb3Vwcyk7CgkJZm9yIChpPTA7IGk8bmdyb3VwczsgaSsrKQoJCQlx
d29yZF9hZGR1aW50KCZicCwgJmJsZW4sIGdyb3Vwc1tpXSk7Cgl9IGVsc2UKCQlxd29yZF9hZGR1
aW50KCZicCwgJmJsZW4sIDApOwoJcXdvcmRfYWRkZW9sKCZicCwgJmJsZW4pOwoJaWYgKGJsZW4g
PD0gMCB8fCB3cml0ZShmLCBidWYsIGJwIC0gYnVmKSAhPSBicCAtIGJ1ZikKCQl4bG9nKExfRVJS
T1IsICJhdXRoX3VuaXhfZ2lkOiBlcnJvciB3cml0aW5nIHJlcGx5Iik7Cn0KCmludCBtYWluKHZv
aWQpewogY29uc3QgY2hhciAqbmFtZXNbXT17ImV4aXN0aW5nX3VzZXIiLCJ1bmtub3duX3VzZXIi
LCJ0ZW1wb3JhcnlfbG9va3VwX2Vycm9yIn07CiBjaGFyIHNhdmVkWzNdWzI1Nl07CiBmb3IobW9k
ZT0wO21vZGU8Mzttb2RlKyspewogIGludCBwYWlyWzJdO2Fzc2VydCghc29ja2V0cGFpcihBRl9V
TklYLFNPQ0tfU1RSRUFNLDAscGFpcikpOwogIGFzc2VydCh3cml0ZShwYWlyWzBdLCIyMDAwMDFc
biIsNyk9PTcpO2F1dGhfdW5peF9naWQocGFpclsxXSk7CiAgc3NpemVfdCBuPXJlYWQocGFpclsw
XSxzYXZlZFttb2RlXSxzaXplb2Yoc2F2ZWRbbW9kZV0pLTEpO2Fzc2VydChuPjApO3NhdmVkW21v
ZGVdW25dPTA7CiAgcHJpbnRmKCJjYXNlPSVzIHJlcGx5PSVzIixuYW1lc1ttb2RlXSxzYXZlZFtt
b2RlXSk7Y2xvc2UocGFpclswXSk7Y2xvc2UocGFpclsxXSk7CiB9CiBhc3NlcnQoc3Ryc3RyKHNh
dmVkWzBdLCIyIDIwMDAwMSAyMDAwMDIiKSk7YXNzZXJ0KCFzdHJjbXAoc2F2ZWRbMV0sc2F2ZWRb
Ml0pKTsKIHB1dHMoImNhc2VzX2NoZWNrZWQ9My8zIHRyYW5zaWVudF9lcnJvcl9hbmRfbWlzc2lu
Z191c2VyX2VtaXRfc2FtZV9yZXBseT15ZXMiKTsKfQo=
--0000000000003a26d6065e0c3c27--
