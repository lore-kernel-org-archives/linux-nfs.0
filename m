Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:45777 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754846AbdEKMQn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 May 2017 08:16:43 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "mhocko@kernel.org" <mhocko@kernel.org>,
        "n.borisov.lkml@gmail.com" <n.borisov.lkml@gmail.com>
CC: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client fixes for 4.12
Date: Thu, 11 May 2017 12:16:37 +0000
Message-ID: <1494504995.3207.1.camel@primarydata.com>
References: <1494434821.4764.1.camel@primarydata.com>
         <be16be57-235c-fdf9-f708-3898aeeeb5aa@gmail.com>
         <20170511075910.GD26782@dhcp22.suse.cz>
In-Reply-To: <20170511075910.GD26782@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE3LTA1LTExIGF0IDA5OjU5ICswMjAwLCBNaWNoYWwgSG9ja28gd3JvdGU6DQo+
IE9uIFRodSAxMS0wNS0xNyAxMDo1MzoyNywgTmlrb2xheSBCb3Jpc292IHdyb3RlOg0KPiA+IA0K
PiA+IA0KPiA+IE9uIDEwLjA1LjIwMTcgMTk6NDcsIFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4g
DQo+IFsuLi5dDQo+ID4gPiAtIENsZWFudXAgYW5kIHJlbW92YWwgb2Ygc29tZSBtZW1vcnkgZmFp
bHVyZSBwYXRocyBub3cgdGhhdA0KPiA+ID4gwqAgR0ZQX05PRlMgaXMgZ3VhcmFudGVlZCB0byBu
ZXZlciBmYWlsLg0KPiA+IA0KPiA+IFdoYXQgZ3VhcmFudGVlcyB0aGF0PyBTaW5jZSBpZiB0aGlz
IGlzIHRoZSBjYXNlIHRoZW4gdGhpcyBjYW4NCj4gPiByZXN1bHQgaW4NCj4gPiBhIGxvdCBvZiBv
cHBvcnR1bml0aWVzIGZvciBjbGVhbnVwIGFjcm9zcyB0aGUgd2hvbGUga2VybmVsIHRyZWUuDQo+
ID4gQWZ0ZXINCj4gPiBkaXNjdXNzaW5nIHdpdGggbWhvY2tvIChjYydlZCkgaXQgc2VlbXMgdGhh
dCBpbiBwcmFjdGljZSBldmVyeXRoaW5nDQo+ID4gYmVsb3cgQ09TVExZX09SREVSIHdoaWNoIGFy
ZSBub3QgR0ZQX05PUkVUUlkgd2lsbCBuZXZlciBmYWlsLiBCdXQNCj4gPiB0aGlzDQo+ID4gc2Vt
YW50aWMgaXMgbm90IHRoZSBzYW1lIGFzIEdGUF9OT0ZBSUwuIEUuZy4gbm90aGluZyBndWFyYW50
ZWVzDQo+ID4gdGhhdA0KPiA+IHRoaXMgd2lsbCBzdGF5IGxpa2UgdGhhdCBpbiB0aGUgZnV0dXJl
Pw0KPiANCj4gSW4gcHJhY3RpY2UgaXQgaXMgaGFyZCB0byBjaGFuZ2UgdGhlIHNlbWFudGljIG9m
IHNtYWxsIGFsbG9jYXRpb25zDQo+IG5ldmVyDQo+IGZhaWwgX3ByYWN0aWNhbGx5Xy4gQnV0IHRo
aXMgaXMgYWJzb2x1dGVseSBub3QgZ3VhcmFudGVlZCEgVGhleSBjYW4NCj4gZmFpbA0KPiBlLmcu
IHdoZW4gdGhlIGFsbG9jYXRpb24gY29udGV4dCBpcyB0aGUgb29tIHZpY3RpbS4gUmVtb3Zpbmcg
ZXJyb3INCj4gcGF0aHMNCj4gZm9yIGFsbG9jYXRpb24gZmFpbHVyZXMgaXMganVzdCB3cm9uZy4N
Cg0KT0ssIHRoaXMgbWFrZXMgbm8gZnVja2luZyBzZW5zZSBhdCBhbGwuDQoNCkVpdGhlciBhbGxv
Y2F0aW9ucyBjYW4gZmFpbCBvciB0aGV5IGNhbid0Lg0KMSkgSWYgdGhleSBjYW4ndCBmYWlsLCB0
aGVuIHdlIGRvbid0IG5lZWQgdGhlIGNoZWNrcy4NCjIpIElmIHRoZXkgY2FuIGZhaWwsIHRoZW4g
d2UgZG8gbmVlZCB0aGVtLCBhbmQgdGhpcyBoYW5kIHdyaW5naW5nIGluDQp0aGUgTU0gY29tbXVu
aXR5IGFib3V0IEdGUF8qIHNlbWFudGljcyBhbmQgaG93IHdlIG5lZWQgdG8gcHJldmVudA0KZmFp
bHVyZSBpcyBmdWNraW5nIHBvaW50bGVzcy4NCg0KU28gd2hpY2ggaXMgaXQ/ICgxKSBvciAoMik/
DQoNCg0KDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWlu
ZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

