Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:34505 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753454AbcFOOuN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 10:50:13 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 11/12] NFS: Don't count O_DIRECT reads in the
 inode->i_dio_count
Date: Wed, 15 Jun 2016 14:50:07 +0000
Message-ID: <B4354EF8-B0AB-43C6-B7C3-FD27E43364B1@primarydata.com>
References: <1465931115-30784-4-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-5-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-7-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-8-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-9-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-11-git-send-email-trond.myklebust@primarydata.com>
 <20160615071605.GD4318@infradead.org>
 <C9DCA08F-F8FE-41FD-978B-8B1CAF3DEB17@primarydata.com>
 <20160615144150.GA18524@infradead.org>
In-Reply-To: <20160615144150.GA18524@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNCk9uIDYvMTUvMTYsIDEwOjQxLCAiQ2hyaXN0b3BoIEhlbGx3aWciIDxoY2hAaW5mcmFkZWFk
Lm9yZz4gd3JvdGU6DQoNCj5PbiBXZWQsIEp1biAxNSwgMjAxNiBhdCAwMjozNjowNFBNICswMDAw
LCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6DQo+PiBPbiA2LzE1LzE2LCAwMzoxNiwgIkNocmlzdG9w
aCBIZWxsd2lnIiA8aGNoQGluZnJhZGVhZC5vcmc+IHdyb3RlOg0KPj4gDQo+PiA+RXhwbGFuYXRp
b24gb2Ygd2h5IHJlYWRzIGFyZSBtb3JlIHNwZWNpYWwgdGhhbiB3cml0ZXMgaGVyZSBvciBpbg0K
Pj4gPmdlbmVyYWwgd2h5IHRoZXkgYXJlIHNhZmU/DQo+PiA+DQo+PiANCj4+IFdpdGggdGhlIG5l
dyBsb2NraW5nLCB3ZSBhbHJlYWR5IGhhdmUgZXhjbHVzaW9uIGJldHdlZW4gYnVmZmVyZWQgSS9P
IGFuZCBkaXJlY3QgSS9PLCBhbmQgc28gdGhlIG9ubHkgcmVtYWluaW5nIHVzZSBjYXNlIGZvciBp
bm9kZV9kaW9fd2FpdCgpIGlzIHRvIHdhaXQgZm9yIHdyaXRlcyB0byBjb21wbGV0ZSBpbiBvcGVy
YXRpb25zIGxpa2UgZnN5bmMoKS4NCj4NCj5UaGVyZSBpcyBubyBuZWVkIHRvIHdhaXQgZm9yIHBl
bmRpbmcgZGlvIGluIGZzeW5jIC0gZnN5bmMgaXMgb25seQ0KPmd1YXJhbnRlZSB0byBmbHVzaCBv
dXQgSS9PIHRoYXQncyBhbHJlYXlkIGJlZW4gY29tcGxldGVkLg0KPg0KPmlub2RlX2Rpb193YWl0
IGFuZCBmcmllbmRzIHdlcmUgaW50cm9kdWNlcyB0byBwcm90ZWN0IGFpbyB0aGF0IGRvZXNuJ3QN
Cj5ob2xkIGlfbXV0ZXggYWdhaW5zdCB0cnVuY2F0ZS4NCg0KRmFpciBlbm91Z2guIFNvIGl0IHNv
dW5kcyBhcyBpZiB5b3UgYXJlIHN1Z2dlc3Rpbmcgd2UgY2FuIGp1c3QgZHJvcCB1c2luZyBpbm9k
ZV9kaW9fKigpIGFsdG9nZXRoZXI/DQoNCg0K

