Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34975 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752355Ab2CHOG7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Mar 2012 09:06:59 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH V2] NFSv4.1 handle DS stateid errors
Date: Thu, 8 Mar 2012 14:06:34 +0000
Message-ID: <1331215594.2472.8.camel@lade.trondhjem.org>
References: <1331163873-2306-1-git-send-email-andros@netapp.com>
	 <1331163873-2306-2-git-send-email-andros@netapp.com>
In-Reply-To: <1331163873-2306-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTAzLTA3IGF0IDE4OjQ0IC0wNTAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gDQo+IEhhbmRs
ZSBEUyBSRUFEIGFuZCBXUklURSBzdGF0ZWlkIGVycm9ycyBieSByZWNvdmVyaW5nIHRoZSBzdGF0
ZWlkIG9uIHRoZSBNRFMuDQo+IA0KPiBORlM0RVJSX09MRF9TVEFURUlEIGlzIGlnbm9yZWQgYXMg
dGhlIGNsaWVudCBhbHdheXMgc2VuZHMgYQ0KPiBzdGF0ZSBzZXF1ZW5jZWlkIG9mIHplcm8gZm9y
IERTIFJFQUQgYW5kIFdSSVRFIHN0YXRlaWRzLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogQW5keSBB
ZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gU2lnbmVkLW9mZi1ieTogVHJvbmQgTXlrbGVi
dXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbT4NCj4gLS0tDQoNCkNhbiB5b3UgcGxlYXNl
IG1ha2UgdGhpcyBpbmNyZW1lbnRhbCB3LnIudC4gdGhlIGZpcnN0IHBhdGNoLg0KLS0gDQpUcm9u
ZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25k
Lk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
