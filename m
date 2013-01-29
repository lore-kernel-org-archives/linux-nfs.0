Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:51395 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752911Ab3A2FQT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jan 2013 00:16:19 -0500
Received: by mail-pa0-f46.google.com with SMTP id kp14so157172pab.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 21:16:18 -0800 (PST)
Date: Tue, 29 Jan 2013 13:16:01 +0800
From: majianpeng <majianpeng@gmail.com>
To: bfields <bfields@fieldses.org>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Reply-To: majianpeng <majianpeng@gmail.com>
Subject: [PATCH 1/2] nfsd: Fix memleak.
Mime-Version: 1.0
Message-ID: <201301291315544246751@gmail.com>
Content-Type: text/plain;
	charset="gb2312"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SW4gZnVuYyBzdmNfZXhwb3J0X3BhcnNlLHRoZSB1dWlkIHdoaWNoIHVzZWQga21lbWR1cCB0byBh
bGxvYyB3aWxsIGJlDQpjaGFuZ2VkIGluIGZ1bmMgZXhwb3J0X3VwZGF0ZS5TbyB0aGUgbGF0ZXIg
a2ZyZWUgZG9uJ3QgZnJlZSB0aGlzIG1lbW9yeS4NCkFuZCBpdCBjYW4ndCBiZSBmcmVlIGluIGZ1
bmMgc3ZjX2V4cG9ydF9wYXJzZSBiZWNhdXNlIG90aGVyIHBsYWNlIHN0aWxsDQp1c2VkLlNvIHB1
dCB0aGlzIG9wZXJhdGlvbiBpbiBmdW5jIHN2Y19leHBvcnRfcHV0Lg0KDQpTaWduZWQtb2ZmLWJ5
OiBKaWFucGVuZyBNYSA8bWFqaWFucGVuZ0BnbWFpbC5jb20+DQotLS0NCiBmcy9uZnNkL2V4cG9y
dC5jIHwgICAgMSArDQogMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspDQoNCmRpZmYgLS1n
aXQgYS9mcy9uZnNkL2V4cG9ydC5jIGIvZnMvbmZzZC9leHBvcnQuYw0KaW5kZXggYTM5NDZjZi4u
NDUxNTllZSAxMDA2NDQNCi0tLSBhL2ZzL25mc2QvZXhwb3J0LmMNCisrKyBiL2ZzL25mc2QvZXhw
b3J0LmMNCkBAIC0zMTUsNiArMzE1LDcgQEAgc3RhdGljIHZvaWQgc3ZjX2V4cG9ydF9wdXQoc3Ry
dWN0IGtyZWYgKnJlZikNCiAJcGF0aF9wdXQoJmV4cC0+ZXhfcGF0aCk7DQogCWF1dGhfZG9tYWlu
X3B1dChleHAtPmV4X2NsaWVudCk7DQogCW5mc2Q0X2ZzbG9jc19mcmVlKCZleHAtPmV4X2ZzbG9j
cyk7DQorCWtmcmVlKGV4cC0+ZXhfdXVpZCk7DQogCWtmcmVlKGV4cCk7DQogfQ0KIA0KLS0gDQox
LjcuOS41DQo=

