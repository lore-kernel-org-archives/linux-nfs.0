Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:20058 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752107AbdKCSR3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Nov 2017 14:17:29 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: Fix ugly referral attributes
Date: Fri, 3 Nov 2017 18:17:24 +0000
Message-ID: <1509733043.21477.9.camel@primarydata.com>
References: <20171103174658.31159.24496.stgit@manet.1015granger.net>
In-Reply-To: <20171103174658.31159.24496.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE3LTExLTAzIGF0IDEzOjQ2IC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
QmVmb3JlIHRyYXZlcnNpbmcgYSByZWZlcnJhbCBhbmQgcGVyZm9ybWluZyBhIG1vdW50LCB0aGUg
bW91bnRlZC1vbg0KPiBkaXJlY3RvcnkgbG9va3Mgc3RyYW5nZToNCj4gDQo+IGRyLXhyLXhyLXgu
IDIgNDI5NDk2NzI5NCA0Mjk0OTY3Mjk0IDAgRGVjIDMxICAxOTY5IGRpci4wDQo+IA0KPiBuZnM0
X2dldF9yZWZlcnJhbCBpcyB3aXBpbmcgb3V0IGFueSBjYWNoZWQgYXR0cmlidXRlcyB3aXRoIHdo
YXQgd2FzDQo+IHJldHVybmVkIHZpYSBHRVRBVFRSKGZzX2xvY2F0aW9ucyksIGJ1dCB0aGUgYml0
IG1hc2sgZm9yIHRoYXQNCj4gb3BlcmF0aW9uIGRvZXMgbm90IHJlcXVlc3QgYW55IGZpbGUgYXR0
cmlidXRlcy4NCj4gDQo+IFNldCB0aGUgZGVmYXVsdCBiaXRzIGluIHRoZSBHRVRBVFRSIGJpdG1h
c2sgdG8gcmV0cmlldmUgdGhlIHVzdWFsDQo+IHNldCBvZiBvYmplY3QgYXR0cmlidXRlcyBzbyB0
aGF0IHRoZSBtZW1jcHkgaW4gbmZzNF9nZXRfcmVmZXJyYWwgY2FuDQo+IGZpbGwgdGhlIGF0dHJp
YnV0ZXMgaW4gcHJvcGVybHkuDQo+IA0KDQpIbW0uLi4gU28gSSBiZWxpZXZlIHRoZSByZWFzb24g
d2h5IHdlIGRpZG4ndCBkbyB0aGlzIGluIHRoZSBvcmlnaW5hbA0KaW1wbGVtZW50YXRpb24gaXMg
YmVjYXVzZSBvZiBSRkM3NTMwLCBTZWN0aW9uIDguMy4xLCB3aGljaCBzYXlzOg0KDQogICBPdGhl
ciBhdHRyaWJ1dGVzIFNIT1VMRCBOT1QgYmUgbWFkZSBhdmFpbGFibGUgZm9yIGFic2VudCBmaWxl
DQogICBzeXN0ZW1zLCBldmVuIHdoZW4gaXQgaXMgcG9zc2libGUgdG8gcHJvdmlkZSB0aGVtLiBU
aGUgc2VydmVyIHNob3VsZA0KICAgbm90IGFzc3VtZSB0aGF0IG1vcmUgaW5mb3JtYXRpb24gaXMg
YWx3YXlzIGJldHRlciBhbmQgc2hvdWxkIGF2b2lkDQogICBncmF0dWl0b3VzbHkgcHJvdmlkaW5n
IGFkZGl0aW9uYWwgaW5mb3JtYXRpb24uDQoNCldoZXJlICJvdGhlciBhdHRyaWJ1dGVzIiBtZWFu
cyBhbnl0aGluZyBvdGhlciB0aGFuIGZzX2xvY2F0aW9ucywgZnNpZA0KYW5kIG1vdW50ZWQtb24t
ZmlsZWlkLg0KDQpJT1c6IHRoZSBwcm90b2NvbCBzcGVjIGhhcyBub3JtYXRpdmUgbGFuZ3VhZ2Ug
c3RhdGluZyB0aGF0IHdlIHNob3VsZA0Kbm90IGV4cGVjdCB0byBiZSBhYmxlIHRvIHJldHJpZXZl
IG90aGVyIGF0dHJpYnV0ZXMsIGFuZCB0aGF0IHRoZSBzZXJ2ZXINCnNob3VsZCBub3QgcmV0dXJu
IHRoZW0uDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWlu
ZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

