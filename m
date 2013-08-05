Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:7691 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751922Ab3HEO75 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Aug 2013 10:59:57 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Julia Lawall <Julia.Lawall@lip6.fr>, Steve Dickson <steved@redhat.com>,
        David Quigley <dpquigl@davequigley.com>
CC: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] fs/nfs/inode.c: adjust code alignment
Date: Mon, 5 Aug 2013 14:59:55 +0000
Message-ID: <1375714793.7337.12.camel@leira.trondhjem.org>
References: <1375714059-29567-1-git-send-email-Julia.Lawall@lip6.fr>
	 <1375714059-29567-2-git-send-email-Julia.Lawall@lip6.fr>
In-Reply-To: <1375714059-29567-2-git-send-email-Julia.Lawall@lip6.fr>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEzLTA4LTA1IGF0IDE2OjQ3ICswMjAwLCBKdWxpYSBMYXdhbGwgd3JvdGU6DQo+
IEZyb206IEp1bGlhIExhd2FsbCA8SnVsaWEuTGF3YWxsQGxpcDYuZnI+DQo+IA0KPiBTaWduZWQt
b2ZmLWJ5OiBKdWxpYSBMYXdhbGwgPEp1bGlhLkxhd2FsbEBsaXA2LmZyPg0KPiANCj4gLS0tDQo+
IA0KPiBUaGlzIHBhdGNoIGFkanVzdHMgdGhlIGNvZGUgc28gdGhhdCB0aGUgYWxpZ25tZW50IG1h
dGNoZXMgdGhlIGN1cnJlbnQNCj4gc2VtYW50aWNzLiAgSSBoYXZlIG5vIGlkZWEgaWYgaXQgaXMg
dGhlIGludGVuZGVkIHNlbWFudGljcywgdGhvdWdoLiAgU2hvdWxkDQo+IHRoZSBjYWxsIHRvIG5m
c19zZXRzZWN1cml0eSBhbHNvIGJlIHVuZGVyIHRoZSBlbHNlPw0KPiANCg0KPiAgZnMvbmZzL2lu
b2RlLmMgfCAgICAyICstDQo+ICAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyksIDEgZGVs
ZXRpb24oLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9mcy9uZnMvaW5vZGUuYyBiL2ZzL25mcy9pbm9k
ZS5jDQo+IGluZGV4IGFmNmU4MDYuLmQ4YWQ2ODUgMTAwNjQ0DQo+IC0tLSBhL2ZzL25mcy9pbm9k
ZS5jDQo+ICsrKyBiL2ZzL25mcy9pbm9kZS5jDQo+IEBAIC00NjMsNyArNDYzLDcgQEAgbmZzX2Zo
Z2V0KHN0cnVjdCBzdXBlcl9ibG9jayAqc2IsIHN0cnVjdCBuZnNfZmgNCj4gKmZoLCBzdHJ1Y3Qg
bmZzX2ZhdHRyICpmYXR0ciwgc3QNCj4gICAgICAgICAgICAgICAgIHVubG9ja19uZXdfaW5vZGUo
aW5vZGUpOw0KPiAgICAgICAgIH0gZWxzZQ0KPiAgICAgICAgICAgICAgICAgbmZzX3JlZnJlc2hf
aW5vZGUoaW5vZGUsIGZhdHRyKTsNCj4gLSAgICAgICAgICAgICAgIG5mc19zZXRzZWN1cml0eShp
bm9kZSwgZmF0dHIsIGxhYmVsKTsNCj4gKyAgICAgICBuZnNfc2V0c2VjdXJpdHkoaW5vZGUsIGZh
dHRyLCBsYWJlbCk7DQo+ICAgICAgICAgZHByaW50aygiTkZTOiBuZnNfZmhnZXQoJXMvJUxkIGZo
X2NyYz0weCUwOHggY3Q9JWQpXG4iLA0KPiAgICAgICAgICAgICAgICAgaW5vZGUtPmlfc2ItPnNf
aWQsDQo+ICAgICAgICAgICAgICAgICAobG9uZyBsb25nKU5GU19GSUxFSUQoaW5vZGUpLA0KDQpI
aSBKdWxpYSwNCg0KVGhhbmtzIGZvciBwb2ludGluZyB0aGlzIG91dCEgR2l2ZW4gdGhhdCB0aGUg
J3RoZW4nIGNsYXVzZSBvZiB0aGUgaWYNCnN0YXRlbWVudCBhbHJlYWR5IGNhbGxzIG5mc19zZXRz
ZWN1cml0eSBiZWZvcmUgdW5sb2NraW5nIHRoZSBpbm9kZSwgSQ0Kc3VzcGVjdCB0aGF0IHRoZSBh
Ym92ZSBfc2hvdWxkXyByZWFsbHkgYmUgcGFydCBvZiB0aGUgJ2Vsc2UnIGNsYXVzZS4gDQoNClRo
YXQgc2FpZCwgSSBjYW4ndCBzZWUgdGhhdCBjYWxsaW5nIG5mc19zZXRzZWN1cml0eSB0d2ljZSBv
biB0aGUgaW5vZGUNCmNhbiBjYXVzZSBhbnkgdW5pbnRlbmRlZCBzaWRlLWVmZmVjdHMsIHNvIEkg
c3VnZ2VzdCB0aGF0IHdlIHJhdGhlciBxdWV1ZQ0KdGhlIHBhdGNoIHVwIGZvciBpbmNsdXNpb24g
aW4gMy4xMi4NClN0ZXZlIGFuZCBEYXZlLCBhbnkgY29tbWVudHM/DQoNCi0tIA0KVHJvbmQgTXlr
bGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWts
ZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg==
