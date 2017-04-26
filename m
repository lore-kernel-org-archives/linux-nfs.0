Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:28090 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932351AbdDZQmz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Apr 2017 12:42:55 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "kolga@netapp.com" <kolga@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFS4.1 handle interrupted slot reuse from ERR_DELAY
Date: Wed, 26 Apr 2017 16:42:48 +0000
Message-ID: <1493224965.92280.1.camel@primarydata.com>
References: <20170422163139.97844-1-kolga@netapp.com>
In-Reply-To: <20170422163139.97844-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gU2F0LCAyMDE3LTA0LTIyIGF0IDEyOjMxIC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gSWYgdGhlIFJQQyBzbG90IHdhcyBpbnRlcnJ1cHRlZCBhbmQgc2VydmVyIHJlcGxpZWQg
dG8gdGhlIG5leHQNCj4gb3BlcmF0aW9uIG9uIHRoZSAicmV1c2VkIiBzbG90IHdpdGggRVJSX0RF
TEFZLCBkb24ndCBjbGVhciBvdXQNCj4gdGhlICJpbnRlcnJ1cHRlZCIgZmxhZyB1bnRpbCB3ZSBw
cm9wZXJseSByZWNvdmVyLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogT2xnYSBLb3JuaWV2c2thaWEg
PGtvbGdhQG5ldGFwcC5jb20+DQo+IC0tLQ0KPiDCoGZzL25mcy9uZnM0cHJvYy5jIHwgMyArKy0N
Cj4gwqAxIGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pDQo+IA0K
PiBkaWZmIC0tZ2l0IGEvZnMvbmZzL25mczRwcm9jLmMgYi9mcy9uZnMvbmZzNHByb2MuYw0KPiBp
bmRleCAwZDMzNDdlLi5hMTU5NzljIDEwMDY0NA0KPiAtLS0gYS9mcy9uZnMvbmZzNHByb2MuYw0K
PiArKysgYi9mcy9uZnMvbmZzNHByb2MuYw0KPiBAQCAtNjk3LDcgKzY5Nyw4IEBAIHN0YXRpYyBp
bnQgbmZzNDFfc2VxdWVuY2VfcHJvY2VzcyhzdHJ1Y3QgcnBjX3Rhc2sNCj4gKnRhc2ssDQo+IMKg
CXNlc3Npb24gPSBzbG90LT50YWJsZS0+c2Vzc2lvbjsNCj4gwqANCj4gwqAJaWYgKHNsb3QtPmlu
dGVycnVwdGVkKSB7DQo+IC0JCXNsb3QtPmludGVycnVwdGVkID0gMDsNCj4gKwkJaWYgKHRhc2st
PnRrX3N0YXR1cyAhPSAtTkZTNEVSUl9ERUxBWSkNCj4gKwkJCXNsb3QtPmludGVycnVwdGVkID0g
MDsNCg0KVGhpcyBpcyBvbmx5IGNvcnJlY3QgaWYgdGhlIE5GUzRFUlJfREVMQVkgaXMgb24gdGhl
IHNlcXVlbmNlIG9wIGl0c2VsZi4NCkNhbiB3ZSB0aGVyZWZvcmUgcGxlYXNlIGNvcnJlY3QgdGhp
cyB0byBjaGVjayByZXMtPnNyX3N0YXR1cyBpbnN0ZWFkPw0KDQo+IMKgCQlpbnRlcnJ1cHRlZCA9
IHRydWU7DQo+IMKgCX0NCj4gwqANCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xp
ZW50IG1haW50YWluZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEu
Y29tDQo=

