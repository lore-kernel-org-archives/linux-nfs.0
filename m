Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36296 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751044Ab3IJTbl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Sep 2013 15:31:41 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFSv4.1: clean up after using machine cred
Date: Tue, 10 Sep 2013 19:31:39 +0000
Message-ID: <1378841499.21916.22.camel@leira.trondhjem.org>
References: <1378839358-10389-1-git-send-email-dros@netapp.com>
	 <1378839358-10389-2-git-send-email-dros@netapp.com>
In-Reply-To: <1378839358-10389-2-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEzLTA5LTEwIGF0IDE0OjU1IC0wNDAwLCBXZXN0b24gQW5kcm9zIEFkYW1zb24g
d3JvdGU6DQo+IENsaWVudCBjYWxscyBnZXRfcnBjY3JlZCB3aGVuIHJlZmVyZW5jaW5nIHRoZSBt
YWNoaW5lIGNyZWQsIHNvIGl0IG11c3QgY2FsbA0KPiBwdXRfcnBjY3JlZCBhZnRlciBwYXNzaW5n
IGNyZWQgdG8gcnBjIGxheWVyLg0KPiANCj4gVGhpcyBwYXRjaCBhbHNvIG1vdmVzIG5mczRfc3A0
X2luaXQgKGZvcm1lcmx5IG5mczRfc3RhdGVfcHJvdGVjdCkgdG8gcmlnaHQNCj4gYmVmb3JlIHRo
ZSBjYWxsIHRvIHJwY19ydW5fdGFzayAoYW5kIHdyYXBwZXJzIG9mIHJwY19ydW5fdGFzaykgdG8g
bWluaW1pemUNCj4gZXJyb3IgcGF0aCBjbGVhbnVwIGNvZGUuDQo+IA0KDQpEbyB3ZSByZWFsbHkg
bmVlZCB0aGlzPyBBRkFJQ1Mgb25jZSB0aGUgY2xwLT5jbF9tYWNoaW5lX2NyZWQgaXMgc2V0LCBp
dA0KaXNuJ3QgZnJlZWQgdW50aWwgdGhlIGNhbGwgdG8gbmZzX2ZyZWVfY2xpZW50KCkuIEluIGZh
Y3QsIHdlIHByb2JhYmx5DQpfcmVseV8gb24gdGhpcyBiZWluZyB0aGUgY2FzZSBmb3IgU1A0X01B
Q0hfQ1JFRCwgc2luY2UgaWYgdGhlIG1hY2hpbmUNCmNyZWQgd2VyZSB0byBjaGFuZ2UsIHdlJ2Qg
bm8gbG9uZ2VyIGJlIGFibGUgdG8gY2hhbmdlIG91ciBzZXNzaW9uIG9yDQpsZWFzZS4NCg0KSU9X
OiBpbnN0ZWFkIG9mIHJlZmVyZW5jaW5nIHRoZSBjcmVkIHZpYSBnZXQvcHV0X3JwY2NyZWQoKSwg
bWF5YmUgd2UgY2FuDQpqdXN0IGZlZWQgdGhlIGN1cnJlbnQgdmFsdWUgb2YgY2xwLT5jbF9tYWNo
aW5lX2NyZWQgaW50byB0aGUNCm1zZy0+cnBjX2NyZWQuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0
DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RA
bmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg==
