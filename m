Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30375 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751880Ab2CKWOq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Mar 2012 18:14:46 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Kevin Coffman <kwc@citi.umich.edu>,
        Dr James Bruce Fields <bfields@fieldses.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Bug in gss_krb5_crypto.c
Date: Sun, 11 Mar 2012 22:14:44 +0000
Message-ID: <1331504084.2792.7.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SGkgS2V2aW4gJiBCcnVjZSwNCg0KV2hlbiBydW5uaW5nIHNwYXJzZSBvbiB0aGUgc3VucnBjIGNv
ZGUsIEknbSBzZWVpbmcgdGhlIGZvbGxvd2luZyBlcnJvcg0KbWVzc2FnZToNCiJuZXQvc3VucnBj
L2F1dGhfZ3NzL2dzc19rcmI1X2NyeXB0by5jOjYwMzo1MjogZXJyb3I6IGJhZCBjb25zdGFudA0K
ZXhwcmVzc2lvbiINCg0KVGhpcyBib2lscyBkb3duIHRvIHRoZSBsaW5lOg0KICAgICAgICB1OCBk
YXRhW2NyeXB0b19ibGtjaXBoZXJfYmxvY2tzaXplKGNpcGhlcikgKiAyXTsNCg0Kd2hpY2ggaXMg
dXNpbmcgYSBHTlUgQ2MtaXNtIGluIG9yZGVyIHRvIGRvIGR5bmFtaWMgYWxsb2NhdGlvbiBvbiB0
aGUNCnN0YWNrLiBUaGlzIGlzIG5vdCBhY2NlcHRhYmxlIGluIGtlcm5lbCBjb2RlLCBhbmQgcmVh
bGx5IG5lZWRzIHRvIGJlDQpjaGFuZ2VkLiBIb3cgc2hvdWxkIHdlIG1vdmUgZm9yd2FyZCB3aXRo
IHRoaXM/IElzIHRoZXJlIGFuIHVwcGVyIGxpbWl0DQpvbiB0aGUgdmFsdWUgb2YgY3J5cHRvX2Js
a2NpcGhlcl9ibG9ja3NpemUoY2lwaGVyKSB0aGF0IHdlIGNhbiB1c2U/DQoNCkNoZWVycw0KICBU
cm9uZA0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVy
DQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoN
Cg==
