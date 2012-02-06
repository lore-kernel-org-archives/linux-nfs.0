Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30312 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756066Ab2BFXFY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Feb 2012 18:05:24 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFS: Fall back on old idmapper if request_key()
 fails
Date: Mon, 6 Feb 2012 23:05:01 +0000
Message-ID: <1328569500.23323.5.camel@lade.trondhjem.org>
References: <1327614865-29322-1-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1327614865-29322-1-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTAxLTI2IGF0IDE2OjU0IC0wNTAwLCBianNjaHVtYUBuZXRhcHAuY29tIHdy
b3RlOg0KPiBGcm9tOiBCcnlhbiBTY2h1bWFrZXIgPGJqc2NodW1hQG5ldGFwcC5jb20+DQo+IA0K
PiBUaGlzIHBhdGNoIHJlbW92ZXMgdGhlIENPTkZJR19ORlNfVVNFX05FV19JRE1BUFBFUiBjb21w
aWxlIG9wdGlvbi4NCj4gRmlyc3QsIHRoZSBpZG1hcHBlciB3aWxsIGF0dGVtcHQgdG8gbWFwIHRo
ZSBpZCB1c2luZyAvc2Jpbi9yZXF1ZXN0LWtleQ0KPiBhbmQgbmZzaWRtYXAuICBJZiB0aGlzIGZh
aWxzIChpZiAvZXRjL3JlcXVlc3Qta2V5LmNvbmYgaXMgbm90IGNvbmZpZ3VyZWQNCj4gcHJvcGVy
bHkpIHRoZW4gdGhlIGlkbWFwcGVyIHdpbGwgY2FsbCB0aGUgbGVnYWN5IGNvZGUgdG8gcGVyZm9y
bSB0aGUNCj4gbWFwcGluZy4gIEkgbGVmdCBhIGNvbW1lbnQgc3RhdGluZyB3aGVyZSB0aGUgbGVn
YWN5IGNvZGUgYmVnaW5zIHRvIG1ha2UNCj4gaXQgZWFzaWVyIGZvciBzb21lYm9keSB0byByZW1v
dmUgaW4gdGhlIGZ1dHVyZS4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEJyeWFuIFNjaHVtYWtlciA8
YmpzY2h1bWFAbmV0YXBwLmNvbT4NCj4gLS0tDQo+IEkgdGVzdGVkIHRoaXMgb24gYm90aCBBcmNo
bGludXggd2l0aCBuZnMtdXRpbHMgMS4yLjUgYW5kIG9uIEZlZG9yYSB3aXRoDQo+IG5mcy11dGls
cyAxLjIuNi1yYzYuICBJdCBkaWQgd2hhdCB3YXMgZXhwZWN0ZWQgaW4gYm90aCBjYXNlcy4NCj4g
DQoNCkl0IGRpZG4ndCBhcHBseSBvbiB0b3Agb2YgdGhlIG5hbWVzcGFjZSBjaGFuZ2VzLiBDYW4g
eW91IHBsZWFzZSBjaGVjayBpZg0KbXkgYXR0ZW1wdCBhdCBmaXhpbmcgaXQgdXAgaXMgY29ycmVj
dD8gWW91J2xsIGZpbmQgaXQgaW4gdGhlICdkZXZlbCcNCmJyYW5jaCBvZiBteSBnaXQgcmVwb3Np
dG9yeS4NCg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFp
bmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29t
DQoNCg==
