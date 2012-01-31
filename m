Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35400 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753526Ab2AaPDe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jan 2012 10:03:34 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Jeff Layton <jlayton@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] sunrpc: initialize delayed work on each rpc_inode
 allocation
Date: Tue, 31 Jan 2012 15:03:12 +0000
Message-ID: <1328022192.4090.48.camel@lade.trondhjem.org>
References: <1327426850-14837-1-git-send-email-jlayton@redhat.com>
	 <4F2700E2.9020803@RedHat.com> <1327957652.4090.32.camel@lade.trondhjem.org>
	 <20120130185753.50280816@tlielax.poochiereds.net>
	 <4F2800B4.6040302@panasas.com>
In-Reply-To: <4F2800B4.6040302@panasas.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTAxLTMxIGF0IDE2OjU0ICswMjAwLCBCb2F6IEhhcnJvc2ggd3JvdGU6DQo+
IE9uIDAxLzMxLzIwMTIgMDE6NTcgQU0sIEplZmYgTGF5dG9uIHdyb3RlOg0KPiA+ICAgICBXQVJO
SU5HOiBhdCBsaWIvZGVidWdvYmplY3RzLmM6MjYyIGRlYnVnX3ByaW50X29iamVjdCsweDhjLzB4
YjAoKQ0KPiA+IA0KPiA+IEZvciBub3csIHRoaXMgcGF0Y2ggaXMgcmVhbGx5IGp1c3QgcGFwZXJp
bmcgb3ZlciB0aGF0IHByb2JsZW0sIGJ1dCBpdA0KPiA+IHNob3VsZCBiZSAibW9zdGx5IGhhcm1s
ZXNzIi4gVGhhdCBzYWlkLCBJJ20gb2sgd2l0aCBkcm9wcGluZyBpdCBpZg0KPiA+IFRob21hcyBp
cyBwbGFubmluZyB0byBmaXggdGhpcyBpbiB0aGUgZGVidWdvYmplY3RzIGNvZGUgaG93ZXZlci4N
Cj4gPiANCj4gDQo+IEkgZGlzYWdyZWUgaXQncyBoYXJtbGVzcy4gV2hhdCBpZiBrbWVtX2NhY2hl
X2ZyZWUva21lbV9jYWNoZV9hbGxvYyBkZXBsb3lzDQo+IGEgcG9pc29uaW5nIHNjaGVtYSwgaW4g
ZGVidWcgbW9kZS4gV2hpY2ggc3R1bXBzIG92ZXIgbWVtb3J5LiBJcyBpdA0KPiBpbml0aWFsaXpl
ZCB0aGVuPw0KDQpJZiB0aGF0IHdlcmUgdGhlIGNhc2UsIHRoZW4gdGhlIGVudGlyZSBpbm9kZSB3
b3VsZCBiZSB1c2VsZXNzIHRvIHVzLiBXZQ0KcmVseSBvbiBpbml0aWFsaXNhdGlvbiBpbiBpbml0
X29uY2UoKSBmb3IgYSBidW5jaCBvZiBvdGhlciBzdHVmZg0KaW5jbHVkaW5nIGxpc3QgaGVhZHMs
IHdhaXRxdWV1ZSBoZWFkcywgZXRjLg0KDQo+IFdoYXQgd2FzIHRoZSBsYXN0IHN0YXRlIG9mIHRo
ZSB0aW1lciwgaXMgaXQgc2FmZSBmb3IgcmVzdW1lPw0KDQpJbml0aWFsaXNlZCwgYW5kIHllcy4N
Cg0KPiBGb3IgdXMgdGhpcyBpcyBhIG5ldyBvYmplY3Qgd2Ugc2hvdWxkIGluaXRpYWxpemUgaXQu
DQoNCk5vIGl0IGlzIGRlZmluaXRlbHkgbm90IGEgbmV3IG9iamVjdC4uLg0KDQotLSANClRyb25k
IE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQu
TXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
