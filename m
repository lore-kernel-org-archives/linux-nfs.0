Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:47786 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753664AbcFMTYN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2016 15:24:13 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <schumakeranna@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] fix backchannel crash due to multipath
Date: Mon, 13 Jun 2016 19:24:06 +0000
Message-ID: <285640B8-5ACD-4108-BFF6-F9342E857102@primarydata.com>
References: <20160613182104.GA19825@fieldses.org>
In-Reply-To: <20160613182104.GA19825@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNCk9uIDYvMTMvMTYsIDE0OjIxLCAiSi4gQnJ1Y2UgRmllbGRzIiA8YmZpZWxkc0BmaWVsZHNl
cy5vcmc+IHdyb3RlOg0KDQo+T24gTWFyY2ggMjQgSi4gQnJ1Y2UgRmllbGRzIHNhaWQ6DQo+PiBw
eW5mcyBjYW4gY3Jhc2ggdGhlIG5mcyBzZXJ2ZXIgc2luY2UgdGhlIG5ldyBtdWx0aXBhdGggY29k
ZS4gIFRoZQ0KPj4gcHJvYmxlbSBpcyB0aGF0IHB5bmZzIHVzZXMgdGhlIHNhbWUgdGNwIGNvbm5l
Y3Rpb24gZm9yIG11bHRpcGxlIHY0DQo+PiBjbGllbnRzIChzb21ldGhpbmcgdGhlIHNwZWMgZXhw
bGljaXRseSBhbGxvd3MpLiAgVGhlIGNhbGxiYWNrIGNsaWVudCBpbg0KPj4gc3VjaCBjYXNlcyBo
YXMgdG8gc2hhcmUgdGhlIHNhbWUgcnBjX3hwcnQuICBUaGUgbmV3IHJwYyBjb2RlLCB3aGVuIGl0
DQo+PiBjcmVhdGVzIHR3byBjYWxsYmFjayBjbGllbnRzIHNoYXJpbmcgdGhlIHNhbWUgcnBjX3hw
cnQsIGVuZHMgdXAgdHJ5aW5nDQo+PiB0byBrZWVwIHRoYXQgcnBjX3hwcnQgb24gdGhlIGxpc3Rz
IG9mIHR3byBkaWZmZXJlbnQgcnBjX3hwcnRfc3dpdGNoJ3MuDQo+PiBUaGUgZmlyc3Qgc3ltcHRv
bSBJIHNlZSBpcyBhIGxpc3QgY29ycnVwdGlvbiB3YXJuaW5nLg0KPj4NCj4+IFNvLCBJJ20gZW5m
b3JjaW5nIHRoZSByZXF1aXJlbWVudCB0aGF0IHRoZXJlIGJlIG9ubHkgb25lIGJhY2tjaGFubmVs
DQo+PiBycGNfeHBydF9zd2l0Y2ggcGVyIHRjcCBjb25uZWN0aW9uIGJ5IGRvaW5nIGFzIHdlIGRv
IGluIHRoZSBycGNfeHBydA0KPj4gY2FzZToga2VlcGluZyBhIHBvaW50ZXIgdG8gaXQgaW4gdGhl
IHN2Y194cHJ0LCBhbmQgdXNpbmcgdGhhdCB3aGVuIGl0J3MNCj4+IGF2YWlsYWJsZSBpbnN0ZWFk
IG9mIGFsbG9jYXRpbmcgYSBuZXcgb25lLg0KPg0KPj4gVGhhdCdzIGEgcHJldHR5IHN0cmFpZ2h0
Zm9yd2FyZCBmaXggKGFuZCBJJ3ZlIHZlcmlmaWVkIGl0IHdvcmtzKSwgYnV0DQo+PiBkb2Vzbid0
IGxvb2sgdmVyeSBlbGVnYW50LiAgSWYgdGhlcmUncyBhIGJldHRlciBzb2x1dGlvbiwgSSdtIGFs
bCBlYXJzLg0KPg0KPkkgaGF2ZW4ndCBjb21lIHVwIHdpdGggYW55dGhpbmcgbmVhdGVyLCBhbmQg
a2luZCBvZiBuZWVkIHRoZSBjcmFzaA0KPmZpeGVkLiAgQUNLIG9yIE5BQ0s/ICBJIGNhbiB0YWtl
IGl0IHRocm91Z2ggbXkgdHJlZSBpZiBpdCdzIGFuIEFDSy4NCj4NCj4tLWIuDQo+DQoNCkFjaw0K
DQo=

