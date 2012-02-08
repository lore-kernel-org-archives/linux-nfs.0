Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28574 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740Ab2BHR13 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 12:27:29 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH 1/2] NFSv4.1: Convert slotid from u8 to u32
Date: Wed, 8 Feb 2012 17:27:22 +0000
Message-ID: <1328722042.3234.13.camel@lade.trondhjem.org>
References: <1328576237-7362-1-git-send-email-Trond.Myklebust@netapp.com>
	 <20120208162322.GA13315@fieldses.org>
In-Reply-To: <20120208162322.GA13315@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTAyLTA4IGF0IDExOjIzIC0wNTAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIE1vbiwgRmViIDA2LCAyMDEyIGF0IDA3OjU3OjE2UE0gLTA1MDAsIFRyb25kIE15a2xl
YnVzdCB3cm90ZToNCj4gPiBJdCBpcyBwZXJmZWN0bHkgbGVnYWwgdG8gbmVnb3RpYXRlIHVwIHRv
IDJeMzItMSBzbG90cyBpbiB0aGUgcHJvdG9jb2wsDQo+ID4gYW5kIHdpdGggMTBHaWdFLCB3ZSBh
cmUgYWxyZWFkeSBzZWVpbmcgdGhhdCAyNTUgc2xvdHMgaXMgZmFyIHRvbyBsaW1pdGluZy4NCj4g
DQo+IFNlZW1zIGxpa2UgYW4gZW50aXJlbHkgcmVhc29uYWJsZSBjaGFuZ2UsIGJ1dCBqdXN0IG91
dCBvZiBjdXJpb3NpdHksDQo+IHdoYXQgd29ya2xvYWQgYXJlIHlvdSB1c2luZyB0byBoaXQgdGhh
dCBsaW1pdD8NCj4gDQo+IChJZiBpdCdzIGp1c3QgYnVsayBJTyBvdmVyIGEgbG9jYWwgMTBHaWdF
IG5ldHdvcmssIHRoZW4gc3VyZWx5IHRoZQ0KPiBwcm9ibGVtIGlzIGVsc2V3aGVyZT8gIEV2ZW4g
b24gMTBHaWdFIEkgdGhpbmsgeW91J2QgbmVlZCBmYWlybHkgaGlnaA0KPiBsYXRlbmNpZXMgKGEg
bGl0dGxlIG92ZXIgMjAwbXMsIGlmIG15IG1hdGggaXMgcmlnaHQ/KSB0byBrZWVwIHRoYXQgbXVj
aA0KPiBkYXRhIGluIGZsaWdodC4gIE9yIGFyZSB5b3UgdGVzdGluZyBtdWNoIHNtYWxsZXIgb3Bl
cmF0aW9ucz8pDQoNCjEwR2lnRSArIGhpZ2ggbGF0ZW5jaWVzIGlzIGV4YWN0bHkgd2hlcmUgd2Un
cmUgc2VlaW5nIHRoZSB2YWx1ZS4gQW5keQ0KaGFzIGJlZW4gd29ya2luZyB3aXRoIHRoZSBoaWdo
IGVuZXJneSBwaHlzaWNzIGNvbW11bml0eSBkb2luZyBORlMNCnRyYWZmaWMgYmV0d2VlbiB0aGUg
VVMgYW5kIENFUk4uLi4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQg
bWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0
YXBwLmNvbQ0KDQo=
