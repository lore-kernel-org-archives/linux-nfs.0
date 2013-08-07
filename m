Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:58922 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932592Ab3HGQ6J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 12:58:09 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSv4.1 Use clientid management rpc_clnt for
 secinfo_no_name
Date: Wed, 7 Aug 2013 16:58:07 +0000
Message-ID: <1375894688.7280.6.camel@leira.trondhjem.org>
References: <1374511328-49579-1-git-send-email-andros@netapp.com>
	 <1374511328-49579-4-git-send-email-andros@netapp.com>
In-Reply-To: <1374511328-49579-4-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEzLTA3LTIyIGF0IDEyOjQyIC0wNDAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gDQo+IEFzIHBl
ciBSRkMgNTY2MSBTZWN1cml0eSBDb25zaWRlcmF0aW9ucw0KPiANCj4gQ29tbWl0IDRlZGFhMzA4
ICJORlM6IFVzZSAia3JiNWkiIHRvIGVzdGFibGlzaCBORlN2NCBzdGF0ZSB3aGVuZXZlciBwb3Nz
aWJsZSINCj4gdXNlcyB0aGUgbmZzX2NsaWVudCBjbF9ycGNjbGllbnQgZm9yIGFsbCBjbGllbnRp
ZCBtYW5hZ2VtZW50IG9wZXJhdGlvbnMuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBBbmR5IEFkYW1z
b24gPGFuZHJvc0BuZXRhcHAuY29tPg0KPiAtLS0NCj4gIGZzL25mcy9uZnM0cHJvYy5jIHwgMyAr
Ky0NCj4gIDEgZmlsZSBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkNCj4g
DQo+IGRpZmYgLS1naXQgYS9mcy9uZnMvbmZzNHByb2MuYyBiL2ZzL25mcy9uZnM0cHJvYy5jDQo+
IGluZGV4IDZhMzBhNzIuLjA0NTJiNjEgMTAwNjQ0DQo+IC0tLSBhL2ZzL25mcy9uZnM0cHJvYy5j
DQo+ICsrKyBiL2ZzL25mcy9uZnM0cHJvYy5jDQo+IEBAIC03MDk4LDcgKzcwOTgsOCBAQCBfbmZz
NDFfcHJvY19zZWNpbmZvX25vX25hbWUoc3RydWN0IG5mc19zZXJ2ZXIgKnNlcnZlciwgc3RydWN0
IG5mc19maCAqZmhhbmRsZSwNCj4gIAkJLnJwY19hcmdwID0gJmFyZ3MsDQo+ICAJCS5ycGNfcmVz
cCA9ICZyZXMsDQo+ICAJfTsNCj4gLQlyZXR1cm4gbmZzNF9jYWxsX3N5bmMoc2VydmVyLT5jbGll
bnQsIHNlcnZlciwgJm1zZywgJmFyZ3Muc2VxX2FyZ3MsICZyZXMuc2VxX3JlcywgMCk7DQo+ICsJ
cmV0dXJuIG5mczRfY2FsbF9zeW5jKHNlcnZlci0+bmZzX2NsaWVudC0+Y2xfcnBjY2xpZW50LCBz
ZXJ2ZXIsICZtc2csDQo+ICsJCQkJJmFyZ3Muc2VxX2FyZ3MsICZyZXMuc2VxX3JlcywgMCk7DQo+
ICB9DQo+ICANCj4gIHN0YXRpYyBpbnQNCg0KRGl0dG86IFRoaXMgbmVlZHMgYSBjb2RlIGNvbW1l
bnQuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIN
Cg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg==
