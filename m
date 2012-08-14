Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hop-nat-141.emc.com ([168.159.213.141]:28160 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755614Ab2HNKJJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Aug 2012 06:09:09 -0400
From: "Peng, Tao" <tao.peng@emc.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bharrosh@panasas.com" <bharrosh@panasas.com>
Date: Tue, 14 Aug 2012 06:08:22 -0400
Subject: RE: [PATCH-v2 2/3] NFS41: send real write size in layoutget
Message-ID: <5DFC6BE3BA248842867E85C73BF94B050B18B54851@MX41A.corp.emc.com>
References: <1344868776-1739-1-git-send-email-bergwolf@gmail.com>
	 <1344868776-1739-2-git-send-email-bergwolf@gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA93A0828@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA93A0828@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBNeWtsZWJ1c3QsIFRyb25kIFtt
YWlsdG86VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb21dDQo+IFNlbnQ6IFR1ZXNkYXksIEF1Z3Vz
dCAxNCwgMjAxMiA4OjQzIEFNDQo+IFRvOiBQZW5nIFRhbw0KPiBDYzogbGludXgtbmZzQHZnZXIu
a2VybmVsLm9yZzsgYmhhcnJvc2hAcGFuYXNhcy5jb207IFBlbmcsIFRhbw0KPiBTdWJqZWN0OiBS
ZTogW1BBVENILXYyIDIvM10gTkZTNDE6IHNlbmQgcmVhbCB3cml0ZSBzaXplIGluIGxheW91dGdl
dA0KPiANCj4gUGxlYXNlIGp1c3QgY2FsY3VsYXRlIHRoZSBjb3JyZWN0IHZhbHVlIGZvciB3Yl9z
aXplIGluc2lkZQ0KPiBibF9wZ19pbml0X3dyaXRlKCksIGFuZCBwYXNzIGl0IGFzIGFuIGV4dHJh
IHBhcmFtZXRlciB0bw0KPiBwbmZzX2dlbmVyaWNfcGdfaW5pdF93cml0ZSgpLg0KPiANCj4gVGhl
biBhZGQgcG5mc19wZ19pbml0X29iamVjdF93cml0ZSBmb3Igb2JqZWN0cywgdGhhdCBjYWxscyB0
aGUgbW9kaWZpZWQNCj4gcG5mc19nZW5lcmljX3BnX2luaXRfd3JpdGUoKSB3aXRoIHRoZSBQTkZT
X0xBWU9VVEdFVF9JU0laRSB2YWx1ZS4NCj4gDQo+IEZpbGVzIGRvbid0IGNhbGwgdGhpcyBmdW5j
dGlvbiwgc28gYWRkaW5nIHRoZSBQTkZTX0xBWU9VVEdFVF9BTExfRklMRQ0KPiBpc24ndCBuZWVk
ZWQuDQpJdCB3YXMganVzdCBmb3IgY29uc2lzdGVuY3kgdG8gYWRkIHRoZSBmbGFnIGZvciBmaWxl
IGxheW91dC4gQW55d2F5LCBJIHNlZSB5b3VyIHBvaW50cy4gV2lsbCBwdXQgYWxsIHRoZXNlIGlu
IGJsb2NrL29iamVjdCBMRCBjb2RlLg0KDQpUaGFua3MsDQpUYW8NCg0K
