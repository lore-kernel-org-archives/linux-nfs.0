Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:27124 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030428AbaDJREQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 13:04:16 -0400
From: Allen Andrews <Allen.Andrews@Emulex.Com>
To: Or Gerlitz <ogerlitz@mellanox.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH] nfs-rdma: Fix for FMR leaks
Date: Thu, 10 Apr 2014 17:04:14 +0000
Message-ID: <A1EC1DB6D8AEAF4CB8006B3653F61C5438341E9F@CMEXMB1.ad.emulex.com>
References: <nyc61n00p3VzoHe01yc7ug>
 <002e01cf5444$a58c2c10$f0a48430$@cox.net> <53464E88.4000309@mellanox.com>
In-Reply-To: <53464E88.4000309@mellanox.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

R290IGl0LiBUaGFua3MuDQoNCg0KPiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9t
OiBsaW51eC1uZnMtb3duZXJAdmdlci5rZXJuZWwub3JnIFttYWlsdG86bGludXgtbmZzLQ0KPiBv
d25lckB2Z2VyLmtlcm5lbC5vcmddIE9uIEJlaGFsZiBPZiBPciBHZXJsaXR6DQo+IFNlbnQ6IFRo
dXJzZGF5LCBBcHJpbCAxMCwgMjAxNCAxMjo1NiBBTQ0KPiBUbzogQWxsZW4gQW5kcmV3cw0KPiBD
YzogdHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbTsgbGludXgtbmZzQHZnZXIua2VybmVs
Lm9yZw0KPiBTdWJqZWN0OiBSZTogW1BBVENIXSBuZnMtcmRtYTogRml4IGZvciBGTVIgbGVha3MN
Cj4gDQo+IE9uIDEwLzA0LzIwMTQgMDE6NDAsIEFsbGVuIEFuZHJld3Mgd3JvdGU6DQo+ID4gVHdv
IG1lbW9yeSByZWdpb24gbGVha3MgaXdlcmUgZm91bmQgZHVyaW5nIHRlc3Rpbmc6DQo+IHMvaXdl
cmUvd2VyZS8NCj4gDQo+IC0tDQo+IFRvIHVuc3Vic2NyaWJlIGZyb20gdGhpcyBsaXN0OiBzZW5k
IHRoZSBsaW5lICJ1bnN1YnNjcmliZSBsaW51eC1uZnMiIGluIHRoZSBib2R5DQo+IG9mIGEgbWVz
c2FnZSB0byBtYWpvcmRvbW9Admdlci5rZXJuZWwub3JnIE1vcmUgbWFqb3Jkb21vIGluZm8gYXQN
Cj4gaHR0cDovL3ZnZXIua2VybmVsLm9yZy9tYWpvcmRvbW8taW5mby5odG1sDQo=
