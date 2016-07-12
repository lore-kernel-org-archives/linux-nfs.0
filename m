Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:36235 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752740AbcGLRQX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2016 13:16:23 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Steve Dickson <steved@redhat.com>
Subject: Re: Lost CLOSE with NFSv4.1 on RHEL7 ( and bejond?)
Date: Tue, 12 Jul 2016 17:16:19 +0000
Message-ID: <34F13011-FB4A-4ACD-9DDC-BAD3F7EC9B56@netapp.com>
References: <1485779983.22627050.1467888579184.JavaMail.zimbra@desy.de>
In-Reply-To: <1485779983.22627050.1467888579184.JavaMail.zimbra@desy.de>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SGkgVGlncmFuDQoNCkNhbiB5b3UgdGVzdCB3aXRoIGFuIHVwc3RyZWFtIGtlcm5lbD8gT2xnYSBo
YXMgc2VlbiBpc3N1ZXMgYXJvdW5kIG5vIENMT1NFIGJlaW5nIHNlbnQgLSBpdCBpcyByZWFsbHkg
aGFyZCB0byByZXByb2R1Y2XigKYuDQoNCuKAlD5BbmR5DQoNCg0KPiBPbiBKdWwgNywgMjAxNiwg
YXQgNjo0OSBBTSwgTWtydGNoeWFuLCBUaWdyYW4gPHRpZ3Jhbi5ta3J0Y2h5YW5AZGVzeS5kZT4g
d3JvdGU6DQo+IA0KPiANCj4gDQo+IERlYXIgTkZTIGZvbGtzLA0KPiANCj4gd2Ugb2JzZXJ2ZSBv
cnBoYW4gb3Blbi1zdGF0ZXMgb24gb3VyIGRlcGxveW1lbnQgd2l0aCBuZnN2NC4xLg0KPiBPdXIg
c2V0dXAgLSB0d28gY2xpZW50IG5vZGVzLCBydW5uaW5nIFJIRUwtNy4yIHdpdGgga2VybmVsDQo+
IDMuMTAuMC0zMjcuMjIuMi5lbDcueDg2XzY0LiBCb3RoIG5vZGVzIHJ1bm5pbmcgb3duQ2xvdWQg
KGxpa2UNCj4gYSBkcm9wYm94KSB3aGljaCBuZnN2NC4xIG1vdW50cyB0byBkQ2FjaGUgc3RvcmFn
ZS4gU29tZSBjbGllbnRzDQo+IGNvbm5lY3RlZCB0byBub2RlMSwgb3RoZXJzIHRvIG5vZGUyLg0K
PiANCj4gVGltZS10by10aW1lIHdlIHNlZSBzb21lICdhY3RpdmUnIHRyYW5zZmVycyBvbiBkYXRh
IG91ciBEUw0KPiB3aGljaCBkbyBub3RoaW5nLiBUaGVyZSBpcyBhIGNvcnJlc3BvbmRpbmcgc3Rh
dGUgb24gTURTLg0KPiANCj4gSSBoYXZlIHRyYWNlZCBvbmUgb25lIHN1Y2ggY2FzZXM6DQo+IA0K
PiAgLSBub2RlMSB1cGxvYWRzIHRoZSBmaWxlLg0KPiAgLSBub2RlMiByZWFkcyB0aGUgZmlsZSBj
b3VwbGUgb2YgdGltZXMsIE9QRU4rTEFZT1VUR0VUK0NMT1NFDQo+ICAtIG5vZGUyIHNlbmRzIE9Q
RU4rTEFZT1VUR0VUDQo+ICAtIHRoZXJlIGlzIG5vIG9wZW4gZmlsZSBvbiBub2RlMiB3aGljaCBw
b2ludHMgdG8gaXQuDQo+ICAtIENMT1NFIG5ldmVyIHNlbmQgdG8gdGhlIHNlcnZlci4gDQo+ICAt
IG5vZGUxIGV2ZW50dWFsbHkgcmVtb3ZlcyB0aGUgcmVtb3ZlcyB0aGUgZmlsZQ0KPiANCj4gV2Ug
aGF2ZSBtYW55IG90aGVyIGNhc2VzIHdoZXJlIGZpbGUgaXMgbm90IHJlbW92ZWQsIGJ1dCB0aGlz
IG9uZSBJIHdhcw0KPiBhYmxlIHRvIHRyYWNlLiBUaGUgbGluayB0byBjYXB0dXJlIGZpbGVzOg0K
PiANCj4gaHR0cHM6Ly9kZXN5Y2xvdWQuZGVzeS5kZS9pbmRleC5waHAvcy9ZbGRvd2NSelRHSmVM
Yk4NCj4gDQo+IFdlIGhhZCB+IDEwXjYgdHJhbnNmZXJzIGluIGxhc3QgMiBkYXlzIGFuZCAyOSBm
aWxlcyBpbiBzdWNoIHN0YXRlICh+MC4wMDI5JSkuDQo+IA0KPiBUaWdyYW4uDQoNCg==
