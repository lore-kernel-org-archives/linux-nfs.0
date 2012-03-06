Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61192 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754275Ab2CFQdU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 11:33:20 -0500
Received: from vmwexceht05-prd.hq.netapp.com (vmwexceht05-prd.hq.netapp.com [10.106.77.35])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q26GXKEw013707
	for <linux-nfs@vger.kernel.org>; Tue, 6 Mar 2012 08:33:20 -0800 (PST)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] NFS: Properly handle the case where the delegation
 is revoked
Date: Tue, 6 Mar 2012 16:33:19 +0000
Message-ID: <1331051598.3260.26.camel@lade.trondhjem.org>
References: <1331046186-5638-1-git-send-email-Trond.Myklebust@netapp.com>
	 <E67CE84F-776D-42C2-8939-8FABEA44D360@netapp.com>
In-Reply-To: <E67CE84F-776D-42C2-8939-8FABEA44D360@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTAzLTA2IGF0IDE2OjI0ICswMDAwLCBBZGFtc29uLCBBbmR5IHdyb3RlOg0K
PiBXaXRoICAiTkZTOiBQcm9wZXJseSBoYW5kbGUgdGhlIGNhc2Ugd2hlcmUgdGhlIGRlbGVnYXRp
b24gaXMgcmV2b2tlZCIgcGF0Y2ggYWRkZWQgdG8gVHJvbmQncyBvcmlnaW4vdGVzdGlnbiBicmFu
Y2gsICBteSBweXRob24gdGVzdCB0aGF0IHJlbW92ZXMgdGhlIChkZWxlZ2F0aW9uKSBzdGF0ZWlk
IG9uIGEgUkVBRCwgYW5kIHJldHVybnMgTkZTNEVSUl9CQURfU1RBVEVJRCBwYXNzZXMgYXMgdGhl
IGNsaWVudCByZWNvdmVycyBieSB0ZXN0aW5nIGFuZCBmcmVlaW5nIHRoZSBzdGF0ZWlkLCBhbmQg
dGhlbiBzZW5kaW5nIGFuIE9QRU4gd2l0aCBhIENMQUlNX05VTEwuDQo+IA0KPiAtLT5BbmR5DQo+
IA0KPiANCj4gQlRXOiB0aGlzIHBhdGNoIGNsZWFucyB1cCBzb21lIHN0YXRlaWQgY29tcGFyZXMg
YW5kIHRoZSBzZWNvbmQgY2h1bmsgaXMgbmVlZGVkIGZvciB0aGUgb3JpZ2luL3Rlc3RpbmcgYnJh
bmNoIHRvIGNvbXBpbGUuICBZb3UndmUgcHJvYmFibHkgYWxyZWFkeSBmb3VuZCB0aGlz4oCmLi4N
Cg0KWWVzLiBJbiBvcmRlciB0byBtYWtlIHRoZSBwYXRjaCBhcHBseSB0byB0aGUgc3RhYmxlIGtl
cm5lbHMsIEkgYWN0dWFsbHkNCmluc2VydGVkIGl0IGJlZm9yZSB0aGUgc3RhdGVpZCBjaGFuZ2Vz
IGluIHRoZSAnZGV2ZWwnIGJyYW5jaCwgYW5kIHRoZW4NCmZpeGVkIHRoZSBzdGF0ZWlkIHBhdGNo
ZXMgdXAgaW5zdGVhZC4gVGhlIGN1cnJlbnQgJ3Rlc3RpbmcnIGJyYW5jaA0Kc2hvdWxkIGhhdmUg
YSB3b3JraW5nIHZlcnNpb24gb2YgYm90aC4NCg0KQlRXOiB3aXRoIHRoaXMgcGF0Y2gsIHRoZSAi
TkZTdjQuMTogRml4IHRoZSBjaGVja2luZyBvZiB0aGUgc3RhdGVpZCB3aGVuDQpyZXR1cm5pbmcg
YSBkZWxlZ2F0aW9uIiBpcyBub3QgbmVlZGVkIGFzIGEgc3RhYmxlIGZpeCwgc2luY2Ugd2Ugbm8N
CmxvbmdlciB1c2UgbmZzX2FzeW5jX2lub2RlX3JldHVybl9kZWxlZ2F0aW9uKCkgaW4gc3RhdGUg
cmVjb3Zlcnkgc28gSSd2ZQ0KcmVtb3ZlZCB0aGUgQ2M6IHN0YWJsZSBmcm9tIHRoYXQgcGF0Y2gu
DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0K
TmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
