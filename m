Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:48973 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752069AbcFVSGd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2016 14:06:33 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Schumaker Anna <Anna.Schumaker@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 11/12] NFS: Remove inode->i_dio_count from the NFS
 O_DIRECT code
Date: Wed, 22 Jun 2016 18:06:18 +0000
Message-ID: <BD2F73AF-8547-4198-A937-0C6EDBF079FA@primarydata.com>
References: <1466544893-12058-1-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-2-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-3-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-4-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-5-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-6-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-7-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-8-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-9-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-10-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-11-git-send-email-trond.myklebust@primarydata.com>
 <74f8a81e-41c2-b28c-0227-780f3d26db75@Netapp.com>
In-Reply-To: <74f8a81e-41c2-b28c-0227-780f3d26db75@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIEp1biAyMiwgMjAxNiwgYXQgMTM6NTgsIEFubmEgU2NodW1ha2VyIDxBbm5hLlNjaHVt
YWtlckBuZXRhcHAuY29tPiB3cm90ZToNCj4gDQo+IEhpIFRyb25kLA0KPiANCj4gT24gMDYvMjEv
MjAxNiAwNTozNCBQTSwgVHJvbmQgTXlrbGVidXN0IHdyb3RlOg0KPj4gTm93IHRoYXQgd2UgY2Fu
IHNlcmlhbGlzZSBPX0RJUkVDVCBhbmQgd3JpdGUvdHJ1bmNhdGUgdXNpbmcgdGhlDQo+PiBpbm9k
ZS0+aV9yd3NlbSwgd2Ugbm8gbG9uZ2VyIG5lZWQgaW5vZGUtPmlfZGlvX2NvdW50Lg0KPiANCj4g
SSdtIHNlZWluZyBjdGhvbiBiYXNpYyB0ZXN0cyBmYWlsIG9uIGFsbCBORlMgdmVyc2lvbnMgYWZ0
ZXIgYXBwbHlpbmcgdGhpcyBwYXRjaDoNCj4gDQo+IC4vdGVzdDU6IHJlYWQgYW5kIHdyaXRlDQo+
ICAgICAgICAuL3Rlc3Q1OiAoL25mcy9iYXNpYykgJ2JpZ2ZpbGUnIGhhcyBzaXplIDgxOTIsIHNo
b3VsZCBiZSAxMDQ4NTc2DQo+IGJhc2ljIHRlc3RzIGZhaWxlZA0KPiANCg0KPz8/PyBDb25uZWN0
YXRob24gZG9lc27igJl0IHVzZSBPX0RJUkVDVC4gQXJlIHlvdSBzdXJlIGl0IGlzIHRoaXMgcGF0
Y2g/DQoNCg==

