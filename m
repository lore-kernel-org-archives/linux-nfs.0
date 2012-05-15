Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1162 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932774Ab2EOANe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 May 2012 20:13:34 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Andreas Dilger <adilger@dilger.ca>
CC: "J. Bruce Fields" <bfields@fieldses.org>, "Theodore Ts'o" <tytso@mit.edu>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] ext4: turn on i_version updates by default
Date: Tue, 15 May 2012 00:13:13 +0000
Message-ID: <1337040811.2522.50.camel@lade.trondhjem.org>
References: <20120514140618.GA29902@fieldses.org>
	 <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca>
	 <1337036918.2522.32.camel@lade.trondhjem.org>
	 <A0359961-B147-4343-BFA3-E82F38C6700B@dilger.ca>
In-Reply-To: <A0359961-B147-4343-BFA3-E82F38C6700B@dilger.ca>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA1LTE0IGF0IDE3OjMzIC0wNjAwLCBBbmRyZWFzIERpbGdlciB3cm90ZToN
Cj4gRXZlbiBiZXR0ZXIgdGhhbiBqdXN0IGJsaW5kbHkgYnVtcGluZyB0aGUgaV92ZXJzaW9uIG9u
IGV2ZXJ5IGNoYW5nZSwNCj4gaXQgd291bGQgYmUgYmV0dGVyIHRvIGhhdmUgdXNlcnMgb2YgaV92
ZXJzaW9uIChpLmUuIGtuZnNkKSBmbGFnIHRoZQ0KPiBpbm9kZSB3aXRoICJuZWVkcyBpX3ZlcnNp
b24gdXBkYXRlIiB0aGVuIHJlYWQgdGhlIHZlcnNpb24uICBXaGVuIHRoZQ0KPiBmaWxlc3lzdGVt
L1ZGUyBidW1wcyBpX3ZlcnNpb24gdGhlIG5leHQgdGltZSBpdCBjYW4gY2xlYXIgdGhpcyBmbGFn
DQo+IGFuZCBub3QgdXBkYXRlIGlfdmVyc2lvbiBhZ2FpbiB1bnRpbCBhZnRlciB0aGUgbmV4dCB0
aW1lIGlfdmVyc2lvbg0KPiBpcyBhY3R1YWxseSB1c2VkLg0KDQpUaGF0IGRvdWJseSBwZW5hbGlz
ZXMgYWN0dWFsIHVzZXJzIG9mIGlfdmVyc2lvbjogbm90IG9ubHkgZG9lcyB0aGUNCmZpbGVzeXN0
ZW0gaGF2ZSB0byBidW1wIGl0IG9uIGEgZmlsZSBjaGFuZ2UsIGJ1dCBpdCBub3cgaGFzIHRvIHNl
dCBhbmQNCndyaXRlIHRoaXMgZmxhZyBvbiB0aGUgbmV4dCByZWFkIG9mIGlfdmVyc2lvbi4NCg0K
SWYgdGhvc2UgcmVhZHMgb2YgaV92ZXJzaW9uIHdlcmUgcmVhbGx5IGZldyBhbmQgZmFyIGJldHdl
ZW4sIHRoZW4gSQ0KYWdyZWUgdGhhdCBpdCBtaWdodCBiZSBhIHNvbHV0aW9uLCBidXQgbW9zdCBO
RlMgY2xpZW50cyB3aWxsIGFzayBmb3IgdGhlDQp1cGRhdGVkIGlfdmVyc2lvbiBhZnRlciBldmVy
eSBjaGFuZ2UgdGhhdCB0aGV5IG1ha2UgdG8gdGhlIGZpbGUgYmVjYXVzZQ0KdGhleSBuZWVkIHRv
IHRyYWNrIHRoYXQgdmFsdWUgZm9yIGNhY2hlIGNvbnNpc3RlbmN5IG1hbmFnZW1lbnQgcHVycG9z
ZXMuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIN
Cg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
