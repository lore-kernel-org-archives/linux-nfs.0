Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:55602 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752482AbdLCPRj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Dec 2017 10:17:39 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>,
        "elfring@users.sourceforge.net" <elfring@users.sourceforge.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "rostedt@goodmis.org" <rostedt@goodmis.org>
Subject: Re: Difficulties for compilation without extra optimisation
Date: Sun, 3 Dec 2017 15:17:32 +0000
Message-ID: <1512314250.3673.6.camel@primarydata.com>
References: <7f072f78-eef4-6d87-d233-cee71dac5a32@users.sourceforge.net>
         <a2ac6d05-fdd6-82bb-075e-b7eb81b516fe@users.sourceforge.net>
In-Reply-To: <a2ac6d05-fdd6-82bb-075e-b7eb81b516fe@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gU3VuLCAyMDE3LTEyLTAzIGF0IDE1OjE1ICswMTAwLCBTRiBNYXJrdXMgRWxmcmluZyB3cm90
ZToNCj4gSGVsbG8sDQo+IA0KPiBJIGNhbWUgYWxvbmcgc29tZSBzb2Z0d2FyZSBtb2R1bGVzIHdo
ZXJlIEkgc3VnZ2VzdGVkIHNvdXJjZSBjb2RlDQo+IGFkanVzdG1lbnRzLg0KPiANCj4gRXhhbXBs
ZToNCj4gbmZzL3dyaXRlOiBVc2UgY29tbW9uIGVycm9yIGhhbmRsaW5nIGNvZGUgaW4NCj4gbmZz
X2xvY2tfYW5kX2pvaW5fcmVxdWVzdHMoKQ0KPiANCj4gaHR0cHM6Ly9sa21sLm9yZy9sa21sLzIw
MTcvMTEvNy81OTkNCj4gaHR0cHM6Ly9wYXRjaHdvcmsua2VybmVsLm9yZy9wYXRjaC8xMDA0NzAx
My8NCj4gaHR0cHM6Ly9sa21sLmtlcm5lbC5vcmcvci88N2YwNzJmNzgtZWVmNC02ZDg3LWQyMzMt
Y2VlNzFkYWM1YTMyQHVzZXJzDQo+IC5zb3VyY2Vmb3JnZS5uZXQ+Ow0KPiANCj4gSSB3b3VsZCBs
aWtlIHRvIGNoZWNrIGNvcnJlc3BvbmRpbmcgYnVpbGQgcmVzdWx0cyB0aGVuIHdpdGhvdXQgZXh0
cmENCj4gb3B0aW1pc2F0aW9uIGFwcGxpZWQgYnkgdGhlIGNvbXBpbGVyLg0KPiBCdXQgSSBnb3Qg
c3VycHJpc2VkIGJ5IGVycm9yIG1lc3NhZ2VzIGZvciBhIGNvbW1hbmQgbGlrZSB0aGUNCj4gZm9s
bG93aW5nLg0KPiANCj4gZWxmcmluZ0BTb25uZTp+L1Byb2pla3RlL0xpbnV4L25leHQtcGF0Y2hl
ZD4gbXlfY2M9L3Vzci9iaW4vZ2NjLTcgJiYNCj4gTEFORz1DIG1ha2UgLWo0IENDPSIke215X2Nj
fSIgSE9TVENDPSIke215X2NjfSIgRVhUUkFfQ0ZMQUdTPSctTzAnDQo+IGFsbG1vZGNvbmZpZyBm
cy9uZnMvd3JpdGUubw0KPiDigKYNCj4gSW4gZmlsZSBpbmNsdWRlZCBmcm9tIC4vaW5jbHVkZS9s
aW51eC9jb21waWxlci5oOjU4OjAsDQo+ICAgICAgICAgICAgICAgICAgZnJvbSAuL2luY2x1ZGUv
dWFwaS9saW51eC9zdGRkZWYuaDoxLA0KPiAgICAgICAgICAgICAgICAgIGZyb20gLi9pbmNsdWRl
L2xpbnV4L3N0ZGRlZi5oOjQsDQo+ICAgICAgICAgICAgICAgICAgZnJvbSAuL2luY2x1ZGUvdWFw
aS9saW51eC9wb3NpeF90eXBlcy5oOjQsDQo+ICAgICAgICAgICAgICAgICAgZnJvbSAuL2luY2x1
ZGUvdWFwaS9saW51eC90eXBlcy5oOjEzLA0KPiAgICAgICAgICAgICAgICAgIGZyb20gLi9pbmNs
dWRlL2xpbnV4L3R5cGVzLmg6NSwNCj4gICAgICAgICAgICAgICAgICBmcm9tIGZzL25mcy93cml0
ZS5jOjk6DQo+IC4vYXJjaC94ODYvaW5jbHVkZS9hc20vanVtcF9sYWJlbC5oOiBJbiBmdW5jdGlv
bg0KPiDigJh0cmFjZV9uZnNfd3JpdGViYWNrX3BhZ2VfZW50ZXLigJk6DQo+IC4vaW5jbHVkZS9s
aW51eC9jb21waWxlci1nY2MuaDoyNzU6Mzg6IHdhcm5pbmc6IGFzbSBvcGVyYW5kIDANCj4gcHJv
YmFibHkgZG9lc27igJl0IG1hdGNoIGNvbnN0cmFpbnRzDQo+ICAjZGVmaW5lIGFzbV92b2xhdGls
ZV9nb3RvKHguLi4pIGRvIHsgYXNtIGdvdG8oeCk7IGFzbSAoIiIpOyB9IHdoaWxlDQo+ICgwKQ0K
PiDigKYNCj4gDQo+IA0KPiBIb3cgZG8geW91IHRoaW5rIGFib3V0IHRvIGltcHJvdmUgdGhpcyBz
b2Z0d2FyZSBzaXR1YXRpb24gYW55aG93Pw0KDQpJJ20gbm90IHNlZWluZyBhbnl0aGluZyBvYnZp
b3VzbHkgd3Jvbmcgd2l0aCB0aGUgTkZTIHVzZSBvZiB0cmFjZXBvaW50cw0KdGhlcmUsIGFuZCB0
aGUgd2FybmluZyBzdWdnZXN0cyByYXRoZXIgdGhhdCBnY2MgaGFzIGFuIGlzc3VlIHdpdGggdGhl
DQppbmxpbmVkIGFzc2VtYmx5IGNvZGUgaW4ganVtcF9sYWJlbC5oLg0KDQpDY2luZyBQZXRlciBa
aWpsc3RyYSAod2hvIGFwcGVhcnMgdG8gaGF2ZSBiZWVuIHRoZSBsYXN0IHBlcnNvbiB0byB0b3Vj
aA0KdGhhdCBhc3NlbWJseSBjb2RlKSBhbmQgU3RldmVuIFJvc3RlZHQuDQoNCi0tIA0KVHJvbmQg
TXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIFByaW1hcnlEYXRhDQp0cm9u
ZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

