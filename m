From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Fri, 18 Apr 2008 15:46:01 -0400
Message-ID: <24c1515f0804181246lbd40b60jb167484b07b4a6ed@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <20080418173646.GC19038@fieldses.org>
	 <24c1515f0804181111x465d7083o4b78e1ba36b51cb@mail.gmail.com>
	 <20080418182550.GC24552@fieldses.org>
	 <24c1515f0804181131i238a50a7v85ef80299ec2216f@mail.gmail.com>
	 <20080418183443.GE24552@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_8907_22444710.1208547961705"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:27516 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760837AbYDRTqD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2008 15:46:03 -0400
Received: by wa-out-1112.google.com with SMTP id m16so1119887waf.23
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2008 12:46:02 -0700 (PDT)
In-Reply-To: <20080418183443.GE24552@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

------=_Part_8907_22444710.1208547961705
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Fri, Apr 18, 2008 at 2:34 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

>  I was looking at recent git.  Note the most recent tarball on
>  sourceforge.net is 1.1.2, and that has the relevant changes.

There you go, against 1.1.2.


-- 
// Janne

------=_Part_8907_22444710.1208547961705
Content-Type: text/x-patch; name=rmtcall-nsmif.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ff7676zv0
Content-Disposition: attachment; filename=rmtcall-nsmif.patch

LS0tIHJtdGNhbGwuYy5vcmcJMjAwOC0wNC0xOCAxNTo0MToxNi4wMDAwMDAwMDAgLTA0MDAKKysr
IHJtdGNhbGwuYwkyMDA4LTA0LTE4IDE1OjQwOjEyLjAwMDAwMDAwMCAtMDQwMApAQCAtMjcsNiAr
MjcsNyBAQAogI2luY2x1ZGUgPHN5cy90eXBlcy5oPgogI2luY2x1ZGUgPHN5cy9zb2NrZXQuaD4K
ICNpbmNsdWRlIDxzeXMvdGltZS5oPgorI2luY2x1ZGUgPHN5cy9zdGF0Lmg+CiAjaW5jbHVkZSA8
bmV0aW5ldC9pbi5oPgogI2luY2x1ZGUgPG5ldC9pZi5oPgogI2luY2x1ZGUgPGFycGEvaW5ldC5o
PgpAQCAtMzcsNiArMzgsOSBAQAogI2luY2x1ZGUgPG5ldGRiLmg+CiAjaW5jbHVkZSA8c3RyaW5n
Lmg+CiAjaW5jbHVkZSA8dW5pc3RkLmg+CisjaW5jbHVkZSA8ZmNudGwuaD4KKyNpbmNsdWRlIDxl
cnJuby5oPgorI2luY2x1ZGUgPG5ldGRiLmg+CiAjaWZkZWYgSEFWRV9JRkFERFJTX0gKICNpbmNs
dWRlIDxpZmFkZHJzLmg+CiAjZW5kaWYgLyogSEFWRV9JRkFERFJTX0ggKi8KQEAgLTU0LDYgKzU4
LDM0IEBACiAKIHN0YXRpYyB1bnNpZ25lZCBsb25nCXhpZCA9IDA7CS8qIFJQQyBYSUQgY291bnRl
ciAqLwogc3RhdGljIGludAkJc29ja2ZkID0gLTE7CS8qIG5vdGlmeSBzb2NrZXQgKi8KK3N0YXRp
YyBpbnQJCWlmc2V0ID0gMDsKKworLyoKKyAqIE5vdGlmeSBsb2NrZCBvZiBub24tc3RhbmRhcmQg
YmluZGluZyAKKyAqLwordm9pZAorbmxtX25zbV9zZXQodW5zaWduZWQgaW50IGFkZHIpCit7CisJ
c3NpemVfdCBzeiA9IDA7CisJY2hhciBidWZbMjBdOworCWludCBmZDsKKworCWlmICggaWZzZXQg
KQorCQlyZXR1cm4gOworCisJc3ByaW50ZiAoYnVmLCIldSIsYWRkcik7CisKKwlmZCA9IG9wZW4g
KCIvcHJvYy9zeXMvZnMvbmZzL25sbV9uc21faW50ZXJmYWNlIiwgT19SRFdSKTsKKwlpZiAoZmQg
PiAwKSB7CisJCXN6ID0gd3JpdGUgKGZkLGJ1ZixzdHJsZW4oKGNoYXIqKWJ1ZikpOworCQlpZiAo
IHN6ID09IC0xICkKKwkJCW5vdGUoTl9DUklULCAic3RhdGQ6IHdyaXRlOiAlc1xuIiwgc3RyZXJy
b3IoZXJybm8pKTsKKwkJY2xvc2UgKGZkKTsKKwl9IGVsc2UKKwkJbm90ZShOX0NSSVQsICJzdGF0
ZDogLW4gd2FzIHNwZWNpZmllZCB3aXRoIHdpdGggbm8ga2VybmVsIHN1cHBvcnQ/XG4iKTsKKwor
CWlmc2V0ID0gMTsKK30KIAogLyoKICAqIEluaXRpYWxpemUgY2FsbGJhY2sgc29ja2V0CkBAIC02
Myw2ICs5NSw3IEBAIHN0YXRkX2dldF9zb2NrZXQodm9pZCkKIHsKIAlzdHJ1Y3Qgc29ja2FkZHJf
aW4Jc2luOwogCXN0cnVjdCBzZXJ2ZW50ICpzZTsKKwlzdHJ1Y3QgaG9zdGVudCAqaHA7CiAJaW50
IGxvb3BjbnQgPSAxMDA7CiAKIAlpZiAoc29ja2ZkID49IDApCkBAIC03NywxMSArMTEwLDE4IEBA
IHN0YXRkX2dldF9zb2NrZXQodm9pZCkKIAkJCXJldHVybiAtMTsKIAkJfQogCi0KIAkJbWVtc2V0
KCZzaW4sIDAsIHNpemVvZihzaW4pKTsKIAkJc2luLnNpbl9mYW1pbHkgPSBBRl9JTkVUOwogCQlz
aW4uc2luX2FkZHIuc19hZGRyID0gSU5BRERSX0FOWTsKIAorCQlpZiAoTVlfTkFNRSkgeworCQkJ
aHAgPSBnZXRob3N0YnluYW1lKE1ZX05BTUUpOworCQkJaWYgKGhwKSB7CisJCQkJc2luLnNpbl9h
ZGRyID0gKihzdHJ1Y3QgaW5fYWRkciAqKSBocC0+aF9hZGRyOworCQkJCW5sbV9uc21fc2V0ICgo
dW5zaWduZWQgaW50KXNpbi5zaW5fYWRkci5zX2FkZHIpOworCQkJfQorCQl9IAorCiAJCWlmIChi
aW5kcmVzdnBvcnQoc29ja2ZkLCAmc2luKSA8IDApIHsKIAkJCWRwcmludGYoTl9XQVJOSU5HLAog
CQkJCSJwcm9jZXNzX2hvc3RzOiBjYW4ndCBiaW5kIHRvIHJlc2VydmVkIHBvcnRcbiIpOwo=
------=_Part_8907_22444710.1208547961705--
