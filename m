Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:31530 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751986AbdD0WHO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Apr 2017 18:07:14 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "kinglongmee@gmail.com" <kinglongmee@gmail.com>,
        "bfields@redhat.com" <bfields@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFSv4: Fix callback server shutdown
Date: Thu, 27 Apr 2017 22:07:07 +0000
Message-ID: <1493330824.34802.1.camel@primarydata.com>
References: <20170426155527.92213-1-trond.myklebust@primarydata.com>
         <20170426155527.92213-2-trond.myklebust@primarydata.com>
         <20170426155527.92213-3-trond.myklebust@primarydata.com>
         <1692a8de-1d22-dfdd-d36f-e2b040160e26@gmail.com>
         <1493263484.1401.2.camel@primarydata.com>
         <4275e06f-97c0-b5b9-e71c-db7380d90534@gmail.com>
         <20170427220342.GC29775@parsley.fieldses.org>
In-Reply-To: <20170427220342.GC29775@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE3LTA0LTI3IGF0IDE4OjAzIC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIFRodSwgQXByIDI3LCAyMDE3IGF0IDExOjU0OjQ4QU0gKzA4MDAsIEtpbmdsb25nIE1l
ZSB3cm90ZToNCj4gPiANCj4gPiANCj4gPiBPbiA0LzI3LzIwMTcgMTE6MjQsIFRyb25kIE15a2xl
YnVzdCB3cm90ZToNCj4gPiA+IE9uIFRodSwgMjAxNy0wNC0yNyBhdCAxMTowNiArMDgwMCwgS2lu
Z2xvbmcgTWVlIHdyb3RlOg0KPiA+ID4gPiANCj4gPiA+ID4gVGhlcmUgaXMgb25seSBvbmUgdXNl
IG9mIHN2Y19zZXRfbnVtX3RocmVhZHMgdGhhdCBieSBuZnNkLA0KPiA+ID4gPiBJJ2QgbGlrZSB0
byBjaGFuZ2Ugc3ZjX3NldF9udW1fdGhyZWFkcyBhbmQgdXBkYXRlIG5mc2QgdGhhbiBhZGQNCj4g
PiA+ID4gYSBuZXcNCj4gPiA+ID4gZnVuY3Rpb24uDQo+ID4gPiANCj4gPiA+IFlvdSBjYW4ndCBy
ZWFsbHkgY29tYmluZSB0aGUgdHdvIG1ldGhvZHMuIEVpdGhlciB5b3UgY2hvb3NlDQo+ID4gPiBz
aWduYWxzIG9yDQo+ID4gPiB5b3UgY2hvb3NlIGt0aHJlYWRfc3RvcCgpLiBUaGUgcHJvYmxlbSBp
cyB0aGF0IHNpZ25hbHMgcmVxdWlyZQ0KPiA+ID4gdGhlDQo+ID4gPiB0aHJlYWQgdG8gYmUgYWJs
ZSB0byBwZXJzaXN0IHBhc3QgdGhlIG5mc2RfZGVzdHJveSgpICh3aGljaCBhZ2Fpbg0KPiA+ID4g
Zm9yY2VzIHRoaW5ncyBsaWtlIG5mc2QoKSBoYXZpbmcgdG8gdGFrZSBuZnNkX211dGV4KSwgb3Ig
eW91IGhhdmUNCj4gPiA+IHRvDQo+ID4gPiBtYWtlIHRoaW5ncyBzeW5jaHJvbm91cywgaW4gd2hp
Y2ggY2FzZSBoYXZpbmcgbmZzZCgpIHRyeSB0byB0YWtlDQo+ID4gPiBuZnNkX211dGV4IGNhdXNl
cyBkZWFkbG9ja3MuDQo+ID4gPiANCj4gPiA+IElPVzogaWYgdGhlcmUgaXMgbGVnYWN5IGJlaGF2
aW91ciBoZXJlIHRoYXQgcmVxdWlyZXMgdGhlIHNpZ25hbA0KPiA+ID4gbWV0aG9kLA0KPiA+ID4g
dGhlbiBrbmZzZCBjYW5ub3QgYmUgY29udmVydGVkLg0KPiA+IA0KPiA+IEdvdCBpdC4NCj4gPiAN
Cj4gPiBUZXN0ZWQtYW5kLXJldmlld2VkLWJ5OiBLaW5nbG9uZyBNZWUgPGtpbmdsb25nbWVlQGdt
YWlsLmNvbT4NCj4gDQo+IFNvIGRvZXMgd2hhdCBJIGhhdmUgaW4gZ2l0Oi8vbGludXgtbmZzLm9y
Zy9+YmZpZWxkcy9saW51eC5naXQgbmZzZC0NCj4gbmV4dA0KPiBsb29rIGNvcnJlY3Q/DQo+IA0K
PiAoQWx0ZXJuYXRpdmVseSwgaWYgVHJvbmQncyB0YWtpbmcgdGhpcyB0aHJvdWdoIGhpcyB0cmVl
LCB0aGF0J3MgZmluZQ0KPiB0b28sIGZlZWwgZnJlZSB0byBhZGQgbXkgQUNLLikNCj4gDQpJZiB5
b3UndmUgYWxyZWFkeSBnb3QgaXQgcXVldWVkIHVwIHRoZW4gSSdtIGZpbmUgd2l0aCB0aGF0LiBJ
IGhhdmUgaXQNCmluIG15ICJ0ZXN0aW5nIiBicmFuY2ggKHdoaWNoIHBhc3NlcyDimLopIGJ1dCBo
YXZlbid0IHlldCBtb3ZlZCBpdCBpbnRvDQpsaW51eC1uZXh0Lg0KDQotLSANClRyb25kIE15a2xl
YnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBQcmltYXJ5RGF0YQ0KdHJvbmQubXlr
bGVidXN0QHByaW1hcnlkYXRhLmNvbQ0K

