Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:26059 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753995AbcLOXBt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2016 18:01:49 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "seth.forshee@canonical.com" <seth.forshee@canonical.com>
CC: "ebiederm@xmission.com" <ebiederm@xmission.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: Use current_real_cred() when looking up rpc
 credentials
Date: Thu, 15 Dec 2016 23:01:41 +0000
Message-ID: <1481842899.11785.1.camel@primarydata.com>
References: <1481821992-77583-1-git-send-email-seth.forshee@canonical.com>
In-Reply-To: <1481821992-77583-1-git-send-email-seth.forshee@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE2LTEyLTE1IGF0IDExOjEzIC0wNjAwLCBTZXRoIEZvcnNoZWUgd3JvdGU6DQo+
IFNpbmNlIDQuOCBmb2xsb3dfYXV0b21vdW50KCkgb3ZlcnJpZGVzIHRoZSBjcmVkZW50aWFscyB3
aXRoDQo+ICZpbml0X2NyZWQgYmVmb3JlIGNhbGxpbmcgZF9hdXRvbW91bnQoKS4gV2hlbg0KPiBy
cGNhdXRoX2xvb2t1cGNyZWQoKSBpcyBjYWxsZWQgaW4gdGhpcyBjb250ZXh0IGl0IGlzIG5vdyB1
c2luZw0KPiBmc1t1Z11pZCBmcm9tIHRoZSBvdmVycmlkZSBjcmVkcyBpbnN0ZWFkIG9mIGZyb20g
dGhlIHVzZXIncw0KPiBjcmVkcywgd2hpY2ggY2FuIGNhdXNlIGF1dGhlbnRpY2F0aW9uIHRvIGZh
aWwuIFRvIGZpeCB0aGlzLCB0YWtlDQo+IHRoZSBpZHMgZnJvbSBjdXJyZW50X3JlYWxfY3JlZCgp
IGluc3RlYWQuDQo+IA0KPiBDYzogc3RhYmxlQHZnZXIua2VybmVsLm9yZyAjIHY0LjgrDQo+IEND
OiBFcmljIFcuIEJpZWRlcm1hbiA8ZWJpZWRlcm1AeG1pc3Npb24uY29tPg0KPiBGaXhlczogYWVh
YTRhNzlmZjZhICgiZnM6IENhbGwgZF9hdXRvbW91bnQgd2l0aCB0aGUgZmlsZXN5c3RlbXMNCj4g
Y3JlZHMiKQ0KPiBTaWduZWQtb2ZmLWJ5OiBTZXRoIEZvcnNoZWUgPHNldGguZm9yc2hlZUBjYW5v
bmljYWwuY29tPg0KPiAtLS0NCj4gwqBuZXQvc3VucnBjL2F1dGguYyB8IDIgKy0NCj4gwqAxIGZp
bGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSkNCj4gDQo+IGRpZmYgLS1n
aXQgYS9uZXQvc3VucnBjL2F1dGguYyBiL25ldC9zdW5ycGMvYXV0aC5jDQo+IGluZGV4IDJiZmY2
M2E3M2NmOC4uZTYxOTdiMmJkYTg2IDEwMDY0NA0KPiAtLS0gYS9uZXQvc3VucnBjL2F1dGguYw0K
PiArKysgYi9uZXQvc3VucnBjL2F1dGguYw0KPiBAQCAtNjIyLDcgKzYyMiw3IEBAIHJwY2F1dGhf
bG9va3VwY3JlZChzdHJ1Y3QgcnBjX2F1dGggKmF1dGgsIGludA0KPiBmbGFncykNCj4gwqB7DQo+
IMKgCXN0cnVjdCBhdXRoX2NyZWQgYWNyZWQ7DQo+IMKgCXN0cnVjdCBycGNfY3JlZCAqcmV0Ow0K
PiAtCWNvbnN0IHN0cnVjdCBjcmVkICpjcmVkID0gY3VycmVudF9jcmVkKCk7DQo+ICsJY29uc3Qg
c3RydWN0IGNyZWQgKmNyZWQgPSBjdXJyZW50X3JlYWxfY3JlZCgpOw0KPiDCoA0KPiDCoAlkcHJp
bnRrKCJSUEM6wqDCoMKgwqDCoMKgwqBsb29raW5nIHVwICVzIGNyZWRcbiIsDQo+IMKgCQlhdXRo
LT5hdV9vcHMtPmF1X25hbWUpOw0KDQpBbW9uZyBvdGhlciB0aGluZ3MsIHRoaXMgd2lsbCBicmVh
ayB0aGUgYWNjZXNzKCkgc3lzY2FsbC4gSXQncw0KY29tcGxldGVseSB0aGUgd3JvbmcgbGV2ZWwg
aW4gd2hpY2ggdG8gb3ZlcnJpZGUgY3JlZGVudGlhbHMuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0
DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1
c3RAcHJpbWFyeWRhdGEuY29tDQo=

