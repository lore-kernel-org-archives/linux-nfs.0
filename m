Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:22598 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423992AbcBQWfo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Feb 2016 17:35:44 -0500
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Martin Houry <martinhoury@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: "Re: [PATCH RFC Version 1 0/6] Request for Comment: NFS4.1
 Session Trunking"
Date: Wed, 17 Feb 2016 22:35:43 +0000
Message-ID: <3B48A59F-638A-45C9-B2E4-2D65C00DE639@netapp.com>
References: <CAEUt8V+L3hV1tQTzanVjGyZ1qoG8qJk7ZnS5HM1_3+Nc4mpO3A@mail.gmail.com>
 <F6DC5176-6340-4945-9EBD-537410882E1D@netapp.com>
 <B10307D6-13C6-4A04-B3A9-B66C27F51E19@oracle.com>
 <20160217205929.GF10401@fieldses.org>
In-Reply-To: <20160217205929.GF10401@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIEZlYiAxNywgMjAxNiwgYXQgMzo1OSBQTSwgSi4gQnJ1Y2UgRmllbGRzIDxiZmllbGRz
QGZpZWxkc2VzLm9yZz4gd3JvdGU6DQo+IA0KPiBPbiBXZWQsIEZlYiAxNywgMjAxNiBhdCAwMjow
NjozNVBNIC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4+IA0KPj4+IE9uIEZlYiAxNywgMjAx
NiwgYXQgOTo1MCBBTSwgQWRhbXNvbiwgQW5keQ0KPj4+IDxXaWxsaWFtLkFkYW1zb25AbmV0YXBw
LmNvbT4gd3JvdGU6IFRoYW5rcyBmb3IgdGVzdGluZy4gQXMgVHJvbmQNCj4+PiBwb2ludGVkIG91
dCwgdGhlIGNvcnJlY3Qgd2F5IHRvIGluZGljYXRlIG11bHRpcGxlIGhvc3RuYW1lcyBpcyBvbg0K
Pj4+IHRoZSBtb3VudCBjb21tYW5kIGxpbmUNCj4+PiANCj4+PiBtb3VudCAtbyBtaW5vcnZlcnNp
b249MSBob3N0MSxob3N0MizDouKCrMKmLGhvc3RuOi88ZXhwb3J0PiAgLzxtbnRkaXI+DQo+PiAN
Cj4+IEl0IG1pZ2h0IGJlIG1vcmUgbmF0dXJhbCBmb3IgTkZTdjQueCB0byB1c2UgYSByZWZlcnJh
bCBvciBhIHBORlMNCj4+IGxheW91dCBpbnN0ZWFkLiAgRG8geW91IHRoaW5rIHRoYXQncyBhIHZp
YWJsZSBhcHByb2FjaD8NCj4gDQo+IFNlZW1zIGxpa2UgYW4gZWFzeSBhcHBsaWNhdGlvbiBmb3Ig
ZnNfbG9jYXRpb25ze19pbmZvP30uICBJdCdkIG5lZWQNCj4gc2VydmVyIHN1cHBvcnQgdG9vLCBh
bmQgSSB0aGluayB5b3UgcHJvYmFibHkgd2FudCB0aGlzIG1hbnVhbCBtZXRob2QgYXMNCj4gd2Vs
bCBmb3Igbm93Lg0KDQpJIGFncmVlIHRoYXQgdGhlIG1hbnVhbCBtZXRob2QgaXMgdXNlZnVsIGFz
IGl0IGFsbG93cyB0aGUgY2xpZW50IGFkbWluIHRvIGRlY2lkZSBpZiB0aGUgbW91bnQgcmVxdWly
ZXMgc2Vzc2lvbiB0cnVua2luZy4NClRoZSBmc19sb2NhdGlvbnMgd291bGQgbmVlZCB0byBiZSBy
ZXF1ZXN0ZWQgYnkgdGhlIGNsaWVudC4gSSBndWVzcyB3ZSByZXFlc3QgdGhlbSBhdCBldmVyeSBt
b3VudOKApi4NCg0KPiANCj4gSSB3b25kZXIgaWYgdGhlIHNlcnZlciBjYW4gZWFzaWx5IGdlbmVy
YXRlIGEgbGlzdCBvZiBJUCBhZGRyZXNzZXMgdG8NCj4gYWR2ZXJ0aXNlIGF1dG9tYXRpY2FsbHk/
ICANCg0KWWVzIC0gZnNfbG9jYXRpb25zIQ0KDQrigJQ+QW5keQ0KDQo+IEluIHdoaWNoIGNhc2Ug
dGhlIHdob2xlIHRoaW5nIHdvdWxkIGJlDQo+IHplcm8tY29uZmlndXJhdGlvbiwgd2hpY2ggd291
bGQgYmUgbmljZS4NCj4gDQo+IHBORlMgc291bmRzIGxpa2Ugb3ZlcmtpbGwuDQo+IA0KPiAtLWIu
DQoNCg==
