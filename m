Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:40871 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751368AbeFCQe6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Jun 2018 12:34:58 -0400
Received: by mail-wm0-f47.google.com with SMTP id x2-v6so10308694wmh.5
        for <linux-nfs@vger.kernel.org>; Sun, 03 Jun 2018 09:34:58 -0700 (PDT)
Received: from [192.168.25.210] (dslb-002-203-092-011.002.203.pools.vodafone-ip.de. [2.203.92.11])
        by smtp.gmail.com with ESMTPSA id e188-v6sm10296286wmf.21.2018.06.03.09.34.56
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 03 Jun 2018 09:34:56 -0700 (PDT)
Message-ID: <1528043693.3598.6.camel@gmail.com>
Subject: Re: tools/locktest/testlk.c:84: argument 4 has type
 =?UTF-8?Q?=E2=80=98=5F=5Foff64=5Ft?= {aka long long
 =?UTF-8?Q?int}=E2=80=99?=
From: Philipp Psurek <philipp.psurek@gmail.com>
To: linux-nfs@vger.kernel.org
Date: Sun, 03 Jun 2018 18:34:53 +0200
In-Reply-To: <1528043420.3598.4.camel@gmail.com>
References: <1528043420.3598.4.camel@gmail.com>
Content-Type: multipart/mixed; boundary="=-Bt0D1A/8XGl+0HiAtLKA"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-Bt0D1A/8XGl+0HiAtLKA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hi again,

i see, email likes also no tabs. Patch as attachment.

best regards
  Philipp
--=-Bt0D1A/8XGl+0HiAtLKA
Content-Disposition: attachment; filename="testlk.c.patch"
Content-Transfer-Encoding: base64
Content-Type: text/x-patch; name="testlk.c.patch"; charset="UTF-8"

ZmwubF9zdGFydCBhbmQgZmwubF9sZW4gYXJlIDY0IGJpdCB3aWRlLiBJdCBoYXMgYmVlbiBhc3N1
bWVkIHRoYXQgbG9uZwppcyA2NCBiaXQgaW4gYSBwcmludGYoKSwgd2hpY2ggaXMgaW5jb3JyZWN0
IG9uIGEgMzIgYml0IGFyY2h0ZWN0dXJlCgoqIDFzdCBjaGFuZ2Ugc3VwcHJlc3MgZmFsbCB0aHJv
dWdoIHdhcm5pbmcgZnJvbSBnY2MtNyBhbmQgaGlnaGVyCiogMm5kIGNoYW5nZSByZW1vdmVzIHdo
aXRlc3BhY2UKKiAzcmQgY2hhbmdlIGlzIHRoaXMgYnVnIGFuZCBjaGFuZ2VzIHRoaXMgaW50byBh
IGxvbmcgbG9uZwoKU2lnbmVkLW9mZi1ieTogUGhpbGlwcCBQc3VyZWsgPHBoaWxpcHAucHN1cmVr
QGdtYWlsLmNvbT4KLS0tCgotLS0gYS90b29scy9sb2NrdGVzdC90ZXN0bGsuYyAgICAyMDE4LTA1
LTIyIDIwOjMzOjAxLjAwMDAwMDAwMCArMDIwMAorKysgYi90b29scy9sb2NrdGVzdC90ZXN0bGsu
YyAgICAyMDE4LTA2LTAzIDE3OjI2OjM2LjgwMDIwMjkwMSArMDIwMApAQCAtMjgsNiArMjgsNyBA
QAogCQlzd2l0Y2ggKGMpIHsKIAkJY2FzZSAnaCc6CiAJCQl1c2FnZSgwKTsKKwkJCS8qIGZhbGwg
dGhyb3VnaCAqLwogCQljYXNlICdyJzoKIAkJCWNtZCA9IEZfU0VUTEs7CiAJCQl0eXAgPSBGX1JE
TENLOwpAQCAtNzUsMTMgKzc2LDEzIEBACiAJaWYgKGZjbnRsKGZkLCBjbWQsICZmbCkgPCAwKQog
CQlmYXRhbCgiZmNudGwiKTsKIAlwcmludGYoImZjbnRsOiBva1xuIik7Ci0JCisKIAkvKiBwcmlu
dGYoIlRQMlxuIik7ICovCiAJaWYgKGNtZCA9PSBGX0dFVExLKSB7CiAJCWlmIChmbC5sX3R5cGUg
PT0gRl9VTkxDSykgewogCQkJcHJpbnRmKCIlczogbm8gY29uZmxpY3RpbmcgbG9ja1xuIiwgZm5h
bWUpOwogCQl9IGVsc2UgewotCQkJcHJpbnRmKCIlczogY29uZmxpY3RpbmcgbG9jayBieSAlZCBv
biAoJWxkOyVsZClcbiIsCisJCQlwcmludGYoIiVzOiBjb25mbGljdGluZyBsb2NrIGJ5ICVkIG9u
ICglbGxkOyVsbGQpXG4iLAogCQkJCWZuYW1lLCBmbC5sX3BpZCwgZmwubF9zdGFydCwgZmwubF9s
ZW4pOwogCQl9CiAJCXJldHVybiAwOwoK


--=-Bt0D1A/8XGl+0HiAtLKA--

