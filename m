Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59036 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755382Ab2B0WIw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Feb 2012 17:08:52 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Dave Kleikamp <dave.kleikamp@oracle.com>
CC: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Zach Brown <zab@zabbo.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH 22/22] nfs: add support for read_iter, write_iter
Date: Mon, 27 Feb 2012 22:08:50 +0000
Message-ID: <1330380530.5541.87.camel@lade.trondhjem.org>
References: <1330377576-3659-1-git-send-email-dave.kleikamp@oracle.com>
	 <1330377576-3659-23-git-send-email-dave.kleikamp@oracle.com>
In-Reply-To: <1330377576-3659-23-git-send-email-dave.kleikamp@oracle.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTAyLTI3IGF0IDE1OjE5IC0wNjAwLCBEYXZlIEtsZWlrYW1wIHdyb3RlOg0K
PiBUaGlzIHBhdGNoIGltcGxlbWVudHMgdGhlIHJlYWRfaXRlciBhbmQgd3JpdGVfaXRlciBmaWxl
IG9wZXJhdGlvbnMgd2hpY2gNCj4gYWxsb3cga2VybmVsIGNvZGUgdG8gaW5pdGlhdGUgZGlyZWN0
SU8uIFRoaXMgYWxsb3dzIHRoZSBsb29wIGRldmljZSB0bw0KPiByZWFkIGFuZCB3cml0ZSBkaXJl
Y3RseSB0byB0aGUgc2VydmVyLCBieXBhc3NpbmcgdGhlIHBhZ2UgY2FjaGUuDQo+IA0KPiBTaWdu
ZWQtb2ZmLWJ5OiBEYXZlIEtsZWlrYW1wIDxkYXZlLmtsZWlrYW1wQG9yYWNsZS5jb20+DQo+IENj
OiBaYWNoIEJyb3duIDx6YWJAemFiYm8ubmV0Pg0KPiBDYzogVHJvbmQgTXlrbGVidXN0IDxUcm9u
ZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbT4NCj4gQ2M6IGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmcN
Cg0KUGVyZm9ybWFuY2UgaXMgZ29pbmcgdG8gYmUgYWJzb2x1dGVseSB0ZXJyaWJsZSBmb3IgT19E
SVJFQ1QgYnZlY3MgaWYgeW91DQpzZW5kIGp1c3Qgb25lIHBhZ2UgcGVyIFJQQyBjYWxsLiBXZSBh
cmUgd29ya2luZyBvbiBtZXJnaW5nIHRoZSBPX0RJUkVDVA0KYW5kIHBhZ2UgY2FjaGUgY29kZSBp
biBvcmRlciB0byBnaXZlIE9fRElSRUNUIHRoZSBhYmlsaXR5IHRvIGNvYWxlc2NlDQpyZXF1ZXN0
cyBhbmQgZG8gcE5GUywgYW5kIEknbSBob3BpbmcgdGhhdCBjb2RlIHdpbGwgYmUgYXZhaWxhYmxl
IHNvb24uDQoNCkluIHRoZSBtZWFudGltZSwgd291bGRuJ3QgaXQgYmUgcG9zc2libGUgdG8gYWRk
IGJhc2ljIGNvYWxlc2NpbmcgdG8NCm5mc19kaXJlY3RfcmVhZF9zY2hlZHVsZV9idmVjL25mc19k
aXJlY3Rfd3JpdGVfc2NoZWR1bGVfYnZlYyBtb3JlIG9yDQpsZXNzIGluIHRoZSBzYW1lIHdheSB0
aGF0IHdlIGRvIGZvciBtdWx0aS1wYWdlIGlvdmVjIHNlZ21lbnRzPw0KaS5lLiBpZiB0aGUgbmV4
dCBidmVjIGlzIGNvbnRpZ3VvdXMgd2l0aCB0aGUgcHJldmlvdXMsIGFuZCB0aGUgcmVzdWx0aW5n
DQpSUEMgcmVhZCBsZW5ndGggPCByc2l6ZSAvIHdyaXRlIGxlbmd0aCA8IHdzaXplLCB0aGVuIGFk
ZCBpdCB0byB0aGUgc2FtZQ0KUlBDIGNhbGwuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51
eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBw
LmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
