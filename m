Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:19661 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932502Ab3GVSuz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 14:50:55 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 4 2/2] NFSv4.1 Use the MDS nfs_server authflavor
 for pNFS data server connections
Date: Mon, 22 Jul 2013 18:50:53 +0000
Message-ID: <1374519051.7972.18.camel@leira.trondhjem.org>
References: <1374267997-4305-1-git-send-email-andros@netapp.com>
	 <1374267997-4305-2-git-send-email-andros@netapp.com>
In-Reply-To: <1374267997-4305-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEzLTA3LTE5IGF0IDE3OjA2IC0wNDAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gDQo+IHBORlMg
ZGF0YSBzZXJ2ZXJzIGFyZSBub3QgbW91bnRlZCBpbiB0aGUgbm9ybWFsIHNlbnNlIGFzIHRoZXJl
IGlzIG5vIGFzc29jaWF0ZWQNCj4gbmZzX3NlcnZlciBzdHJ1Y3R1cmUuDQo+IENvbW1pdCA0ZWRh
YTMwOCAiTkZTOiBVc2UgImtyYjVpIiB0byBlc3RhYmxpc2ggTkZTdjQgc3RhdGUgd2hlbmV2ZXIg
cG9zc2libGUiDQo+IHVzZXMgdGhlIG5mc19jbGllbnQgY2xfcnBjY2xpZW50IGZvciBhbGwgc3Rh
dGUgbWFuYWdlbWVudCBvcGVyYXRpb25zLCBhbmQNCj4gd2lsbCB1c2Uga3JiNWkgb3IgYXV0aF9z
eXMgd2l0aCBubyByZWdhcmQgdG8gdGhlIG1vdW50IGNvbW1hbmQgYXV0aGZsYXZvcg0KPiBjaG9p
Y2UuICBGb3Igbm9ybWFsIG1vdW50ZWQgc2VydmVycywgdGhlIG5mc19zZXJ2ZXIgY2xpZW50IGF1
dGhmbGF2b3IgaXMgdXNlZA0KPiBmb3IgYWxsIG5vbi1zdGF0ZSBtYW5hZ2VtZW50IG9wZXJhdGlv
bnMNCj4gDQo+IERhdGEgc2VydmVycyBhbHNvIG5lZWQgdG8gdXNlIHRoZSBzYW1lIGF1dGhmbGF2
b3IgYXMgdGhlIE1EUyBtb3VudCBmb3INCj4gbm9uLXN0YXRlIG1hbmFnZW1lbnQgb3BlcmF0aW9u
cy4gQWRkIGEgc3RydXQgcnBjX2NsbnQgdG8gc3RydWN0IG5mc19jbGllbnQgZm9yDQo+IGRhdGEg
c2VydmVyIGNvbm5lY3Rpb25zLg0KDQpJcyB0aGF0IHN1ZmZpY2llbnQ/IEFzIGZhciBhcyBJIGNh
biB0ZWxsLCB0aGVyZSBpcyBub3RoaW5nIHRoYXQgc3RhdGVzDQp0aGF0IHRoZSBkYXRhIHNlcnZl
cnMgbXVzdCB1c2UgdGhlIHNhbWUgc2VjdXJpdHkgbWVjaGFuaXNtIGZvciBhbGwgdGhlDQpmaWxl
cz8NCkluIGZhY3QsIHNlY3Rpb24gMTMuMTIgc3BlY2lmaWNhbGx5IG1lbnRpb25zIHRoYXQgdGhl
IGRhdGEgc2VydmVycyBoYXZlDQp0byBzdXBwb3J0IFNFQ0lORk9fTk9fTkFNRSB0byBhbGxvdyBj
bGllbnRzIHRvIGZpZ3VyZSBvdXQgd2hhdCB0byB1c2UNCmZvciBhIGdpdmVuIERTIGZpbGVoYW5k
bGUuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIN
Cg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg==
