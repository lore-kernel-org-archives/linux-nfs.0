Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr720096.outbound.protection.outlook.com ([40.107.72.96]:56576
        "EHLO NAM05-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727553AbeGSUab (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Jul 2018 16:30:31 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "sargun@sargun.me" <sargun@sargun.me>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
CC: "kinglongmee@gmail.com" <kinglongmee@gmail.com>,
        "Anna.Schumaker@Netapp.com" <Anna.Schumaker@Netapp.com>,
        "ebiederm@xmission.com" <ebiederm@xmission.com>
Subject: Re: [PATCH] net/sunrpc: Add user namespace support
Date: Thu, 19 Jul 2018 19:45:50 +0000
Message-ID: <e3988e150b5737e13f8b05ab25fd3ed3e5d42c14.camel@hammerspace.com>
References: <20180719174246.GA19824@ircssh-2.c.rugged-nimbus-611.internal>
In-Reply-To: <20180719174246.GA19824@ircssh-2.c.rugged-nimbus-611.internal>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE4LTA3LTE5IGF0IDE3OjQyICswMDAwLCBTYXJndW4gRGhpbGxvbiB3cm90ZToN
Cj4gVGhpcyBhZGRzIHRoZSBhYmlsaXR5IHRvIHBhc3MgYSBub24taW5pdCB1c2VyIG5hbWVzcGFj
ZSB0bw0KPiBycGNhdXRoX2NyZWF0ZSwNCj4gdmlhIHJwY19hdXRoX2NyZWF0ZV9hcmdzLiBJZiB0
aGUgc3BlY2lmaWMgYXV0aGVudGljYXRpb24gbWVjaGFuaXNtDQo+IGRvZXMgbm90IHN1cHBvcnQg
bm9uLWluaXQgdXNlciBuYW1lc3BhY2VzLCB0aGVuIGl0IHdpbGwgcmV0dXJuIGFuDQo+IGVycm9y
Lg0KPiANCj4gQ3VycmVudGx5LCB0aGUgb25seSB0d28gYXV0aGVudGljYXRpb24gbWVjaGFuaXNt
cyB0aGF0IHN1cHBvcnQNCj4gbm9uLWluaXQgdXNlciBuYW1lc3BhY2VzIGFyZSBhdXRoX251bGws
IGFuZCBhdXRoX3VuaXguIGF1dGhfdW5peA0KPiB3aWxsIHNlbmQgdGhlIFVJRCAvIEdJRCBmcm9t
IHRoZSB1c2VyIG5hbWVzcGFjZSBmb3IgYXV0aGVudGljYXRpb24uDQo+IA0KDQpGaXJzdGx5LCBw
bGVhc2UgYXQgbGVhc3QgQ2MgdGhlIGxpbnV4LW5mcyBtYWlsaW5nIGxpc3QgKGFzIHBlciB0aGUN
Ck1BSU5UQUlORVJTIGZpbGUpIHdoZW4gY2hhbmdpbmcgTkZTIGFuZCBzdW5ycGMgY29kZS4NCg0K
U2Vjb25kbHksIGNhbiB5b3UgcGxlYXNlIGV4cGxhaW4gd2h5IHdlIHdvdWxkIHdhbnQgdG8gdXNl
IGFueSB1c2VyDQpuYW1lc3BhY2Ugb3RoZXIgdGhhbiB0aGUgb25lIHNwZWNpZmllZCBpbiB0aGUg
bmV0IG5hbWVzcGFjZSBzdHJ1Y3R1cmUNCihzdHJ1Y3QgbmV0KSB3aGVuIGNvbW11bmljYXRpbmcg
d2l0aCBuZXR3b3JrIHJlc291cmNlcyBzdWNoIGFzDQpycGMuZ3NzZCwgdGhlIGlkbWFwcGVyIG9y
LCBmb3IgdGhhdCBtYXR0ZXIsIHRoZSBORlMgc2VydmVyPw0KDQpUaGFua3MNCiAgVHJvbmQNCi0t
IA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNw
YWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg==
