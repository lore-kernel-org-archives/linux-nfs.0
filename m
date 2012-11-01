Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2723 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936003Ab2KAP4N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Nov 2012 11:56:13 -0400
Received: from vmwexceht01-prd.hq.netapp.com (exchsmtp.hq.netapp.com [10.106.76.239])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id qA1FuC3s007000
	for <linux-nfs@vger.kernel.org>; Thu, 1 Nov 2012 08:56:12 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 05/25] SUNRPC: remove BUG_ON from rpc_call_sync
Date: Thu, 1 Nov 2012 15:56:10 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9092A12FD@SACEXCMBX04-PRD.hq.netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
	 <1351003429-18887-6-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-6-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTEwLTIzIGF0IDEwOjQzIC0wNDAwLCBXZXN0b24gQW5kcm9zIEFkYW1zb24g
d3JvdGU6DQo+IFJldHVybiAtRUlOVkFMIGluc3RlYWQgb2YgY2FsbGluZyBCVUdfT04oKSB3aGVu
IFJQQ19UQVNLX0FTWU5DIGZsYWcgaXMgcGFzc2VkDQo+IHRvIHJwY19jYWxsX3N5bmMoKS4NCj4g
DQo+IFNpZ25lZC1vZmYtYnk6IFdlc3RvbiBBbmRyb3MgQWRhbXNvbiA8ZHJvc0BuZXRhcHAuY29t
Pg0KPiAtLS0NCj4gIG5ldC9zdW5ycGMvY2xudC5jIHwgICAgNiArKysrKy0NCj4gIDEgZmlsZSBj
aGFuZ2VkLCA1IGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkNCj4gDQo+IGRpZmYgLS1naXQg
YS9uZXQvc3VucnBjL2NsbnQuYyBiL25ldC9zdW5ycGMvY2xudC5jDQo+IGluZGV4IGRkMTZlNTIu
LjBjMDAzNWYgMTAwNjQ0DQo+IC0tLSBhL25ldC9zdW5ycGMvY2xudC5jDQo+ICsrKyBiL25ldC9z
dW5ycGMvY2xudC5jDQo+IEBAIC04MzksNyArODM5LDExIEBAIGludCBycGNfY2FsbF9zeW5jKHN0
cnVjdCBycGNfY2xudCAqY2xudCwgY29uc3Qgc3RydWN0IHJwY19tZXNzYWdlICptc2csIGludCBm
bGFnDQo+ICAJfTsNCj4gIAlpbnQgc3RhdHVzOw0KPiAgDQo+IC0JQlVHX09OKGZsYWdzICYgUlBD
X1RBU0tfQVNZTkMpOw0KPiArCWlmIChmbGFncyAmIFJQQ19UQVNLX0FTWU5DKSB7DQoNClRoaXMg
ZGVmaW5pdGVseSBuZWVkcyBhIFdBUk5fT05fT05DRTogaXQncyBhIHByb2dyYW1tZXIgZXJyb3Is
IG5vdCBhbg0KYXBwbGljYXRpb24gZXJyb3IuLi4NCg0KPiArCQlycGNfcmVsZWFzZV9jYWxsZGF0
YSh0YXNrX3NldHVwX2RhdGEuY2FsbGJhY2tfb3BzLA0KPiArCQkJdGFza19zZXR1cF9kYXRhLmNh
bGxiYWNrX2RhdGEpOw0KPiArCQlyZXR1cm4gLUVJTlZBTDsNCj4gKwl9DQo+ICANCj4gIAl0YXNr
ID0gcnBjX3J1bl90YXNrKCZ0YXNrX3NldHVwX2RhdGEpOw0KPiAgCWlmIChJU19FUlIodGFzaykp
DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0K
TmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg==
