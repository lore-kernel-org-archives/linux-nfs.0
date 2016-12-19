Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:22441 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754342AbcLSRAP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Dec 2016 12:00:15 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: Anna Schumaker <schumaker.anna@gmail.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/9] NFSv4: Don't invalidate the directory twice
Date: Mon, 19 Dec 2016 17:00:09 +0000
Message-ID: <D434087C-A5A6-4DC8-AC79-967A6BBA21A0@primarydata.com>
References: <20161217182711.10643-1-trond.myklebust@primarydata.com>
 <20161217182711.10643-2-trond.myklebust@primarydata.com>
 <2099263b-3d8e-f237-3dd8-50dc0f63fb3e@gmail.com>
 <DBC3F2C7-BF49-4209-B403-AAEB68D0A96A@primarydata.com>
In-Reply-To: <DBC3F2C7-BF49-4209-B403-AAEB68D0A96A@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIERlYyAxOSwgMjAxNiwgYXQgMTE6NTYsIFRyb25kIE15a2xlYnVzdCA8dHJvbmRteUBw
cmltYXJ5ZGF0YS5jb20+IHdyb3RlOg0KPiANCj4gV2hhdOKAmXMgdGhlIGZpbGVzeXN0ZW0geW91
4oCZcmUgdGVzdGluZyBvbj8NCg0K4oCmYW5kIHdoYXQgaXMgdGhlIHRpbWVzdGFtcCByZXNvbHV0
aW9uIHlvdeKAmXJlIHNlZWluZyBvbiBpdD8NCg0KPiANCj4+IE9uIERlYyAxOSwgMjAxNiwgYXQg
MTE6NTQsIEFubmEgU2NodW1ha2VyIDxzY2h1bWFrZXIuYW5uYUBnbWFpbC5jb20+IHdyb3RlOg0K
Pj4gDQo+PiBIaSBUcm9uZCwNCj4+IA0KPj4gT24gMTIvMTcvMjAxNiAwMToyNyBQTSwgVHJvbmQg
TXlrbGVidXN0IHdyb3RlOg0KPj4+IElmIGFuIG9wZXJhdGlvbiB0aGF0IG1vZGlmaWVkIHRoZSBk
aXJlY3RvcnkgcmFjZWQgd2l0aCBhIEdFVEFUVFIsIHRoZW4gd2UNCj4+PiBkb24ndCBuZWVkIHRv
IGludmFsaWRhdGUgdGhlIGRpcmVjdG9yeSBjYWNoZSBtb3JlIHRoYW4gb25jZS4NCj4+IA0KPj4g
VGhpcyBwYXRjaCBjYXVzZXMgY3Rob24gYmFzaWMgdGVzdHMgdG8gZmFpbCB3aXRoOg0KPj4gDQo+
PiAuL3Rlc3Q2OiByZWFkZGlyDQo+PiAgICAgICAuL3Rlc3Q2OiAoL25mcy9hbGwpIHVubGlua2Vk
ICdmaWxlLjAnIGRpciBlbnRyeSByZWFkIHBhc3MgMQ0KPj4gICAgICAgLi90ZXN0NjogKC9uZnMv
YWxsKSBUZXN0IGZhaWxlZCB3aXRoIDEgZXJyb3JzDQo+PiBiYXNpYyB0ZXN0cyBmYWlsZWQNCj4+
IA0KPj4gVGhhbmtzLA0KPj4gQW5uYQ0KPj4+IA0KPj4+IFNpZ25lZC1vZmYtYnk6IFRyb25kIE15
a2xlYnVzdCA8dHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbT4NCj4+PiAtLS0NCj4+PiBm
cy9uZnMvbmZzNHByb2MuYyB8IDMgKysrDQo+Pj4gMSBmaWxlIGNoYW5nZWQsIDMgaW5zZXJ0aW9u
cygrKQ0KPj4+IA0KPj4+IGRpZmYgLS1naXQgYS9mcy9uZnMvbmZzNHByb2MuYyBiL2ZzL25mcy9u
ZnM0cHJvYy5jDQo+Pj4gaW5kZXggZDMzMjQyYzhkOTVkLi43MTM5MzI0NDBlMDcgMTAwNjQ0DQo+
Pj4gLS0tIGEvZnMvbmZzL25mczRwcm9jLmMNCj4+PiArKysgYi9mcy9uZnMvbmZzNHByb2MuYw0K
Pj4+IEBAIC0xMDg4LDEyICsxMDg4LDE1IEBAIHN0YXRpYyB2b2lkIHVwZGF0ZV9jaGFuZ2VhdHRy
KHN0cnVjdCBpbm9kZSAqZGlyLCBzdHJ1Y3QgbmZzNF9jaGFuZ2VfaW5mbyAqY2luZm8pDQo+Pj4g
CXN0cnVjdCBuZnNfaW5vZGUgKm5mc2kgPSBORlNfSShkaXIpOw0KPj4+IA0KPj4+IAlzcGluX2xv
Y2soJmRpci0+aV9sb2NrKTsNCj4+PiArCWlmIChkaXItPmlfdmVyc2lvbiA9PSBjaW5mby0+YWZ0
ZXIpDQo+Pj4gKwkJZ290byBvdXQ7DQo+Pj4gCW5mc2ktPmNhY2hlX3ZhbGlkaXR5IHw9IE5GU19J
Tk9fSU5WQUxJRF9BVFRSfE5GU19JTk9fSU5WQUxJRF9EQVRBOw0KPj4+IAlpZiAoIWNpbmZvLT5h
dG9taWMgfHwgY2luZm8tPmJlZm9yZSAhPSBkaXItPmlfdmVyc2lvbikNCj4+PiAJCW5mc19mb3Jj
ZV9sb29rdXBfcmV2YWxpZGF0ZShkaXIpOw0KPj4+IAlkaXItPmlfdmVyc2lvbiA9IGNpbmZvLT5h
ZnRlcjsNCj4+PiAJbmZzaS0+YXR0cl9nZW5jb3VudCA9IG5mc19pbmNfYXR0cl9nZW5lcmF0aW9u
X2NvdW50ZXIoKTsNCj4+PiAJbmZzX2ZzY2FjaGVfaW52YWxpZGF0ZShkaXIpOw0KPj4+ICtvdXQ6
DQo+Pj4gCXNwaW5fdW5sb2NrKCZkaXItPmlfbG9jayk7DQo+Pj4gfQ0KPj4+IA0KPj4+IA0KPj4g
DQo+IA0KPiBO77+977+977+977+977+9cu+/ve+/vXnvv73vv73vv71i77+9WO+/ve+/vcendu+/
vV7vv70p3rp7Lm7vv70r77+977+977+977+9e++/ve+/ve+/vSLvv73vv71ebu+/vXLvv73vv73v
v71677+9Gu+/ve+/vWjvv73vv73vv73vv70m77+977+9Hu+/vUfvv73vv73vv71o77+9Ayjvv73p
mo7vv73domoi77+977+9Gu+/vRtt77+977+977+977+977+9eu+/vd6W77+977+977+9Zu+/ve+/
ve+/vWjvv73vv73vv71+77+9be+/vQ0KDQo=

