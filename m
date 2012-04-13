Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:17901 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324Ab2DMPw0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Apr 2012 11:52:26 -0400
Received: from vmwexceht04-prd.hq.netapp.com (vmwexceht04-prd.hq.netapp.com [10.106.77.34])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q3DFqPQD011464
	for <linux-nfs@vger.kernel.org>; Fri, 13 Apr 2012 08:52:26 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Isaman, Fred" <Fred.Isaman@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/26] NFS: put open context on error in nfs_pagein_multi
Date: Fri, 13 Apr 2012 15:52:24 +0000
Message-ID: <1334332344.25130.17.camel@lade.trondhjem.org>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
	 <1334004744-31842-11-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334004744-31842-11-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA0LTA5IGF0IDE2OjUyIC0wNDAwLCBGcmVkIElzYW1hbiB3cm90ZToNCj4g
U2lnbmVkLW9mZi1ieTogRnJlZCBJc2FtYW4gPGlpc2FtYW5AbmV0YXBwLmNvbT4NCj4gLS0tDQo+
ICBmcy9uZnMvcmVhZC5jIHwgICAgMiArLQ0KPiAgMSBmaWxlcyBjaGFuZ2VkLCAxIGluc2VydGlv
bnMoKyksIDEgZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZnMvbmZzL3JlYWQuYyBi
L2ZzL25mcy9yZWFkLmMNCj4gaW5kZXggZTFkYjA0YS4uNGRkYmE2NyAxMDA2NDQNCj4gLS0tIGEv
ZnMvbmZzL3JlYWQuYw0KPiArKysgYi9mcy9uZnMvcmVhZC5jDQo+IEBAIC0zMjMsNyArMzIzLDcg
QEAgb3V0X2JhZDoNCj4gIAl3aGlsZSAoIWxpc3RfZW1wdHkocmVzKSkgew0KPiAgCQlkYXRhID0g
bGlzdF9lbnRyeShyZXMtPm5leHQsIHN0cnVjdCBuZnNfcmVhZF9kYXRhLCBsaXN0KTsNCj4gIAkJ
bGlzdF9kZWwoJmRhdGEtPmxpc3QpOw0KPiAtCQluZnNfcmVhZGRhdGFfZnJlZShkYXRhKTsNCj4g
KwkJbmZzX3JlYWRkYXRhX3JlbGVhc2UoZGF0YSk7DQo+ICAJfQ0KPiAgCW5mc19yZWFkcGFnZV9y
ZWxlYXNlKHJlcSk7DQo+ICAJcmV0dXJuIC1FTk9NRU07DQoNClNob3VsZCB0aGlzIGJlIGEgc3Rh
YmxlIHRyZWUgY2FuZGlkYXRlPw0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNs
aWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3
dy5uZXRhcHAuY29tDQoNCg==
