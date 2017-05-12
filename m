Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:23856 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757389AbdELUOL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 16:14:11 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: hch <hch@lst.de>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: remove function pointer casts and constify function tables
Date: Fri, 12 May 2017 20:14:03 +0000
Message-ID: <1494620040.19467.1.camel@primarydata.com>
References: <20170512161701.22468-1-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE3LTA1LTEyIGF0IDE4OjE2ICswMjAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gVGhpcyBzZXJpZXMgd2FzIGluc3BpcmVkIGJ5IHR3byByZWNlbnQgZXZlbnRzOsKgwqB0
YWxraW5nIHRvIGEgYWNhZGVtaWMNCj4gcmVzZWFyY2hlciBhYm91dCB0aGUgaGFybSBvZiBmdW5j
dGlvbiBwb2ludGVyIGNhc3RzIGZvciBzdGF0aWMNCj4gYW5hbHlzaXMNCj4gYXQgYSBjb25mZXJl
bmNlLCBhbmQgcmVhZGluZyB1cCB0aGUgd2hvbGUgR3JzZWN1cml0eSBkcmFtYSwgaW5jbHVkaW5n
DQo+IGZpbmRpbmcgdGhhdCB0aGVpciBwYXRjaHNldCBkb2VzIGEgbG90IG9mIHdvcmsgdG8gcmVt
b3ZlIHRoZXNlIGNhc3RzDQo+IGluIHN1bnJwYyBhbmQgbmZzIChhbmQgaW4gZmFjdCB0aG9zZSBz
ZWVtIHRoZSBiaWdnZXN0IGN1bHByaXQgaW4gdGhlDQo+IGtlcm5lbCksIGFuZCBjb25zdGlmeWlu
ZyB0aGUgb3BlcmF0aW9uIHZlY3RvcnMgbGlrZSBzbyBtYW55IG90aGVycyBpbg0KPiB0aGUga2Vy
bmVsLCBhbHRob3VnaCBkb25lIGluIGEgcmF0aGVyIGhhY2t5IGFuZC9vciBtZWNobmljYWwgd2F5
Lg0KPiANCj4gTm90ZSB0aGF0IHRoZSBmaXJzdCBwYXJ0IG9mIHRoZSBzZXJpZXMgaXMgYWJvdXQg
dGhlIFJQQyBmb3JlY2hhbm5lbCwNCj4gYW5kIHRoZSBsYXR0ZXIgYWJvdXQgdGhlIGJhY2tjaGFu
bmVsLCBidXQgZHVlIHRvIGJpZGlyZWN0aW9uDQo+IG9wZXJhdGlvbg0KPiBpbiBORlN2NCB0aGVy
ZSBpcyBubyByZWFsbHkgY2xlYW4gc3BsaXQgYmV0d2VlbiB0aGUgY2xpZW50IGFuZCBzZXJ2ZXIN
Cj4gcGFydHMuDQo+IA0KPiBDaGFuZ2VzIGZyb20gUkZDOg0KPiDCoC0gbW92ZSBwcm9jZWR1cmUg
Y2FsbCBjb3VudGVycyBpbnRvIHNlcGFyYXRlIGFycmF5cw0KPiANCg0KSG93IHNob3VsZCB3ZSBw
cm9jZWVkIHRvIG1lcmdlIHRoaXMgc2VyaWVzPyBHaXZlbiB0aGF0IGl0IGlzIGNoYW5naW5nIGEN
CmxvdCBvZiBmdW5jdGlvbiBoZWFkZXJzLCBidXQgbm90IGFjdHVhbGx5IGNoYW5naW5nIGZ1bmN0
aW9uYWxpdHksIG1pZ2h0DQppdCBiZSBwb3NzaWJsZSB0byBtZXJnZSBpdCBvdXQtb2YtYmFuZCB3
aXRoIHRoZSBtZXJnZSB3aW5kb3cgKGUuZy4gbmV4dA0Kd2VlaykgaW4gb3JkZXIgdG8gbWluaW1p
c2UgdGhlIGFtb3VudCBvZiB3b3JrIG5lZWRlZCB0byBmaXggdXAgZnV0dXJlDQpwYXRjaGVzPw0K
DQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBQcmlt
YXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbQ0K

