Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-co1nam03on0113.outbound.protection.outlook.com ([104.47.40.113]:51276
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S964827AbeEJPZS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 May 2018 11:25:18 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        "vallish@amazon.com" <vallish@amazon.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
CC: "jsstraus@amazon.com" <jsstraus@amazon.com>
Subject: Re: [PATCH 2/2] SUNRPC: Reconnect with new port on server initiated
 connection termination
Date: Thu, 10 May 2018 15:25:14 +0000
Message-ID: <aa092f62079986ec164863f33873b278f69f79a9.camel@hammerspace.com>
References: <1525932774-98736-1-git-send-email-vallish@amazon.com>
         <1525932774-98736-3-git-send-email-vallish@amazon.com>
In-Reply-To: <1525932774-98736-3-git-send-email-vallish@amazon.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE4LTA1LTEwIGF0IDA2OjEyICswMDAwLCBWYWxsaXNoIFZhaWR5ZXNod2FyYSB3
cm90ZToNCj4gU2VydmVyIGluaXRpYXRlZCBzb2NrZXQgY2xvc2UgY2FuIGNvcnJ1cHQgY29ubmVj
dGlvbiBzdGF0ZSB0cmFja2luZw0KPiB0YWJsZSBpbiBjb25qdW5jdGlvbiB3aXRoIG90aGVyIG5l
dHdvcmsgbWlkZGxlIGJveGVzLiBJbiBzaXR1YXRpb25zDQo+IGxpa2UgdGhlc2UsIGNsaWVudCBj
b25uZWN0aW9uIGhhbmdzIHRpbGwgY29ubmVjdGlvbiBzdGF0ZSB0cmFja2luZw0KPiB0YWJsZSBl
bnRyaWVzIGFnZSBvdXQgYW5kIGdldCBwdXJnZWQuIENsaWVudCByZWNvbm5lY3Rpb24gd2l0aCBh
IG5ldw0KPiBwb3J0IGluIHN1Y2ggYSBzaXR1YXRpb24gd2lsbCBhdm9pZCBjb25uZWN0aW9uIGhh
bmcuDQo+IA0KPiBSZXZpZXdlZC1ieTogSmFjb2IgU3RyYXVzcyA8anNzdHJhdXNAYW1hem9uLmNv
bT4NCj4gUmV2aWV3ZWQtYnk6IEFsYWtlc2ggSGFsb2kgPGFsYWtlc2hoQGFtYXpvbi5jb20+DQo+
IFNpZ25lZC1vZmYtYnk6IFZhbGxpc2ggVmFpZHllc2h3YXJhIDx2YWxsaXNoQGFtYXpvbi5jb20+
DQo+IC0tLQ0KPiAgbmV0L3N1bnJwYy94cHJ0c29jay5jIHwgNSArKysrKw0KPiAgMSBmaWxlIGNo
YW5nZWQsIDUgaW5zZXJ0aW9ucygrKQ0KPiANCj4gZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMveHBy
dHNvY2suYyBiL25ldC9zdW5ycGMveHBydHNvY2suYw0KPiBpbmRleCA1YmY3NWIzLi5kMjkzYzhk
IDEwMDY0NA0KPiAtLS0gYS9uZXQvc3VucnBjL3hwcnRzb2NrLmMNCj4gKysrIGIvbmV0L3N1bnJw
Yy94cHJ0c29jay5jDQo+IEBAIC0xNjI5LDYgKzE2MjksOCBAQCBzdGF0aWMgdm9pZCB4c190Y3Bf
c3RhdGVfY2hhbmdlKHN0cnVjdCBzb2NrDQo+ICpzaykNCj4gIAkJLyogVGhlIHNlcnZlciBpbml0
aWF0ZWQgYSBzaHV0ZG93biBvZiB0aGUgc29ja2V0ICovDQo+ICAJCXhwcnQtPmNvbm5lY3RfY29v
a2llKys7DQo+ICAJCWNsZWFyX2JpdChYUFJUX0NPTk5FQ1RFRCwgJnhwcnQtPnN0YXRlKTsNCj4g
KwkJLyogU2VydmVyIHNlbnQgRklOLCByZWNvbm5lY3Qgd2l0aCBhIG5ldyBwb3J0ICovDQo+ICsJ
CXRyYW5zcG9ydC0+c3JjcG9ydCA9IDA7DQo+ICAJCXhzX3RjcF9mb3JjZV9jbG9zZSh4cHJ0KTsN
Cj4gIAkJLyogZmFsbCB0aHJvdWdoICovDQo+ICAJY2FzZSBUQ1BfQ0xPU0lORzoNCj4gQEAgLTE2
NTAsNiArMTY1Miw5IEBAIHN0YXRpYyB2b2lkIHhzX3RjcF9zdGF0ZV9jaGFuZ2Uoc3RydWN0IHNv
Y2sNCj4gKnNrKQ0KPiAgCQkJCQkmdHJhbnNwb3J0LT5zb2NrX3N0YXRlKSkNCj4gIAkJCXhwcnRf
Y2xlYXJfY29ubmVjdGluZyh4cHJ0KTsNCj4gIAkJY2xlYXJfYml0KFhQUlRfQ0xPU0lORywgJnhw
cnQtPnN0YXRlKTsNCj4gKwkJLyogU2VydmVyIHNlbnQgUlNULCByZWNvbm5lY3Qgd2l0aCBhIG5l
dyBwb3J0ICovDQo+ICsJCWlmIChzay0+c2tfZXJyID09IEVDT05OUkVTRVQpDQo+ICsJCQl0cmFu
c3BvcnQtPnNyY3BvcnQgPSAwOw0KPiAgCQlpZiAoc2stPnNrX2VycikNCj4gIAkJCXhwcnRfd2Fr
ZV9wZW5kaW5nX3Rhc2tzKHhwcnQsIC1zay0+c2tfZXJyKTsNCj4gIAkJLyogVHJpZ2dlciB0aGUg
c29ja2V0IHJlbGVhc2UgKi8NCg0KTkFDSy4gVGhpcyB3aWxsIHV0dGVybHkgYnJlYWsgTkZTdjIs
IE5GU3YzIGFuZCBORlN2NC4wIGR1cGxpY2F0ZSByZXBsYXkNCmNhY2hlIHNlbWFudGljcy4gDQoN
CkNoZWVycw0KICBUcm9uZA0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQg
bWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20N
Cg==
