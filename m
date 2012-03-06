Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28699 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757893Ab2CFO5U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 09:57:20 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFSv4.1: Fix the checking of the stateid when
 returning a delegation
Date: Tue, 6 Mar 2012 14:57:19 +0000
Message-ID: <1331045839.3260.8.camel@lade.trondhjem.org>
References: <1331045205-3031-1-git-send-email-andros@netapp.com>
	 <1331045205-3031-2-git-send-email-andros@netapp.com>
In-Reply-To: <1331045205-3031-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTAzLTA2IGF0IDA5OjQ2IC0wNTAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbT4N
Cj4gDQo+IG5mczQxX3ZhbGlkYXRlX2RlbGVnYXRpb25fc3RhdGVpZCBpcyBicm9rZW4gaWYgd2Ug
c3VwcGx5IGEgc3RhdGVpZCB3aXRoDQo+IGEgbm9uLXplcm8gc2VxdWVuY2UgaWQuIEluc3RlYWQg
b2YgdHJ5aW5nIHRvIG1hdGNoIHRoZSBzZXF1ZW5jZSBpZCwNCj4gdGhlIGZ1bmN0aW9uIGFzc3Vt
ZXMgdGhhdCB3ZSBhbHdheXMgd2FudCB0byBlcnJvci4gV2hpbGUgdGhpcyBpcw0KPiB0cnVlIGZv
ciBhIGRlbGVnYXRpb24gY2FsbGJhY2ssIGl0IGlzIG5vdCB0cnVlIGluIGdlbmVyYWwuDQo+IA0K
PiBBbHNvIGZpeCBhIHR5cG8gaW4gbmZzNF9jYWxsYmFja19yZWNhbGwuDQo+IA0KPiBSZXBvcnRl
ZC1ieTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gU2lnbmVkLW9mZi1ieTog
VHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbT4NCg0KRGlkIHlvdSBy
ZWFsbHkgaW50ZW5kIHRvIENjOiBzdGFibGUgb24gdGhlc2UgYmVmb3JlIHdlJ3ZlIGNvbW1pdHRl
ZCB0aGVtDQp1cHN0cmVhbT8NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGll
bnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cu
bmV0YXBwLmNvbQ0KDQo=
