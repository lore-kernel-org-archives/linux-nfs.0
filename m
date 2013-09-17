Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:41879 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751946Ab3IQB7x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Sep 2013 21:59:53 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Contact <contact@ryper.org>, "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: 16+ GID issue, mountd's --manage-gids not helping
Date: Tue, 17 Sep 2013 01:59:42 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9467CD9A6@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130916094351.263d433d@svelte.ryper.org>
	<20130916193709.GA25308@fieldses.org>
	<20130916175612.012d7301@svelte.ryper.org>
	<20130916232024.GC25308@fieldses.org>	<20130917003825.GD25308@fieldses.org>
 <20130916201105.717449b1@svelte.ryper.org>
In-Reply-To: <20130916201105.717449b1@svelte.ryper.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBsaW51eC1uZnMtb3duZXJAdmdl
ci5rZXJuZWwub3JnIFttYWlsdG86bGludXgtbmZzLQ0KPiBvd25lckB2Z2VyLmtlcm5lbC5vcmdd
IE9uIEJlaGFsZiBPZiBDb250YWN0DQo+IFNlbnQ6IE1vbmRheSwgU2VwdGVtYmVyIDE2LCAyMDEz
IDk6MTEgUE0NCj4gVG86IEouIEJydWNlIEZpZWxkcw0KPiBDYzogbGludXgtbmZzQHZnZXIua2Vy
bmVsLm9yZw0KPiBTdWJqZWN0OiBSZTogMTYrIEdJRCBpc3N1ZSwgbW91bnRkJ3MgLS1tYW5hZ2Ut
Z2lkcyBub3QgaGVscGluZw0KPiANCj4gSGVsbG8sDQo+IA0KPiBNeSBhcG9sb2dpZXMgZm9yIG5v
dCBwcm92aWRpbmcgdGhlIGluZm9ybWF0aW9uIHRoYXQgeW91IHJlcXVlc3RlZC4NCj4gDQo+IChj
bGllbnQpDQo+IHJ5cGVydmVuY2hlQHN2ZWx0ZSB+ICQgaWQNCj4gdWlkPTEwMDAocnlwZXJ2ZW5j
aGUpIGdpZD0xMDAwKHJ5cGVydmVuY2hlKQ0KPiBncm91cHM9MTAwMChyeXBlcnZlbmNoZSksNChh
ZG0pLDYoZGlzayksNyhscCksMTAod2hlZWwpLDE2KGNyb24pLDE4KGF1ZGlvDQo+ICksMjcodmlk
ZW8pLDM1KGdhbWVzKSw3MChwb3N0Z3JlcyksODUodXNiKSwxMDAodXNlcnMpLDEwMyh2Ym94dXNl
cnMpLDEwNSgNCj4gd2lyZXNoYXJrKSwxMDYobHBhZG1pbiksMjQ0KHBsdWdkZXYpLDI0Nihjcm9u
dGFiKSwyNTAocG9ydGFnZSksMTEwMChuZnMpDQo+IA0KPiAoc2VydmVyKQ0KPiBuZnNAbm9pciB+
ICQgaWQNCj4gdWlkPTExMDAobmZzKSBnaWQ9MTEwMChuZnMpIGdyb3Vwcz0xMTAwKG5mcykNCg0K
RG9lcyB0aGUgJy9ldGMvZ3JvdXBzJyBlbnRyaWVzIGZvciB0aGUgdXNlciB3aXRoIHVpZD0xMDAw
IG9uIHRoZSBzZXJ2ZXIgbWF0Y2ggdGhvc2UgbGlzdGVkIGFib3ZlIGZvciB0aGUgY2xpZW50Pw0K
DQotLW1hbmFnZS1naWRzIHdpbGwgb25seSB3b3JrIGNvcnJlY3RseSBpZiB0aGUgL2V0Yy9wYXNz
d2QgYW5kIC9ldGMvZ3JvdXBzIGVudHJpZXMgb24gdGhlIHNlcnZlciBtYXRjaCB0aG9zZSBvbiB0
aGUgY2xpZW50Lg0KDQpDaGVlcnMsDQogIFRyb25kDQo=
