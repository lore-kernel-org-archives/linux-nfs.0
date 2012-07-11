Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:46801 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754740Ab2GKRtL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jul 2012 13:49:11 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Simo Sorce <simo@redhat.com>, "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism for
 nfsd
Date: Wed, 11 Jul 2012 17:49:09 +0000
Message-ID: <1342028948.25375.45.camel@lade.trondhjem.org>
References: <1337983796-26476-1-git-send-email-simo@redhat.com>
	 <20120710204913.GA6038@fieldses.org>
	 <1341957169.17428.4.camel@lade.trondhjem.org>
	 <20120710215618.GC6038@fieldses.org>
	 <1341958332.17428.12.camel@lade.trondhjem.org>
	 <1341959112.17428.19.camel@lade.trondhjem.org>
	 <20120710223818.GA6720@fieldses.org>
	 <1341961118.17428.29.camel@lade.trondhjem.org>
	 <20120711170331.GE11432@fieldses.org> <20120711172714.GA13610@fieldses.org>
In-Reply-To: <20120711172714.GA13610@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTA3LTExIGF0IDEzOjI3IC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IFNvLCBpZiB0aGUgaXNzdWUgaXM6IHlvdSB3YW50IHRvIGJlIGFibGUgdG8gY2hvb3NlLCBp
biBpbmRpdmlkdWFsDQo+IGNvbnRhaW5lcnMsIHdoaWNoIG1lY2hhbmlzbSB0byB1c2U6IHdoYXRl
dmVyLCB3ZSBjYW4gcHJvYmFibHkgbWFrZSB0aGF0DQo+IHdvcmsuDQoNClBsZWFzZSBkbyB0aGVu
Lg0KDQo+IElmIHlvdSdyZSBpbnN0ZWFkIHNheWluZzogaXQncyBub3QgYWNjZXB0YWJsZSB0byB1
c2UgdGhlIGdzc3Byb3h5DQo+IG1lY2hhbmlzbSB0byBhdXRoZW50aWNhdGUgdjQuMCBjYWxsYmFj
a3MsIHRoZSBjbGllbnQgbXVzdCBvbmx5IGV2ZXIgdXNlDQo+IHRoZSBleGlzdGluZyBtZWNoYW5p
c206IHRoZW4gSSdkIHJhdGhlciBkcm9wIHRoaXMgZW50aXJlbHkuICBJIGRvbid0DQo+IHdhbnQg
dG8gbWVyZ2UgYW4gcnBjIHNlcnZlciBhdXRoZW50aWNhdGlvbiB1cGNhbGwgdGhhdCdzIG5vdCBh
Y2NlcHRhYmxlDQo+IGZvciBvbmUgb2YgdGhlIHJwYyBzZXJ2ZXJzLg0KDQpJZiBpdCBnb2VzIGlu
LCBJIHdhbnQgaXQgdG8gYmUgb3B0aW9uYWwgc28gdGhhdCBpdCBkb2Vzbid0IGJyZWFrIHdvcmtp
bmcNCnNldHVwcy4gSSBhbHNvIHdhbnQgdXBncmFkZXMvZG93bmdyYWRlcyB0byBiZSBhcyBwYWlu
bGVzcyBhcyBwb3NzaWJsZS4gDQoNClNlZSBmb3IgaW5zdGFuY2UgdGhlIGlkbWFwcGVyIGNoYW5n
ZXMgaW4gMy41IHdoaWNoIGFyZSB0b3RhbGx5DQp0cmFuc3BhcmVudCB0byB0aGUgdXNlcjogaWYg
dGhlIGFkbWluIHNldHMgdXAgL2V0Yy9yZXF1ZXN0LWtleS5jb25mIHRvDQp1c2UgdGhlIG5ldyBp
ZF9yZXNvbHZlciwgdGhlbiB0aGF0IHdvcmtzLCBvdGhlcndpc2Ugd2UganVzdCBmYWxsIGJhY2sg
dG8NCnVzaW5nIHRoZSBvbGQgcnBjLmlkbWFwZCBtZXRob2QuIFRoZXJlIGFyZSBubyBtb2R1bGUg
cGFyYW1ldGVycyBldGMNCmludm9sdmVkLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXgg
TkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5j
b20NCnd3dy5uZXRhcHAuY29tDQoNCg==
