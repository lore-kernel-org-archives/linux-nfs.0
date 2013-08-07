Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13993 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932088Ab3HGSgT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 14:36:19 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/4] NFSv4.1 Use clientid management rpc_clnt for
 fs_locations
Date: Wed, 7 Aug 2013 18:36:16 +0000
Message-ID: <1375900575.7280.26.camel@leira.trondhjem.org>
References: <1374511328-49579-1-git-send-email-andros@netapp.com>
	 <1374511328-49579-2-git-send-email-andros@netapp.com>
	 <1375894458.7280.2.camel@leira.trondhjem.org>
	 <479EB531-9CD2-42E2-AB98-A3CD9B13603D@netapp.com>
	 <1375898644.7280.10.camel@leira.trondhjem.org>
	 <1375899556.7280.16.camel@leira.trondhjem.org>
	 <015EF10A-7962-484C-90D1-A1520E8B3431@netapp.com>
In-Reply-To: <015EF10A-7962-484C-90D1-A1520E8B3431@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEzLTA4LTA3IGF0IDE4OjMyICswMDAwLCBBZGFtc29uLCBBbmR5IHdyb3RlOg0K
PiBPbiBBdWcgNywgMjAxMywgYXQgMjoxOSBQTSwgIk15a2xlYnVzdCwgVHJvbmQiIDxUcm9uZC5N
eWtsZWJ1c3RAbmV0YXBwLmNvbT4NCj4gIHdyb3RlOg0KPiANCj4gPiBPbiBXZWQsIDIwMTMtMDgt
MDcgYXQgMTQ6MDQgLTA0MDAsIFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4gPj4gT24gV2VkLCAy
MDEzLTA4LTA3IGF0IDE4OjAxICswMDAwLCBBZGFtc29uLCBBbmR5IHdyb3RlOg0KPiA+Pj4gDQo+
ID4+PiBIZXJlIGlzIHRoZSBhdHRhY2sgYXMgZGVzY3JpYmVkIGluIDM1MzBiaXMgU2VjdXJpdHkg
Q29uc2lkZXJhdGlvbnMNCj4gPj4+IHNlY3Rpb246DQo+ID4+PiANCj4gPj4+IA0KPiA+Pj4gICBU
aGUgc2Vjb25kIG9wZXJhdGlvbiB0aGF0IHNob3VsZCBkZWZpbml0ZWx5IHVzZSBpbnRlZ3JpdHkg
cHJvdGVjdGlvbg0KPiA+Pj4gICBpcyBhbnkgR0VUQVRUUiBmb3IgdGhlIGZzX2xvY2F0aW9ucyBh
dHRyaWJ1dGUuICBUaGUgYXR0YWNrIGhhcyB0d28NCj4gPj4+ICAgc3RlcHMuICBGaXJzdCB0aGUg
YXR0YWNrZXIgbW9kaWZpZXMgdGhlIHVucHJvdGVjdGVkIHJlc3VsdHMgb2Ygc29tZQ0KPiA+Pj4g
ICBvcGVyYXRpb24gdG8gcmV0dXJuIE5GUzRFUlJfTU9WRUQuICBTZWNvbmQsIHdoZW4gdGhlIGNs
aWVudCBmb2xsb3dzDQo+ID4+PiAgIHVwIHdpdGggYSBHRVRBVFRSIGZvciB0aGUgZnNfbG9jYXRp
b25zIGF0dHJpYnV0ZSwgdGhlIGF0dGFja2VyDQo+ID4+PiAgIG1vZGlmaWVzIHRoZSByZXN1bHRz
IHRvIGNhdXNlIHRoZSBjbGllbnQgbWlncmF0ZSBpdHMgdHJhZmZpYyB0byBhDQo+ID4+PiAgIHNl
cnZlciBjb250cm9sbGVkIGJ5IHRoZSBhdHRhY2tlci4NCj4gPj4gDQo+ID4+IFlvdSBjYW4gdGhl
IGV4YWN0IHNhbWUgdGhpbmcgYnkgY2hhbmdpbmcgdGhlIFJFQURMSU5LIHJlc3VsdHMuDQo+ID4g
DQo+ID4gVGhlIGF0dGFjayBpczogY2hhbmdlIHRoZSB1bnByb3RlY3RlZCBMT09LVVAgcmVzdWx0
cyB0byBwb2ludCB0byBhDQo+ID4gc3ltbGluaywgdGhlbiBmZWVkICcvbmV0LzxldmlsLWlwLWFk
ZHJlc3M+L215L2V2aWwvcGF0aG5hbWUnIGludG8NCj4gPiBSRUFETElOSy4NCj4gDQo+IERvZXMg
dGhlIGxpbnV4IGNsaWVudCBhY3R1YWxseSBmb2xsb3cgbGlua3Mgd2l0aCBlbWJlZGRlZCBJUCBh
ZGRyZXNzZXM/DQoNCklmIHlvdSBoYXZlIGF1dG9mcyBvciBhbWQgcnVubmluZyBvbiB5b3VyIGNs
aWVudCwgdGhlbiBzdXJlLi4uDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xp
ZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3
Lm5ldGFwcC5jb20NCg==
