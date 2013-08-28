Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61858 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754770Ab3H1QcM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Aug 2013 12:32:12 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Matt Craighead <mcraighead@nvidia.com>, Mark Young <MYoung@nvidia.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Issue found with kernel/net/sunrpc/xdr.c
Date: Wed, 28 Aug 2013 16:32:10 +0000
Message-ID: <1377707529.11903.3.camel@leira.trondhjem.org>
References: <1FC56210173BB445BD77F608D6FB8D03620A9978B5@HQMAIL03.nvidia.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA94677C96F@SACEXCMBX04-PRD.hq.netapp.com>
	 <20130828143256.GA2960@fieldses.org>
	 <71D0C6F08977AC42A3EF66AA1BEB0F10A11801ADF5@HQMAIL02.nvidia.com>
	 <20130828154124.GC2960@fieldses.org>
	 <71D0C6F08977AC42A3EF66AA1BEB0F10A11801AE16@HQMAIL02.nvidia.com>
	 <20130828160853.GD2960@fieldses.org>
In-Reply-To: <20130828160853.GD2960@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEzLTA4LTI4IGF0IDEyOjA4IC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIFdlZCwgQXVnIDI4LCAyMDEzIGF0IDA4OjQ3OjU3QU0gLTA3MDAsIE1hdHQgQ3JhaWdo
ZWFkIHdyb3RlOg0KPiA+IE5GU3YzIG92ZXIgVURQLiAgTm8gS2VyYmVyb3Mgb3IgYW55IG90aGVy
IGF1dGhlbnRpY2F0aW9uIG9mIGFueSBzb3J0Lg0KPiANCj4gVHJvbmQsIHNob3VsZG4ndCB0aGUg
c2l6ZSBvZiB0aGUgUlBDIGhlYWRlciBiZSBlbnRpcmVseSBwcmVkaWN0YWJsZSBpbg0KPiB0aGlz
IGNhc2U/ICBJIHdvbmRlciB3aHkgaXQgd2FzIGdldHRpbmcgdG8geGRyX3Nocmlua19idWZoZWFk
Lg0KDQpORlN2MyBwb3N0LW9wIGF0dHJpYnV0ZXMgYXJlIG9wdGlvbmFsIHRvIHJldHVybiwgc28g
d2hpbGUgdGhlIFJQQyBoZWFkZXINCm1heSBiZSBjb21wbGV0ZWx5IHByZWRpY3RhYmxlLCB0aGUg
TkZTIHJlcGx5IHBheWxvYWQgYmVmb3JlIGEgUkVBRCBvcg0KUkVBRERJUiBjYWxsIHRvIHhkcl9y
ZWFkX3BhZ2VzKCkgaXMgbm90Lg0KDQpDaGVlcnMsDQogIFRyb25kDQoNCi0tIA0KVHJvbmQgTXlr
bGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWts
ZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg==
