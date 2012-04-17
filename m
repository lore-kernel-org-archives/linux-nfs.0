Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2909 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755863Ab2DQQNo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 12:13:44 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Fred Isaman <faisaman4@gmail.com>
CC: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 14/26] NFS: merge _full and _partial read rpc_ops
Date: Tue, 17 Apr 2012 16:13:43 +0000
Message-ID: <1334679223.2703.15.camel@lade.trondhjem.org>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
	 <1334004744-31842-15-git-send-email-iisaman@netapp.com>
	 <1334608102.2879.37.camel@lade.trondhjem.org>
	 <CADnza467ROBp0-=Qgq5DwSK=Zu5Vyk5i1v1qFN2aMbKXDWdT=A@mail.gmail.com>
In-Reply-To: <CADnza467ROBp0-=Qgq5DwSK=Zu5Vyk5i1v1qFN2aMbKXDWdT=A@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA0LTE3IGF0IDExOjM3IC0wNDAwLCBGcmVkIElzYW1hbiB3cm90ZToNCj4g
T24gTW9uLCBBcHIgMTYsIDIwMTIgYXQgNDoyOCBQTSwgTXlrbGVidXN0LCBUcm9uZA0KPiA8VHJv
bmQuTXlrbGVidXN0QG5ldGFwcC5jb20+IHdyb3RlOg0KPiA+IE9uIE1vbiwgMjAxMi0wNC0wOSBh
dCAxNjo1MiAtMDQwMCwgRnJlZCBJc2FtYW4gd3JvdGU6DQo+ID4+IEBAIC02NCwxMCArODAsMTYg
QEAgdm9pZCBuZnNfcmVhZGhkcl9mcmVlKHN0cnVjdCBuZnNfcGdpb19oZWFkZXIgKmhkcikNCj4g
Pj4NCj4gPj4gIHZvaWQgbmZzX3JlYWRkYXRhX3JlbGVhc2Uoc3RydWN0IG5mc19yZWFkX2RhdGEg
KnJkYXRhKQ0KPiA+PiAgew0KPiA+PiArICAgICBzdHJ1Y3QgbmZzX3BnaW9faGVhZGVyICpoZHIg
PSByZGF0YS0+aGVhZGVyOw0KPiA+PiArDQo+ID4+ICAgICAgIHB1dF9uZnNfb3Blbl9jb250ZXh0
KHJkYXRhLT5hcmdzLmNvbnRleHQpOw0KPiA+PiAgICAgICBpZiAocmRhdGEtPnBhZ2VzLnBhZ2V2
ZWMgIT0gcmRhdGEtPnBhZ2VzLnBhZ2VfYXJyYXkpDQo+ID4+ICAgICAgICAgICAgICAga2ZyZWUo
cmRhdGEtPnBhZ2VzLnBhZ2V2ZWMpOw0KPiA+PiAtICAgICBuZnNfcmVhZGhkcl9mcmVlKHJkYXRh
LT5oZWFkZXIpOw0KPiA+PiArICAgICBpZiAoY29udGFpbmVyX29mKGhkciwgc3RydWN0IG5mc19y
ZWFkX2hlYWRlciwgaGVhZGVyKSAhPQ0KPiA+PiArICAgICAgICAgY29udGFpbmVyX29mKHJkYXRh
LCBzdHJ1Y3QgbmZzX3JlYWRfaGVhZGVyLCBycGNfZGF0YSkpDQo+ID4+ICsgICAgICAgICAgICAg
a2ZyZWUocmRhdGEpOw0KPiA+DQo+ID4gVGhpcyBsb29rcyB1bm5lY2Vzc2FyaWx5IGNvbXBsaWNh
dGVkLiBIb3cgYWJvdXQNCj4gPg0KPiA+ICAgICAgICBpZiAocmRhdGEgIT0gJmhkci0+cnBjX2Rh
dGEpDQo+ID4gICAgICAgICAgICAgICAga2ZyZWUocmRhdGEpOw0KPiA+DQo+IA0KPiBUaGF0IHdv
bid0IHdvcmsuICBUaGVyZSBpcyBubyBoZHItPnJwY19kYXRhLg0KDQpEb2ghIE1ha2UgdGhhdA0K
DQoJc3RydWN0IG5mc19yZWFkX2hlYWRlciAqcmVhZF9oZWFkZXIgPSBjb250YWluZXJfb2YoaGRy
LCBzdHJ1Y3QuLi4uKTsNCg0KCWlmIChyZGF0YSAhPSAmcmVhZF9oZWFkZXItPnJwY19kYXRhKQ0K
CQlrZnJlZShyZGF0YSk7DQoNClRoZSByZWFzb24gZm9yIHByZWZlcnJpbmcgdGhlIGFib3ZlIGxp
bmUgaXMgdGhhdCBJIGNhbiB0cml2aWFsbHkgc2VlDQp0aGF0IHRoZSByZWFzb24gd2h5IEkgZG9u
J3Qgd2FudCB0byBkbyB0aGUga2ZyZWUoKSBpcyBiZWNhdXNlIEknbQ0KcG9pbnRpbmcgYXQgYSBm
aWVsZCBpbnNpZGUgdGhlIHJlYWRfaGVhZGVyLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGlu
dXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFw
cC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
