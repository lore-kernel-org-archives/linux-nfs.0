Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:42601 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766Ab1FANhR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Jun 2011 09:37:17 -0400
Received: from [10.30.3.27] ([10.30.3.27])
	(authenticated bits=0)
	by relay.sw.ru (8.13.4/8.13.4) with ESMTP id p51Dd3sa007210
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 1 Jun 2011 17:39:04 +0400 (MSD)
Message-ID: <4DE6408A.8050105@parallels.com>
Date: Wed, 01 Jun 2011 17:37:14 +0400
From: Vasily Averin <vvs@parallels.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] lockd: properly convert be32 values in debug messages
Content-Type: multipart/mixed;
 boundary="------------040308090600050507000400"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------040308090600050507000400
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit


--------------040308090600050507000400
Content-Type: text/plain;
 name="diff-sunrpc-debug-20110601-2"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="diff-sunrpc-debug-20110601-2"

RnJvbSBiZTFlNGZhNDVhYTBjODI4ZDJlODY0YzE2MDg1N2E0MWQyZGUwNTMxIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBWYXNpbHkgQXZlcmluIDx2dnNAc3cucnU+CkRhdGU6IFdlZCwg
MSBKdW4gMjAxMSAxNjo1NDozMiArMDQwMApTdWJqZWN0OiBbUEFUQ0ggMi8yXSBsb2NrZDogcHJv
cGVybHkgY29udmVydCBiZTMyIHZhbHVlcyBpbiBkZWJ1ZyBtZXNzYWdlcwoKbG9ja2Q6IHNlcnZl
ciByZXR1cm5zIHN0YXR1cyA1MDMzMTY0OCAKaXQncyBxdWl0ZSBoYXJkIHRvIHVuZGVyc3RhbmQg
dGhhdCBudW1iZXIgaW4gdGhpcyBtZXNzYWdlIGlzIDMgaW4gYmlnIGVuZGlhbgoKU2lnbmVkLW9m
Zi1ieTogVmFzaWx5IEF2ZXJpbiA8dnZzQHN3LnJ1PgotLS0KIGZzL2xvY2tkL2NsbnRwcm9jLmMg
fCAgICA5ICsrKysrKy0tLQogMSBmaWxlcyBjaGFuZ2VkLCA2IGluc2VydGlvbnMoKyksIDMgZGVs
ZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZnMvbG9ja2QvY2xudHByb2MuYyBiL2ZzL2xvY2tkL2Ns
bnRwcm9jLmMKaW5kZXggYWRiNDVlYy4uYWNlZjZiNyAxMDA2NDQKLS0tIGEvZnMvbG9ja2QvY2xu
dHByb2MuYworKysgYi9mcy9sb2NrZC9jbG50cHJvYy5jCkBAIC0zMDIsNyArMzAyLDggQEAgbmxt
Y2xudF9jYWxsKHN0cnVjdCBycGNfY3JlZCAqY3JlZCwgc3RydWN0IG5sbV9ycXN0ICpyZXEsIHUz
MiBwcm9jKQogCQkJCS8qIFdlIGFwcGVhciB0byBiZSBvdXQgb2YgdGhlIGdyYWNlIHBlcmlvZCAq
LwogCQkJCXdha2VfdXBfYWxsKCZob3N0LT5oX2dyYWNld2FpdCk7CiAJCQl9Ci0JCQlkcHJpbnRr
KCJsb2NrZDogc2VydmVyIHJldHVybnMgc3RhdHVzICVkXG4iLCByZXNwLT5zdGF0dXMpOworCQkJ
ZHByaW50aygibG9ja2Q6IHNlcnZlciByZXR1cm5zIHN0YXR1cyAlZFxuIiwKKwkJCQludG9obChy
ZXNwLT5zdGF0dXMpKTsKIAkJCXJldHVybiAwOwkvKiBPa2F5LCBjYWxsIGNvbXBsZXRlICovCiAJ
CX0KIApAQCAtNjkwLDcgKzY5MSw4IEBAIG5sbWNsbnRfdW5sb2NrKHN0cnVjdCBubG1fcnFzdCAq
cmVxLCBzdHJ1Y3QgZmlsZV9sb2NrICpmbCkKIAkJZ290byBvdXQ7CiAKIAlpZiAocmVzcC0+c3Rh
dHVzICE9IG5sbV9sY2tfZGVuaWVkX25vbG9ja3MpCi0JCXByaW50aygibG9ja2Q6IHVuZXhwZWN0
ZWQgdW5sb2NrIHN0YXR1czogJWRcbiIsIHJlc3AtPnN0YXR1cyk7CisJCXByaW50aygibG9ja2Q6
IHVuZXhwZWN0ZWQgdW5sb2NrIHN0YXR1czogJWRcbiIsCisJCQludG9obChyZXNwLT5zdGF0dXMp
KTsKIAkvKiBXaGF0IHRvIGRvIG5vdz8gSSdtIG91dCBvZiBteSBkZXB0aC4uLiAqLwogCXN0YXR1
cyA9IC1FTk9MQ0s7CiBvdXQ6CkBAIC04MzcsNiArODM5LDcgQEAgbmxtX3N0YXRfdG9fZXJybm8o
X19iZTMyIHN0YXR1cykKIAkJcmV0dXJuIC1FTk9MQ0s7CiAjZW5kaWYKIAl9Ci0JcHJpbnRrKEtF
Uk5fTk9USUNFICJsb2NrZDogdW5leHBlY3RlZCBzZXJ2ZXIgc3RhdHVzICVkXG4iLCBzdGF0dXMp
OworCXByaW50ayhLRVJOX05PVElDRSAibG9ja2Q6IHVuZXhwZWN0ZWQgc2VydmVyIHN0YXR1cyAl
ZFxuIiwKKwkJIG50b2hsKHN0YXR1cykpOwogCXJldHVybiAtRU5PTENLOwogfQotLSAKMS43LjQu
MQoK

--------------040308090600050507000400--
