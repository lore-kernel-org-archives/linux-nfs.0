Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:59308 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754927AbcEZTdP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 May 2016 15:33:15 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Tom Haynes <loghyr@excfb.com>, Andy Adamson <androsadamson@gmail.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Configuring flex file DS on Linux upstream
Date: Thu, 26 May 2016 19:33:13 +0000
Message-ID: <62F2279F-BDDF-4E97-A472-58ED47D2FFA0@netapp.com>
References: <04273F60-806B-4E12-B097-388C346F2DED@oracle.com>
 <40E6E131-029E-4337-A235-B1DB5CA687AA@netapp.com>
 <20160525184837.GA15210@fieldses.org>
 <9614D777-9C75-4FBB-BD06-4EC366273B49@oracle.com>
 <CAHVgHyVEx1fUP36tHaB-uBMJmC3gqCeQ5PSgaHm9XrAWQqerqw@mail.gmail.com>
 <20160526152253.GC21450@fieldses.org>
 <20160526183134.GA30979@psyklo.internal.excfb.com>
 <20160526184118.GB22868@fieldses.org>
In-Reply-To: <20160526184118.GB22868@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIE1heSAyNiwgMjAxNiwgYXQgMjo0MSBQTSwgSi4gQnJ1Y2UgRmllbGRzIDxiZmllbGRz
QGZpZWxkc2VzLm9yZz4gd3JvdGU6DQo+IA0KPiBPbiBUaHUsIE1heSAyNiwgMjAxNiBhdCAxMToz
MTozNEFNIC0wNzAwLCBUb20gSGF5bmVzIHdyb3RlOg0KPj4gZndpdywgSSdtIGxvb2tpbmcgYXQg
YmVpbmcgYWJsZSB0byBzcGVjaWZ5IGEgcmVtb3RlIERTIGZvciB0aGUgbmV4dCB2ZXJzaW9uDQo+
PiBvZiB0aGUgZmxleCBmaWxlIHNlcnZlci4gSXMgaXQgd29ydGggY29uc2lkZXJpbmcgdGhhdCBp
biB0aGUgZGlzY3Vzc2lvbg0KPj4gYmVpbmcgZG9uZSBpbiBBbmR5J3MgdGhyZWFkIGFib3V0ICJD
b25maWd1cmluZyBmc19sb2NhdGlvbnMgb24gTGludXggdXBzdHJlYW0gc2VydmVyIHBzZXVkbyBm
cyBmb3Igc2Vzc2lvbiB0cnVua2luZyI/DQo+PiANCj4+IEZvciBleGFtcGxlOg0KPj4gDQo+PiAv
bWRzICoocncscG5mcyxmZl9kcz0xOTIuMTY4LjIuMTAxLjIwNDk6L2RzLGluc2VjdXJlLG5vX3Jv
b3Rfc3F1YXNoLG5vX2FsbF9zcXVhc2gpDQo+PiANCj4+IEFuZCBpbiB0aGUgZmFyIGZ1dHVyZSwg
SSdkIHdhbnQgaXQgdG8gYmUgYSBtdWx0aXBhdGggbGlzdC4NCj4+IA0KPj4gSSBkb24ndCBzZWUg
dGhpcyBhcyBzb21ldGhpbmcgdGhhdCBjaGFuZ2VzIG9mdGVuIGFuZCB0aGUgZXhwb3J0cw0KPj4g
c2VlbSBsaWtlIHRoZSBtb3N0IG5hdHVyYWwgZml0Lg0KPiANCj4gSSBkb24ndCB1bmRlcnN0YW5k
IHRoZSAiOi9kcyIgcGFydC4gIFlvdSBqdXN0IGxvb2sgdXAgc3R1ZmYgYnkNCj4gZmlsZWhhbmRs
ZSBvbiB0aGUgZGF0YSBzZXJ2ZXIsIHNvIHdlIHNob3VsZG4ndCBoYXZlIHRvIGtub3cgYW55dGhp
bmcNCj4gYWJvdXQgcGF0aHMgdGhlcmUsIHNob3VsZCB3ZT8gIE9yIGlzIHRoZSBwcm9ibGVtIHRo
YXQgaXQgbWlnaHQgbmVlZCB0bw0KPiBtb3VudCBzb21ldGhpbmcgZmlyc3QgaW4gdGhlIHYzIGNh
c2U/DQo+IA0KPiBPdGhlcndpc2UsIEkgZ3Vlc3MgZXhwb3J0cyBtYWtlcyBzZW5zZSwgYXMgbG9u
ZyBhcyB0aGlzIHJlYWxseSBpcw0KPiBwZXItZXhwb3J0IGluZm9ybWF0aW9uLg0KDQoNCklJVUMg
dGhlIGZmX2RzPSBsaW5lIHRlbGxzIHRoZSBtZHMgb2YgZGF0YSBzZXJ2ZXJzIGl0IGlzIG1hbmFn
aW5nLCBhbmQgaG93IHRvIG1vdW50IHRoZW0uIFNvIHRoaXMgaXMgbm90IG1kcyBleHBvcnQgaW5m
b3JtYXRpb24gLSBtZHMgaXMgbm90IGV4cG9ydGluZyB0aGUgZmZfZHM9ICwgcmF0aGVyIG1kcyBt
b3VudCBpbmZvcm1hdGlvbi4NCg0K4oCUPkFuZHkNCg0KPiANCj4gDQo+IFRoZSB0aGluZyB0aGF0
J3MgYSBsaXR0bGUgZGlmZmVyZW50IGFib3V0IHRoZSBtdWx0aXBhdGggaW5mb3JtYXRpb24gaXMN
Cj4gdGhhdCB0aGF0J3MgcmVhbGx5IGEgZ2xvYmFsIHNlcnZlciBwcm9wZXJ0eSwgbm90IHNvbWV0
aGluZyB0aGF0IGNhbiB2YXJ5DQo+IGZyb20gb25lIGZpbGVzeXN0ZW0gdG8gYW5vdGhlci4NCj4g
DQo+IC0tYi4NCg0K
