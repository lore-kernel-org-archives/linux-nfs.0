Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819Ab2B0Nos (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Feb 2012 08:44:48 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: fix use-after-free of rpc pipes
Date: Mon, 27 Feb 2012 13:44:45 +0000
Message-ID: <1330350288.5541.3.camel@lade.trondhjem.org>
References: <1330019288-13031-1-git-send-email-iisaman@netapp.com>
		 <4F47D37D.2080409@parallels.com>
	 <1330300376.18817.0.camel@lade.trondhjem.org>
	 <4F4B7C4B.5000901@parallels.com>
In-Reply-To: <4F4B7C4B.5000901@parallels.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTAyLTI3IGF0IDE2OjUxICswNDAwLCBTdGFuaXNsYXYgS2luc2J1cnNreSB3
cm90ZToNCj4gRnJhbmtseSwgSSBkb24ndCBsaWtlIHRoZSBpZGVhIG9mIHB1dCdpbmcgcGlwZSBk
YXRhIG9uIGRlbnRyeSB1bmxpbmsuIElPVywgSSANCj4gZG9uJ3QgbGlrZSB0aGF0IHRoaXMgZGF0
YSB3aWxsIGJlIGNvbnRyb2xsZWQgc29tZWhvdyBpbiBQaXBlRlMuDQo+IEknbGwgc2VuZCBteSB2
ZXJzaW9uIHNvb24uDQo+IA0KDQpJIGRvbid0IHVuZGVyc3RhbmQgdGhhdCBvYmplY3Rpb24uIFRo
ZSBsaWZldGltZSBvZiB0aGF0IGRhdGEgbmVlZHMgdG8gYmUNCmJvdW5kZWQgYnkgdGhlIGxpZmV0
aW1lIG9mIHRoZSBwaXBlIGl0c2VsZiwgd2hpY2ggbWVhbnMgdGhhdCBpdCBfaGFzXyB0bw0KYmUg
Y29udHJvbGxlZCBieSB0aGUgcGlwZWZzLg0KDQpCVFc6IGl0IGlzbid0IGJlaW5nIHB1dCBvbiBk
ZW50cnkgdW5saW5rLiBJdCBpcyBiZWluZyBwdXQgb24gZGVudHJ5DQpfZGVzdHJ1Y3Rpb25fLiBU
aG9zZSBhcmUgdHdvIGRpZmZlcmVudCBldmVudHMgKHdoaWNoIGlzIHdoeSB3ZSBoYXZlIGENCnBy
b2JsZW0gdG9kYXkpLg0KDQpDaGVlcnMNCiAgVHJvbmQNCg==
