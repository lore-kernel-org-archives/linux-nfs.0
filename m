Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:33970 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755815AbdEKNlS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 May 2017 09:41:18 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "n.borisov.lkml@gmail.com" <n.borisov.lkml@gmail.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "mhocko@suse.com" <mhocko@suse.com>
Subject: Re: [GIT PULL] Please pull NFS client fixes for 4.12
Date: Thu, 11 May 2017 13:41:12 +0000
Message-ID: <1494510068.6968.0.camel@primarydata.com>
References: <1494434821.4764.1.camel@primarydata.com>
         <be16be57-235c-fdf9-f708-3898aeeeb5aa@gmail.com>
In-Reply-To: <be16be57-235c-fdf9-f708-3898aeeeb5aa@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE3LTA1LTExIGF0IDEwOjUzICswMzAwLCBOaWtvbGF5IEJvcmlzb3Ygd3JvdGU6
DQo+IA0KPiBPbiAxMC4wNS4yMDE3IDE5OjQ3LCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6DQo+ID4g
SGkgTGludXMsDQo+ID4gDQo+ID4gVGhlIGZvbGxvd2luZyBjaGFuZ2VzIHNpbmNlIGNvbW1pdA0K
PiA+IDRmN2QwMjliOWJmMDA5ZmJlZTc2YmIxMGMwYzQzNTFhMTg3MGQyZjM6DQo+ID4gDQo+ID4g
wqAgTGludXggNC4xMS1yYzcgKDIwMTctMDQtMTYgMTM6MDA6MTggLTA3MDApDQo+ID4gDQo+ID4g
YXJlIGF2YWlsYWJsZSBpbiB0aGUgZ2l0IHJlcG9zaXRvcnkgYXQ6DQo+ID4gDQo+ID4gwqAgZ2l0
Oi8vZ2l0LmxpbnV4LW5mcy5vcmcvcHJvamVjdHMvdHJvbmRteS9saW51eC1uZnMuZ2l0IHRhZ3Mv
bmZzLQ0KPiA+IGZvci00LjEyLTENCj4gPiANCj4gPiBmb3IgeW91IHRvIGZldGNoIGNoYW5nZXMg
dXAgdG8NCj4gPiA3NmIyYTMwMzM4NGUxZDYyOTljM2EwMjQ5ZjBmMGNlMmY4Zjk2MDE3Og0KPiA+
IA0KPiA+IMKgIHBORlMvZmxleGZpbGVzOiBBbHdheXMgYXR0ZW1wdCB0byBjYWxsIGxheW91dHN0
YXRzIHdoZW4gZmxleGZpbGVzDQo+ID4gaXMgZW5hYmxlZCAoMjAxNy0wNS0wOSAxNjowMjo1NyAt
MDQwMCkNCj4gPiANCj4gPiAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQo+ID4gTkZTIGNsaWVudCB1cGRhdGVzIGZvciBMaW51
eCA0LjEyDQo+ID4gDQo+ID4gSGlnaGxpZ2h0cyBpbmNsdWRlOg0KPiA+IA0KPiA+IFN0YWJsZSBi
dWdmaXhlczoNCj4gPiAtIEZpeCB1c2UgYWZ0ZXIgZnJlZSBpbiB3cml0ZSBlcnJvciBwYXRoDQo+
ID4gLSBVc2UgR0ZQX05PSU8gZm9yIHR3byBhbGxvY2F0aW9ucyBpbiB3cml0ZWJhY2sNCj4gPiAt
IEZpeCBhIGhhbmcgaW4gT1BFTiByZWxhdGVkIHRvIHNlcnZlciByZWJvb3QNCj4gPiAtIENoZWNr
IHRoZSByZXN1bHQgb2YgbmZzNF9wbmZzX2RzX2Nvbm5lY3QNCj4gPiAtIEZpeCBhbiByY3UgbG9j
ayBsZWFrDQo+ID4gDQo+ID4gRmVhdHVyZXM6DQo+ID4gLSBSZW1vdmFsIG9mIHRoZSB1bm1haW50
YWluZWQgYW5kIHVudXNlZCBPU0QgcE5GUyBsYXlvdXQNCj4gPiAtIENsZWFudXAgYW5kIHJlbW92
YWwgb2YgbG90cyBvZiB1bm5lY2Vzc2FyeSBkcHJpbnRrKClzDQo+ID4gLSBDbGVhbnVwIGFuZCBy
ZW1vdmFsIG9mIHNvbWUgbWVtb3J5IGZhaWx1cmUgcGF0aHMgbm93IHRoYXQNCj4gPiDCoCBHRlBf
Tk9GUyBpcyBndWFyYW50ZWVkIHRvIG5ldmVyIGZhaWwuDQo+IA0KPiBXaGF0IGd1YXJhbnRlZXMg
dGhhdD8gU2luY2UgaWYgdGhpcyBpcyB0aGUgY2FzZSB0aGVuIHRoaXMgY2FuIHJlc3VsdA0KPiBp
bg0KPiBhIGxvdCBvZiBvcHBvcnR1bml0aWVzIGZvciBjbGVhbnVwIGFjcm9zcyB0aGUgd2hvbGUg
a2VybmVsIHRyZWUuDQo+IEFmdGVyDQo+IGRpc2N1c3Npbmcgd2l0aCBtaG9ja28gKGNjJ2VkKSBp
dCBzZWVtcyB0aGF0IGluIHByYWN0aWNlIGV2ZXJ5dGhpbmcNCj4gYmVsb3cgQ09TVExZX09SREVS
IHdoaWNoIGFyZSBub3QgR0ZQX05PUkVUUlkgd2lsbCBuZXZlciBmYWlsLiBCdXQNCj4gdGhpcw0K
PiBzZW1hbnRpYyBpcyBub3QgdGhlIHNhbWUgYXMgR0ZQX05PRkFJTC4gRS5nLiBub3RoaW5nIGd1
YXJhbnRlZXMgdGhhdA0KPiB0aGlzIHdpbGwgc3RheSBsaWtlIHRoYXQgaW4gdGhlIGZ1dHVyZT8N
Cj4gDQoNCkFjdHVhbGx5LCBnb2luZyBiYWNrIHRvIHRoZSBjb2RlIHdpdGggY29mZmVlOiBpdCdz
IHRoZSBmYWN0IHdlIGhhdmUNCm1lbXBvb2xzLCB3aXRoIGRpcmVjdCByZWNsYWltIHRoYXQgZ3Vh
cmFudGVlIHRoaXMuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1h
aW50YWluZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

