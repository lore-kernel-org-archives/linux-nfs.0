Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:34532 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751944AbdDMSva (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Apr 2017 14:51:30 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bjschuma@netapp.com" <bjschuma@netapp.com>,
        "aglo@umich.edu" <aglo@umich.edu>
Subject: Re: RFC: fixing kernel oops on interrupted COMMIT from
 nfs_commit_file
Date: Thu, 13 Apr 2017 18:51:25 +0000
Message-ID: <1492109480.7917.1.camel@primarydata.com>
References: <CAN-5tyHD9NspwAzL2YwoQGwcUk52ak0OWZ-dBfwpW6nynAf1Og@mail.gmail.com>
In-Reply-To: <CAN-5tyHD9NspwAzL2YwoQGwcUk52ak0OWZ-dBfwpW6nynAf1Og@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE3LTA0LTEzIGF0IDE0OjAwIC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gSGkgZm9sa3MsDQo+IA0KPiBMb29raW5nIGZvciBzdWdnZXN0aW9ucyBvbiBob3cgdG8g
Zml4IGEga2VybmVsIG9vcHMuDQo+IA0KPiBJdCdzIHBvc3NpYmxlIHRoYXQgdGhlcmUgaXMgYSBj
dHJsLWMgd2hlbiB0aGUgQ09NTUlUIGlzIHNlbmQuIEluIGNhc2UNCj4gb2YgdGhlIENPUFksIGl0
IGNhbGxzDQo+IG5mc19jb21taXRfZmlsZSgpIHdoaWNoIGNhbGxzIHdhaXRfb25fY29tbWl0KCkg
dGhhdCBpcyBpbnRlcnJ1cHRlZCBieQ0KPiB0aGUgY3J0bC1jIGFuZCBmcmVlcyB0aGUgbmZzX3Bh
Z2UgcmVxdWVzdC4gU28gd2hlbiBhc3luY2hyb25vdXMNCj4gQ09NTUlUDQo+IHJwYyBjb21lcyBi
YWNrIGl0IHRyaWVkIHRvIHVzZSB0aGUgbmZzX3BhZ2UgcmVxdWVzdCBhbmQgZ2V0cyB0aGUNCj4g
b29wcy4NCj4gDQoNCklzIHRoYXQgY2FsbCB0byBuZnNfZnJlZV9yZXF1ZXN0KCkgaW4gbmZzX2Nv
bW1pdF9maWxlKCkgY29ycmVjdD8gSXQNCmxvb2tzIHRvIG1lIGFzIGlmIHRoZSBzYW1lIHJlcXVl
c3Qgd2lsbCBiZSBmcmVlZCBpbg0KbmZzX2NvbW1pdF9yZWxlYXNlX3BhZ2VzKCkuDQoNCkFubmE/
DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIFBy
aW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

