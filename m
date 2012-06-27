Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61305 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755655Ab2F0T4l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jun 2012 15:56:41 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Harshula <harshula@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: rpciod process is blocked in nfs_release_page waiting for
 nfs_commit_inode to complete
Date: Wed, 27 Jun 2012 19:56:38 +0000
Message-ID: <1340826996.2398.15.camel@lade.trondhjem.org>
References: <1339764850.30233.11.camel@serendib>
	 <20120615092103.15cc2b11@corrin.poochiereds.net>
	 <1339795503.16363.9.camel@lade.trondhjem.org>
	 <20120627115447.0fdf8c6e@corrin.poochiereds.net>
	 <1340822635.2398.7.camel@lade.trondhjem.org>
	 <20120627152814.4774048b@tlielax.poochiereds.net>
In-Reply-To: <20120627152814.4774048b@tlielax.poochiereds.net>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTA2LTI3IGF0IDE1OjI4IC0wNDAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4g
T24gV2VkLCAyNyBKdW4gMjAxMiAxODo0Mzo1NiArMDAwMA0KPiAiTXlrbGVidXN0LCBUcm9uZCIg
PFRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tPiB3cm90ZToNCj4gSWYgdGhlcmUgcmVhbGx5IGlz
IG5vIGFsdGVybmF0aXZlIHRvIGZyZWVpbmcgdGhlIHNvY2tldCwgdGhlbiB0aGUgb25seQ0KPiBy
ZWFsIGZpeCBJIGNhbiBzZWUgaXMgdG8gc2V0IFBGX01FTUFMTE9DIHdoZW4gd2UgZ28gdG8gY3Jl
YXRlIGl0IGFuZA0KPiB0aGVuIHJlc2V0IGl0IGFmdGVyd2FyZC4gVGhhdCdzIGEgcHJldHR5IHVn
bHkgZml4IHRob3VnaC4uLg0KDQpJIGNhbiB0aGluayBvZiAyIHBvc3NpYmxlIGFsdGVybmF0aXZl
czoNCg0KICAgICAxLiBVc2UgdGhlIFBGX0ZTVFJBTlMgZmxhZyB0byB0ZWxsIG5mc19yZWxlYXNl
X3BhZ2UgdGhhdCB0aGlzIGlzIGENCiAgICAgICAgZGlyZWN0IHJlY2xhaW0gZnJvbSBycGNpb2Qu
DQogICAgIDIuIEFkZCBhICdjb25nZXN0ZWQnIGZsYWcgdG8gdGhlIHJwYyBjbGllbnQgdGhhdCBj
b3VsZCB0ZWxsIHJlY2xhaW0NCiAgICAgICAgdHlwZSBvcGVyYXRpb25zIHRvIGdpdmUgdXAgaWYg
YSBzb2NrZXQgYWxsb2NhdGlvbiBpcyBpbg0KICAgICAgICBwcm9ncmVzcy4NCg0KLS0gDQpUcm9u
ZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25k
Lk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
