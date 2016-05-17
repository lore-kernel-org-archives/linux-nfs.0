Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:6992 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751515AbcEQUVd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2016 16:21:33 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Schumaker, Anna" <Anna.Schumaker@netapp.com>
CC: "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 4 01/10] NFS default callback ops
Date: Tue, 17 May 2016 20:21:15 +0000
Message-ID: <D6069393-D221-47BD-8B55-B5920E2B4964@netapp.com>
References: <1462993705-14673-1-git-send-email-andros@netapp.com>
 <1462993705-14673-2-git-send-email-andros@netapp.com>
 <6beca2b4-4951-fa56-f965-18863e85f700@Netapp.com>
In-Reply-To: <6beca2b4-4951-fa56-f965-18863e85f700@Netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIE1heSAxNywgMjAxNiwgYXQgNDoxNyBQTSwgU2NodW1ha2VyLCBBbm5hIDxBbm5hLlNj
aHVtYWtlckBuZXRhcHAuY29tPiB3cm90ZToNCj4gDQo+IEhpIEFuZHksDQo+IA0KPiBJIHRoaW5r
IHlvdSdyZSBtaXNzaW5nIGEgd29yZCBvciB0d28gZnJvbSB0aGUgdGl0bGUgb2YgdGhpcyBwYXRj
aC4gIEknbSBndWVzc2luZyBpdCBzaG91bGQgc2F5ICJyZW5hbWUgZGVmYXVsdCBjYWxsYmFjayBv
cHPigJ0/DQoNClllcy4NCg0K4oCUPkFuZHkNCj4gDQo+IEFubmENCj4gDQo+IE9uIDA1LzExLzIw
MTYgMDM6MDggUE0sIGFuZHJvc0BuZXRhcHAuY29tIHdyb3RlOg0KPj4gRnJvbTogQW5keSBBZGFt
c29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4+IA0KPj4gQWxzbyB1c2Ugd2l0aCByZWZhY3RvcmVk
IGV4Y2hhbmdlX2lkIGZvciBzZXNzaW9uIHRydW5raW5nDQo+PiANCj4+IFNpZ25lZC1vZmYtYnk6
IEFuZHkgQWRhbXNvbiA8YW5kcm9zQG5ldGFwcC5jb20+DQo+PiAtLS0NCj4+IGZzL25mcy9uZnM0
cHJvYy5jIHwgOCArKysrLS0tLQ0KPj4gMSBmaWxlIGNoYW5nZWQsIDQgaW5zZXJ0aW9ucygrKSwg
NCBkZWxldGlvbnMoLSkNCj4+IA0KPj4gZGlmZiAtLWdpdCBhL2ZzL25mcy9uZnM0cHJvYy5jIGIv
ZnMvbmZzL25mczRwcm9jLmMNCj4+IGluZGV4IDMyN2I4YzMuLmRhMmFhMmUgMTAwNjQ0DQo+PiAt
LS0gYS9mcy9uZnMvbmZzNHByb2MuYw0KPj4gKysrIGIvZnMvbmZzL25mczRwcm9jLmMNCj4+IEBA
IC02Nzg0LDEyICs2Nzg0LDEyIEBAIG5mczQxX3NhbWVfc2VydmVyX3Njb3BlKHN0cnVjdCBuZnM0
MV9zZXJ2ZXJfc2NvcGUgKmEsDQo+PiB9DQo+PiANCj4+IHN0YXRpYyB2b2lkDQo+PiAtbmZzNF9i
aW5kX29uZV9jb25uX3RvX3Nlc3Npb25fZG9uZShzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2ssIHZvaWQg
KmNhbGxkYXRhKQ0KPj4gK25mczRfcHJvY19kZWZhdWx0X2RvbmUoc3RydWN0IHJwY190YXNrICp0
YXNrLCB2b2lkICpjYWxsZGF0YSkNCj4+IHsNCj4+IH0NCj4+IA0KPj4gLXN0YXRpYyBjb25zdCBz
dHJ1Y3QgcnBjX2NhbGxfb3BzIG5mczRfYmluZF9vbmVfY29ubl90b19zZXNzaW9uX29wcyA9IHsN
Cj4+IC0JLnJwY19jYWxsX2RvbmUgPSAgJm5mczRfYmluZF9vbmVfY29ubl90b19zZXNzaW9uX2Rv
bmUsDQo+PiArc3RhdGljIGNvbnN0IHN0cnVjdCBycGNfY2FsbF9vcHMgbmZzNF9wcm9jX2RlZmF1
bHRfb3BzID0gew0KPj4gKwkucnBjX2NhbGxfZG9uZSA9ICAmbmZzNF9wcm9jX2RlZmF1bHRfZG9u
ZSwNCj4+IH07DQo+PiANCj4+IC8qDQo+PiBAQCAtNjgyMCw3ICs2ODIwLDcgQEAgaW50IG5mczRf
cHJvY19iaW5kX29uZV9jb25uX3RvX3Nlc3Npb24oc3RydWN0IHJwY19jbG50ICpjbG50LA0KPj4g
CXN0cnVjdCBycGNfdGFza19zZXR1cCB0YXNrX3NldHVwX2RhdGEgPSB7DQo+PiAJCS5ycGNfY2xp
ZW50ID0gY2xudCwNCj4+IAkJLnJwY194cHJ0ID0geHBydCwNCj4+IC0JCS5jYWxsYmFja19vcHMg
PSAmbmZzNF9iaW5kX29uZV9jb25uX3RvX3Nlc3Npb25fb3BzLA0KPj4gKwkJLmNhbGxiYWNrX29w
cyA9ICZuZnM0X3Byb2NfZGVmYXVsdF9vcHMsDQo+PiAJCS5ycGNfbWVzc2FnZSA9ICZtc2csDQo+
PiAJCS5mbGFncyA9IFJQQ19UQVNLX1RJTUVPVVQsDQo+PiAJfTsNCj4+IA0KPiANCg0K
