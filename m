Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38971 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752634Ab2E1Ro0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 May 2012 13:44:26 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Peng Tao <tao.peng@emc.com>
CC: Boaz Harrosh <bharrosh@panasas.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFS41: add pnfs_dio_begin/dio_end
Date: Mon, 28 May 2012 17:44:24 +0000
Message-ID: <1338227064.3472.19.camel@lade.trondhjem.org>
References: <1338096780-2763-1-git-send-email-bergwolf@gmail.com>
	 <1338096780-2763-2-git-send-email-bergwolf@gmail.com>
	 <1338136170.3044.7.camel@lade.trondhjem.org>
	 <F19688880B763E40B28B2B462677FBF805F0BADF35@MX09A.corp.emc.com>
	 <1338176574.2265.7.camel@lade.trondhjem.org>
	 <F19688880B763E40B28B2B462677FBF805F0BADF5C@MX09A.corp.emc.com>
	 <4FC356FA.2070008@panasas.com> <4FC358CA.2090301@panasas.com>
	 <CA+a=Yy5c2wCMvOnOSh2y+tHShmR6bnOtMWhoQPPRmkv_q-4D9w@mail.gmail.com>
	 <4FC3B4D7.9080000@panasas.com>
	 <CA+a=Yy4=SFWFce=SitUZd-=9VYAdt9QTZm7N6=ANhqix==--JA@mail.gmail.com>
In-Reply-To: <CA+a=Yy4=SFWFce=SitUZd-=9VYAdt9QTZm7N6=ANhqix==--JA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA1LTI5IGF0IDAxOjM2ICswODAwLCBQZW5nIFRhbyB3cm90ZToNCj4gT24g
VHVlLCBNYXkgMjksIDIwMTIgYXQgMToyNCBBTSwgQm9heiBIYXJyb3NoIDxiaGFycm9zaEBwYW5h
c2FzLmNvbT4gd3JvdGU6DQo+ID4gT24gMDUvMjgvMjAxMiAwODoxNCBQTSwgUGVuZyBUYW8gd3Jv
dGU6DQo+ID4gRG9uJ3QgYWRkIG5ldyBwYXJhbWV0ZXJzIHRvIHRoZSBmdW5jdGlvbnMuIEFkZCBu
ZXcgZmllbGRzIHRvIHRoZSBwYXNzZWQNCj4gPiBzdHJ1Y3R1cmVzLg0KPiA+DQo+IEdvdCBpdC4N
Cg0KVGhlIG90aGVyIHRoaW5nIGlzIHRoYXQgc2luY2Ugc3RydWN0IG5mc19wYWdlaW9fZGVzY3Jp
cHRvciBpcyBhbGxvY2F0ZWQNCm9uIHRoZSBzdGFjaywgbGV0J3MgcGxlYXNlIG5vdCBncm93IGl0
IHRvbyBtdWNoIGZ1cnRoZXIuIElmIHlvdSBuZWVkIHRvDQphZGQgc3RydWN0dXJlcyB0aGF0IGFy
ZSBwcml2YXRlIHRvIHlvdXIgbGF5b3V0IGRyaXZlciwgdGhlbiBwbGVhc2UNCmFsbG9jYXRlIHRo
b3NlIHN0cnVjdHVyZXMgZHluYW1pY2FsbHksIGFuZCB1c2UgYSB2b2lkICpwZ19sYXlvdXRfcHJp
dmF0ZQ0KdG8gcG9pbnQgdG8gdGhlbS4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5G
UyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29t
DQp3d3cubmV0YXBwLmNvbQ0KDQo=
