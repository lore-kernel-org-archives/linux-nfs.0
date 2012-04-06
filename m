Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:42061 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757078Ab2DFCO2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Apr 2012 22:14:28 -0400
Received: from vmwexceht01-prd.hq.netapp.com (vmwexceht01-prd.hq.netapp.com [10.106.76.239])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q362ERqn002471
	for <linux-nfs@vger.kernel.org>; Thu, 5 Apr 2012 19:14:28 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH 1/1] NFS: check for req==NULL in
 nfs_try_to_update_request cleanup
Date: Fri, 6 Apr 2012 02:14:26 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA915A29A@SACEXCMBX04-PRD.hq.netapp.com>
References: <1333653996-4951-1-git-send-email-iisaman@netapp.com>
In-Reply-To: <1333653996-4951-1-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBGcmVkIElzYW1hbiBbbWFpbHRv
Omlpc2FtYW5AbmV0YXBwLmNvbV0NCj4gU2VudDogVGh1cnNkYXksIEFwcmlsIDA1LCAyMDEyIDEy
OjI3IFBNDQo+IFRvOiBsaW51eC1uZnNAdmdlci5rZXJuZWwub3JnDQo+IENjOiBNeWtsZWJ1c3Qs
IFRyb25kDQo+IFN1YmplY3Q6IFtQQVRDSCAxLzFdIE5GUzogY2hlY2sgZm9yIHJlcT09TlVMTCBp
bg0KPiBuZnNfdHJ5X3RvX3VwZGF0ZV9yZXF1ZXN0IGNsZWFudXANCj4gDQo+IFNpZ25lZC1vZmYt
Ynk6IEZyZWQgSXNhbWFuIDxpaXNhbWFuQG5ldGFwcC5jb20+DQo+IC0tLQ0KPiAgZnMvbmZzL3dy
aXRlLmMgfCAgICAzICsrLQ0KPiAgMSBmaWxlcyBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyksIDEg
ZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZnMvbmZzL3dyaXRlLmMgYi9mcy9uZnMv
d3JpdGUuYyBpbmRleCAyYzY4ODE4Li45YjhkNGQ0IDEwMDY0NA0KPiAtLS0gYS9mcy9uZnMvd3Jp
dGUuYw0KPiArKysgYi9mcy9uZnMvd3JpdGUuYw0KPiBAQCAtNjgyLDcgKzY4Miw4IEBAIHN0YXRp
YyBzdHJ1Y3QgbmZzX3BhZ2UNCj4gKm5mc190cnlfdG9fdXBkYXRlX3JlcXVlc3Qoc3RydWN0IGlu
b2RlICppbm9kZSwNCj4gIAkJcmVxLT53Yl9ieXRlcyA9IHJxZW5kIC0gcmVxLT53Yl9vZmZzZXQ7
DQo+ICBvdXRfdW5sb2NrOg0KPiAgCXNwaW5fdW5sb2NrKCZpbm9kZS0+aV9sb2NrKTsNCj4gLQlu
ZnNfY2xlYXJfcmVxdWVzdF9jb21taXQocmVxKTsNCj4gKwlpZiAocmVxKQ0KPiArCQluZnNfY2xl
YXJfcmVxdWVzdF9jb21taXQocmVxKTsNCj4gIAlyZXR1cm4gcmVxOw0KPiAgb3V0X2ZsdXNobWU6
DQo+ICAJc3Bpbl91bmxvY2soJmlub2RlLT5pX2xvY2spOw0KPiAtLQ0KPiAxLjcuMi4xDQoNClRo
YW5rcyBGcmVkISBBcHBsaWVkIGFuZCBwdXNoZWQgdG8gdGhlIGJ1Z2ZpeGVzIGFuZCBsaW51eC1u
ZXh0IGJyYW5jaGVzLg0KDQpDaGVlcnMNCiAgVHJvbmQNCg==
