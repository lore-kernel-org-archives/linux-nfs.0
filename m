Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:29592 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651Ab3CRM5m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Mar 2013 08:57:42 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: chenditang <chendt.fnst@cn.fujitsu.com>,
        "bhalevy@tonian.com" <bhalevy@tonian.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        LINE <fnst-xmlinux@cn.fujitsu.com>
Subject: RE: pnfs: WRITE operation will not send LAYOUTCOMMI OP to MDS if
 use filelayout
Date: Mon, 18 Mar 2013 12:57:40 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286D8004@SACEXCMBX04-PRD.hq.netapp.com>
References: <5146BE38.2060004@cn.fujitsu.com>
In-Reply-To: <5146BE38.2060004@cn.fujitsu.com>
Content-Type: text/plain; charset="gb2312"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBsaW51eC1uZnMtb3duZXJAdmdl
ci5rZXJuZWwub3JnIFttYWlsdG86bGludXgtbmZzLQ0KPiBvd25lckB2Z2VyLmtlcm5lbC5vcmdd
IE9uIEJlaGFsZiBPZiBjaGVuZGl0YW5nDQo+IFNlbnQ6IE1vbmRheSwgTWFyY2ggMTgsIDIwMTMg
MzoxMiBBTQ0KPiBUbzogYmhhbGV2eUB0b25pYW4uY29tDQo+IENjOiBsaW51eC1uZnNAdmdlci5r
ZXJuZWwub3JnOyBMSU5FDQo+IFN1YmplY3Q6IHBuZnM6IFdSSVRFIG9wZXJhdGlvbiB3aWxsIG5v
dCBzZW5kIExBWU9VVENPTU1JIE9QIHRvIE1EUyBpZg0KPiB1c2UgZmlsZWxheW91dA0KPiANCj4g
SW4gdGhlIHJlY2VudCBwbmZzIGtlcm5lbCB2ZXJzaW9ucywgV1JJVEUgb3BlcmF0aW9uIHdpbGwg
bm90IHNlbmQNCj4gTEFZT1VUQ09NTUkgT1AgdG8gTURTIGlmIHVzZSBmaWxlbGF5b3V0Lg0KPiAN
Cj4gSW4gbmZzX3dyaXRlX3JwY3NldHVwIGZ1bmN0aW9uLCB0aGUgdmFsdWUgb2YgdGhlIHZhcmlh
YmxlICdzdGFibGUnIHdpbGwgYWx3YXlzDQo+IGJlIE5GU19GSUxFX1NZTkMobmNvbW1pdCBpcyAw
KS4gc28gTkZTX0lOT19MQVlPVVRDT01NSVQgZmxhZyB3aWxsIG5vdA0KPiBiZSBzZXQuDQoNCklm
IHRoZXNlIGFyZSBzbWFsbCBmaWxlcywgdGhlbiB0aGF0IGlzIGV4cGVjdGVkIGJlaGF2aW91ci4g
VGhlIHBORlMgc3BlYyBkb2VzIG5vdCBleGVtcHQgdGhlIERTIGZyb20gaGF2aW5nIHRvIGhvbm91
ciB0aGUgJ3N0YWJsZScgZmxhZy4NCg0KQ2hlZXJzDQogIFRyb25kDQo=
