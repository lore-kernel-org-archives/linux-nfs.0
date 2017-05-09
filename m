Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:33195 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751100AbdEIMLu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 08:11:50 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: hch <hch@lst.de>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 31/32] sunrpc: mark all struct svc_version instances as
 const
Date: Tue, 9 May 2017 12:11:44 +0000
Message-ID: <1494331902.4209.2.camel@primarydata.com>
References: <20170509092010.30752-1-hch@lst.de>
         <20170509092010.30752-32-hch@lst.de>
In-Reply-To: <20170509092010.30752-32-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE3LTA1LTA5IGF0IDExOjIwICswMjAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gU2lnbmVkLW9mZi1ieTogQ2hyaXN0b3BoIEhlbGx3aWcgPGhjaEBsc3QuZGU+DQo+IC0t
LQ0KPiDCoGZzL2xvY2tkL3N2Yy5jwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqB8IDMyICsrKysr
KysrKysrKysrKystLS0tLS0tLS0tLS0tLS0tDQo+IMKgZnMvbmZzL2NhbGxiYWNrLmPCoMKgwqDC
oMKgwqDCoMKgwqDCoHzCoMKgMiArLQ0KPiDCoGZzL25mcy9jYWxsYmFja194ZHIuY8KgwqDCoMKg
wqDCoHzCoMKgNCArKy0tDQo+IMKgZnMvbmZzL2ludGVybmFsLmjCoMKgwqDCoMKgwqDCoMKgwqDC
oHzCoMKgNCArKy0tDQo+IMKgZnMvbmZzL25mczRfZnMuaMKgwqDCoMKgwqDCoMKgwqDCoMKgwqB8
wqDCoDQgKystLQ0KPiDCoGZzL25mc2QvbmZzMmFjbC5jwqDCoMKgwqDCoMKgwqDCoMKgwqB8IDEy
ICsrKysrKy0tLS0tLQ0KPiDCoGZzL25mc2QvbmZzM2FjbC5jwqDCoMKgwqDCoMKgwqDCoMKgwqB8
IDEyICsrKysrKy0tLS0tLQ0KPiDCoGZzL25mc2QvbmZzM3Byb2MuY8KgwqDCoMKgwqDCoMKgwqDC
oHwgMTIgKysrKysrLS0tLS0tDQo+IMKgZnMvbmZzZC9uZnM0cHJvYy5jwqDCoMKgwqDCoMKgwqDC
oMKgfMKgwqAyICstDQo+IMKgZnMvbmZzZC9uZnNkLmjCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oHzCoMKgNiArKystLS0NCj4gwqBmcy9uZnNkL25mc3Byb2MuY8KgwqDCoMKgwqDCoMKgwqDCoMKg
fCAxMiArKysrKystLS0tLS0NCj4gwqBmcy9uZnNkL25mc3N2Yy5jwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoHzCoMKgOCArKysrLS0tLQ0KPiDCoGluY2x1ZGUvbGludXgvc3VucnBjL3N2Yy5oIHzCoMKg
MiArLQ0KPiDCoG5ldC9zdW5ycGMvc3ZjLmPCoMKgwqDCoMKgwqDCoMKgwqDCoMKgfMKgwqA0ICsr
LS0NCj4gwqAxNCBmaWxlcyBjaGFuZ2VkLCA1OCBpbnNlcnRpb25zKCspLCA1OCBkZWxldGlvbnMo
LSkNCj4gDQo+IA0KQWNrZWQtYnk6IFRyb25kIE15a2xlYnVzdCA8dHJvbmQubXlrbGVidXN0QHBy
aW1hcnlkYXRhLmNvbT4NCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1h
aW50YWluZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

