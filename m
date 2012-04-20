Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48757 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757495Ab2DTTqe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 15:46:34 -0400
Received: from vmwexceht02-prd.hq.netapp.com (vmwexceht02-prd.hq.netapp.com [10.106.76.240])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q3KJkHsR012406
	for <linux-nfs@vger.kernel.org>; Fri, 20 Apr 2012 12:46:17 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Isaman, Fred" <Fred.Isaman@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 18/25] NFS: prepare coalesce testing for directio
Date: Fri, 20 Apr 2012 19:46:16 +0000
Message-ID: <1334951175.3295.17.camel@lade.trondhjem.org>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
	 <1334947677-28864-19-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-19-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTA0LTIwIGF0IDE0OjQ3IC0wNDAwLCBGcmVkIElzYW1hbiB3cm90ZToNCj4g
VGhlIGNvYWxlc2NlIGNvZGUgbWFkZSBhc3N1bXB0aW9ucyB0aGF0IHdpbGwgbm8gbG9uZ2VyIGJl
IHRydWUgb25jZQ0KPiBub24tcGFnZSBhbGlnbmVkIGlvIG9jY3Vycy4gIFRoaXMgaW50cm9kdWNl
cyBubyBjaGFuZ2UgaW4NCj4gY3VycmVudCBiZWhhdmlvciwgYnV0IGFsbG93cyBmb3IgbW9yZSBn
ZW5lcmFsIHNpdHVhdGlvbnMgdG8gY29tZS4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEZyZWQgSXNh
bWFuIDxpaXNhbWFuQG5ldGFwcC5jb20+DQo+IC0tLQ0KPiAgZnMvbmZzL25mczRmaWxlbGF5b3V0
LmMgfCAgIDEyICsrKysrKysrKysrKw0KPiAgZnMvbmZzL3BhZ2VsaXN0LmMgICAgICAgfCAgICAy
ICstDQo+ICBmcy9uZnMvcG5mcy5jICAgICAgICAgICB8ICAgIDggKysrKysrKysNCj4gIDMgZmls
ZXMgY2hhbmdlZCwgMjEgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYg
LS1naXQgYS9mcy9uZnMvcGFnZWxpc3QuYyBiL2ZzL25mcy9wYWdlbGlzdC5jDQo+IGluZGV4IDVk
MDFhMTYuLmIzNDQ5NDYgMTAwNjQ0DQo+IC0tLSBhL2ZzL25mcy9wYWdlbGlzdC5jDQo+ICsrKyBi
L2ZzL25mcy9wYWdlbGlzdC5jDQo+IEBAIC0yODAsNyArMjgwLDcgQEAgc3RhdGljIGJvb2wgbmZz
X2Nhbl9jb2FsZXNjZV9yZXF1ZXN0cyhzdHJ1Y3QgbmZzX3BhZ2UgKnByZXYsDQo+ICAJCXJldHVy
biBmYWxzZTsNCj4gIAlpZiAocmVxLT53Yl9jb250ZXh0LT5zdGF0ZSAhPSBwcmV2LT53Yl9jb250
ZXh0LT5zdGF0ZSkNCj4gIAkJcmV0dXJuIGZhbHNlOw0KPiAtCWlmIChyZXEtPndiX2luZGV4ICE9
IChwcmV2LT53Yl9pbmRleCArIDEpKQ0KPiArCWlmIChyZXFfb2Zmc2V0KHJlcSkgIT0gcmVxX29m
ZnNldChwcmV2KSArIHByZXYtPndiX2J5dGVzKQ0KDQpDYW4gd2UgbWljcm8tb3B0aW1pc2UgdGhp
cyBqdXN0IGEgdGVlbnN5IGJpdCBieSBtb3ZpbmcgaXQgdW50aWwgYWZ0ZXINCnRoZSByZXEtPndi
X2Jhc2UgYW5kIHByZXYtPndiX2Jhc2UgdGVzdHM/IFNpbmNlIHRob3NlIGFyZQ0KY29tcHV0YXRp
b25hbGx5IHNpbXBsZXIsIGRvaW5nIHRoZW0gZmlyc3QgbWlnaHQgbWFrZSB0aGUgImNhbid0DQpj
b2FsZXNjZSIgdGVzdCBhIGxpdHRsZSBmYXN0ZXIuDQoNCj4gIAkJcmV0dXJuIGZhbHNlOw0KPiAg
CWlmIChyZXEtPndiX3BnYmFzZSAhPSAwKQ0KPiAgCQlyZXR1cm4gZmFsc2U7DQoNCg0KLS0gDQpU
cm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRy
b25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
