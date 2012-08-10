Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21538 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752114Ab2HJQRF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Aug 2012 12:17:05 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: William Dauchy <wdauchy@gmail.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] NFS: Use kzalloc() instead of kmalloc() in the
 idmapper
Date: Fri, 10 Aug 2012 16:16:33 +0000
Message-ID: <1344615387.7696.1.camel@lade.trondhjem.org>
References: <1344535551-4412-1-git-send-email-bjschuma@netapp.com>
	 <1344535551-4412-3-git-send-email-bjschuma@netapp.com>
	 <CAJ75kXaYhQ8_Vw72j1Am5AxhHATsoEaOzh6JXA=buqeN38-8xA@mail.gmail.com>
In-Reply-To: <CAJ75kXaYhQ8_Vw72j1Am5AxhHATsoEaOzh6JXA=buqeN38-8xA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTA4LTEwIGF0IDEyOjEwICswMjAwLCBXaWxsaWFtIERhdWNoeSB3cm90ZToN
Cj4gT24gVGh1LCBBdWcgOSwgMjAxMiBhdCA4OjA1IFBNLCAgPGJqc2NodW1hQG5ldGFwcC5jb20+
IHdyb3RlOg0KPiA+IFRoaXMgd2lsbCBhbGxvY2F0ZSBtZW1vcnkgdGhhdCBoYXMgYWxyZWFkeSBi
ZWVuIHplcm9lZCwgYWxsb3dpbmcgdXMgdG8NCj4gPiByZW1vdmUgdGhlIG1lbXNldCBsYXRlciBv
bi4NCj4gPg0KPiA+IFNpZ25lZC1vZmYtYnk6IEJyeWFuIFNjaHVtYWtlciA8YmpjaHVtYUBuZXRh
cHAuY29tPg0KPiANCj4gVGVzdGVkLWJ5OiBXaWxsaWFtIERhdWNoeSA8d2RhdWNoeUBnbWFpbC5j
b20+DQo+IENjOiBzdGFibGVAdmdlci5rZXJuZWwub3JnDQo+IA0KDQpOby4gVGhpcyBpcyBhIGNs
ZWFudXAgYW5kIHNvIGlzIG5vdCBzdGFibGUga2VybmVsIG1hdGVyaWFsLg0KDQotLSANClRyb25k
IE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQu
TXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQoNCg==
