Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13421 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030423Ab2HIOhJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Aug 2012 10:37:09 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Boaz Harrosh <bharrosh@panasas.com>, Benny Halevy <bhalevy@tonian.com>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>
Subject: Re: [PATCH] NFSv4.1: Remove a bogus BUG_ON() in
 nfs4_layoutreturn_done
Date: Thu, 9 Aug 2012 14:36:21 +0000
Message-ID: <1344522979.23523.2.camel@lade.trondhjem.org>
References: <1344457310-26442-1-git-send-email-Trond.Myklebust@netapp.com>
	 <CA+a=Yy7SX+cPLFiNy552bU9ZMS_rSwvaSpV732_mDwpcPAH5Wg@mail.gmail.com>
In-Reply-To: <CA+a=Yy7SX+cPLFiNy552bU9ZMS_rSwvaSpV732_mDwpcPAH5Wg@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTA4LTA5IGF0IDIyOjMwICswODAwLCBQZW5nIFRhbyB3cm90ZToNCj4gT24g
VGh1LCBBdWcgOSwgMjAxMiBhdCA0OjIxIEFNLCBUcm9uZCBNeWtsZWJ1c3QNCj4gPFRyb25kLk15
a2xlYnVzdEBuZXRhcHAuY29tPiB3cm90ZToNCj4gPiBFdmVyIHNpbmNlIGNvbW1pdCAwYTU3Y2Rh
YzNmIChORlN2NC4xIHNlbmQgbGF5b3V0cmV0dXJuIHRvIGZlbmNlDQo+ID4gZGlzY29ubmVjdGVk
IGRhdGEgc2VydmVyKSB3ZSd2ZSBiZWVuIHNlbmRpbmcgbGF5b3V0cmV0dXJuIGNhbGxzDQo+ID4g
d2hpbGUgdGhlcmUgaXMgcG90ZW50aWFsbHkgc3RpbGwgb3V0c3RhbmRpbmcgSS9PIHRvIHRoZSBk
YXRhDQo+ID4gc2VydmVycy4gVGhlIHJlYXNvbiB3ZSBkbyB0aGlzIGlzIHRvIGF2b2lkIHJhY2Vz
IGJldHdlZW4gcmVwbGF5ZWQNCj4gPiB3cml0ZXMgdG8gdGhlIE1EUyBhbmQgdGhlIG9yaWdpbmFs
IHdyaXRlcyB0byB0aGUgRFMuDQo+ID4NCj4gPiBXaGVuIHRoaXMgaGFwcGVucywgdGhlIEJVR19P
TigpIGluIG5mczRfbGF5b3V0cmV0dXJuX2RvbmUgY2FuDQo+ID4gYmUgdHJpZ2dlcmVkIGJlY2F1
c2UgaXQgYXNzdW1lcyB0aGF0IHdlIHdvdWxkIG5ldmVyIGNhbGwNCj4gPiBsYXlvdXRyZXR1cm4g
d2l0aG91dCBrbm93aW5nIHRoYXQgYWxsIEkvTyB0byB0aGUgRFMgaXMNCj4gPiBmaW5pc2hlZC4g
VGhlIGZpeCBpcyB0byByZW1vdmUgdGhlIEJVR19PTigpIG5vdyB0aGF0IHRoZQ0KPiA+IGFzc3Vt
cHRpb25zIGJlaGluZCB0aGUgdGVzdCBhcmUgb2Jzb2xldGUuDQo+ID4NCj4gSXNuJ3QgTURTIHN1
cHBvc2VkIHRvIHJlY2FsbCB0aGUgbGF5b3V0IGlmIHJhY2VzIGFyZSBwb3NzaWJsZSBiZXR3ZWVu
DQo+IG91dHN0YW5kaW5nIHdyaXRlLXRvLURTIGFuZCB3cml0ZS10aHJvdWdoLU1EUz8NCg0KV2hl
cmUgZG8geW91IHJlYWQgdGhhdCBpbiBSRkM1NjYxPw0KDQo+IEFuZCBpdCBjYXVzZXMgZGF0YSBj
b3JydXB0aW9uIGZvciBibG9ja2xheW91dCBpZiBjbGllbnQgcmV0dXJucyBsYXlvdXQNCj4gd2hp
bGUgdGhlcmUgaXMgaW4tZmxpZ2h0IGRpc2sgSU8uLi4NCg0KVGhlbiBpdCBuZWVkcyB0byB0dXJu
IG9mZiBmYXN0IGZhaWxvdmVyIHRvIHdyaXRlLXRocm91Z2gtTURTLg0KDQotLSANClRyb25kIE15
a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlr
bGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
