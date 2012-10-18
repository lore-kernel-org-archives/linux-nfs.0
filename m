Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48114 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751062Ab2JRSs5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Oct 2012 14:48:57 -0400
Received: from vmwexceht02-prd.hq.netapp.com (vmwexceht02-prd.hq.netapp.com [10.106.76.240])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q9IIme5O026945
	for <linux-nfs@vger.kernel.org>; Thu, 18 Oct 2012 11:48:40 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 05/25] SUNRPC: remove BUG_ON() from rpc_call_sync()
Date: Thu, 18 Oct 2012 18:48:39 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA909281219@SACEXCMBX04-PRD.hq.netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
	 <1350405043-39316-5-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-5-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTEwLTE2IGF0IDEyOjMwIC0wNDAwLCBXZXN0b24gQW5kcm9zIEFkYW1zb24g
d3JvdGU6DQo+IFJldHVybiAtRUlOVkFMIGluc3RlYWQgb2YgY2FsbGluZyBCVUdfT04oKSB3aGVu
IFJQQ19UQVNLX0FTWU5DIGZsYWcgaXMgcGFzc2VkDQo+IHRvIHJwY19jYWxsX3N5bmMoKS4NCj4g
DQo+IFNpZ25lZC1vZmYtYnk6IFdlc3RvbiBBbmRyb3MgQWRhbXNvbiA8ZHJvc0BuZXRhcHAuY29t
Pg0KPiAtLS0NCj4gIG5ldC9zdW5ycGMvY2xudC5jIHwgICAgMyArKy0NCj4gIDEgZmlsZSBjaGFu
Z2VkLCAyIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9u
ZXQvc3VucnBjL2NsbnQuYyBiL25ldC9zdW5ycGMvY2xudC5jDQo+IGluZGV4IDc2ZDE3MzAuLmE4
YTZiY2YgMTAwNjQ0DQo+IC0tLSBhL25ldC9zdW5ycGMvY2xudC5jDQo+ICsrKyBiL25ldC9zdW5y
cGMvY2xudC5jDQo+IEBAIC04MzksNyArODM5LDggQEAgaW50IHJwY19jYWxsX3N5bmMoc3RydWN0
IHJwY19jbG50ICpjbG50LCBjb25zdCBzdHJ1Y3QgcnBjX21lc3NhZ2UgKm1zZywgaW50IGZsYWcN
Cj4gIAl9Ow0KPiAgCWludCBzdGF0dXM7DQo+ICANCj4gLQlCVUdfT04oZmxhZ3MgJiBSUENfVEFT
S19BU1lOQyk7DQo+ICsJaWYgKGZsYWdzICYgUlBDX1RBU0tfQVNZTkMpDQo+ICsJCXJldHVybiAt
RUlOVkFMOw0KDQpOZWVkcyBhIFdBUk5fT05fT05DRSgpLiBUaGlzIGlzbid0IGEgY29uZGl0aW9u
IHRoYXQgdGhlIHVzZXIgY2FuIGZpeCwgc28NCnRoZXkgbmVlZCB0byBrbm93IHRoYXQgaXQgbmVl
ZHMgcmVwb3J0aW5nLg0KDQo+ICANCj4gIAl0YXNrID0gcnBjX3J1bl90YXNrKCZ0YXNrX3NldHVw
X2RhdGEpOw0KPiAgCWlmIChJU19FUlIodGFzaykpDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpM
aW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg==
