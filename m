From: "Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
Subject: RE: [PATCH 1/1] nfs: fix race between renewd, umount, and the state manager in V4.1
Date: Fri, 22 Jan 2010 12:24:53 -0800
Message-ID: <B9364369CA66BF45806C2CD86EAB8BA604F355A6@SACMVEXC3-PRD.hq.netapp.com>
References: <1264135871-13083-1-git-send-email-batsakis@netapp.com> <1264186039.30757.7.camel@localhost> <B9364369CA66BF45806C2CD86EAB8BA604F35537@SACMVEXC3-PRD.hq.netapp.com> <1264189298.30757.16.camel@localhost> <B9364369CA66BF45806C2CD86EAB8BA604F35581@SACMVEXC3-PRD.hq.netapp.com> <1264191084.30757.28.camel@localhost> <1264191680.30757.33.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Cc: <linux-nfs@vger.kernel.org>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62591 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933Ab0AVUYz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jan 2010 15:24:55 -0500
In-Reply-To: <1264191680.30757.33.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogVHJvbmQgTXlrbGVidXN0
IFttYWlsdG86dHJvbmQubXlrbGVidXN0QGZ5cy51aW8ubm9dDQo+IFNlbnQ6IEZyaWRheSwgSmFu
dWFyeSAyMiwgMjAxMCAxMjoyMSBQTQ0KPiBUbzogQmF0c2FraXMsIEFsZXhhbmRyb3MNCj4gQ2M6
IGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogUkU6IFtQQVRDSCAxLzFdIG5m
czogZml4IHJhY2UgYmV0d2VlbiByZW5ld2QsIHVtb3VudCwgYW5kIHRoZQ0KPiBzdGF0ZSBtYW5h
Z2VyIGluIFY0LjENCj4gDQo+IE9uIEZyaSwgMjAxMC0wMS0yMiBhdCAxNToxMSAtMDUwMCwgVHJv
bmQgTXlrbGVidXN0IHdyb3RlOg0KPiA+IFRoZW4gdGhlIGNvcnJlY3QgdGhpbmcgdG8gZG8gaXMg
dG8gZml4IHRoZSByZW5ld2Qga2lsbCBwcm9jZXNzLiBPbmNlDQo+ID4gdGhhdCBpcyBkb25lLCB0
aGVyZSBzaG91bGQgYmUgbm8gcmVhc29uIGZvciBhbnkgc2VxdWVuY2VfZG9uZSBjYWxscw0KPiB0
bw0KPiA+IGJlIHBlbmRpbmcgKHNlZSByZWFzb24gYWJvdmUpLg0KPiANCj4gSU9XOiB3ZSBzaG91
bGQgYWRkIGEgY2FsbCB0byBhdG9taWNfaW5jX25vdF96ZXJvKCZjbHAtPmNsX2NvdW50KSBpbg0K
PiBuZnM0X3Byb2NfYXN5bmNfcmVuZXcoKS9uZnM0MV9wcm9jX2FzeW5jX3NlcXVlbmNlKCksIGFu
ZCBoYXZlIHRoZW0gZmFpbA0KPiBpZiB0aGF0IGF0dGVtcHQgdG8gZ3JhYiBhIHJlZmVyZW5jZSBm
YWlscy4gVGhlbiB3ZSBzaG91bGQgYWRkIGEgY2FsbCB0bw0KPiBuZnNfcHV0X2NsaWVudCgpIGlu
IHRoZWlyIC5ycGNfcmVsZWFzZSBtZXRob2QuDQo+IA0KPiBUcm9uZA0KDQpHb3QgaXQuLi53aWxs
IGRvLiBUaGFua3MhDQoNCi1hDQo=
