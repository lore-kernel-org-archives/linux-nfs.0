Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:37015 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752525AbdJKRuH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Oct 2017 13:50:07 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "tj@kernel.org" <tj@kernel.org>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "lorenzo.pieralisi@arm.com" <lorenzo.pieralisi@arm.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jiangshanlai@gmail.com" <jiangshanlai@gmail.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
Subject: Re: net/sunrpc: v4.14-rc4 lockdep warning
Date: Wed, 11 Oct 2017 17:49:59 +0000
Message-ID: <1507744197.50316.3.camel@primarydata.com>
References: <20171009181738.GA30680@red-moon>
         <1507573931.3516.3.camel@primarydata.com>
         <20171010140336.GI3301751@devbig577.frc2.facebook.com>
         <1507654135.4442.4.camel@primarydata.com>
         <20171010171919.GO3301751@devbig577.frc2.facebook.com>
In-Reply-To: <20171010171919.GO3301751@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE3LTEwLTEwIGF0IDEwOjE5IC0wNzAwLCB0akBrZXJuZWwub3JnIHdyb3RlOg0K
PiBIZWxsbywNCj4gDQo+IE9uIFR1ZSwgT2N0IDEwLCAyMDE3IGF0IDA0OjQ4OjU3UE0gKzAwMDAs
IFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4gPiBUaGFua3MgZm9yIHRoZSBleHBsYW5hdGlvbi4g
V2hhdCBJJ20gbm90IHJlYWxseSB1bmRlcnN0YW5kaW5nIGhlcmUNCj4gPiB0aG91Z2gsIGlzIGhv
dyB0aGUgd29yayBpdGVtIGNvdWxkIGJlIHF1ZXVlZCBhdCBhbGwuIFdlIGhhdmUgYQ0KPiA+IHdh
aXRfb25fYml0X2xvY2soKSBpbiB4cHJ0X2Rlc3Ryb3koKSB0aGF0IHNob3VsZCBtZWFuIHRoZSB4
cHJ0LQ0KPiA+ID4gdGFza19jbGVhbnVwIHdvcmsgaXRlbSBoYXMgY29tcGxldGVkIHJ1bm5pbmcs
IGFuZCB0aGF0IGl0IGNhbm5vdA0KPiA+ID4gYmUNCj4gPiANCj4gPiByZXF1ZXVlZC4NCj4gPiAN
Cj4gPiBJcyB0aGVyZSBhIHBvc3NpYmlsaXR5IHRoYXQgdGhlIGZsdXNoX3F1ZXVlKCkgbWlnaHQg
YmUgdHJpZ2dlcmVkDQo+ID4gZGVzcGl0ZSB0aGUgd29yayBpdGVtIG5vdCBiZWluZyBxdWV1ZWQ/
DQo+IA0KPiBZZWFoLCBmb3Igc3VyZS4gIFRoZSBsb2NrZGVwIGFubm90YXRpb25zIGRvbid0IGRp
c3Rpbmd1aXNoIHRob3NlDQo+IGNhc2VzIGFuZCBhc3N1bWUgdGhlIHdvcnN0IGNhc2UuDQo+IA0K
DQpPSy4gTGV0J3MganVzdCByZW1vdmUgdGhhdCBjYWxsIHRvIGNhbmNlbF93b3JrX3N5bmMoKSB0
aGVuLiBBcyBJIHNhaWQsDQppdCBzaG91bGQgYmUgcmVkdW5kYW50IGR1ZSB0byB0aGUgd2FpdF9v
bl9iaXRfbG9jaygpLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBt
YWludGFpbmVyLCBQcmltYXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbQ0K

