Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59386 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751764Ab2GQTNi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jul 2012 15:13:38 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH v3 04/12] NFS: Create an init_nfs_v4() function
Date: Tue, 17 Jul 2012 19:13:37 +0000
Message-ID: <1342552415.24779.12.camel@lade.trondhjem.org>
References: <1342471161-22452-1-git-send-email-bjschuma@netapp.com>
	 <1342471161-22452-5-git-send-email-bjschuma@netapp.com>
	 <5005B8D7.8090600@netapp.com>
In-Reply-To: <5005B8D7.8090600@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTA3LTE3IGF0IDE1OjExIC0wNDAwLCBCcnlhbiBTY2h1bWFrZXIgd3JvdGU6
DQo+IFRoaXMgcGF0Y2ggc2hvdWxkIHdvcmsgYmV0dGVyLCB0aGFua3MgRmVuZ2d1YW5nIQ0KPiAN
Cj4gLSBCcnlhbg0KPiANCj4gDQo+IA0KPiBJIHdhbnQgdG8gaW5pdGlhbGl6ZSBhbGwgb2YgTkZT
IHY0IGluIGEgc2luZ2xlIGZ1bmN0aW9uIHRoYXQgd2lsbA0KPiBldmVudHVhbGx5IGJlIHVzZWQg
YXMgdGhlIHY0IG1vZHVsZSBpbml0IGZ1bmN0aW9uLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogQnJ5
YW4gU2NodW1ha2VyIDxianNjaHVtYUBuZXRhcHAuY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBUcm9u
ZCBNeWtsZWJ1c3QgPFRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tPg0KPiAtLS0NCj4gdjM6ICBE
b24ndCBkZWNsYXJlIGV4aXRfbmZzX3Y0KCkgYXMgYW4gX19leGl0ICBmdW5jdGlvbg0KDQpQbGVh
c2UgcmVkbyB0aGlzIGFzIGFuIGluY3JlbWVudGFsIHBhdGNoIHRvIHRoZSBmaXJzdCBvbmUuLi4u
DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0K
TmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
