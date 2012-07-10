Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41290 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751830Ab2GJTPN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 15:15:13 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Tomasz Chmielewski <mangoo@wpkg.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: cachefilesd - using multiple cache directories (disks)?
Date: Tue, 10 Jul 2012 19:15:11 +0000
Message-ID: <1341947709.12698.15.camel@lade.trondhjem.org>
References: <4FFC733D.7050306@wpkg.org>
In-Reply-To: <4FFC733D.7050306@wpkg.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTA3LTExIGF0IDAyOjIzICswODAwLCBUb21hc3ogQ2htaWVsZXdza2kgd3Jv
dGU6DQo+IEhpLA0KPiANCj4gaXMgaXQgcG9zc2libGUgdG8gdXNlIGNhY2hlZmlsZXNkIHdpdGgg
bXVsdGlwbGUgZGlyZWN0b3JpZXMgKGRpc2tzKT8NCj4gDQo+IA0KPiBUaGUgZmluZSBtYW51YWwg
aXMgbm90IHZlcnkgY2xlYXIgYWJvdXQgdGhpczoNCj4gDQo+ICAgICAgICAgZGlyIDxwYXRoPg0K
PiAgICAgICAgICAgICAgICBUaGlzIGNvbW1hbmQgc3BlY2lmaWVzIHRoZSBkaXJlY3RvcnkgY29u
dGFpbmluZyB0aGUgcm9vdA0KPiAgICAgICAgICAgICAgICBvZiB0aGUgY2FjaGUuICBJdCBtYXkg
b25seSBzcGVjaWZpZWQgb25jZSBwZXINCj4gICAgICAgICAgICAgICAgY29uZmlndXJhdGlvbiBm
aWxlLg0KPiANCj4gDQo+IFRoaXMgbWF5IGJlIGludGVycHJldGVkIGFzIGVpdGhlcjoNCj4gDQo+
IDEpIG5vLCBpdCdzIG5vdCBwb3NzaWJsZSB0byB1c2UgbXVsdGlwbGUgZGlyZWN0b3JpZXMgd2l0
aCBjYWNoZWZpbGVzZA0KPiANCj4gMikgaXQncyBub3QgcG9zc2libGUgdG8gdXNlIG11bHRpcGxl
IGRpcmVjdG9yaWVzIHdpdGggb25lIGNhY2hlZmlsZXNkIA0KPiBwcm9jZXNzLCBidXQgaXQncyBw
ZXJmZWN0bHkgT0sgdG8gcnVuIG11bHRpcGxlIGluc3RhbmNlcyBvZiBjYWNoZWZpbGVzZCANCj4g
b24gb25lIHNlcnZlcg0KPiANCj4gDQo+IFdoaWNoIG9uZSBpcyB0cnVlPw0KDQpTZWUgRG9jdW1l
bnRhdGlvbi9maWxlc3lzdGVtcy9jYWNoaW5nL2NhY2hlZmlsZXMudHh0Og0KPT09PT09PT0NCk9W
RVJWSUVXDQo9PT09PT09PQ0KLi4uDQpDYWNoZUZpbGVzIGlzIGN1cnJlbnRseSBsaW1pdGVkIHRv
IGEgc2luZ2xlIGNhY2hlLg0KDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xp
ZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3
Lm5ldGFwcC5jb20NCg0K
