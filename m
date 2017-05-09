Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:35750 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753712AbdEIMi5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 08:38:57 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: hch <hch@lst.de>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 13/32] nfs: don't cast callback decode/proc/encode
 routines
Date: Tue, 9 May 2017 12:38:52 +0000
Message-ID: <1494333530.4209.16.camel@primarydata.com>
References: <20170509092010.30752-1-hch@lst.de>
         <20170509092010.30752-14-hch@lst.de>
In-Reply-To: <20170509092010.30752-14-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE3LTA1LTA5IGF0IDExOjE5ICswMjAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gSW5zdGVhZCBkZWNsYXJlIGFsbCBmdW5jdGlvbnMgd2l0aCB0aGUgcHJvcGVyIG1ldGhv
ZHMgc2lnbmF0dXJlLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogQ2hyaXN0b3BoIEhlbGx3aWcgPGhj
aEBsc3QuZGU+DQo+IC0tLQ0KPiDCoGZzL25mcy9jYWxsYmFjay5owqDCoMKgwqDCoMKgfCAyNyAr
KysrKystLS0tLS0tLS0tDQo+IMKgZnMvbmZzL2NhbGxiYWNrX3Byb2MuYyB8IDMzICsrKysrKysr
KysrKy0tLS0tLS0NCj4gwqBmcy9uZnMvY2FsbGJhY2tfeGRyLmPCoMKgfCA4NiArKysrKysrKysr
KysrKysrKysrKysrKysrKystLS0tLS0tLS0tLS0tDQo+IC0tLS0tLS0tLS0NCj4gwqAzIGZpbGVz
IGNoYW5nZWQsIDc3IGluc2VydGlvbnMoKyksIDY5IGRlbGV0aW9ucygtKQ0KPiANCg0KQWNrZWQt
Ynk6IFRyb25kIE15a2xlYnVzdCA8dHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbT4NCi0t
IA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIFByaW1hcnlE
YXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

