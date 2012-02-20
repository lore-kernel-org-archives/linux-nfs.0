Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952Ab2BTTJN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Feb 2012 14:09:13 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Ben Greear <greearb@candelatech.com>
CC: Jim Rees <rees@umich.edu>, Chris Rankin <rankincj@yahoo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [OOPS] NFS dereferenced NULL pointer with 3.2.6 kernel.
Date: Mon, 20 Feb 2012 19:09:04 +0000
Message-ID: <1329764945.5151.13.camel@lade.trondhjem.org>
References: <4F4194C4.40104@yahoo.com>
	  <1329760844.2834.1.camel@lade.trondhjem.org>
	  <20120220182709.GA22899@umich.edu>
	 <1329762949.5151.8.camel@lade.trondhjem.org>
	 <4F429450.5080502@candelatech.com>
In-Reply-To: <4F429450.5080502@candelatech.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTAyLTIwIGF0IDEwOjQzIC0wODAwLCBCZW4gR3JlZWFyIHdyb3RlOg0KPiBP
biAwMi8yMC8yMDEyIDEwOjM1IEFNLCBNeWtsZWJ1c3QsIFRyb25kIHdyb3RlOg0KPiA+IE9uIE1v
biwgMjAxMi0wMi0yMCBhdCAxMzoyNyAtMDUwMCwgSmltIFJlZXMgd3JvdGU6DQo+ID4+IE15a2xl
YnVzdCwgVHJvbmQgd3JvdGU6DQo+ID4+DQo+ID4+ICAgIEl0J3MgYSBrbm93biBidWcuIFRoZXJl
IGlzIGEgZml4IGF0DQo+ID4+DQo+ID4+ICAgIGh0dHA6Ly9naXQubGludXgtbmZzLm9yZy8/cD10
cm9uZG15L25mcy0yLjYuZ2l0O2E9Y29tbWl0O2g9MzMxODE4ZjFjNDY4YTI0ZTU4MWFlZGNiZTUy
YWY3OTkzNjZhOWRmZQ0KPiA+Pg0KPiA+PiBTaG91bGRuJ3QgdGhpcyBiZSBpbiBzdGFibGUgYnkg
bm93PyAgWW91IHNlbnQgaXQgRmViIDMsIGFuZCB0aGVyZSBoYXZlIGJlZW4NCj4gPj4gdHdvIHN0
YWJsZSByZWxlYXNlcyBzaW5jZSB0aGVuLg0KPiA+DQo+ID4gSSd2ZSBiZWVuIHdhaXRpbmcgZm9y
IEFuZHkgdG8gZ2V0IGJhY2sgZnJvbSB2YWNhdGlvbi4gV2UndmUgYWxyZWFkeSBzZW50DQo+ID4g
b25lIGJ1Z2d5IHBhdGNoIHRvIHN0YWJsZS4uLg0KPiA+DQo+IA0KPiBJdCdzIHN0aWxsIG5vdCBp
biAzLjMtcmMgZWl0aGVyLCBhdCBsZWFzdCBwdXQgaXQgdGhlcmUgc28gb3RoZXJzDQo+IGNhbiB0
ZXN0IGl0Pw0KDQozLjMtcmMgaXMgX05PVF8gYSBwbGFjZSB0byBwdXQgcGF0Y2hlcyBmb3IgdGVz
dGluZy4uLiBZb3UgdGVzdCB0aGUNCnBhdGNoZXMgX0JFRk9SRV8geW91IHNlbmQgdGhlbSB1cHN0
cmVhbS4NCg0KSW4gdGhpcyBjYXNlLCB0aGUgZGVsYXkgaGFzIGJlZW4gdGhyZWVmb2xkLg0KDQox
KSBBbmR5IHdhcyBvbiB2YWNhdGlvbg0KMikgVGhlcmUgYXJlIG90aGVyIGZpeGVzIHRoYXQgbmVl
ZCB0byBiZSBwdXNoZWQgYW5kIHRoYXQgdGVzdGVkIHRvbw0KMykgSSdtIGluIE5vcndheSB0cnlp
bmcgdG8gYXR0ZW5kIGEgZnVuZXJhbC4uLg0KDQoNCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxp
bnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRh
cHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
