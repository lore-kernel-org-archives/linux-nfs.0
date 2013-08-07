Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:41022 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932258Ab3HGSTS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 14:19:18 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/4] NFSv4.1 Use clientid management rpc_clnt for
 fs_locations
Date: Wed, 7 Aug 2013 18:19:17 +0000
Message-ID: <1375899556.7280.16.camel@leira.trondhjem.org>
References: <1374511328-49579-1-git-send-email-andros@netapp.com>
	 <1374511328-49579-2-git-send-email-andros@netapp.com>
	 <1375894458.7280.2.camel@leira.trondhjem.org>
	 <479EB531-9CD2-42E2-AB98-A3CD9B13603D@netapp.com>
	 <1375898644.7280.10.camel@leira.trondhjem.org>
In-Reply-To: <1375898644.7280.10.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEzLTA4LTA3IGF0IDE0OjA0IC0wNDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IE9uIFdlZCwgMjAxMy0wOC0wNyBhdCAxODowMSArMDAwMCwgQWRhbXNvbiwgQW5keSB3cm90
ZToNCj4gPiANCj4gPiBIZXJlIGlzIHRoZSBhdHRhY2sgYXMgZGVzY3JpYmVkIGluIDM1MzBiaXMg
U2VjdXJpdHkgQ29uc2lkZXJhdGlvbnMNCj4gPiBzZWN0aW9uOg0KPiA+IA0KPiA+IA0KPiA+ICAg
IFRoZSBzZWNvbmQgb3BlcmF0aW9uIHRoYXQgc2hvdWxkIGRlZmluaXRlbHkgdXNlIGludGVncml0
eSBwcm90ZWN0aW9uDQo+ID4gICAgaXMgYW55IEdFVEFUVFIgZm9yIHRoZSBmc19sb2NhdGlvbnMg
YXR0cmlidXRlLiAgVGhlIGF0dGFjayBoYXMgdHdvDQo+ID4gICAgc3RlcHMuICBGaXJzdCB0aGUg
YXR0YWNrZXIgbW9kaWZpZXMgdGhlIHVucHJvdGVjdGVkIHJlc3VsdHMgb2Ygc29tZQ0KPiA+ICAg
IG9wZXJhdGlvbiB0byByZXR1cm4gTkZTNEVSUl9NT1ZFRC4gIFNlY29uZCwgd2hlbiB0aGUgY2xp
ZW50IGZvbGxvd3MNCj4gPiAgICB1cCB3aXRoIGEgR0VUQVRUUiBmb3IgdGhlIGZzX2xvY2F0aW9u
cyBhdHRyaWJ1dGUsIHRoZSBhdHRhY2tlcg0KPiA+ICAgIG1vZGlmaWVzIHRoZSByZXN1bHRzIHRv
IGNhdXNlIHRoZSBjbGllbnQgbWlncmF0ZSBpdHMgdHJhZmZpYyB0byBhDQo+ID4gICAgc2VydmVy
IGNvbnRyb2xsZWQgYnkgdGhlIGF0dGFja2VyLg0KPiANCj4gWW91IGNhbiB0aGUgZXhhY3Qgc2Ft
ZSB0aGluZyBieSBjaGFuZ2luZyB0aGUgUkVBRExJTksgcmVzdWx0cy4NCg0KVGhlIGF0dGFjayBp
czogY2hhbmdlIHRoZSB1bnByb3RlY3RlZCBMT09LVVAgcmVzdWx0cyB0byBwb2ludCB0byBhDQpz
eW1saW5rLCB0aGVuIGZlZWQgJy9uZXQvPGV2aWwtaXAtYWRkcmVzcz4vbXkvZXZpbC9wYXRobmFt
ZScgaW50bw0KUkVBRExJTksuDQoNCk15IHBvaW50IGlzIHRoYXQgaWYgeW91J3JlIG9uIGEgbmV0
d29yayB3aGVyZSB0aGUgYWJvdmUgaXMgYSBwb3RlbnRpYWwNCnRocmVhdCwgdGhlbiB5b3Ugc2hv
dWxkIGJlIHVzaW5nIGtyYjVpIG9yLCBiZXR0ZXIgeWV0LCBrcmI1cCBmb3IgX2FsbF8NCm9wZXJh
dGlvbnMuIEl0J3Mgbm90IHN1ZmZpY2llbnQgdG8gc2luZ2xlIG91dCBmc19sb2NhdGlvbnMgZm9y
IHNwZWNpYWwNCnRyZWF0bWVudC4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBj
bGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tDQp3
d3cubmV0YXBwLmNvbQ0K
