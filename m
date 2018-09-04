Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr690107.outbound.protection.outlook.com ([40.107.69.107]:57520
        "EHLO NAM04-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725825AbeIEDil (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Sep 2018 23:38:41 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "neilb@suse.com" <neilb@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4.1 session reset needs to update ->rsize and ->wsize -
 how???
Date: Tue, 4 Sep 2018 23:11:20 +0000
Message-ID: <f7f84aced6ae709b1c66e1475e8d79927fa29132.camel@hammerspace.com>
References: <87r2i8vq10.fsf@notabene.neil.brown.name>
In-Reply-To: <87r2i8vq10.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE4LTA5LTA1IGF0IDA4OjQ3ICsxMDAwLCBOZWlsQnJvd24gd3JvdGU6DQo+IFdp
dGggTkZTdjQuMSwgdGhlIHNlcnZlciBzcGVjaWZpZXMgbWF4X3Jxc3Rfc3ogYW5kIG1heF9yZXNw
X3N6IGluIHRoZQ0KPiByZXBseSB0byBDUkVBVEUgc2Vzc2lvbi4NCj4gDQo+IElmIHRoZSBjbGll
bnQgZmluZHMgaXQgbmVlZHMgdG8gY2FsbCBuZnM0X3Jlc2V0X3Nlc3Npb24oKSwgaXQgbWlnaHQN
Cj4gZ2V0DQo+IHNtYWxsZXIgc2l6ZXMgYmFjaywgc28gYW55IHBlbmRpbmcgcmVhZC93cml0ZXMg
d291bGQgbmVlZCB0byBiZQ0KPiByZXNpemVkLg0KPiANCj4gSG93ZXZlciwgSSBjYW5ub3Qgc2Vl
IGhvdyB0aGUgcmV0cnkgaGFuZGxpbmcgZm9yIHJlYWRzL3dyaXRlcyBoYXMgYW55DQo+IGNoYW5j
ZSB0byBjaGFuZ2UgdGhlIHNpemUuICBJdCBsb29rcyBsaWtlIGEgcmVxdWVzdCBpcyBicm9rZW4g
dXAgdG8NCj4gbWF0Y2ggdGhlIG9yaWdpbmFsIC0+cnNpemUgYW5kIC0+d3NpemUsIHRoZW4gdGhv
c2UgaW5kaXZpZHVhbCBJTw0KPiByZXF1ZXN0cyBjYW4gYmUgcmV0cmllZCwgYnV0IHRoZSBoaWdo
ZXIgbGV2ZWwgcmVxdWVzdCBpcyBuZXZlcg0KPiByZS1ldmFsdWF0ZWQgaW4gbGlnaHQgb2YgYSBu
ZXcgc2l6ZS4NCj4gDQo+IEFtIEkgbWlzc2luZyBzb21ldGhpbmcsIG9yIGlzIHRoaXMgbm90IHN1
cHBvcnRlZCBhdCBwcmVzZW50Pw0KPiBJZiBpdCBpc24ndCBzdXBwb3J0ZWQsIGFueSBzdWdnZXN0
aW9ucyBvbiBob3cgYmVzdCB0byBoYW5kbGUgYQ0KPiByZWR1Y3Rpb24gb2YgdGhlIHJzaXplL3dz
aXplID8/DQo+IA0KDQpXaHkgd291bGQgYSBzYW5lIHNlcnZlciB3YW50IHRvIGRvIHRoaXM/DQoN
CkNoZWVycw0KICBUcm9uZA0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQg
bWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20N
Cg0KDQo=
