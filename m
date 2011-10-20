Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:59936 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650Ab1JTMWt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Oct 2011 08:22:49 -0400
Received: by yxl42 with SMTP id 42so154231yxl.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 Oct 2011 05:22:49 -0700 (PDT)
Message-ID: <956652236-1319113365-cardhu_decombobulator_blackberry.rim.net-813536196-@b18.c3.bise3.blackberry>
Reply-To: bhalevy@tonian.com
Subject: Re: [PATCH 6/7] nfsd4: typo logical vs bitwise negate for want_mask
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Benny Halevy" <benny@tonian.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
From: "Benny Halevy" <bhalevy@tonian.com>
Date: Thu, 20 Oct 2011 12:22:41 +0000
Content-Type: text/plain
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

VGhlIG90aGVyIHBhdGNoIHdhcyBmb3IgdGhlIGRlbnkgYml0cyB0aGlzIGlzIGZvciB0aGUgd2Fu
dCBtYXNrLi4uDQpTaW1pbGFyIGJ1ZywgZGlmZmVyZW50IHBsYWNlIDopDQoNCkJlbm55DQotLS0t
LS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0tDQpGcm9tOiBKLiBCcnVjZSBGaWVsZHMNClRvOiBCZW5u
eSBIYWxldnkNCkNjOiBKLiBCcnVjZSBGaWVsZHMNCkNjOiBsaW51eC1uZnNAdmdlci5rZXJuZWwu
b3JnDQpDYzogQmVubnkgSGFsZXZ5DQpTdWJqZWN0OiBSZTogW1BBVENIIDYvN10gbmZzZDQ6IHR5
cG8gbG9naWNhbCB2cyBiaXR3aXNlIG5lZ2F0ZSBmb3Igd2FudF9tYXNrDQpTZW50OiBPY3QgMjAs
IDIwMTEgMDQ6NTMNCg0KWWVwLCBiYWQgbWlzdGFrZSBvbiBteSBwYXJ0LS1idXQgc29tZW9uZSBl
bHNlIGFscmVhZHkgY2F1Z2h0IHRoaXMsIGFuZA0KaXQncyBhbHJlYWR5IGNvbW1pdHRlZCB0byBt
eSAzLjIgYnJhbmNoLi0tYi4NCg0KT24gV2VkLCBPY3QgMTksIDIwMTEgYXQgMDc6MTM6MjlQTSAt
MDcwMCwgQmVubnkgSGFsZXZ5IHdyb3RlOg0KPiBGcm9tOiBCZW5ueSBIYWxldnkgPGJoYWxldnlA
dG9uaWFuLmNvbT4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEJlbm55IEhhbGV2eSA8YmhhbGV2eUB0
b25pYW4uY29tPg0KPiAtLS0NCj4gIGZzL25mc2QvbmZzNHhkci5jIHwgICAgMiArLQ0KPiAgMSBm
aWxlcyBjaGFuZ2VkLCAxIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZm
IC0tZ2l0IGEvZnMvbmZzZC9uZnM0eGRyLmMgYi9mcy9uZnNkL25mczR4ZHIuYw0KPiBpbmRleCAx
YTQxOWMwLi4xYTVjYjdlIDEwMDY0NA0KPiAtLS0gYS9mcy9uZnNkL25mczR4ZHIuYw0KPiArKysg
Yi9mcy9uZnNkL25mczR4ZHIuYw0KPiBAQCAtNjcxLDcgKzY3MSw3IEBAIHN0YXRpYyBfX2JlMzIg
bmZzZDRfZGVjb2RlX3NoYXJlX2FjY2VzcyhzdHJ1Y3QgbmZzZDRfY29tcG91bmRhcmdzICphcmdw
LCB1MzIgKngpDQo+ICAJZGVmYXVsdDoNCj4gIAkJcmV0dXJuIG5mc2Vycl9iYWRfeGRyOw0KPiAg
CX0NCj4gLQl3ICY9ICFORlM0X1NIQVJFX1dBTlRfTUFTSzsNCj4gKwl3ICY9IH5ORlM0X1NIQVJF
X1dBTlRfTUFTSzsNCj4gIAlpZiAoIXcpDQo+ICAJCXJldHVybiBuZnNfb2s7DQo+ICAJc3dpdGNo
ICh3KSB7DQo+IC0tIA0KPiAxLjcuNg0KPiANCg0K

