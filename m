Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:37088 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754018AbdAZSOL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2017 13:14:11 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfs: Don't increment lock sequence ID after
 NFS4ERR_MOVED
Date: Thu, 26 Jan 2017 18:14:04 +0000
Message-ID: <1485454442.9473.1.camel@primarydata.com>
References: <20170126175938.6021.69650.stgit@manet.1015granger.net>
In-Reply-To: <20170126175938.6021.69650.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE3LTAxLTI2IGF0IDEzOjAwIC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
WHVhbiBRaSByZXBvcnRzIHRoYXQgdGhlIExpbnV4IE5GU3Y0IGNsaWVudCBmYWlsZWQgdG8gbG9j
ayBhIGZpbGUNCj4gdGhhdCB3YXMgbWlncmF0ZWQuIFRoZSBzdGVwcyBoZSBvYnNlcnZlZCBvbiB0
aGUgd2lyZToNCj4gDQo+IDEuIFRoZSBjbGllbnQgc2VudCBhIExPQ0sgcmVxdWVzdCB0byB0aGUg
c291cmNlIHNlcnZlcg0KPiAyLiBUaGUgc291cmNlIHNlcnZlciByZXBsaWVkIE5GUzRFUlJfTU9W
RUQNCj4gMy4gVGhlIGNsaWVudCBzd2l0Y2hlZCB0byB0aGUgZGVzdGluYXRpb24gc2VydmVyDQo+
IDQuIFRoZSBjbGllbnQgc2VudCB0aGUgTE9DSyByZXF1ZXN0IHRvIHRoZSBkZXN0aW5hdGlvbg0K
PiDCoMKgwqBzZXJ2ZXIgd2l0aCBhIGJ1bXBlZCBsb2NrIHNlcXVlbmNlIElEDQo+IDUuIFRoZSBk
ZXN0aW5hdGlvbiBzZXJ2ZXIgcmVqZWN0ZWQgdGhlIExPQ0sgcmVxdWVzdCB3aXRoDQo+IMKgwqDC
oE5GUzRFUlJfQkFEX1NFUUlEDQo+IA0KPiBSRkMgMzUzMCBzZWN0aW9uIDguMS41IHByb3ZpZGVz
IGEgbGlzdCBvZiBORlMgZXJyb3JzIHdoaWNoIGRvIG5vdA0KPiBidW1wIGEgbG9jayBzZXF1ZW5j
ZSBJRC4NCj4gDQo+IEhvd2V2ZXIsIFJGQyAzNTMwIGlzIG5vdyBvYnNvbGV0ZWQgYnkgUkZDIDc1
MzAuIEluIFJGQyA3NTMwIHNlY3Rpb24NCj4gOS4xLjcsIHRoaXMgbGlzdCBoYXMgYmVlbiB1cGRh
dGVkIGJ5IHRoZSBhZGRpdGlvbiBvZiBORlM0RVJSX01PVkVELg0KPiANCj4gUmVwb3J0ZWQtYnk6
IFh1YW4gUWkgPHh1YW4ucWlAb3JhY2xlLmNvbT4NCj4gU2lnbmVkLW9mZi1ieTogQ2h1Y2sgTGV2
ZXIgPGNodWNrLmxldmVyQG9yYWNsZS5jb20+DQo+IFRlc3RlZC1ieTogWHVhbiBRaSA8eHVhbi5x
aUBvcmFjbGUuY29tPg0KPiBDYzogc3RhYmxlQHZnZXIua2VybmVsLm9yZyAjIHYzLjcrDQo+IC0t
LQ0KPiBUZXN0aW5nIGNvbmZpcm1zIHRoaXMgcGF0Y2ggYWRkcmVzc2VzIHRoZSBwcm9ibGVtIHRo
YXQgWHVhbiBmaXJzdA0KPiBvYnNlcnZlZC4NCj4gDQoNClNpbmNlIHRoZSBmaXJzdCBwYXRjaCB3
YXMgYWxyZWFkeSBhcHBsaWVkIHRvIGxpbnV4LW5leHQsIGNvdWxkIHlvdQ0KcGxlYXNlIG1ha2Ug
dGhpcyBvbmUgaW5jcmVtZW50YWw/DQoNClRoYW5rcw0KDQotLSANClRyb25kIE15a2xlYnVzdA0K
TGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBQcmltYXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0
QHByaW1hcnlkYXRhLmNvbQ0K

