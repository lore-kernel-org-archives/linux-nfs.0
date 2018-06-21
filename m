Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-sn1nam01on0090.outbound.protection.outlook.com ([104.47.32.90]:31040
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933392AbeFUQ73 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Jun 2018 12:59:29 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "manjunath.b.patil@oracle.com" <manjunath.b.patil@oracle.com>
Subject: Re: [PATCH nfs-utils] mount: handle ENOSPC in nfs_autonegotiate()
Date: Thu, 21 Jun 2018 16:59:26 +0000
Message-ID: <4ea9eda36b96167203e5943385909278d5e7d5d6.camel@hammerspace.com>
References: <1529598860-1960-1-git-send-email-manjunath.b.patil@oracle.com>
In-Reply-To: <1529598860-1960-1-git-send-email-manjunath.b.patil@oracle.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE4LTA2LTIxIGF0IDA5OjM0IC0wNzAwLCBNYW5qdW5hdGggUGF0aWwgd3JvdGU6
DQo+IFRoZSBzZXJ2ZXIgbWF5IHJldHVybiBORlM0RVJSX05PU1BDIGR1cmluZyBORlN2NC4xKyBt
b3VudCBpZiB0aGVyZSBpcw0KPiBhDQo+IG1lbW9yeSBwcmVzc3VyZSB0byBhbGxvY2F0ZSBhIERS
QyBzbG90IGZvciBzZXNzaW9uIGJlaW5nIGNyZWF0ZWQuIEluDQo+IHN1Y2ggY2FzZXMsIHRyeSB3
aXRoIGxvd2VyIG5mcyB2ZXJzaW9ucywgd2hpY2ggbWF5IHN1Y2NlZWQgYXMgRFJDIGlzDQo+IHNo
YXJlZCBieSBjbGllbnRzLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogTWFuanVuYXRoIFBhdGlsIDxt
YW5qdW5hdGguYi5wYXRpbEBvcmFjbGUuY29tPg0KPiAtLS0NCj4gIHV0aWxzL21vdW50L3N0cm9w
dHMuYyB8IDQgKysrKw0KPiAgMSBmaWxlIGNoYW5nZWQsIDQgaW5zZXJ0aW9ucygrKQ0KPiANCj4g
ZGlmZiAtLWdpdCBhL3V0aWxzL21vdW50L3N0cm9wdHMuYyBiL3V0aWxzL21vdW50L3N0cm9wdHMu
Yw0KPiBpbmRleCBkMWIwNzA4Li43ZTk3YTg4IDEwMDY0NA0KPiAtLS0gYS91dGlscy9tb3VudC9z
dHJvcHRzLmMNCj4gKysrIGIvdXRpbHMvbW91bnQvc3Ryb3B0cy5jDQo+IEBAIC04ODEsNiArODgx
LDEwIEBAIGNoZWNrX3Jlc3VsdDoNCj4gIAljYXNlIEVJTlZBTDoNCj4gIAkJLyogQSBsZXNzIGNs
ZWFyIGluZGljYXRpb24gdGhhdCBvdXIgY2xpZW50DQo+ICAJCSAqIGRvZXMgbm90IHN1cHBvcnQg
TkZTdjQgbWlub3IgdmVyc2lvbi4gKi8NCj4gKwljYXNlIEVOT1NQQzoNCj4gKwkJLyogU2VydmVy
IHJldHVybmVkIE5GUzRFUlJfTk9TUEMgZm9yIGNyZWF0ZSBzZXNzaW9uDQo+IFtORlN2NC4xK10u
DQo+ICsJCSAqIFRyeSB3aXRoIGxvd2VyIE5GUyB2ZXJzaW9ucyB3aGljaCBzaGFyZSBEUkMNCj4g
YW1vdW5nIGNsaWVudHMgYW5kDQo+ICsJCSAqIGhlbmNlIGxvdyBtZW1vcnkgbWF5IGJlIG9rLiAq
Lw0KPiAgCWNhc2UgRUFDQ0VTOg0KPiAgCQkvKiBBbiB1bmNsZWFyIGluZGljYXRpb24gdGhhdCB0
aGUgc2VydmVyDQo+ICAJCSAqIG1heSBub3Qgc3VwcG9ydCBORlN2NCBtaW5vciB2ZXJzaW9uLiAq
Lw0KDQpUaGlzIGNvbW1lbnQgbWFrZXMgbm8gc2Vuc2UuIE5GU3Y0LjEgc2VydmVycyBhbHNvIHNo
YXJlIG1lbW9yeSBiZXR3ZWVuDQpjbGllbnRzLCBhbmQgdW5saWtlIG9sZGVyIHZlcnNpb25zIG9m
IE5GUywgdGhleSBoYXZlIHdheXMgdG8gcmVjbGFpbQ0KdGhhdCBtZW1vcnkgKHNlZSBDQl9SRUNB
TExfU0xPVCkuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50
YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg==
