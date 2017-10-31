Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:39820 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753934AbdJaUMM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Oct 2017 16:12:12 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "aweits@rit.edu" <aweits@rit.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: deal with revoked delegations appropriately
Date: Tue, 31 Oct 2017 20:12:06 +0000
Message-ID: <1509480724.45082.0.camel@primarydata.com>
References: <20171031192238.6906-1-aweits@rit.edu>
In-Reply-To: <20171031192238.6906-1-aweits@rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE3LTEwLTMxIGF0IDE1OjIyIC0wNDAwLCBBbmRyZXcgRWxibGUgd3JvdGU6DQo+
IElmIGEgZGVsZWdhdGlvbiBoYXMgYmVlbiByZXZva2VkIGJ5IHRoZSBzZXJ2ZXIsIG9wZXJhdGlv
bnMgdXNpbmcgdGhhdA0KPiBkZWxlZ2F0aW9uIHNob3VsZCBlcnJvciBvdXQgd2l0aCBORlM0RVJS
X0RFTEVHX1JFVk9LRUQgaW4gdGhlID40LjENCj4gY2FzZSwgYW5kIE5GUzRFUlJfQkFEX1NUQVRF
SUQgb3RoZXJ3aXNlLiBERUxFR1JFVFVSTiBoYXMgYWxzbyBiZWVuDQo+IG9wdGltaXplZCB0byBy
ZXR1cm4gTkZTNF9PSyB3aGVuIGNhbGxlZCB3aXRoIGEgcmV2b2tlZCBkZWxlZ2F0aW9uLg0KPiAN
Cj4gVGhyZWFkIG9uIERFTEVHUkVUVVJOIG9wdGltaXphdGlvbiBpcyBoZXJlOg0KPiBodHRwczov
L3d3dy5zcGluaWNzLm5ldC9saXN0cy9saW51eC1uZnMvbXNnNTUyMTYuaHRtbA0KPiANCj4gU2ln
bmVkLW9mZi1ieTogQW5kcmV3IEVsYmxlIDxhd2VpdHNAcml0LmVkdT4NCj4gDQpQbGVhc2Ugc2Vl
IHRoZSBwYXRjaCBzZXJpZXMgZm9yIGtuZnNkIHRoYXQgSSBwb3N0ZWQgeWVzdGVyZGF5LiBEb2Vz
DQp0aGF0IGZpeCB5b3VyIGlzc3VlPw0KDQpDaGVlcnMNCiAgVHJvbmQNCi0tIA0KVHJvbmQgTXlr
bGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5t
eWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

