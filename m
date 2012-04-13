Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:3588 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324Ab2DMPwp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Apr 2012 11:52:45 -0400
Received: from vmwexceht05-prd.hq.netapp.com (vmwexceht05-prd.hq.netapp.com [10.106.77.35])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q3DFqjlA027665
	for <linux-nfs@vger.kernel.org>; Fri, 13 Apr 2012 08:52:45 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Isaman, Fred" <Fred.Isaman@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 11/26] NFS: put open context on error in nfs_flush_multi
Date: Fri, 13 Apr 2012 15:52:44 +0000
Message-ID: <1334332364.25130.18.camel@lade.trondhjem.org>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
	 <1334004744-31842-12-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334004744-31842-12-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA0LTA5IGF0IDE2OjUyIC0wNDAwLCBGcmVkIElzYW1hbiB3cm90ZToNCj4g
U2lnbmVkLW9mZi1ieTogRnJlZCBJc2FtYW4gPGlpc2FtYW5AbmV0YXBwLmNvbT4NCj4gLS0tDQo+
ICBmcy9uZnMvd3JpdGUuYyB8ICAgIDIgKy0NCj4gIDEgZmlsZXMgY2hhbmdlZCwgMSBpbnNlcnRp
b25zKCspLCAxIGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2ZzL25mcy93cml0ZS5j
IGIvZnMvbmZzL3dyaXRlLmMNCj4gaW5kZXggMmVkOTNiOC4uNzY3MzVkZCAxMDA2NDQNCj4gLS0t
IGEvZnMvbmZzL3dyaXRlLmMNCj4gKysrIGIvZnMvbmZzL3dyaXRlLmMNCj4gQEAgLTEwMTgsNyAr
MTAxOCw3IEBAIG91dF9iYWQ6DQo+ICAJd2hpbGUgKCFsaXN0X2VtcHR5KHJlcykpIHsNCj4gIAkJ
ZGF0YSA9IGxpc3RfZW50cnkocmVzLT5uZXh0LCBzdHJ1Y3QgbmZzX3dyaXRlX2RhdGEsIGxpc3Qp
Ow0KPiAgCQlsaXN0X2RlbCgmZGF0YS0+bGlzdCk7DQo+IC0JCW5mc193cml0ZWRhdGFfZnJlZShk
YXRhKTsNCj4gKwkJbmZzX3dyaXRlZGF0YV9yZWxlYXNlKGRhdGEpOw0KPiAgCX0NCj4gIAluZnNf
cmVkaXJ0eV9yZXF1ZXN0KHJlcSk7DQo+ICAJcmV0dXJuIC1FTk9NRU07DQoNClN0YWJsZSBjYW5k
aWRhdGU/DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWlu
ZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20N
Cg0K
