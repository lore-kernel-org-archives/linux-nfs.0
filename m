Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:17808 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752651Ab2HHSuW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Aug 2012 14:50:22 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
CC: "bharrosh@panasas.com" <bharrosh@panasas.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Peng Tao <tao.peng@emc.com>
Subject: Re: [PATCH RFC 2/3] NFS41: send real write size in layoutget
Date: Wed, 8 Aug 2012 18:50:20 +0000
Message-ID: <1344451818.8925.27.camel@lade.trondhjem.org>
References: <1344391392-1948-1-git-send-email-bergwolf@gmail.com>
	 <1344391392-1948-3-git-send-email-bergwolf@gmail.com>
In-Reply-To: <1344391392-1948-3-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTA4LTA4IGF0IDEwOjAzICswODAwLCBQZW5nIFRhbyB3cm90ZToNCj4gRnJv
bTogUGVuZyBUYW8gPHRhby5wZW5nQGVtYy5jb20+DQo+IA0KPiBGb3IgYnVmZmVycmVkIHdyaXRl
LCBzY2FuIGRpcnR5IHBhZ2VzIHRvIGZpbmQgb3V0IGxvbmdlc3QgY29udGludW91cw0KPiBkaXJ0
eSBwYWdlcy4gSW4gdGhpcyBjYXNlLCBhbHNvIGFsbG93IGxheW91dCBkcml2ZXIgdG8gc3BlY2lm
eSBhDQo+IG1heGltdW0gbGF5b3V0Z2V0IHNpemUgd2hpY2ggaXMgdXNlZnVsIHRvIGF2b2lkIGJ1
c3kgc2Nhbm5pbmcgZGlydHkgcGFnZXMNCj4gZm9yIGJsb2NrIGxheW91dCBjbGllbnQuDQoNClRo
aXMgaXMgX3JlYWxseV8gdWdseSwgYW5kIGlzIGEgc291cmNlIG9mIHBvdGVudGlhbCBkZWFkbG9j
a3MgaWYNCm11bHRpcGxlIHRocmVhZHMgYXJlIHNjYW5uaW5nK2xvY2tpbmcgcGFnZXMgYXQgdGhl
IHNhbWUgdGltZS4NCg0KV2h5IG5vdCBzaW1wbGlmeSB0aGlzIGJ5IGRyb3BwaW5nIHRoZSBjb21w
bGljYXRlZCB0ZXN0cyBmb3Igd2hldGhlciBvcg0Kbm90IHRoZSBwYWdlcyBhcmUgZGlydHk/IFRo
YXQgZ2V0cyByaWQgb2YgdGhlIGRlYWRsb2NrLXByb25lIGxvY2tfcGFnZSgpDQpjYWxscywgYW5k
IHdvdWxkIGVuYWJsZSB5b3UgdG8ganVzdCB1c2UgcmFkaXhfdHJlZV9uZXh0X2hvbGUoKS4NCg0K
PiBGb3IgZGlyZWN0IHdyaXRlLCBqdXN0IHVzZSBkcmVxLT5ieXRlc19sZWZ0Lg0KDQpUaGlzIG1h
a2VzIHNlbnNlLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWlu
dGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAu
Y29tDQoNCg==
