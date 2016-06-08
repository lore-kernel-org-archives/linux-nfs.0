Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:39975 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754467AbcFHPHI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2016 11:07:08 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Tom Talpey <tom@talpey.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Chuck Lever <chuck.lever@oracle.com>
CC: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 09/20] xprtrdma: Limit the number of rpcrdma_mws
Date: Wed, 8 Jun 2016 15:06:56 +0000
Message-ID: <8FF9BF11-C5BF-4418-9A84-AAD7A6D6321D@primarydata.com>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
 <20160607194732.18401.71941.stgit@manet.1015granger.net>
 <20160607204941.GA7991@obsidianresearch.com>
 <F1820E16-A2BF-4529-A5C9-59C9AD57369A@oracle.com>
 <20160607212831.GA9192@obsidianresearch.com>
 <D90190F5-ACCB-45D8-B08D-B75023ED6240@oracle.com>
 <20160607220107.GA9982@obsidianresearch.com>
 <c43e37cd-71ea-8629-20f2-bcd674d50b83@talpey.com>
In-Reply-To: <c43e37cd-71ea-8629-20f2-bcd674d50b83@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNCk9uIDYvOC8xNiwgMTA6NTQsICJsaW51eC1uZnMtb3duZXJAdmdlci5rZXJuZWwub3JnIG9u
IGJlaGFsZiBvZiBUb20gVGFscGV5IiA8bGludXgtbmZzLW93bmVyQHZnZXIua2VybmVsLm9yZyBv
biBiZWhhbGYgb2YgdG9tQHRhbHBleS5jb20+IHdyb3RlOg0KDQo+T24gNi83LzIwMTYgNjowMSBQ
TSwgSmFzb24gR3VudGhvcnBlIHdyb3RlOg0KPj4gT24gVHVlLCBKdW4gMDcsIDIwMTYgYXQgMDU6
NTE6MDRQTSAtMDQwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+Pg0KPj4+IFRoZXJlIGlzIGEgcHJh
Y3RpY2FsIG51bWJlciBvZiBNUnMgdGhhdCBjYW4gYmUgYWxsb2NhdGVkDQo+Pj4gcGVyIGRldmlj
ZSwgSSB0aG91Z2h0LiBBbmQgZWFjaCBNUiBjb25zdW1lcyBzb21lIGFtb3VudA0KPj4+IG9mIGhv
c3QgbWVtb3J5Lg0KPj4NCj4+PiB4cHJ0cmRtYSBpcyBoYXBweSB0byBhbGxvY2F0ZSB0aG91c2Fu
ZHMgb2YgTVJzIHBlciBRUC9QRA0KPj4+IHBhaXIsIGJ1dCB0aGF0IGlzbid0IHByYWN0aWNhbCBh
cyB5b3Ugc3RhcnQgYWRkaW5nIG1vcmUNCj4+PiB0cmFuc3BvcnRzL2Nvbm5lY3Rpb25zLg0KPj4N
Cj4+IFllcywgdGhpcyBpcyBhbGwgc2FuZSBhbmQgdmFsaWQuDQo+Pg0KPj4gVHlwaWNhbGx5IHlv
dSdkIHRhcmdldCBhIGNvbmN1cnJlbmN5IGxpbWl0IHBlciBRUCBhbmQgYWxsb2NhdGUNCj4+IGV2
ZXJ5dGhpbmcgKCMgTVJzLCBzcSxycSxjcSBkZXB0aCwgZXRjKSBpbiBhY2NvcmRhbmNlIHdpdGgg
dGhhdCBnb2FsLA0KPj4gSSdkIGFsc28gc3VnZ2VzdCB0aGF0IHRhcmdldCBjb25jdXJyZW5jeSBp
cyBwcm9iYWJseSBhIHVzZXIgdHVuYWJsZS4uDQo+DQo+VGhpcyBpcyBhbHJlYWR5IHByZXNlbnQg
LSBpdCdzIHRoZSBSUEMgc2xvdCB0YWJsZSBkZXB0aC4gSXQgd291bGQgYmUNCj5ncmVhdCwgSU1P
LCB0byBtYWtlIHRoaXMgYSBtb3VudCBwYXJhbWV0ZXIgc2luY2UgaXQgaXMgdHJhbnNwb3J0LSBh
bmQNCj5hbHNvIHNlcnZlci1kZXBlbmRlbnQsIGJ1dCBjdXJyZW50bHkgSSBiZWxpZXZlIGl0IGlz
IGp1c3QgYSBrZXJuZWwNCj5SUEMgbW9kdWxlIHBhcmFtZXRlci4NCg0KVGhhdCB3b3VsZCBiZSBh
IG1vdW50IHBhcmFtZXRlciB3aGljaCB3b3VsZCBvbmx5IGFwcGx5IHRvIFJETUEgc2luY2UgZXZl
cnl0aGluZyBlbHNlIHVzZXMgZHluYW1pYyBzbG90IGFsbG9jYXRpb24gdGhlc2UgZGF5cy4gSeKA
mWQgcHJlZmVyIHRvIGF2b2lkIHRoYXQuDQoNClRyb25kDQoNCg==

