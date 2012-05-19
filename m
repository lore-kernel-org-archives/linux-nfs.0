Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:24786 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752220Ab2ESVgN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 May 2012 17:36:13 -0400
Received: from vmwexceht01-prd.hq.netapp.com (vmwexceht01-prd.hq.netapp.com [10.106.76.239])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q4JLaCIo004061
	for <linux-nfs@vger.kernel.org>; Sat, 19 May 2012 14:36:13 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1 resend LAYOUTGET on data server invalid
 layout errors
Date: Sat, 19 May 2012 21:35:27 +0000
Message-ID: <1337463371.4831.54.camel@lade.trondhjem.org>
References: <1333570957-2008-1-git-send-email-andros@netapp.com>
	 <1333570957-2008-2-git-send-email-andros@netapp.com>
In-Reply-To: <1333570957-2008-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTA0LTA0IGF0IDE2OjIyIC0wNDAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gDQo+IFRoZSAi
aW52YWxpZCBsYXlvdXQiIGNsYXNzIG9mIGVycm9ycyBpcyBoYW5kbGVkIGJ5IGRlc3Ryb3lpbmcg
dGhlIGxheW91dCBhbmQNCj4gZ2V0dGluZyBhIG5ldyBsYXlvdXQgZnJvbSB0aGUgc2VydmVyLiAg
Q3VycmVudGx5LCB0aGUgbGF5b3V0IG11c3QgYmUNCj4gZGVzdHJveWVkIGJlZm9yZSBhIG5ldyBs
YXlvdXQgY2FuIGJlIG9idGFpbmVkLg0KPiANCj4gVGhpcyBtZWFucyB0aGF0IGFsbCByZWZlcmVu
Y2VzIChlLmcubHNlZ3MpIHRvIHRoZSAidG8gYmUgZGVzdHJveWVkIiBsYXlvdXQNCj4gaGVhZGVy
IG11c3QgYmUgZHJvcHBlZCBiZWZvcmUgaXQgY2FuIGJlIGRlc3Ryb3llZC4gVGhpcyBpbiB0dXJu
IG1lYW5zIHdhaXRpbmcNCj4gZm9yIGFsbCBpbiBmbGlnaHQgUlBDJ3MgdXNpbmcgdGhlIG9sZCBs
YXlvdXQgYXMgd2VsbCBhcyBkcmFpbmluZyB0aGUgZGF0YQ0KPiBzZXJ2ZXIgc2Vzc2lvbiBzbG90
IHRhYmxlIHdhaXQgcXVldWUuDQo+IA0KPiBTZXQgdGhlIE5GU19MQVlPVVRfSU5WQUxJRCBmbGFn
IHRvIHJlZGlyZWN0IEkvTyB0byB0aGUgTURTIHdoaWxlIHdhaXRpbmcgZm9yDQo+IHRoZSBvbGQg
bGF5b3V0IHRvIGJlIGRlc3Ryb3llZC4NCj4gDQoNCklzIHRoaXMgcGF0Y2ggc3RpbGwgb2YgaW50
ZXJlc3Q/IGl0IGRvZXNuJ3Qgc2VlbSB0byBhcHBseSBub3cgdGhhdCBJJ3ZlDQphZGRlZCB5b3Vy
IHF1aWNrIGZhaWxvdmVyIHBhdGNoZXMuDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZT
IGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20N
Cnd3dy5uZXRhcHAuY29tDQoNCg==
