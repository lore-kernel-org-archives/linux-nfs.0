Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:31063 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751873AbdEIMcl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 08:32:41 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: hch <hch@lst.de>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 06/32] sunrpc/auth_gss: nfsd: fix encoder callback
 prototypes
Date: Tue, 9 May 2017 12:32:35 +0000
Message-ID: <1494333153.4209.10.camel@primarydata.com>
References: <20170509092010.30752-1-hch@lst.de>
         <20170509092010.30752-7-hch@lst.de>
In-Reply-To: <20170509092010.30752-7-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE3LTA1LTA5IGF0IDExOjE5ICswMjAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gRGVjbGFyZSB0aGUgcF9lbmNvZGUgY2FsbGJhY2tzIHdpdGggdGhlIHByb3BlciBwcm90
b3R5cGUgaW5zdGVhZCBvZg0KPiBjYXN0aW5nIHRvIGt4ZHJlcHJvY190IGFuZCBsb3NpbmcgYWxs
IHR5cGUgc2FmZXR5Lg0KPiANCj4gU2lnbmVkLW9mZi1ieTogQ2hyaXN0b3BoIEhlbGx3aWcgPGhj
aEBsc3QuZGU+DQo+IC0tLQ0KPiDCoG5ldC9zdW5ycGMvYXV0aF9nc3MvZ3NzX3JwY191cGNhbGwu
YyB8wqDCoDIgKy0NCj4gwqBuZXQvc3VucnBjL2F1dGhfZ3NzL2dzc19ycGNfeGRyLmPCoMKgwqDC
oHwgMTEgKysrKysrLS0tLS0NCj4gwqBuZXQvc3VucnBjL2F1dGhfZ3NzL2dzc19ycGNfeGRyLmjC
oMKgwqDCoHzCoMKgMiArLQ0KPiDCoDMgZmlsZXMgY2hhbmdlZCwgOCBpbnNlcnRpb25zKCspLCA3
IGRlbGV0aW9ucygtKQ0KPiANCj4gDQoNCkFja2VkLWJ5OiBUcm9uZCBNeWtsZWJ1c3QgPHRyb25k
Lm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20+DQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXgg
TkZTIGNsaWVudCBtYWludGFpbmVyLCBQcmltYXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0QHByaW1h
cnlkYXRhLmNvbQ0K

