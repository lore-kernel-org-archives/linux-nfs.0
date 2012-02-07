Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:49232 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755608Ab2BGN7G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 08:59:06 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
CC: "J.Bruce Fields" <bfields@fieldses.org>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] lockd: fix arg parsing for grace_period and timeout.
Date: Tue, 7 Feb 2012 13:58:43 +0000
Message-ID: <1328623124.4124.5.camel@lade.trondhjem.org>
References: <20120207153542.3df498ad@notabene.brown>
In-Reply-To: <20120207153542.3df498ad@notabene.brown>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTAyLTA3IGF0IDE1OjM1ICsxMTAwLCBOZWlsQnJvd24gd3JvdGU6DQo+IElm
IHlvdSB0cnkgdG8gc2V0IGdyYWNlX3BlcmlvZCBvciB0aW1lb3V0IHZpYSBhIG1vZHVsZSBwYXJh
bWV0ZXINCj4gdG8gbG9ja2QsIGFuZCBkbyB0aGlzIG9uIGEgYmlnLWVuZGlhbiBtYWNoaW5lIHdo
ZXJlDQo+IA0KPiAgICBzaXplb2YoaW50KSAhPSBzaXplb2YodW5zaWduZWQgbG9uZykNCj4gDQo+
IGl0IHdvbid0IHdvcmsuICBUaGlzIG51bWJlciBnaXZlbiB3aWxsIGJlIGVmZmVjdGl2ZWx5IHNo
aWZ0ZWQgcmlnaHQNCj4gYnkgdGhlIGRpZmZlcmVuY2UgaW4gdGhvc2UgdHdvIHNpemVzLg0KPiAN
Cj4gU28gY2FzdCBrcC0+YXJnIHByb3Blcmx5IHRvIGdldCBjb3JyZWN0IHJlc3VsdC4NCj4gDQo+
IFNpZ25lZC1vZmYtYnk6IE5laWxCcm93biA8bmVpbGJAc3VzZS5kZT4NCj4gDQo+IGRpZmYgLS1n
aXQgYS9mcy9sb2NrZC9zdmMuYyBiL2ZzL2xvY2tkL3N2Yy5jDQo+IGluZGV4IGMwNjFiOWEuLjI0
NDQ3ODAgMTAwNjQ0DQo+IC0tLSBhL2ZzL2xvY2tkL3N2Yy5jDQo+ICsrKyBiL2ZzL2xvY2tkL3N2
Yy5jDQo+IEBAIC00NDAsNyArNDQwLDcgQEAgc3RhdGljIGludCBwYXJhbV9zZXRfIyNuYW1lKGNv
bnN0IGNoYXIgKnZhbCwgc3RydWN0IGtlcm5lbF9wYXJhbSAqa3ApCVwNCj4gIAlfX3R5cGVvZl9f
KHR5cGUpIG51bSA9IHdoaWNoX3N0cnRvbCh2YWwsICZlbmRwLCAwKTsJCVwNCj4gIAlpZiAoZW5k
cCA9PSB2YWwgfHwgKmVuZHAgfHwgbnVtIDwgKG1pbikgfHwgbnVtID4gKG1heCkpCQlcDQo+ICAJ
CXJldHVybiAtRUlOVkFMOwkJCQkJCVwNCj4gLQkqKChpbnQgKikga3AtPmFyZykgPSBudW07CQkJ
CQlcDQo+ICsJKigodHlwZSAqKSBrcC0+YXJnKSA9IG51bTsJCQkJCVwNCj4gIAlyZXR1cm4gMDsJ
CQkJCQkJXA0KPiAgfQ0KPiAgDQpXb3csIHRoYXQncyBhIHNlcmlvdXNseSBvbGQgYnVnLi4uIEJy
dWNlLCBkbyB5b3Ugd2FudCB0byBjYXJyeSBpdD8NCg0KVHJvbmQNCi0tIA0KVHJvbmQgTXlrbGVi
dXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1
c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
