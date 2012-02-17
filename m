Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8830 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285Ab2BQTEd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Feb 2012 14:04:33 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q1HJ4N49000485
	for <linux-nfs@vger.kernel.org>; Fri, 17 Feb 2012 11:04:23 -0800 (PST)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH] NFS: include filelayout DS rpc stats in mountstats
Date: Fri, 17 Feb 2012 19:04:13 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9030685@SACEXCMBX04-PRD.hq.netapp.com>
References: <1329502524-27114-1-git-send-email-dros@netapp.com>
 <1329504423.12048.3.camel@lade.trondhjem.org>
 <9E808232-0D4C-4498-8BD8-4856C4D8190F@netapp.com>
In-Reply-To: <9E808232-0D4C-4498-8BD8-4856C4D8190F@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBBZGFtc29uLCBEcm9zDQo+IFNl
bnQ6IEZyaWRheSwgRmVicnVhcnkgMTcsIDIwMTIgMjowMiBQTQ0KPiBUbzogTXlrbGVidXN0LCBU
cm9uZA0KPiBDYzogQWRhbXNvbiwgRHJvczsgbGludXgtbmZzQHZnZXIua2VybmVsLm9yZw0KPiBT
dWJqZWN0OiBSZTogW1BBVENIXSBORlM6IGluY2x1ZGUgZmlsZWxheW91dCBEUyBycGMgc3RhdHMg
aW4gbW91bnRzdGF0cw0KPiANCj4gT24gRmViIDE3LCAyMDEyLCBhdCAxOjQ3IFBNLCBNeWtsZWJ1
c3QsIFRyb25kIHdyb3RlOg0KPiANCj4gPiBPbiBGcmksIDIwMTItMDItMTcgYXQgMTM6MTUgLTA1
MDAsIFdlc3RvbiBBbmRyb3MgQWRhbXNvbiB3cm90ZToNCj4gPj4gSW5jbHVkZSBSUEMgc3RhdGlz
dGljcyBmcm9tIGFsbCBkYXRhIHNlcnZlcnMgaW4gL3Byb2Mvc2VsZi9tb3VudHN0YXRzIGZvcg0K
PiBwTkZTDQo+ID4+IGZpbGVsYXlvdXQgbW91bnRzLg0KPiA+Pg0KPiA+PiBTaWduZWQtb2ZmLWJ5
OiBXZXN0b24gQW5kcm9zIEFkYW1zb24gPGRyb3NAbmV0YXBwLmNvbT4NCj4gPj4gLS0tDQo+ID4+
IFVwZGF0ZTogZG9uJ3QgaW5jcmVtZW50IHRrX2NsaWVudCBzdGF0cyBpZiBjYWxsYmFjayBpcyB1
c2VkLg0KPiA+Pg0KPiA+PiBUaGlzIHN0aWxsIGNoZWNrcyB0YXNrLT50a19jbGllbnQgIT0gTlVM
TCAtLSBJJ20gbm90IGNvbnZpbmNlZCBpdCdzIHVubmVlZGVkDQo+ID4+IGFzIGl0IGV4aXN0ZWQg
aW4gcnBjX2NvdW50X2lvc3RhdHMuDQo+ID4NCj4gPiBJJ2xsIHJlbW92ZSBpdCBiZWZvcmUgYXBw
bHlpbmcuDQo+IA0KPiBJIGNhbiByZXBvc3QgdGhlIHBhdGNoLCBpZiB0aGF0J3MgZWFzaWVyLg0K
DQpOYWguIEkndmUgYWxyZWFkeSBhcHBsaWVkIGFuZCBwdXNoZWQgdG8gdGhlIGdpdCByZXBvc2l0
b3J5Lg0KDQo=
