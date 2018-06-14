Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-cys01nam02on0124.outbound.protection.outlook.com ([104.47.37.124]:5232
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755071AbeFNQ0Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Jun 2018 12:26:25 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>
CC: "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] NFS: Fix an rcu deadlock in nfs_delegation_find_inode()
Date: Thu, 14 Jun 2018 16:26:21 +0000
Message-ID: <d04511bbd3c35862af6267ba696954af3e724f14.camel@hammerspace.com>
References: <20180614133917.27656-1-Anna.Schumaker@Netapp.com>
In-Reply-To: <20180614133917.27656-1-Anna.Schumaker@Netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE4LTA2LTE0IGF0IDA5OjM5IC0wNDAwLCBzY2h1bWFrZXIuYW5uYUBnbWFpbC5j
b20gd3JvdGU6DQo+IEZyb206IEFubmEgU2NodW1ha2VyIDxBbm5hLlNjaHVtYWtlckBOZXRhcHAu
Y29tPg0KPiANCj4gSSB3YXMgYWJsZSB0byByZXByb2R1Y2UgdGhpcyBwcmV0dHkgcmVndWxhcmls
eSB1c2luZyB4ZnN0ZXN0cw0KPiBnZW5lcmljLzAxMyBvbiBORlMgdjQuMC4NCj4gDQo+IFJlcG9y
dGVkLWJ5OiBSb3NzIFp3aXNsZXIgPFJvc3MuWndpc2xlckBsaW51eC5pbnRlbC5jb20+DQo+IEZp
eGVzOiBhMzM3ZmU5MSAoTkZTdjQ6IFJldHVybiBORlM0RVJSX0RFTEFZIHdoZW4gYSBkZWxlZ2F0
aW9uIHJlY2FsbA0KPiBmYWlscyBkdWUgdG8gaWdyYWIoKSkNCj4gU2lnbmVkLW9mZi1ieTogQW5u
YSBTY2h1bWFrZXIgPEFubmEuU2NodW1ha2VyQE5ldGFwcC5jb20+DQo+IC0tLQ0KPiAgZnMvbmZz
L2RlbGVnYXRpb24uYyB8IDQgKysrLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygr
KSwgMSBkZWxldGlvbigtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2ZzL25mcy9kZWxlZ2F0aW9uLmMg
Yi9mcy9uZnMvZGVsZWdhdGlvbi5jDQo+IGluZGV4IGJiZDA0NjU1MzVlYi4uZjAzM2YzYTY5YTNi
IDEwMDY0NA0KPiAtLS0gYS9mcy9uZnMvZGVsZWdhdGlvbi5jDQo+ICsrKyBiL2ZzL25mcy9kZWxl
Z2F0aW9uLmMNCj4gQEAgLTg4Myw4ICs4ODMsMTAgQEAgc3RydWN0IGlub2RlICpuZnNfZGVsZWdh
dGlvbl9maW5kX2lub2RlKHN0cnVjdA0KPiBuZnNfY2xpZW50ICpjbHAsDQo+ICAJcmN1X3JlYWRf
bG9jaygpOw0KPiAgCWxpc3RfZm9yX2VhY2hfZW50cnlfcmN1KHNlcnZlciwgJmNscC0+Y2xfc3Vw
ZXJibG9ja3MsDQo+IGNsaWVudF9saW5rKSB7DQo+ICAJCXJlcyA9IG5mc19kZWxlZ2F0aW9uX2Zp
bmRfaW5vZGVfc2VydmVyKHNlcnZlciwNCj4gZmhhbmRsZSk7DQo+IC0JCWlmIChyZXMgIT0gRVJS
X1BUUigtRU5PRU5UKSkNCj4gKwkJaWYgKHJlcyAhPSBFUlJfUFRSKC1FTk9FTlQpKSB7DQo+ICsJ
CQlyY3VfcmVhZF91bmxvY2soKTsNCj4gIAkJCXJldHVybiByZXM7DQo+ICsJCX0NCj4gIAl9DQo+
ICAJcmN1X3JlYWRfdW5sb2NrKCk7DQo+ICAJcmV0dXJuIEVSUl9QVFIoLUVOT0VOVCk7DQoNCk9o
LCBkdWguLi4gVGhhbmtzIGZvciBzcG90dGluZyB0aGF0IQ0KDQotLSANClRyb25kIE15a2xlYnVz
dA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVi
dXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQo=
