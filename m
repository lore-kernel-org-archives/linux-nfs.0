Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:48967 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932521Ab3GVTDV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 15:03:21 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 07/19] NFS: Fix compiler warning in
 nfs_setup_sequence()
Date: Mon, 22 Jul 2013 19:03:20 +0000
Message-ID: <1374519800.7972.20.camel@leira.trondhjem.org>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
	 <20130712163228.1444.26489.stgit@seurat.1015granger.net>
In-Reply-To: <20130712163228.1444.26489.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEzLTA3LTEyIGF0IDEyOjMyIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
Q2xlYW4gdXAuICBTcXVlbGNoIGNvbXBpbGVyIHdhcm5pbmc6DQo+IA0KPiBsaW51eC9mcy9uZnMv
bmZzNHByb2MuYzogSW4gZnVuY3Rpb24g4oCYbmZzNF9zZXR1cF9zZXF1ZW5jZeKAmToNCj4gbGlu
dXgvZnMvbmZzL25mczRwcm9jLmM6NzAzOjI6IHdhcm5pbmc6IHNpZ25lZCBhbmQgdW5zaWduZWQg
dHlwZSBpbg0KPiAJY29uZGl0aW9uYWwgZXhwcmVzc2lvbiBbLVdzaWduLWNvbXBhcmVdDQo+IA0K
PiBTaWduZWQtb2ZmLWJ5OiBDaHVjayBMZXZlciA8Y2h1Y2subGV2ZXJAb3JhY2xlLmNvbT4NCj4g
LS0tDQo+ICBmcy9uZnMvbmZzNHByb2MuYyB8ICAgIDIgKy0NCj4gIDEgZmlsZSBjaGFuZ2VkLCAx
IGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2ZzL25mcy9u
ZnM0cHJvYy5jIGIvZnMvbmZzL25mczRwcm9jLmMNCj4gaW5kZXggN2IyZTAwOC4uNTkxM2UxZCAx
MDA2NDQNCj4gLS0tIGEvZnMvbmZzL25mczRwcm9jLmMNCj4gKysrIGIvZnMvbmZzL25mczRwcm9j
LmMNCj4gQEAgLTY1NSw3ICs2NTUsNyBAQCBzdGF0aWMgaW50IG5mczRfc2V0dXBfc2VxdWVuY2Uo
Y29uc3Qgc3RydWN0IG5mc19zZXJ2ZXIgKnNlcnZlciwNCj4gIA0KPiAgCWRwcmludGsoIi0tPiAl
cyBjbHAgJXAgc2Vzc2lvbiAlcCBzcl9zbG90ICVkXG4iLA0KPiAgCQlfX2Z1bmNfXywgc2Vzc2lv
bi0+Y2xwLCBzZXNzaW9uLCByZXMtPnNyX3Nsb3QgPw0KPiAtCQkJcmVzLT5zcl9zbG90LT5zbG90
X25yIDogLTEpOw0KPiArCQkJKGludClyZXMtPnNyX3Nsb3QtPnNsb3RfbnIgOiAtMSk7DQo+ICAN
Cg0KUGxlYXNlIGNvbnZlcnQgdG8gbWFrZSBpdCB1bnNpZ25lZCwgYW5kIHRvIHVzZSBORlM0X05P
X1NMT1QgaW5zdGVhZCBvZg0KJy0xJy4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5G
UyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29t
DQp3d3cubmV0YXBwLmNvbQ0K
