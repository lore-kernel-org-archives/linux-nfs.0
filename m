Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:23743 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753241AbcFOOgM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 10:36:12 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 11/12] NFS: Don't count O_DIRECT reads in the
 inode->i_dio_count
Date: Wed, 15 Jun 2016 14:36:04 +0000
Message-ID: <C9DCA08F-F8FE-41FD-978B-8B1CAF3DEB17@primarydata.com>
References: <1465931115-30784-2-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-3-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-4-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-5-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-7-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-8-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-9-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-11-git-send-email-trond.myklebust@primarydata.com>
 <20160615071605.GD4318@infradead.org>
In-Reply-To: <20160615071605.GD4318@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gNi8xNS8xNiwgMDM6MTYsICJDaHJpc3RvcGggSGVsbHdpZyIgPGhjaEBpbmZyYWRlYWQub3Jn
PiB3cm90ZToNCg0KPkV4cGxhbmF0aW9uIG9mIHdoeSByZWFkcyBhcmUgbW9yZSBzcGVjaWFsIHRo
YW4gd3JpdGVzIGhlcmUgb3IgaW4NCj5nZW5lcmFsIHdoeSB0aGV5IGFyZSBzYWZlPw0KPg0KDQpX
aXRoIHRoZSBuZXcgbG9ja2luZywgd2UgYWxyZWFkeSBoYXZlIGV4Y2x1c2lvbiBiZXR3ZWVuIGJ1
ZmZlcmVkIEkvTyBhbmQgZGlyZWN0IEkvTywgYW5kIHNvIHRoZSBvbmx5IHJlbWFpbmluZyB1c2Ug
Y2FzZSBmb3IgaW5vZGVfZGlvX3dhaXQoKSBpcyB0byB3YWl0IGZvciB3cml0ZXMgdG8gY29tcGxl
dGUgaW4gb3BlcmF0aW9ucyBsaWtlIGZzeW5jKCkuDQoNCkNoZWVycw0KICBUcm9uZA0KDQo=

