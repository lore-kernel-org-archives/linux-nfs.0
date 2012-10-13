Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:54008 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751915Ab2JMCcL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Oct 2012 22:32:11 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>,
        Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Larry McVoy <lm@bitmover.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Date: Sat, 13 Oct 2012 02:32:09 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9091FDFA9@SACEXCMBX04-PRD.hq.netapp.com>
References: <20121012211701.GA8301@bitmover.com>
	 <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
	 <5078D17C.9090002@panasas.com>
In-Reply-To: <5078D17C.9090002@panasas.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTEwLTEyIGF0IDE5OjI3IC0wNzAwLCBCb2F6IEhhcnJvc2ggd3JvdGU6DQo+
IE9uIDEwLzEyLzIwMTIgMDQ6NTIgUE0sIExpbnVzIFRvcnZhbGRzIHdyb3RlOg0KPiA+IEd1eXMs
IGNoZWNrIHRoaXMgcmVwb3J0IGZyb20gTGFycnkgb3V0Lg0KPiA+IA0KPiA+IEFsc28sIHdoeSB0
aGUgKkhFTEwqIGlzIHRoYXQgYSBCVUdfT04oKSBpbiB0aGUgZmlyc3QgcGxhY2U/IFdobyB3YXMN
Cj4gPiB0aGUgbGVzcy10aGFuLWdpZnRlZCBwZXJzb24gd2hvIGRlY2lkZWQgImlmIHRoaXMgdGhp
bmcgY2FuIGhhcHBlbiwNCj4gPiBsZXQncyBqdXN0IGtpbGwgdGhlIHdob2xlIG1hY2hpbmUiPw0K
PiA+IA0KPiANCj4gU29tZXRoaW5nIGlzIHRyaXZpYWxseSB3ZWlyZA0KPiANCj4gZnMvbG9ja2Qv
Y2xudHhkci5jOjIyNiBpcyBpbiB0aGlzIHN0YXRpYyBmdW5jdGlvbjoNCj4gCWVuY29kZV9ubG1f
c3RhdCgpDQo+IA0KPiBlbmNvZGVfbmxtX3N0YXQoKSBpcyBjYWxsZWQgaW4gdHdvIHBsYWNlcw0K
PiAJc3RhdGljIHZvaWQgbmxtX3hkcl9lbmNfcmVzKC4uLikNCj4gICBhbmQNCj4gCXN0YXRpYyB2
b2lkIG5sbV94ZHJfZW5jX3Rlc3RyZXMoLi4uKQ0KPiANCj4gQnV0IHRoZXNlIHR3byBhcmUgbm90
IGNhbGxlZCBhbnl3aGVyZS4gSW4tZmFjdCBhIEtlcm5lbCB3aWRlIGdyZXANCj4gcmV0dXJucyBh
IHNpbmdsZSBvY2N1cnJlbmNlIG9mIGJvdGgNCg0KVGhleSBhcmUgdXNlZCBpbiB0aGUgbmxtX3By
b2NlZHVyZXNbXSBhcnJheSBhcyBURVNUX1JFUywgTE9DS19SRVMsDQpDQU5DRUxfUkVTLCBVTkxP
Q0tfUkVTIGFuZCBHUkFOVEVEX1JFUyB4ZHIgZW5jb2RpbmcgcHJvY2VkdXJlcy4NCg0KDQoNCi0t
IA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBw
DQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg==
