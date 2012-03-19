Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18365 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030328Ab2CSS0Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 14:26:24 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>, Nikolaus Rath <Nikolaus@rath.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: [nfsv4] NFS4 over VPN hangs when connecting > 2 clients
Date: Mon, 19 Mar 2012 18:26:22 +0000
Message-ID: <1332181582.2636.15.camel@lade.trondhjem.org>
References: <87pqchn64e.fsf@inspiron.ap.columbia.edu>
	 <20120312193115.GA7203@fieldses.org> <4F5E5241.7070008@rath.org>
	 <20120312201505.GC7203@fieldses.org> <4F5E5CF2.50309@rath.org>
	 <20120312204238.GA8991@fieldses.org>
	 <7C4C12AF-5820-4BF3-8262-3BF5C201DA8C@oracle.com>
	 <20120312210414.GB8991@fieldses.org>
	 <D62C59BB-D68B-42FD-A916-78B86C1133F7@oracle.com>
	 <20120312212708.GC8991@fieldses.org> <20120319162851.GA22336@fieldses.org>
In-Reply-To: <20120319162851.GA22336@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTAzLTE5IGF0IDEyOjI4IC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIE1vbiwgTWFyIDEyLCAyMDEyIGF0IDA1OjI3OjA4UE0gLTA0MDAsIEouIEJydWNlIEZp
ZWxkcyB3cm90ZToNCj4gPiBPbiBNb24sIE1hciAxMiwgMjAxMiBhdCAwNToxNDoxNlBNIC0wNDAw
LCBDaHVjayBMZXZlciB3cm90ZToNCj4gPiA+IElNTywgdGhlIHNlcnZlciBzaG91bGQgZG8gYSBj
b21wYXJpc29uIG9mIHRoZSBuZnNfY2xpZW50X2lkNCBzdHJpbmdzLA0KPiA+ID4gYW5kIG5vdGhp
bmcgZWxzZS4NCj4gPiANCj4gPiBXZSdyZSBzdXBwb3NlZCB0byByZXR1cm4gQ0xJRF9JTlVTRSB3
aGVuIHdlIHNlZSBhIHNldGNsaWVudGlkIGZyb20gYQ0KPiA+ICJkaWZmZXJlbnQiIGNsaWVudCB1
c2luZyB0aGUgc2FtZSBzdHJpbmcsIHRvIGtlZXAgY2xpZW50cyBmcm9tIGRvaW5nDQo+ID4gbWlz
Y2hpZWYgd2l0aCBvdGhlciBjbGllbnRzJyBzdGF0ZSAoZWl0aGVyIG1hbGljaW91c2x5IG9yLCBh
cyBpbiB0aGlzDQo+ID4gY2FzZSwgYWNjaWRlbnRhbGx5KS4NCj4gPiANCj4gPiAiRGlmZmVyZW50
IiBoZXJlIGlzIGRlZmluZWQgYXMgIm5vdCBoYXZpbmcgdGhlIHNhbWUgcHJpbmNpcGFsIi4gIEkg
a25vdw0KPiA+IHdoYXQgdGhhdCBtZWFucyBpbiB0aGUga3JiNSBjYXNlLCBidXQgSSdtIGxlc3Mg
Y2VydGFpbiBpbiB0aGUgYXV0aF9zeXMNCj4gPiBjYXNlLg0KPiANCj4gQ2MnaW5nIHRoZSBpZXRm
IGxpc3QuICBJcyBpdCByZWFzb25hYmxlIGZvciBhIHNlcnZlciB0byBleHBlY3QNCj4gc2V0Y2xp
ZW50aWQncyB0byBjb21lIGZyb20gdGhlIHNhbWUgY2xpZW50IElQIGFkZHJlc3MgYXQgbGVhc3Qg
aW4gdGhlDQo+IGF1dGhfc3lzIGNhc2UsIG9yIGNvdWxkIHRoYXQgYnJlYWsgbXVsdGktaG9tZWQg
Y2xpZW50cz8NCj4gDQo+IEF0IGxlYXN0IGluIHRoZSBhdXRoX3N5cyBjYXNlIElQIGFkZHJlc3Nl
cyBhcmUgb25lIG9mIHRoZSBvbmx5IHRoaW5ncyB3ZQ0KPiBoYXZlIGxlZnQgdG8gZ28gb24gd2hl
biB0aGUgY2xpZW50J3MgaWRlbnRpZmllci1nZW5lcmF0aW9uIGlzIG1lc3NlZCB1cA0KPiAobm90
IHRoYXQgZGlmZmljdWx0KS4NCg0KWWVzLCBidXQgSVAgYWRkcmVzc2VzIGNhbiBiZSByZWFzc2ln
bmVkIGR5bmFtaWNhbGx5LiBUaGF0J3Mgb25lIG9mIHRoZQ0KcmVhc29ucyBmb3Igd2FudGluZyBh
IGNsaWVudCBpZCBpbiB0aGUgZmlyc3QgcGxhY2UuLi4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QN
CkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBu
ZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
