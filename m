Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59553 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756522Ab2BGTor (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 14:44:47 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: Jeff Layton <jlayton@redhat.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFS: Fall back on old idmapper if request_key()
 fails
Date: Tue, 7 Feb 2012 19:44:28 +0000
Message-ID: <1328643867.4124.42.camel@lade.trondhjem.org>
References: <1327614865-29322-1-git-send-email-bjschuma@netapp.com>
	  <20120207141254.2948e735@tlielax.poochiereds.net>
	 <1328642485.4124.40.camel@lade.trondhjem.org> <4F317BA1.4050102@netapp.com>
In-Reply-To: <4F317BA1.4050102@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTAyLTA3IGF0IDE0OjI5IC0wNTAwLCBCcnlhbiBTY2h1bWFrZXIgd3JvdGU6
DQo+IE9uIDAyLzA3LzEyIDE0OjIxLCBNeWtsZWJ1c3QsIFRyb25kIHdyb3RlOg0KPiANCj4gPiBP
biBUdWUsIDIwMTItMDItMDcgYXQgMTQ6MTIgLTA1MDAsIEplZmYgTGF5dG9uIHdyb3RlOg0KPiA+
PiBPbiBhIDMyLWJpdCBib3ggd2hlbiB5b3UgdHJ5IHRvIG1vdW50IGFuZCBsb3cgbWVtb3J5IGlz
IGhlYXZpbHkNCj4gPj4gZnJhZ21lbnRlZCwgeW91IGNhbiBnZXQgYSBOVUxMIHBvaW50ZXIgYmFj
ayBvbiB0aGF0IGt6YWxsb2Mgd2l0aCBhDQo+ID4+IG5pY2Ugc3RhY2sgdHJhY2UgaGVhZGVkIGJ5
IGEgbWVzc2FnZSBsaWtlIHRoaXM6DQo+ID4+DQo+ID4+ICAgICBtb3VudC5uZnM6IHBhZ2UgYWxs
b2NhdGlvbiBmYWlsdXJlLiBvcmRlcjo0LCBtb2RlOjB4YzBkMA0KPiA+Pg0KPiA+PiBIZXJlJ3Mg
YSBSSEJaIGFnYWluc3QgUkhFTDYgaWYgeW91J3JlIGludGVyZXN0ZWQgaW4gZ29yeSBkZXRhaWxz
Og0KPiA+Pg0KPiA+PiAgICAgaHR0cHM6Ly9idWd6aWxsYS5yZWRoYXQuY29tL3Nob3dfYnVnLmNn
aT9pZD03MzAwNDUNCj4gPj4NCj4gPj4gSW4gYW55IGNhc2UsIHRoaXMgcHJvYmxlbSB3YXMgb25l
IG9mIHRoZSByZWFzb25zIGZvciBwdXNoaW5nIHRoZSBuZXcNCj4gPj4gaWRtYXBwZXIuIEEgbnVt
YmVyIG9mIHBlb3BsZSBoYXZlIGNvbXBsYWluZWQgYWJvdXQgdGhpcyBwcm9ibGVtIGluIHRoZQ0K
PiA+PiBwYXN0IGFuZCB3ZSB0b2xkIHRoZW0gInVzZSB0aGUgbmV3IGlkbWFwcGVyIi4gTm93LCB3
aXRoIHRoaXMgcGF0Y2hzZXQsDQo+ID4+IHRoYXQgd29uJ3QgaGVscC4NCj4gPiANCj4gPiBXYWl0
LiBIb3cgaXMgdGhhdCB0cnVlPyBUaGUgd2hvbGUgcG9pbnQgb2YgdGhpcyBwYXRjaHNldCBpcyB0
aGF0IGl0DQo+ID4gYWxsb3dzIHlvdSB0byBjb21waWxlIGluIHN1cHBvcnQgZm9yIF9ib3RoXyBp
ZG1hcHBlcnMsIHdpdGggdGhlIG5ldw0KPiA+IGtleXJpbmctYmFzZWQgaWRtYXBwZXIgYmVpbmcg
dHJpZWQgZmlyc3QuIFRoZSBjbGllbnQgdGhlbiBmYWxscyBiYWNrIHRvDQo+ID4gdXNpbmcgdGhl
IG9sZCBpZG1hcHBlciBpZiBhbmQgb25seSBpZiB0aGUgdXNlciBoYXMgZmFpbGVkIHRvIHNldCB1
cCB0aGUNCj4gPiBuZXcgaWRtYXBwZXIgY29ycmVjdGx5Lg0KPiANCj4gDQo+IEJlY2F1c2UgaXQg
c3RpbGwgYWxsb2NhdGVzIHRoZSBzdHJ1Y3R1cmVzLCB0aGV5IGp1c3QgZ28gdW51c2VkIGlmIHRo
ZSBuZXcgaWRtYXBwZXIgd29ya3MuICBUaGlzIHNlZW1zIGtpbmQgb2Ygd2FzdGVmdWwgbm93IHRo
YXQgSSBrbm93IGFib3V0IGl0Li4uDQoNCk9uZSB3YXkgdG8gZWFzaWx5IHNocmluayB0aGUgc2l6
ZSBvZiB0aGF0IGFsbG9jYXRpb24gaXMgdG8gY29udmVydCB0aGUNCmloX25hbWUgc3RyaW5nIGlu
dG8gYSBwb2ludGVyLCBhbmQgaGF2ZSB0aGUgZG93bmNhbGwgYWxsb2NhdGUgdGhlDQpzdG9yYWdl
IGZvciB0aGF0IHN0cmluZyBkeW5hbWljYWxseS4uLg0KDQoNCg0KLS0gDQpUcm9uZCBNeWtsZWJ1
c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVz
dEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
