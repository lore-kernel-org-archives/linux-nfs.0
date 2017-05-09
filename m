Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:51464 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751210AbdEIMmP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 08:42:15 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: hch <hch@lst.de>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 15/32] sunrpc: mark all struct rpc_procinfo instances as
 const
Date: Tue, 9 May 2017 12:42:10 +0000
Message-ID: <1494333727.4209.19.camel@primarydata.com>
References: <20170509092010.30752-1-hch@lst.de>
         <20170509092010.30752-16-hch@lst.de>
In-Reply-To: <20170509092010.30752-16-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE3LTA1LTA5IGF0IDExOjE5ICswMjAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gc3RydWN0IHJwY19wcm9jaW5mbyBjb250YWlucyBmdW5jdGlvbiBwb2ludGVycywgYW5k
IG1hcmtpbmcgaXQgYXMNCj4gY29uc3RhbnQgYXZvaWRzIGl0IGJlaW5nIGFibGUgdG8gYmUgdXNl
ZCBhcyBhbiBhdHRhY2ggdmVjdG9yIGZvcg0KPiBjb2RlIGluamVjdGlvbnMuDQo+IA0KPiBTaWdu
ZWQtb2ZmLWJ5OiBDaHJpc3RvcGggSGVsbHdpZyA8aGNoQGxzdC5kZT4NCj4gLS0tDQo+IMKgZnMv
bG9ja2QvY2xudDR4ZHIuY8KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHzCoMKg
MiArLQ0KPiDCoGZzL2xvY2tkL2NsbnR4ZHIuY8KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgfMKgwqAyICstDQo+IMKgZnMvbG9ja2QvbW9uLmPCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgfMKgwqAyICstDQo+IMKgZnMvbmZzL2ludGVybmFs
LmjCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgfMKgwqA2ICsrKy0tLQ0K
PiDCoGZzL25mcy9tb3VudF9jbG50LmPCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqB8wqDCoDQgKystLQ0KPiDCoGZzL25mcy9uZnMyeGRyLmPCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqB8wqDCoDIgKy0NCj4gwqBmcy9uZnMvbmZzM3hkci5jwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgfMKgwqA0ICsrLS0NCj4gwqBmcy9u
ZnMvbmZzNF9mcy5owqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgfMKg
wqAyICstDQo+IMKgZnMvbmZzL25mczR4ZHIuY8KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoHzCoMKgMiArLQ0KPiDCoGZzL25mc2QvbmZzNGNhbGxiYWNrLmPCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqB8wqDCoDIgKy0NCj4gwqBpbmNsdWRlL2xpbnV4L3N1bnJw
Yy9jbG50LmjCoMKgwqDCoMKgwqDCoMKgwqDCoHzCoMKgNCArKy0tDQo+IMKgaW5jbHVkZS9saW51
eC9zdW5ycGMvc2NoZWQuaMKgwqDCoMKgwqDCoMKgwqDCoHzCoMKgMiArLQ0KPiDCoG5ldC9zdW5y
cGMvYXV0aF9nc3MvZ3NzX3JwY191cGNhbGwuYyB8wqDCoDIgKy0NCj4gwqBuZXQvc3VucnBjL2Ns
bnQuY8KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqB8wqDCoDQgKystLQ0K
PiDCoG5ldC9zdW5ycGMvcnBjYl9jbG50LmPCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqB8
IDE5ICsrKysrKysrKystLS0tLS0tLS0NCj4gwqBuZXQvc3VucnBjL3N0YXRzLmPCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHzCoMKgMiArLQ0KPiDCoDE2IGZpbGVzIGNoYW5n
ZWQsIDMxIGluc2VydGlvbnMoKyksIDMwIGRlbGV0aW9ucygtKQ0KPiANCj4gDQpBY2tlZC1ieTog
VHJvbmQgTXlrbGVidXN0IDx0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tPg0KLS0gDQpU
cm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgUHJpbWFyeURhdGEN
CnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

