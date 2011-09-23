From: "Benny Halevy" <bhalevy@tonian.com>
Subject: Re: [PATCH] nfs-utils/blkmapd: Add complex block layout discovery and mapping daemon
Date: Fri, 23 Sep 2011 12:48:32 +0000
Message-ID: <108203446-1316782113-cardhu_decombobulator_blackberry.rim.net-990329073-@b4.c3.bise3.blackberry>
Reply-To: bhalevy@tonian.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Jim Rees" <rees@umich.edu>, linux-nfs@vger.kernel.org,
	"Peter Honeyman" <honey@citi.umich.edu>
To: "Steve Dickson" <SteveD@redhat.com>,
	"Benny Halevy" <benny@tonian.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:64795 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895Ab1IWMsg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 08:48:36 -0400
Received: by gxk6 with SMTP id 6so2638318gxk.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2011 05:48:36 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

R3JlYXQuIFRoYW5rcy4NCkknbGwgZm9sbG93IHlvdXIgYW5ub3VuY2VtZW50Lg0KDQpCLg0KLS0t
LS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tLQ0KRnJvbTogU3RldmUgRGlja3Nvbg0KVG86IEJlbm55
IEhhbGV2eQ0KQ2M6IEppbSBSZWVzDQpDYzogbGludXgtbmZzQHZnZXIua2VybmVsLm9yZw0KQ2M6
IFBldGVyIEhvbmV5bWFuDQpTdWJqZWN0OiBSZTogW1BBVENIXSBuZnMtdXRpbHMvYmxrbWFwZDog
QWRkIGNvbXBsZXggYmxvY2sgbGF5b3V0IGRpc2NvdmVyeSBhbmQgbWFwcGluZyBkYWVtb24NClNl
bnQ6IFNlcCAyMywgMjAxMSAxNTo0Mw0KDQpIZXkgQmVubnksDQoNCk9uIDA5LzIzLzIwMTEgMDY6
MjkgQU0sIEJlbm55IEhhbGV2eSB3cm90ZToNCj4gU3RldmUsDQo+IA0KPiBJJ2QgbGlrZSB0byBy
ZWJhc2UgbXkgcG5mcy1uZnMtdXRpbHMgdHJlZSBvbiB0b3Agb2YgeW91ciB0cmVlDQo+IGJ1dCBJ
J2QgcmF0aGVyIGRvIGl0IG9uIHRvcCBvZiBhbiAib2ZmaWNpYWwiIHJlbGVhc2UgcmF0aGVyIHRo
YW4NCj4gb3ZlciBhbiBhcmJpdHJhcnkgdGlwLi4uDQo+IA0KPiBXaGVuIGRvIHlvdSBwbGFuIG9u
IHJlbGVhc2luZyBhIG5ldyAtcmM/DQpJJ20gcGxhbm5pbmcgb24gbWFrZSBhIDEuMi41IHJlbGVh
c2Ugc29tZXRpbWUgdG9kYXkuLi4NCg0Kc3RldmVkLg0KIA0KPiANCj4gQmVubnkNCj4gDQo+IE9u
IDIwMTEtMDktMjIgMjI6NDQsIFN0ZXZlIERpY2tzb24gd3JvdGU6DQo+Pg0KPj4NCj4+IE9uIDA5
LzE3LzIwMTEgMDk6MjUgQU0sIFN0ZXZlIERpY2tzb24gd3JvdGU6DQo+Pj4gSGV5IEppbSwNCj4+
Pg0KPj4+IE15IGFwb2xvZ2llcyBmb3IgdGFraW5nIHNvIGxvbmcgdG8gZ2V0IHRvIHRoaXMuLi4g
Rm9yIHNvbWUNCj4+PiByZWFzb24gSSBuZXZlciBhZGRlZCB0byBteSBUT0RPIGxpc3QuLi4gVGhh
dCBwcm9ibGVtIGhhcw0KPj4+IGJlZW4gcmVzb2x2ZWQuLi4gDQo+Pj4gIA0KPj4+DQo+Pj4gT24g
MDgvMTEvMjAxMSAwMjoyMCBQTSwgSmltIFJlZXMgd3JvdGU6DQo+Pj4+IFRoaXMgZGFlbW9uIGlz
IHJlcXVpcmVkIHRvIGhhbmRsZSB1cGNhbGxzIGZyb20gdGhlIGtlcm5lbCBwbmZzIGJsb2NrIGxh
eW91dA0KPj4+PiBkcml2ZXIuDQo+Pj4+DQo+Pj4+IFNpZ25lZC1vZmYtYnk6IEppbSBSZWVzIDxy
ZWVzQHVtaWNoLmVkdT4NCj4+IENvbW1pdHRlZCB3aXRoIGEgZmV3IG1pbm9yIHR3ZWFrcyB0byBi
b3RoIGNvbmZpZ3VyZS5hYyANCj4+IGFuZCB1dGlscy9ibGttYXBkL01ha2VmaWxlLmFjIHRoYXQg
d2UgZGlzY3Vzc2VkLg0KPj4NCj4+IHN0ZXZlZC4NCj4+IC0tDQo+PiBUbyB1bnN1YnNjcmliZSBm
cm9tIHRoaXMgbGlzdDogc2VuZCB0aGUgbGluZSAidW5zdWJzY3JpYmUgbGludXgtbmZzIiBpbg0K
Pj4gdGhlIGJvZHkgb2YgYSBtZXNzYWdlIHRvIG1ham9yZG9tb0B2Z2VyLmtlcm5lbC5vcmcNCj4+
IE1vcmUgbWFqb3Jkb21vIGluZm8gYXQgIGh0dHA6Ly92Z2VyLmtlcm5lbC5vcmcvbWFqb3Jkb21v
LWluZm8uaHRtbA0KPiANCg0K

