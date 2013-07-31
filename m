Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:40061 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027Ab3GaXrd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Jul 2013 19:47:33 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Quentin Barnes <qbarnes@gmail.com>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: don't allow nfs_find_actor to match inodes of the
 wrong type
Date: Wed, 31 Jul 2013 23:47:26 +0000
Message-ID: <1375314445.14217.53.camel@leira.trondhjem.org>
References: <20130731230051.GB31859@gmail.com>
In-Reply-To: <20130731230051.GB31859@gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEzLTA3LTMxIGF0IDE4OjAwIC0wNTAwLCBRdWVudGluIEJhcm5lcyB3cm90ZToN
Cj4gPiBRdWl0ZSBmcmFua2x5LCBhbGwgSSBjYXJlIGFib3V0IGluIGEgc2l0dWF0aW9uIGxpa2Ug
dGhpcyBpcyB0aGF0IHRoZQ0KPiA+IGNsaWVudCBkb2Vzbid0IE9vcHMuDQo+IA0KPiBDZXJ0YWlu
bHksIGFuZCBoaXMgcGF0Y2ggZG9lcyBkbyB0aGF0LCBidXQgaXQncyBhbHNvIHBvaW50aW5nIG91
dA0KPiB0aGVyZSdzIGFub3RoZXIgYnVnIHJ1bm5pbmcgYXJvdW5kLiAgQW5kIG9uY2UgeW91IGZp
eCB0aGF0IGJ1ZywgdGhlDQo+IG9yaWdpbmFsIHBhdGNoIGlzIG5vIGxvbmdlciBuZWVkZWQuDQo+
IA0KPiA+IElmIGEgc2VydmVyIGlzIHJlYWxseSB0aGlzIHV0dGVybHkgYnJva2VuLCB0aGVuIHRo
ZXJlIGlzIG5vIHdheSB3ZSBjYW4NCj4gPiBmaXggaXQgb24gdGhlIGNsaWVudCwgYW5kIHdlJ3Jl
IG5vdCBldmVuIGdvaW5nIHRvIHRyeS4NCj4gDQo+IE9mIGNvdXJzZS4gIEJ1dCB5b3UgYWxzbyBk
b24ndCB3YW50IHRvIHVubmVjZXNzYXJpbHkgbGVhdmUgdGhlDQo+IGNsaWVudCB3aXRoIGFuIGlu
dmFsaWQgaW5vZGUgdGhhdCdzIG5vdCBwcm9wZXJseSBmbGFnZ2VkIGFuZA0KPiBwb3NzaWJseSBs
ZWF2ZSBhbm90aGVyIGJ1ZyB1bmZpeGVkLg0KDQpXaHkgaXMgdGhlIGludmFsaWQgaW5vZGUgbm90
IGJlaW5nIGZsYWdnZWQgYSBwcm9ibGVtIHRoYXQgbmVlZHMgdG8gYmUNCnNvbHZlZD8NCkhvdyBk
b2VzIHRoZSBwYXRjaCB0aGF0IHlvdSd2ZSBwcm9wb3NlZCBjaGFuZ2UgbWF0dGVycyBmb3IgdGhl
IGVuZCB1c2VyDQpvciBhcHBsaWNhdGlvbj8NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4
IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAu
Y29tDQp3d3cubmV0YXBwLmNvbQ0K
