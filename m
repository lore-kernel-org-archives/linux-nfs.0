Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4508 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758763Ab2HHPYC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Aug 2012 11:24:02 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs4 mounts failing with 3.6.0-rc1
Date: Wed, 8 Aug 2012 15:24:00 +0000
Message-ID: <1344439438.3423.11.camel@lade.trondhjem.org>
References: <20120804000819.GB25558@fieldses.org>
	   <20120803220039.743fe1f0@corrin.poochiereds.net>
	   <20120804190104.GA2135@fieldses.org>
	   <20120807130932.79625d7e@tlielax.poochiereds.net>
	   <20120807194250.GB22532@fieldses.org> <50217035.5010304@netapp.com>
	   <20120807195703.GC22532@fieldses.org> <50217649.6010402@netapp.com>
	   <20120807202523.GD22532@fieldses.org>
	  <1344374613.8845.3.camel@lade.trondhjem.org> <50227AE9.2020600@netapp.com>
	 <1344438488.3423.9.camel@lade.trondhjem.org> <5022829A.3040209@netapp.com>
In-Reply-To: <5022829A.3040209@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTA4LTA4IGF0IDExOjE1IC0wNDAwLCBCcnlhbiBTY2h1bWFrZXIgd3JvdGU6
DQo+IE9uIDA4LzA4LzIwMTIgMTE6MDggQU0sIE15a2xlYnVzdCwgVHJvbmQgd3JvdGU6DQo+ID4g
T24gV2VkLCAyMDEyLTA4LTA4IGF0IDEwOjQyIC0wNDAwLCBCcnlhbiBTY2h1bWFrZXIgd3JvdGU6
DQo+ID4+IFNvIHlvdSdyZSBzdWdnZXN0aW5nIHNvbWV0aGluZyBsaWtlIHRoaXM/ICBJIGNhbiBz
cGxpdCBpdCBpbnRvIHR3byBwYXRjaGVzIGZvciB0aGUgZmluYWwgc3VibWlzc2lvbiwgb25lIHRv
IHJlbmFtZSB0aGUgbW9kdWxlcyBhbmQgb25lIHRvIG1vdmUgdGhlIG5mczRfZnNfdHlwZSBiYWNr
IHRvIG5mcy5rby4NCj4gPiANCj4gPiBPbmUgcGF0Y2ggc2hvdWxkIHN1ZmZpY2UsIHNpbmNlIHlv
dSBjYW4ndCBzcGxpdCB0aGlzIHVwIGludG8gc29tZXRoaW5nDQo+ID4gdGhhdCBmaXhlcyBib3Ro
IGlzc3Vlcy4NCj4gPiANCj4gPiBUaGVuIG1heWJlIHdlIGNhbiBhZGQgYSBzZXBhcmF0ZSBwYXRj
aCB3aXRoIGEgTU9EVUxFX0FMSUFTKCJuZnM0Iikgc28NCj4gPiB0aGF0IGRpc3Ryb3MgY2FuIHN0
YXJ0IHJlbW92aW5nIHRoZSAvZXRjL21vZHByb2JlLmNvbmYgYWxpYXMgZW50cmllcy4NCj4gDQo+
IFN1cmUuICBUaGF0IGdvZXMgaW4gdGhlIHY0IG1vZHVsZT8NCg0KTm8uIFRoZSBuZnMgbW9kdWxl
LCBzaW5jZSB0aGF0IGlzIHdoYXQgY2FsbHMgcmVnaXN0ZXJfbmZzNF9mcygpLi4uDQoNCi0tIA0K
VHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpU
cm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
