Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:56785 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751678AbdHPUCU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Aug 2017 16:02:20 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 5/6] SUNRPC: Add a function to allow waiting for RPC
 transmission
Date: Wed, 16 Aug 2017 20:02:16 +0000
Message-ID: <1502913733.5613.5.camel@primarydata.com>
References: <20170816161929.11271-1-trond.myklebust@primarydata.com>
         <20170816161929.11271-2-trond.myklebust@primarydata.com>
         <20170816161929.11271-3-trond.myklebust@primarydata.com>
         <20170816161929.11271-4-trond.myklebust@primarydata.com>
         <20170816161929.11271-5-trond.myklebust@primarydata.com>
         <20170816161929.11271-6-trond.myklebust@primarydata.com>
         <A0D358C7-C590-45CE-B4BF-F93BB08469B4@oracle.com>
In-Reply-To: <A0D358C7-C590-45CE-B4BF-F93BB08469B4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE3LTA4LTE2IGF0IDEyOjQzIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBBdWcgMTYsIDIwMTcsIGF0IDEyOjE5IFBNLCBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15
a2xlYnVzdEBwcmltDQo+ID4gYXJ5ZGF0YS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IFNvbWV0aW1l
cywgd2Ugb25seSB3YW50IHRvIGtub3cgdGhhdCB0aGUgUlBDIG1lc3NhZ2UgaXMgaW4gdGhlDQo+
ID4gcHJvY2Vzcw0KPiA+IG9mIGJlaW5nIHRyYW5zbWl0dGVkLiBBZGQgYSBmdW5jdGlvbiB0byBh
bGxvdyB0aGF0Lg0KPiANCj4gVGhlIGxhc3QgdGltZSBJIHRyaWVkIHRoZXNlIGxhc3QgdHdvLCB0
aGV5IHJlc3VsdGVkIGluIGEgc2lnbmlmaWNhbnQNCj4gcGVyZm9ybWFuY2UgcmVncmVzc2lvbi4g
SXMgdGhlcmUgYW55dGhpbmcgSSBjYW4gZG8gdG8gaGVscCB0cmFjaw0KPiB0aGF0IGRvd24/DQoN
CklmIHRoZXkgYXJlIHRoZSByb290IGNhdXNlIG9mIGEgcGVyZm9ybWFuY2UgcmVncmVzc2lvbiwg
dGhlbiBJJ2xsIGp1c3QNCmRyb3AgdGhlbS4gSSd2ZSBiZWVuIHJlYmFzaW5nIHRvIGVuc3VyZSB0
aGF0IEkga2VlcCB0aGVtIGF0IHRoZSBlbmQgb2YNCnRoZSBxdWV1ZSBwcmVjaXNlbHkgYmVjYXVz
ZSBJIHdhcyB1bnN1cmUgb2YgdGhlaXIgZWZmZWN0IG9uIG92ZXJhbGwNCnBlcmZvcm1hbmNlLg0K
DQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBQcmlt
YXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbQ0K

