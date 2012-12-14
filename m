Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:58527 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756652Ab2LNSW3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Dec 2012 13:22:29 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Al Viro <viro@ZenIV.linux.org.uk>, Ricky Ng-Adam <rngadam@lophilo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "neilb@suse.de" <neilb@suse.de>
Subject: Re: WARNING: at linux/fs/inode.c:280 drop_nlink
Date: Fri, 14 Dec 2012 18:22:27 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91192E5BE@SACEXCMBX04-PRD.hq.netapp.com>
References: <CAOAMTYQ_9bPjCtobC9kfUJrgiT8hx7FsMXoi5ZgWo+P1qjDb0g@mail.gmail.com>
	 <20121112095255.5c7babcc@tlielax.poochiereds.net>
	 <20121213063147.44b1cf73@tlielax.poochiereds.net>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91192A83F@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121213210753.GQ4939@ZenIV.linux.org.uk>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91192CBB6@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121213220636.4c70ec28@corrin.poochiereds.net>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91192D34B@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121214075138.7ab828da@tlielax.poochiereds.net>
In-Reply-To: <20121214075138.7ab828da@tlielax.poochiereds.net>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTEyLTE0IGF0IDA3OjUxIC0wNTAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4g
T1RPSCwgdGhlcmUgaXMgYXQgbGVhc3QgYSBtaW5vciBwcm9ibGVtIGhlcmUgd2l0aCBsZXR0aW5n
IGlfbmxpbmsNCj4gdW5kZXJmbG93LiBXaGVuIHdlIGZpbmFsbHkgZ2V0IGFyb3VuZCB0byBpcHV0
X2ZpbmFsLCBnZW5lcmljX2Ryb3BfaW5vZGUNCj4gaXMgZ29pbmcgdG8gcmV0dXJuIGZhbHNlIGFu
ZCB3ZSdyZSBnb2luZyB0byBlbmQgdXAgd2l0aCB0aGUgaW5vZGUNCj4gbGluZ2VyaW5nIGluIHRo
ZSBjYWNoZSBsb25nZXIgdGhhbiBpdCByZWFsbHkgc2hvdWxkLiBQcmVzdW1hYmx5IG1lbW9yeQ0K
PiBwcmVzc3VyZSB3aWxsIGV2ZW50dWFsbHkgcHVzaCBpdCBvdXQsIGJ1dCBpdCB3b3VsZCBiZSBi
ZXR0ZXIgbm90IHRvDQo+IGhhdmUgdG8gd2FpdCBmb3IgdGhhdC4NCg0KQXMgSSBzYWlkLCB0aGUg
d2hvbGUgbmxpbmsgdGVzdCB0aGluZyBpcyBhIGhldXJpc3RpYyBvbiBORlMuIEp1c3QNCmJlY2F1
c2Ugd2UgdGhpbmsgd2UndmUgc3VjY2Vzc2Z1bGx5IHNlbnQgYSBSRU1PVkUgdG8gdGhlIHNlcnZl
ciwgaXQNCmRvZXNuJ3QgbWVhbiB0aGF0IGZpbGUgaGFzIGFjdHVhbGx5IGJlZW4gZGVsZXRlZC4g
UkVNT1ZFIHJlZmVycyB0byB0aGUNCmZpbGUgYnkgbmFtZSwgc28gdGhlcmUgaXMgcGxlbnR5IG9m
IG9wcG9ydHVuaXR5IGZvciB0aGUgc2VydmVyIHRvIHBsYXkNCnRyaWNrcyBvbiB1cy4gSSdtIGFz
c3VtaW5nIHRoYXQgaXMgd2hhdCBpcyBoYXBwZW5pbmcgaW4geW91ciBGZWRvcmEgYnVnDQpyZXBv
cnRzLg0KDQpBcyBmYXIgYXMgd2UncmUgY29uY2VybmVkLCB0aGUgb25seSByZWxpYWJsZSBpbmRp
Y2F0b3IgdGhhdCBhIGZpbGUgaGFzDQpiZWVuIGRlbGV0ZWQgaXMgd2hlbiB0aGUgc2VydmVyIHN0
YXJ0cyByZXBseWluZyBFU1RBTEUgdG8gdGhhdA0KZmlsZWhhbmRsZS4NCg0KPiBJJ2xsIGFsc28g
bm90ZSB0aGF0IHdlIGNhbGwgbmZzX2Ryb3BfbmxpbmsgdG8gZGVjcmVtZW50IGlfbmxpbmsNCj4g
ZXZlcnl3aGVyZSBlbHNlIGFzaWRlIGZyb20gdGhpcyBjYWxsIHNpdGUuIFdoYXQgbWFrZXMgbmZz
X2RlbnRyeV9pcHV0DQo+IHNwZWNpYWwgaW4gdGhpcyByZWdhcmQ/DQoNCm5mc19kZW50cnlfaXB1
dCgpIGlzIG5vdCBzcGVjaWFsLCBidXQgdGhlIHRlc3QgaW4gbmZzX2Ryb3BfbmxpbmsoKSBpcy4N
CklmIHdlJ3JlIG5vdCBhYmxlIHRvIHRyYWNrIGlub2RlLT5pX25saW5rLCB0aGVuIHdoeSBpcyBm
b3JjaW5nIGFuIGlub2RlDQpldmljdGlvbiBtb3JlIGNvcnJlY3QgdGhhbiBub3QgZG9pbmcgc28/
DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0K
TmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg==
