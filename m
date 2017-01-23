Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:54663 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750765AbdAWQUy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2017 11:20:54 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: hch <hch@lst.de>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>
CC: "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] nfsd: special case truncates some more
Date: Mon, 23 Jan 2017 16:20:45 +0000
Message-ID: <1485188442.41392.1.camel@primarydata.com>
References: <1485104060-15209-1-git-send-email-hch@lst.de>
         <1485104060-15209-2-git-send-email-hch@lst.de>
         <1485174116.2786.7.camel@poochiereds.net> <20170123123348.GA28102@lst.de>
         <20170123153615.GA32201@lst.de> <1485186729.2786.11.camel@poochiereds.net>
         <20170123160559.GA786@lst.de>
In-Reply-To: <20170123160559.GA786@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDE3LTAxLTIzIGF0IDE3OjA1ICswMTAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gT24gTW9uLCBKYW4gMjMsIDIwMTcgYXQgMTA6NTI6MDlBTSAtMDUwMCwgSmVmZiBMYXl0
b24gd3JvdGU6DQo+ID4gVG8gYmUgY2xlYXIsIHRoZSBjbGllbnQgaXMgcmVxdWVzdGluZyB0byBz
ZXQgdGhlIG10aW1lIHRvIGN1cnJlbnQNCj4gPiBzZXJ2ZXINCj4gPiB0aW1lIGFuZCBub3QgdG8g
YSBzcGVjaWZpYyBtdGltZSwgcmlnaHQ/DQo+IA0KPiBZZXMuwqDCoEFuZCBJIHRoaW5rIGl0J3Mg
bW9zdGx5IHRoZSBMaW51eCBjbGllbnQgYmVpbmcgbGF6eSAtDQo+IEFUVFJfTVRJTUUNCj4gaXMg
d2hhdCBpdCBnZXRzIGZyb20gdGhlIFZGUyBmb3IgYSB0cnVuY2F0ZSBvcGVyYXRpb24gKGJ1dCBu
b3QNCj4gZnRydW5hdGUsDQo+IHNvIHdlIHByb2JhYmx5IHdvbid0IHNlZSBpdCBvbiB0aGUgd2ly
ZSBpbiB0aGF0IGNhc2UsIGJ1dCBJIG5lZWQgdG8NCj4gdmVyaWZ5DQo+IHRoYXQgZmlyc3QpLsKg
wqBZZXQgYW5vdGhlciByZWFzb24gZm9yIC0+dHJ1bmNhdGUgOikNCj4gDQoNCk5vdGUgdGhhdCB0
aGUgUE9TSVggc3BlYyBzZWVtcyB0byBoYXZlIGNoYW5nZWQgcmVjZW50bHkuIFRoZSBjdXJyZW50
DQpzcGVjIGFwcGVhcnMgdG8gc3RhdGUgdGhhdCB3ZSBzaG91bGQgc2V0IHRoZSBtdGltZSBhbmQg
Y3RpbWUgKGFuZA0KY2hhbmdlIGF0dHJpYnV0ZSkgb24gc3VjY2VzcyBpbiBvcGVuKE9fVFJVTkMp
LCB0cnVuY2F0ZSgpIGFuZA0KZnRydW5jYXRlKCkuIEluIHByZXZpb3VzIGluY2FybmF0aW9ucyBv
ZiB0aGUgc3BlYywgdHJ1bmNhdGUoKSB3b3VsZA0Kb25seSBzZXQgdGhlIHRpbWUgaWYgdGhlIHNp
emUgd2FzIGNoYW5nZWQ6DQoNClNlZToNCmh0dHA6Ly9wdWJzLm9wZW5ncm91cC5vcmcvb25saW5l
cHVicy85Njk5OTE5Nzk5L2Z1bmN0aW9ucy9mdHJ1bmNhdGUuaHRtDQpsDQpodHRwOi8vcHVicy5v
cGVuZ3JvdXAub3JnL29ubGluZXB1YnMvOTY5OTkxOTc5OS9mdW5jdGlvbnMvdHJ1bmNhdGUuaHRt
bA0KaHR0cDovL3B1YnMub3Blbmdyb3VwLm9yZy9vbmxpbmVwdWJzLzk2OTk5MTk3OTkvZnVuY3Rp
b25zL29wZW4uaHRtbA0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBt
YWludGFpbmVyLCBQcmltYXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbQ0K

