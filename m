Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12322 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754462Ab2LMAo2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Dec 2012 19:44:28 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Sven Wegener <sven.wegener@stealer.net>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: [PATCH] NFSv4: Check for buffer length in
 __nfs4_get_acl_uncached
Date: Thu, 13 Dec 2012 00:44:26 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA911929358@SACEXCMBX04-PRD.hq.netapp.com>
References: <alpine.LNX.2.02.1212130009400.10324@titan.int.lan.stealer.net>
In-Reply-To: <alpine.LNX.2.02.1212130009400.10324@titan.int.lan.stealer.net>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBsaW51eC1uZnMtb3duZXJAdmdl
ci5rZXJuZWwub3JnIFttYWlsdG86bGludXgtbmZzLQ0KPiBvd25lckB2Z2VyLmtlcm5lbC5vcmdd
IE9uIEJlaGFsZiBPZiBTdmVuIFdlZ2VuZXINCj4gU2VudDogV2VkbmVzZGF5LCBEZWNlbWJlciAx
MiwgMjAxMiA2OjE1IFBNDQo+IFRvOiBNeWtsZWJ1c3QsIFRyb25kDQo+IENjOiBsaW51eC1uZnNA
dmdlci5rZXJuZWwub3JnOyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6
IFtQQVRDSF0gTkZTdjQ6IENoZWNrIGZvciBidWZmZXIgbGVuZ3RoIGluDQo+IF9fbmZzNF9nZXRf
YWNsX3VuY2FjaGVkDQo+IA0KPiBDb21taXQgMWYxZWE2YyAiTkZTdjQ6IEZpeCBidWZmZXIgb3Zl
cmZsb3cgY2hlY2tpbmcgaW4NCj4gX19uZnM0X2dldF9hY2xfdW5jYWNoZWQiIGFjY2lkZW50bHkg
ZHJvcHBlZCB0aGUgY2hlY2tpbmcgZm9yIHRvbyBzbWFsbA0KPiByZXN1bHQgYnVmZmVyIGxlbmd0
aC4NCj4gDQo+IElmIHNvbWVvbmUgdXNlcyBnZXR4YXR0ciBvbiAic3lzdGVtLm5mczRfYWNsIiBv
biBhbiBORlN2NCBtb3VudA0KPiBzdXBwb3J0aW5nIEFDTHMsIHRoZSBBQ0wgaGFzIG5vdCBiZWVu
IGNhY2hlZCBhbmQgdGhlIGJ1ZmZlciBzdXBsaWVkIGlzIHRvbw0KPiBzaG9ydCwgd2Ugc3RpbGwg
Y29weSB0aGUgY29tcGxldGUgQUNMLCByZXN1bHRpbmcgaW4ga2VybmVsIGFuZCB1c2VyIHNwYWNl
DQo+IG1lbW9yeSBjb3JydXB0aW9uLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogU3ZlbiBXZWdlbmVy
IDxzdmVuLndlZ2VuZXJAc3RlYWxlci5uZXQ+DQo+IENjOiBzdGFibGVAa2VybmVsLm9yZw0KPiAt
LS0NCj4gIGZzL25mcy9uZnM0cHJvYy5jIHwgNyArKysrKystDQo+ICAxIGZpbGUgY2hhbmdlZCwg
NiBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pDQo+IA0KPiBSZXNlbmRpbmcsIGJlY2F1c2Ug
aXQgZGlkIG5vdCBnZXQgYW55IHJlc3BvbnNlLg0KDQpTb3JyeS4gSSd2ZSBhbHJlYWR5IGFwcGxp
ZWQgaXQgdG8gdGhlIG5mcy1mb3ItbmV4dCBicmFuY2ggb24gZ2l0LmxpbnV4LW5mcy5vcmcsIHNv
IGl0IHNob3VsZCBnbyBpbiBkdXJpbmcgdGhpcyBtZXJnZSB3aW5kb3cuDQoNCkNoZWVycw0KICBU
cm9uZA0K
