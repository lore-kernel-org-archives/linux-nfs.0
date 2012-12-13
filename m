Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:34574 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752978Ab2LMVW3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2012 16:22:29 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
CC: Jeff Layton <jlayton@redhat.com>, Ricky Ng-Adam <rngadam@lophilo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "neilb@suse.de" <neilb@suse.de>
Subject: Re: WARNING: at linux/fs/inode.c:280 drop_nlink
Date: Thu, 13 Dec 2012 21:22:26 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91192CBB6@SACEXCMBX04-PRD.hq.netapp.com>
References: <CAOAMTYQ_9bPjCtobC9kfUJrgiT8hx7FsMXoi5ZgWo+P1qjDb0g@mail.gmail.com>
	 <20121112095255.5c7babcc@tlielax.poochiereds.net>
	 <20121213063147.44b1cf73@tlielax.poochiereds.net>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91192A83F@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121213210753.GQ4939@ZenIV.linux.org.uk>
In-Reply-To: <20121213210753.GQ4939@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTEyLTEzIGF0IDIxOjA3ICswMDAwLCBBbCBWaXJvIHdyb3RlOg0KPiBPbiBU
aHUsIERlYyAxMywgMjAxMiBhdCAwMjo0NToxOFBNICswMDAwLCBNeWtsZWJ1c3QsIFRyb25kIHdy
b3RlOg0KPiANCj4gPiBZb3UgbWVhbiBhc2lkZSBmcm9tIHRoZSBmYWN0IHRoYXQgc2ItPnNfcmVt
b3ZlX2NvdW50IHJlbWFpbnMgYSByYWN5DQo+ID4gcGllY2Ugb2YgY3JhcCB0aGF0IHNlcnZlcyBu
byBnb29kIHB1cnBvc2UgZm9yIE5GUywgYW5kIHlldCB3aWxsIGNvbnRpbnVlDQo+ID4gdG8gZ2l2
ZSB1cyBncmllZj8NCj4gDQo+IEFzIG9wcG9zZWQgdG8gc2Nhbm5pbmcgdGhlIGxpc3Qgb2Ygb3Bl
bmVkIGZpbGVzPw0KDQpGb3Igd2hhdCBpbmZvcm1hdGlvbj8gc2ItPnNfcmVtb3ZlX2NvdW50IHRl
bGxzIHlvdSBub3RoaW5nIG5ldyBhYm91dCB0aGUNCnN0YXRlIG9mIHRoZSBORlMgZmlsZXN5c3Rl
bS4NCg0KVGhpcyB3aG9sZSAiY2hlY2sgZm9yIG5saW5rID09IDAiIHRoaW5nIGlzIGF0IGJlc3Qg
YSBoZXVyaXN0aWMsIHNpbmNlDQp0aGUgZmlsZSBtYXkgcGVyc2lzdCBvciBkaXNhcHBlYXIgb24g
dGhlIHNlcnZlciBpbmRlcGVuZGVudGx5IG9mDQp3aGF0ZXZlciB3ZSBtYXkgdGhpbmsgYWJvdXQg
dGhlIHZhbHVlIG9mIGlub2RlLT5pX25saW5rLiBTZXR0aW5nIHNpcmVucw0KdG8gYmxhcmUgYW5k
IGFuZ2VscyB0byBzaW5nIHdoZW4gd2UgZ2V0IGl0IHdyb25nIChhcyB3ZSBvZnRlbiBkbykgaXMN
Cmp1c3QgcG9pbnRsZXNzLi4uDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xp
ZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3
Lm5ldGFwcC5jb20NCg==
