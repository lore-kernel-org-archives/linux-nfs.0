Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:7135 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756709Ab3ICSuf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Sep 2013 14:50:35 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: William Dauchy <wdauchy@gmail.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        William Dauchy <william@gandi.net>
Subject: Re: [PATCH v2] NFS: Ensure that rmdir() waits for sillyrenames to
 complete
Date: Tue, 3 Sep 2013 18:50:34 +0000
Message-ID: <1378234234.6410.36.camel@leira.trondhjem.org>
References: <1378145871-30071-1-git-send-email-Trond.Myklebust@netapp.com>
	 <CAJ75kXbRgsYVRNobCmjeL-t+AJproq8jAxXkbkk9DxGnE9eYhQ@mail.gmail.com>
In-Reply-To: <CAJ75kXbRgsYVRNobCmjeL-t+AJproq8jAxXkbkk9DxGnE9eYhQ@mail.gmail.com>
Content-Type: multipart/mixed;
	boundary="_002_1378234234641036camelleiratrondhjemorg_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_1378234234641036camelleiratrondhjemorg_
Content-Type: text/plain; charset="utf-8"
Content-ID: <1A2809469691944FB3066F0930E47C97@hq.netapp.com>
Content-Transfer-Encoding: base64

T24gVHVlLCAyMDEzLTA5LTAzIGF0IDExOjMzICswMjAwLCBXaWxsaWFtIERhdWNoeSB3cm90ZToN
Cj4gT24gTW9uLCBTZXAgMiwgMjAxMyBhdCA4OjE3IFBNLCBUcm9uZCBNeWtsZWJ1c3QNCj4gPFRy
b25kLk15a2xlYnVzdEBuZXRhcHAuY29tPiB3cm90ZToNCj4gPiBJZiBhbiBORlMgY2xpZW50IGRv
ZXMNCj4gPg0KPiA+ICAgICAgICAgbWtkaXIoImRpciIpOw0KPiA+ICAgICAgICAgZmQgPSBvcGVu
KCJkaXIvZmlsZSIpOw0KPiA+ICAgICAgICAgdW5saW5rKCJkaXIvZmlsZSIpOw0KPiA+ICAgICAg
ICAgY2xvc2UoZmQpOw0KPiA+ICAgICAgICAgcm1kaXIoImRpciIpOw0KPiA+DQo+ID4gdGhlbiB0
aGUgYXN5bmNocm9ub3VzIG5hdHVyZSBvZiB0aGUgc2lsbHlyZW5hbWUgb3BlcmF0aW9uIG1lYW5z
IHRoYXQNCj4gPiB3ZSBjYW4gZW5kIHVwIGdldHRpbmcgRUJVU1kgZm9yIHRoZSBybWRpcigpIGlu
IHRoZSBhYm92ZSB0ZXN0LiBGaXgNCj4gPiB0aGF0IGJ5IGVuc3VyaW5nIHRoYXQgd2Ugd2FpdCBm
b3IgYW55IGluLXByb2dyZXNzIHNpbGx5cmVuYW1lcw0KPiA+IGJlZm9yZSBzZW5kaW5nIHRoZSBy
bWRpcigpIHRvIHRoZSBzZXJ2ZXIuDQo+IA0KPiBJIHRlc3RlZCB0aGUgcGF0Y2ggb24gdG9wIG9m
IGEgMy4xMC54DQo+IFdoZW4gZG9pbmcgaGVhdnkgb3BlcmF0aW9ucyBsaWtlIHJtIC1yZiBkaXIv
IHdpdGggbG90cyBvZiBkYXRhLCB0aGUNCj4gcHJvY2VzcyBnZXRzIHN0dWNrIGZvciBldmVyLg0K
PiByZW1vdmluZyB0aGUgcGF0Y2ggZml4ZXMgdGhlIGlzc3VlLg0KPiANCg0KSGkgV2lsbGlhbSwN
Cg0KVGhhbmtzIGFnYWluIGZvciB0ZXN0aW5nISBEb2VzIHRoZSBmb2xsb3dpbmcgZml4dXAgb24g
dG9wIG9mIHRoZSAndjInDQpwYXRjaCBhbHNvIGhlbHA/DQoNCkNoZWVycw0KICBUcm9uZA0KDQot
LSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFw
cA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQo=

--_002_1378234234641036camelleiratrondhjemorg_
Content-Type: text/x-patch;
	name="0001-fixup-NFS-Ensure-that-rmdir-waits-for-sillyrenames-t.patch"
Content-Description: 0001-fixup-NFS-Ensure-that-rmdir-waits-for-sillyrenames-t.patch
Content-Disposition: attachment;
	filename="0001-fixup-NFS-Ensure-that-rmdir-waits-for-sillyrenames-t.patch";
	size=803; creation-date="Tue, 03 Sep 2013 18:50:34 GMT";
	modification-date="Tue, 03 Sep 2013 18:50:34 GMT"
Content-ID: <57F3B4C358670C48BE14B8FDB81C0091@hq.netapp.com>
Content-Transfer-Encoding: base64

RnJvbSAyODc1ZTZmMzY3NTVkYjEyZWQ2YTViMzYzZjBkMTRhMjZmY2I0OTViIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDxUcm9uZC5NeWtsZWJ1c3RAbmV0
YXBwLmNvbT4NCkRhdGU6IFR1ZSwgMyBTZXAgMjAxMyAxNDo0ODoyMSAtMDQwMA0KU3ViamVjdDog
W1BBVENIXSBmaXh1cCEgTkZTOiBFbnN1cmUgdGhhdCBybWRpcigpIHdhaXRzIGZvciBzaWxseXJl
bmFtZXMgdG8NCiBjb21wbGV0ZQ0KDQotLS0NCiBmcy9uZnMvdW5saW5rLmMgfCAyICstDQogMSBm
aWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pDQoNCmRpZmYgLS1naXQg
YS9mcy9uZnMvdW5saW5rLmMgYi9mcy9uZnMvdW5saW5rLmMNCmluZGV4IDBjNmRmZTAuLmJiOTM5
ZWQgMTAwNjQ0DQotLS0gYS9mcy9uZnMvdW5saW5rLmMNCisrKyBiL2ZzL25mcy91bmxpbmsuYw0K
QEAgLTIxMSw3ICsyMTEsNyBAQCB2b2lkIG5mc193YWl0X29uX3NpbGx5cmVuYW1lKHN0cnVjdCBk
ZW50cnkgKmRlbnRyeSkNCiB7DQogCXN0cnVjdCBuZnNfaW5vZGUgKm5mc2kgPSBORlNfSShkZW50
cnktPmRfaW5vZGUpOw0KIA0KLQl3YWl0X2V2ZW50KG5mc2ktPndhaXRxdWV1ZSwgYXRvbWljX3Jl
YWQoJm5mc2ktPnNpbGx5X2NvdW50KSA9PSAxKTsNCisJd2FpdF9ldmVudChuZnNpLT53YWl0cXVl
dWUsIGF0b21pY19yZWFkKCZuZnNpLT5zaWxseV9jb3VudCkgPD0gMSk7DQogfQ0KIA0KIHZvaWQg
bmZzX2Jsb2NrX3NpbGx5cmVuYW1lKHN0cnVjdCBkZW50cnkgKmRlbnRyeSkNCi0tIA0KMS44LjMu
MQ0KDQo=

--_002_1378234234641036camelleiratrondhjemorg_--
