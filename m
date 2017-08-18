Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:22880 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751045AbdHRPyA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Aug 2017 11:54:00 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "colin.king@canonical.com" <colin.king@canonical.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>, hch <hch@lst.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "elfring@users.sourceforge.net" <elfring@users.sourceforge.net>,
        "bcodding redhat" <bcodding@redhat.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
Subject: Re: [PATCH 2/2] lockd: Adjust 61 checks for null pointers
Date: Fri, 18 Aug 2017 15:53:53 +0000
Message-ID: <1503071631.44656.4.camel@primarydata.com>
References: <e53b2d3a-239a-268c-5674-3c50b02c966f@users.sourceforge.net>
         <e76e873f-f18e-5bdd-cc93-255321b3d98f@users.sourceforge.net>
In-Reply-To: <e76e873f-f18e-5bdd-cc93-255321b3d98f@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE3LTA4LTE3IGF0IDE2OjM0ICswMjAwLCBTRiBNYXJrdXMgRWxmcmluZyB3cm90
ZToNCj4gRnJvbTogTWFya3VzIEVsZnJpbmcgPGVsZnJpbmdAdXNlcnMuc291cmNlZm9yZ2UubmV0
Pg0KPiBEYXRlOiBUaHUsIDE3IEF1ZyAyMDE3IDE2OjAwOjE4ICswMjAwDQo+IE1JTUUtVmVyc2lv
bjogMS4wDQo+IENvbnRlbnQtVHlwZTogdGV4dC9wbGFpbjsgY2hhcnNldD1VVEYtOA0KPiBDb250
ZW50LVRyYW5zZmVyLUVuY29kaW5nOiA4Yml0DQo+IA0KPiBUaGUgc2NyaXB0IOKAnGNoZWNrcGF0
Y2gucGzigJ0gcG9pbnRlZCBpbmZvcm1hdGlvbiBvdXQgbGlrZSB0aGUNCj4gZm9sbG93aW5nLg0K
PiANCj4gQ29tcGFyaXNvbiB0byBOVUxMIGNvdWxkIGJlIHdyaXR0ZW4g4oCmDQo+IA0KPiBUaHVz
IGZpeCB0aGUgYWZmZWN0ZWQgc291cmNlIGNvZGUgcGxhY2VzLg0KPiANCj4gU2lnbmVkLW9mZi1i
eTogTWFya3VzIEVsZnJpbmcgPGVsZnJpbmdAdXNlcnMuc291cmNlZm9yZ2UubmV0Pg0KPiAtLS0N
Cj4gIGZzL2xvY2tkL2NsbnQ0eGRyLmMgfCAxMiArKysrKystLS0tLS0NCj4gIGZzL2xvY2tkL2Ns
bnRsb2NrLmMgfCAxMCArKysrKy0tLS0tDQo+ICBmcy9sb2NrZC9jbG50cHJvYy5jIHwgMTIgKysr
KysrLS0tLS0tDQo+ICBmcy9sb2NrZC9jbG50eGRyLmMgIHwgMTIgKysrKysrLS0tLS0tDQo+ICBm
cy9sb2NrZC9ob3N0LmMgICAgIHwgMjIgKysrKysrKysrKystLS0tLS0tLS0tLQ0KPiAgZnMvbG9j
a2QvbW9uLmMgICAgICB8IDE2ICsrKysrKysrLS0tLS0tLS0NCj4gIGZzL2xvY2tkL3N2Yy5jICAg
ICAgfCAgNCArKy0tDQo+ICBmcy9sb2NrZC9zdmM0cHJvYy5jIHwgIDYgKysrLS0tDQo+ICBmcy9s
b2NrZC9zdmNsb2NrLmMgIHwgMTQgKysrKysrKy0tLS0tLS0NCj4gIGZzL2xvY2tkL3N2Y3Byb2Mu
YyAgfCAgNiArKystLS0NCj4gIGZzL2xvY2tkL3N2Y3NoYXJlLmMgfCAgMiArLQ0KPiAgZnMvbG9j
a2Qvc3Zjc3Vicy5jICB8ICAzICstLQ0KPiAgMTIgZmlsZXMgY2hhbmdlZCwgNTkgaW5zZXJ0aW9u
cygrKSwgNjAgZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZnMvbG9ja2QvY2xudDR4
ZHIuYyBiL2ZzL2xvY2tkL2NsbnQ0eGRyLmMNCj4gaW5kZXggYzM0OWZjMGY5YjgwLi5lYzY0NzNk
MTk0ZmQgMTAwNjQ0DQo+IC0tLSBhL2ZzL2xvY2tkL2NsbnQ0eGRyLmMNCj4gKysrIGIvZnMvbG9j
a2QvY2xudDR4ZHIuYw0KPiBAQCAtMTMxLDcgKzEzMSw3IEBAIHN0YXRpYyBpbnQgZGVjb2RlX25l
dG9iaihzdHJ1Y3QgeGRyX3N0cmVhbSAqeGRyLA0KPiAgCV9fYmUzMiAqcDsNCj4gIA0KPiAgCXAg
PSB4ZHJfaW5saW5lX2RlY29kZSh4ZHIsIDQpOw0KPiAtCWlmICh1bmxpa2VseShwID09IE5VTEwp
KQ0KPiArCWlmICh1bmxpa2VseSghcCkpDQoNCk9oIFNUT1Agd2l0aCB0aGUgY2hlY2twYXRjaCB3
YW5rZmVzdCENCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRh
aW5lciwgUHJpbWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

