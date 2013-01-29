Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f46.google.com ([209.85.210.46]:36720 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957Ab3A2FQX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jan 2013 00:16:23 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so34590dak.5
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 21:16:23 -0800 (PST)
Date: Tue, 29 Jan 2013 13:16:06 +0800
From: majianpeng <majianpeng@gmail.com>
To: bfields <bfields@fieldses.org>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Reply-To: majianpeng <majianpeng@gmail.com>
Subject: [PATCH 2/2] nfsd: Fix memleak.
Mime-Version: 1.0
Message-ID: <201301291315585633212@gmail.com>
Content-Type: text/plain;
	charset="gb2312"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

V2hlbiBmcmVlIG5mcy1jbGllbnQsIGl0IG11c3QgZnJlZSB0aGUgLT5jbF9zdGF0ZWlkcy4NCg0K
U2lnbmVkLW9mZi1ieTogSmlhbnBlbmcgTWEgPG1hamlhbnBlbmdAZ21haWwuY29tPg0KLS0tDQog
ZnMvbmZzZC9uZnM0c3RhdGUuYyB8ICAgIDIgKysNCiAxIGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRp
b25zKCspDQoNCmRpZmYgLS1naXQgYS9mcy9uZnNkL25mczRzdGF0ZS5jIGIvZnMvbmZzZC9uZnM0
c3RhdGUuYw0KaW5kZXggYWM4ZWQ5Ni4uYTgzMDljNiAxMDA2NDQNCi0tLSBhL2ZzL25mc2QvbmZz
NHN0YXRlLmMNCisrKyBiL2ZzL25mc2QvbmZzNHN0YXRlLmMNCkBAIC0xMDYwLDYgKzEwNjAsOCBA
QCBmcmVlX2NsaWVudChzdHJ1Y3QgbmZzNF9jbGllbnQgKmNscCkNCiAJfQ0KIAlmcmVlX3N2Y19j
cmVkKCZjbHAtPmNsX2NyZWQpOw0KIAlrZnJlZShjbHAtPmNsX25hbWUuZGF0YSk7DQorCWlkcl9y
ZW1vdmVfYWxsKCZjbHAtPmNsX3N0YXRlaWRzKTsNCisJaWRyX2Rlc3Ryb3koJmNscC0+Y2xfc3Rh
dGVpZHMpOw0KIAlrZnJlZShjbHApOw0KIH0NCiANCi0tIA0KMS43LjkuNQ0K

