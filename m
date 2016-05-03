Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:28691 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755635AbcECSsK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2016 14:48:10 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFS: Call nfs4_state_protect{_write}() from the NFSv4
 module
Date: Tue, 3 May 2016 18:41:48 +0000
Message-ID: <769B6D28-ABED-4E6A-B59C-2044911E8D99@primarydata.com>
References: <1462300182-24738-1-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1462300182-24738-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNCg0KDQoNCk9uIDUvMy8xNiwgMTQ6MjksICJBbm5hIFNjaHVtYWtlciIgPEFubmEuU2NodW1h
a2VyQG5ldGFwcC5jb20+IHdyb3RlOg0KDQo+VGhlIGdlbmVyaWMgY2xpZW50IGRvZXNuJ3QgbmVl
ZCB0byBrbm93IGFib3V0IHRoZXNlIGNhbGxzLCBhbmQgd2UgY2FuDQo+aGFuZGxlIHRoZW0gZnJv
bSB0aGUgd3JpdGUgYW5kIGNvbW1pdCBzZXR1cCBmdW5jdGlvbnMgZWFzaWx5IGVub3VnaC4NCg0K
DQpOb3QgcmVhbGx5LiBXaGF0IHdlIGFjdHVhbGx5IHdhbnQgaXMgdG8gbW92ZSB0aGVtIGludG8g
bmZzNF9zZXRfcndfc3RhdGVpZCgpIHNvIHRoYXQgd2UgY2FuIGFsd2F5cyBjaG9vc2UgdGhlIGFw
cHJvcHJpYXRlIGNyZWRlbnRpYWwgdGhhdCBtYXRjaGVzIHRoZSBzdGF0ZWlkLiBJbiBwYXJ0aWN1
bGFyLCBpZiB0aGUgc2VydmVyIHNldHMgRVhDSEdJRDRfRkxBR19CSU5EX1BSSU5DX1NUQVRFSUQs
IHRoZW4gd2Ugd2FudCB0byB1c2UgdGhlIGNyZWRlbnRpYWwgdGhhdCB3YXMgdXNlZCB0byBvYnRh
aW4gdGhlIGRlbGVnYXRpb24gaWYgaXQgaXMgc3RpbGwgdmFsaWQuDQoNCknigJl2ZSBzdGFydGVk
IHRoYXQgd29yayBpbiBhIHByaXZhdGUgYnJhbmNoIHRoYXQgSSBjYW4gcHVibGlzaCBzb29uLCBJ
IGhvcGUuDQoNCi0tLQ0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWlu
ZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

