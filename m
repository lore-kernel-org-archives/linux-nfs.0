Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:54679 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752395AbdAZU0P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2017 15:26:15 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs: Fix "Don't increment lock sequence ID after
 NFS4ERR_MOVED"
Date: Thu, 26 Jan 2017 20:26:07 +0000
Message-ID: <1485462365.3367.1.camel@primarydata.com>
References: <20170126201452.6760.70964.stgit@manet.1015granger.net>
In-Reply-To: <20170126201452.6760.70964.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE3LTAxLTI2IGF0IDE1OjE0IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
TG9jayBzZXF1ZW5jZSBJRHMgYXJlIGJ1bXBlZCBpbiBkZWNvZGVfbG9jayBieSBjYWxsaW5nDQo+
IG5mc19pbmNyZW1lbnRfc2VxaWQoKS4gbmZzX2luY3JlbWVudF9zZXF1aWQoKSBkb2VzIG5vdCB1
c2UgdGhlDQo+IHNlcWlkX211dGF0aW5nX2VycigpIGZ1bmN0aW9uIGZpeGVkIGluIGNvbW1pdCAw
NTlhYTczNDgyNDEgKCJEb24ndA0KPiBpbmNyZW1lbnQgbG9jayBzZXF1ZW5jZSBJRCBhZnRlciBO
RlM0RVJSX01PVkVEIikuDQo+IA0KPiBGaXhlczogMDU5YWE3MzQ4MjQxICgiRG9uJ3QgaW5jcmVt
ZW50IGxvY2sgc2VxdWVuY2UgSUQgYWZ0ZXIgLi4uIikNCj4gU2lnbmVkLW9mZi1ieTogQ2h1Y2sg
TGV2ZXIgPGNodWNrLmxldmVyQG9yYWNsZS5jb20+DQo+IFRlc3RlZC1ieTogWHVhbiBRaSA8eHVh
bi5xaUBvcmFjbGUuY29tPg0KPiBDYzogc3RhYmxlQHZnZXIua2VybmVsLm9yZyAjIHYzLjcrDQo+
IC0tLQ0KPiDCoGZzL25mcy9uZnM0c3RhdGUuYyB8wqDCoMKgwqAxICsNCj4gwqAxIGZpbGUgY2hh
bmdlZCwgMSBpbnNlcnRpb24oKykNCj4gDQo+IGRpZmYgLS1naXQgYS9mcy9uZnMvbmZzNHN0YXRl
LmMgYi9mcy9uZnMvbmZzNHN0YXRlLmMNCj4gaW5kZXggOTBlNjE5My4uZGFlYjk0ZSAxMDA2NDQN
Cj4gLS0tIGEvZnMvbmZzL25mczRzdGF0ZS5jDQo+ICsrKyBiL2ZzL25mcy9uZnM0c3RhdGUuYw0K
PiBAQCAtMTA5MSw2ICsxMDkxLDcgQEAgc3RhdGljIHZvaWQgbmZzX2luY3JlbWVudF9zZXFpZChp
bnQgc3RhdHVzLA0KPiBzdHJ1Y3QgbmZzX3NlcWlkICpzZXFpZCkNCj4gwqAJCWNhc2UgLU5GUzRF
UlJfQkFEWERSOg0KPiDCoAkJY2FzZSAtTkZTNEVSUl9SRVNPVVJDRToNCj4gwqAJCWNhc2UgLU5G
UzRFUlJfTk9GSUxFSEFORExFOg0KPiArCQljYXNlIC1ORlM0RVJSX01PVkVEOg0KPiDCoAkJCS8q
IE5vbi1zZXFpZCBtdXRhdGluZyBlcnJvcnMgKi8NCj4gwqAJCQlyZXR1cm47DQo+IMKgCX07DQo+
IA0KDQpUaGFua3MhIEFwcGxpZWQuLi4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5G
UyBjbGllbnQgbWFpbnRhaW5lciwgUHJpbWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5
ZGF0YS5jb20NCg==

