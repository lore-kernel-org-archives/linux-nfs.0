Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5162 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755829Ab3GVQo4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 12:44:56 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/4] NFSv4.1 Use the mount point rpc_clnt for
 layoutreturn
Date: Mon, 22 Jul 2013 16:44:55 +0000
Message-ID: <1374511492.7972.0.camel@leira.trondhjem.org>
References: <1374511328-49579-1-git-send-email-andros@netapp.com>
In-Reply-To: <1374511328-49579-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEzLTA3LTIyIGF0IDEyOjQyIC0wNDAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gDQo+IFNob3Vs
ZCBub3QgdXNlIHRoZSBjbGllbnRpZCBtYWludGVuYW5jZSBycGNfY2xudC4NCj4gDQo+IFNpZ25l
ZC1vZmYtYnk6IEFuZHkgQWRhbXNvbiA8YW5kcm9zQG5ldGFwcC5jb20+DQo+IC0tLQ0KPiAgZnMv
bmZzL25mczRwcm9jLmMgfCAyICstDQo+ICAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyks
IDEgZGVsZXRpb24oLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9mcy9uZnMvbmZzNHByb2MuYyBiL2Zz
L25mcy9uZnM0cHJvYy5jDQo+IGluZGV4IGNmMTE3OTkuLjdhODQ2YjYgMTAwNjQ0DQo+IC0tLSBh
L2ZzL25mcy9uZnM0cHJvYy5jDQo+ICsrKyBiL2ZzL25mcy9uZnM0cHJvYy5jDQo+IEBAIC02ODc2
LDcgKzY4NzYsNyBAQCBpbnQgbmZzNF9wcm9jX2xheW91dHJldHVybihzdHJ1Y3QgbmZzNF9sYXlv
dXRyZXR1cm4gKmxycCkNCj4gIAkJLnJwY19jcmVkID0gbHJwLT5jcmVkLA0KPiAgCX07DQo+ICAJ
c3RydWN0IHJwY190YXNrX3NldHVwIHRhc2tfc2V0dXBfZGF0YSA9IHsNCj4gLQkJLnJwY19jbGll
bnQgPSBscnAtPmNscC0+Y2xfcnBjY2xpZW50LA0KPiArCQkucnBjX2NsaWVudCA9IE5GU19TRVJW
RVIobHJwLT5hcmdzLmlub2RlKS0+Y2xpZW50LA0KPiAgCQkucnBjX21lc3NhZ2UgPSAmbXNnLA0K
PiAgCQkuY2FsbGJhY2tfb3BzID0gJm5mczRfbGF5b3V0cmV0dXJuX2NhbGxfb3BzLA0KPiAgCQku
Y2FsbGJhY2tfZGF0YSA9IGxycCwNCg0KTkFDSy4gTEFZT1VUUkVUVVJOIG5lZWRzIHRvIHVzZSB0
aGUgc2FtZSBjcmVkZW50aWFsIGFzIExBWU9VVEdFVC4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QN
CkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBu
ZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0K
