Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:50371 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755210AbcFHRut (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2016 13:50:49 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
CC: Tom Talpey <tom@talpey.com>, Chuck Lever <chuck.lever@oracle.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 09/20] xprtrdma: Limit the number of rpcrdma_mws
Date: Wed, 8 Jun 2016 17:50:42 +0000
Message-ID: <B93A49E2-AD7A-4D45-9D7C-DA9AD743DA81@primarydata.com>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
 <20160607194732.18401.71941.stgit@manet.1015granger.net>
 <20160607204941.GA7991@obsidianresearch.com>
 <F1820E16-A2BF-4529-A5C9-59C9AD57369A@oracle.com>
 <20160607212831.GA9192@obsidianresearch.com>
 <D90190F5-ACCB-45D8-B08D-B75023ED6240@oracle.com>
 <20160607220107.GA9982@obsidianresearch.com>
 <c43e37cd-71ea-8629-20f2-bcd674d50b83@talpey.com>
 <8FF9BF11-C5BF-4418-9A84-AAD7A6D6321D@primarydata.com>
 <20160608174014.GB30822@obsidianresearch.com>
In-Reply-To: <20160608174014.GB30822@obsidianresearch.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNCk9uIDYvOC8xNiwgMTM6NDAsICJKYXNvbiBHdW50aG9ycGUiIDxqZ3VudGhvcnBlQG9ic2lk
aWFucmVzZWFyY2guY29tPiB3cm90ZToNCg0KPk9uIFdlZCwgSnVuIDA4LCAyMDE2IGF0IDAzOjA2
OjU2UE0gKzAwMDAsIFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4NCj4+ICAgIFRoYXQgd291bGQg
YmUgYSBtb3VudCBwYXJhbWV0ZXIgd2hpY2ggd291bGQgb25seSBhcHBseSB0byBSRE1BIHNpbmNl
DQo+PiAgICBldmVyeXRoaW5nIGVsc2UgdXNlcyBkeW5hbWljIHNsb3QgYWxsb2NhdGlvbiB0aGVz
ZSBkYXlzLiBJw6JkIHByZWZlciB0bw0KPj4gICAgYXZvaWQgdGhhdC4NCj4NCj5UaGUgb25seSBy
ZWFzb24gUkRNQSBjYW5ub3QgYWxsb2NhdGUgTVJzIG9uIHRoZSBmbHkgaXMNCj5wZXJmb3JtYW5j
ZS4uIE1heWJlIGEgZHluYW1pYyBzY2hlbWUgaXMgdGhlIHJpZ2h0IGFuc3dlci4uDQo+DQoNCkl0
IHNob3VsZCBiZSBlYXN5IHRvIGRvIGZvciBORlN2NC54ICh4PjApLCB3aGVyZSB0aGUgTkZTIHBy
b3RvY29sIGFscmVhZHkgbWFuYWdlcyB0aGUgbnVtYmVyIG9mIHNsb3RzLiBUaGUgUlBDIGxheWVy
IGNvdWxkIGJlIG5vdGlmaWVkIHdoZW4gaXQgaXMgT0sgdG8gcmV0aXJlIHNsb3RzIHRoYXQgYXJl
IG5vIGxvbmdlciBpbiB1c2UuDQoNCg0KDQo=

