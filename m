Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16344 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758463Ab2C1XRL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 19:17:11 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd4: use auth_unix unconditionally on backchannel
Date: Wed, 28 Mar 2012 23:16:49 +0000
Message-ID: <1332976613.19172.25.camel@lade.trondhjem.org>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
	 <1332337929-18580-4-git-send-email-jlayton@redhat.com>
	 <20120323121208.GA3219@fieldses.org> <20120323133111.GA2991@fieldses.org>
	 <1332516024.3087.1.camel@lade.trondhjem.org>
	 <20120323152220.GA4953@fieldses.org>
	 <1332516863.3087.10.camel@lade.trondhjem.org>
	 <20120323115337.28bff808@corrin.poochiereds.net>
	 <20120323121218.74461807@corrin.poochiereds.net>
	 <20120323170405.GA6089@fieldses.org> <20120328230931.GA13231@fieldses.org>
In-Reply-To: <20120328230931.GA13231@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTAzLTI4IGF0IDE5OjA5IC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IFRoaXMgaXMgYSBiYW5kYWlkLg0KPiANCj4gSSBoYXZlIGEgc2VyaWVzIG9mIHBhdGNoZXMg
dGhhdCBhY3R1YWxseSBpbXBsZW1lbnQgdGhlIGNvcnJlY3QgYmVoYXZpb3IsDQo+IGJ1dCB0aGF0
IG1heSBub3QgcXVpdGUgYmUgcmVhZHkgZm9yIDMuNC4NCj4gDQo+IC0tYi4NCj4gDQo+IGNvbW1p
dCAyZjAyNjg2N2M3NjE3MWQyNmYwMDNiMjExMDYzZmYwNTYyMDk3ZDVlDQo+IEF1dGhvcjogSi4g
QnJ1Y2UgRmllbGRzIDxiZmllbGRzQHJlZGhhdC5jb20+DQo+IERhdGU6ICAgV2VkIE1hciAyOCAx
NDoxODoxNiAyMDEyIC0wNDAwDQo+IA0KPiAgICAgbmZzZDQ6IHVzZSBhdXRoX3VuaXggdW5jb25k
aXRpb25hbGx5IG9uIGJhY2tjaGFubmVsDQo+ICAgICANCj4gICAgIFRoaXMgaXNuJ3QgYWN0dWFs
bHkgY29ycmVjdCwgYnV0IGl0IHdvcmtzIHdpdGggdGhlIExpbnV4IGNsaWVudCwgYW5kDQo+ICAg
ICBhZ3JlZXMgd2l0aCB0aGUgYmVoYXZpb3Igd2UgdXNlZCB0byBoYXZlIGJlZm9yZSBjb21taXQg
ODBmYzAxNWJkZmUuDQoNClF1ZXN0aW9uOiBkb2VzIHRoZSBMaW51eCBjbGllbnQgZXZlciBzZW5k
IHlvdSBhbnl0aGluZyBvdGhlciB0aGFuDQpBVVRIX1NZUyBjcmVkZW50aWFscyBmb3IgdGhlIGNz
YV9zZWNfcGFybXMgYXJndW1lbnQgaW4gQ1JFQVRFX1NFU1NJT04/DQpBbnl0aGluZyBvdGhlciB0
aGFuIHRoYXQgd291bGQgYmUgYSBidWcsIHNpbmNlIG91ciBjbGllbnQgZG9lc24ndA0KYWN0dWFs
bHkgc3VwcG9ydCBSUENTRUNfR1NTIGluIHRoZSBjYWxsYmFjayBjaGFubmVsLg0KDQo+ICAgICBM
YXRlciBwYXRjaGVzIHdpbGwgaW1wbGVtZW50IHRoZSBzcGVjLW1hbmRhdGVkIGJlaGF2aW9yICh3
aGljaCBpcyB0byB1c2UNCj4gICAgIHRoZSBzZWN1cml0eSBwYXJhbWV0ZXJzIGV4cGxpY2l0bHkg
Z2l2ZW4gYnkgdGhlIGNsaWVudCBpbiBjcmVhdGVfc2Vzc2lvbg0KPiAgICAgb3IgYmFja2NoYW5u
ZWxfY3RsKS4NCj4gICAgIA0KDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xp
ZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3
Lm5ldGFwcC5jb20NCg0K
