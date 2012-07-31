Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18600 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754641Ab2GaPHn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 11:07:43 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: David Howells <dhowells@redhat.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "sct@redhat.com" <sct@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "steved@redhat.com" <steved@redhat.com>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: [PATCH 1/2] NFS: Fix a number of bugs in the idmapper
Date: Tue, 31 Jul 2012 15:07:42 +0000
Message-ID: <1343747261.5528.10.camel@lade.trondhjem.org>
References: <1343746117.5528.3.camel@lade.trondhjem.org>
	 <20120731144234.6664.85664.stgit@warthog.procyon.org.uk>
	 <6978.1343746575@warthog.procyon.org.uk>
In-Reply-To: <6978.1343746575@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA3LTMxIGF0IDE1OjU2ICswMTAwLCBEYXZpZCBIb3dlbGxzIHdyb3RlOg0K
PiBNeWtsZWJ1c3QsIFRyb25kIDxUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbT4gd3JvdGU6DQo+
IA0KPiA+IFRoaXMgcGF0Y2ggc2hvdWxkIGFscmVhZHkgYmUgcHJlc2VudCBpbiBuZnMtZm9yLW5l
eHQgYXMgb2YgeWVzdGVyZGF5Lg0KPiA+IChJJ3ZlIGJlZW4gb24gYSAyIHdlZWsgdmFjYXRpb24p
Lg0KPiANCj4gSG93IGFib3V0IHRoZSBzZWNvbmQgcGF0Y2g/ICBJIHBvc3RlZCBhbiB1cGRhdGVk
IHZlcnNpb24gb2YgaXQganVzdCBub3cuDQo+IA0KPiBOb3RlIHRoYXQgdGhlIHNlY29uZCBwYXRj
aCBvciBzb21ldGhpbmcgbGlrZSBpdCBpcyBsaWtlbHkgdG8gYmUgbmVjZXNzYXJ5IHRvDQo+IHJl
ZHVjZSB0aGUgbG9hZCBvbiB0aGUga2V5cmluZyAoeW91IGVuZCB1cCBoYXZpbmcgZHVwbGljYXRl
IGtleXMgb2YgZGlmZmVyZW50DQo+IGtleSB0eXBlcyB0aGF0IGNhbid0IGJlIHNoYXJlZCkuDQoN
CldlIGRvbid0IGV4cGVjdCBwZW9wbGUgdG8gYmUgcnVubmluZyBib3RoIHR5cGVzIG9mIGlkbWFw
cGVyIGF0IHRoZSBzYW1lDQp0aW1lLiBOb3JtYWxseSwgdGhlIGRpc3RyaWJ1dGlvbiB3aWxsIHNl
dCB1cCBvbmUgb3IgdGhlIG90aGVyLiBIb3dldmVyDQppZiBib3RoIGlkbWFwcGVycyBkbyBoYXBw
ZW4gdG8gYmUgY29uZmlndXJlZCwgdGhlbiB3ZSB3YW50IHRvIGFsd2F5cw0KY2hvb3NlIHRoZSBu
b24tbGVnYWN5IHR5cGUuLi4NCg0KQ2hlZXJzDQogIFRyb25kDQo=
