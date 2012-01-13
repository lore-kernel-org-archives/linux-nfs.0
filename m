Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mexforward.lss.emc.com ([128.222.32.20]:19163 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752817Ab2AMCik (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2012 21:38:40 -0500
From: <tao.peng@emc.com>
To: <Trond.Myklebust@netapp.com>, <bergwolf@gmail.com>
CC: <linux-nfs@vger.kernel.org>, <mdw@umich.edu>, <honey@citi.umich.edu>,
        <bhalevy@tonian.com>
Date: Thu, 12 Jan 2012 21:38:02 -0500
Subject: RE: [PATCH-v2 1/9] pnfsblock: cleanup bl_mark_sectors_init
Message-ID: <F19688880B763E40B28B2B462677FBF805E7E6820C@MX09A.corp.emc.com>
References: <1326381528-2232-1-git-send-email-bergwolf@gmail.com>
	 <1326381528-2232-2-git-send-email-bergwolf@gmail.com>
 <1326404671.10529.0.camel@lade.trondhjem.org>
In-Reply-To: <1326404671.10529.0.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBUcm9uZCBNeWtsZWJ1c3QgW21h
aWx0bzpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbV0NCj4gU2VudDogRnJpZGF5LCBKYW51YXJ5
IDEzLCAyMDEyIDU6NDUgQU0NCj4gVG86IFBlbmcgVGFvDQo+IENjOiBsaW51eC1uZnNAdmdlci5r
ZXJuZWwub3JnOyBtZHdAdW1pY2guZWR1OyBob25leUBjaXRpLnVtaWNoLmVkdTsgUGVuZywgVGFv
OyBCZW5ueSBIYWxldnkNCj4gU3ViamVjdDogUmU6IFtQQVRDSC12MiAxLzldIHBuZnNibG9jazog
Y2xlYW51cCBibF9tYXJrX3NlY3RvcnNfaW5pdA0KPiANCj4gT24gVGh1LCAyMDEyLTAxLTEyIGF0
IDIzOjE4ICswODAwLCBQZW5nIFRhbyB3cm90ZToNCj4gPiBJdCBkb2VzIG5vdCBuZWVkIHRvIG1h
bmlwdWxhdGUgb24gcGFydGlhbCBpbml0aWFsaXplZCBibG9ja3MuDQo+ID4gV3JpdGViYWNrIGNv
ZGUgdGFrZXMgY2FyZSBvZiBpdC4NCj4gDQo+IEFzIHRoZSBzdWJqZWN0IHN0YXRlcywgdGhpcyBs
b29rcyBtb3JlIGxpa2UgYSBjbGVhbnVwIHRoYW4gYSBidWdmaXgsIHNvDQo+IEknbSBkZWZlcnJp
bmcgaXQgdG8gMy40Lg0KPiANClNvdW5kcyBnb29kIHRvIG1lLg0KDQpUaGFua3MsDQpUYW8NCg0K
