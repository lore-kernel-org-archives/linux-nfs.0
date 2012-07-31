Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:27088 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754696Ab2GaOy1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 10:54:27 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: David Howells <dhowells@redhat.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "sct@redhat.com" <sct@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "steved@redhat.com" <steved@redhat.com>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] NFS: Combine the idmapper key types
Date: Tue, 31 Jul 2012 14:54:25 +0000
Message-ID: <1343746464.5528.7.camel@lade.trondhjem.org>
References: <20120731144234.6664.85664.stgit@warthog.procyon.org.uk>
	 <20120731144245.6664.49160.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120731144245.6664.49160.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA3LTMxIGF0IDE1OjQyICswMTAwLCBEYXZpZCBIb3dlbGxzIHdyb3RlOg0K
PiBUaGUgTkZTIGlkbWFwcGVyIGhhcyB0d28ga2V5IHR5cGVzIChub3JtYWwgYW5kIGxlZ2FjeSkg
YnV0IHNob3VsZCBvbmx5IHVzZSBvbmUNCj4gaWYgaXQgY2FuIC0gb3RoZXJ3aXNlIGl0IHJpc2tz
IGhhdmluZyB0d2ljZSBhcyBtYW55IGtleXMgYXMgaXQgd291bGQgb3RoZXJ3aXNlDQo+IG5lZWQu
DQoNCldoeSBpcyB0aGlzPyBEbyB3ZSBhZGQga2V5cyBpbiB0aGUgY2FzZSB3aGVyZSB0aGUgJ25v
cm1hbCcgdXBjYWxsIGZhaWxzPw0KDQo+IEdldCByaWQgb2YgdGhlIGxlZ2FjeSBrZXkgdHlwZSBh
bmQgaGF2ZSB0aGUgbm9ybWFsIGtleSB0eXBlIGhhdmUgYQ0KPiAucmVxdWVzdF9rZXkoKSBvcC4g
IFRoZSBjaG9pY2Ugb2Ygd2hpY2ggaW5zdGFudGlhdGlvbiBtZXRob2QgaXMgdGhlbiBtYWRlIGJ5
DQo+IHRoZSB1cGNhbGxlciwgaW4gb3JkZXI6DQo+IA0KPiAgKDEpIElmIHRoZXJlJ3Mgbm8gYXV4
ZGF0YSwgdGhlIG5vcm1hbCBtZXRob2QgaXMgY2FsbGVkLCBpbnZva2luZw0KPiAgICAgIC9zYmlu
L3JlcXVlc3Qta2V5Lg0KPiANCj4gICgyKSBJZiB0aGVyZSdzIHNvbWV0aGluZyBhdHRhY2hlZCB0
byB0aGUgaWRtYXBwZXIgcGlwZSAocnBjLmlkbWFwZCkgdGhlbiB1c2UNCj4gICAgICB0aGF0Lg0K
PiANCj4gICgzKSBGYWxsIGJhY2sgdG8gKDEpLg0KPiANCj4gTm90ZSB0aGF0IHRoaXMgZG9lcyBj
aGFuZ2UgdGhlIHByaW9yaXRpc2F0aW9uIG9mIG5vcm1hbCB2cyBsZWdhY3kgaWYgYm90aCBhcmUN
Cj4gYXZhaWxhYmxlLg0KDQpXZSBkb24ndCB3YW50IHRvIGRvIHRoaXMuIFRoZSBsZWdhY3kgY2Fs
bCBpcyAxMDAlIHNlcmlhbGlzZWQsIHNvIHRoaXMNCm1lYW5zIHRoYXQgd2UgZW5kIHVwIGNob29z
aW5nIHRoZSBub24tc2NhbGFibGUgYWx0ZXJuYXRpdmUuDQoNCg0KLS0gDQpUcm9uZCBNeWtsZWJ1
c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVz
dEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
