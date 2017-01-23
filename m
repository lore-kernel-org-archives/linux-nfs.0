Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:53440 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750979AbdAWRZm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2017 12:25:42 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: hch <hch@lst.de>
CC: "bfields@redhat.com" <bfields@redhat.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] nfsd: special case truncates some more
Date: Mon, 23 Jan 2017 17:25:34 +0000
Message-ID: <1485192333.34422.1.camel@primarydata.com>
References: <1485104060-15209-1-git-send-email-hch@lst.de>
         <1485104060-15209-2-git-send-email-hch@lst.de>
         <1485174116.2786.7.camel@poochiereds.net> <20170123123348.GA28102@lst.de>
         <20170123153615.GA32201@lst.de> <1485186729.2786.11.camel@poochiereds.net>
         <20170123160559.GA786@lst.de> <1485188442.41392.1.camel@primarydata.com>
         <20170123162607.GA21199@lst.de>
In-Reply-To: <20170123162607.GA21199@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDE3LTAxLTIzIGF0IDE3OjI2ICswMTAwLCBoY2ggd3JvdGU6DQo+IE9uIE1vbiwg
SmFuIDIzLCAyMDE3IGF0IDA0OjIwOjQ1UE0gKzAwMDAsIFRyb25kIE15a2xlYnVzdCB3cm90ZToN
Cj4gPiBOb3RlIHRoYXQgdGhlIFBPU0lYIHNwZWMgc2VlbXMgdG8gaGF2ZSBjaGFuZ2VkIHJlY2Vu
dGx5LiBUaGUNCj4gPiBjdXJyZW50DQo+ID4gc3BlYyBhcHBlYXJzIHRvIHN0YXRlIHRoYXQgd2Ug
c2hvdWxkIHNldCB0aGUgbXRpbWUgYW5kIGN0aW1lIChhbmQNCj4gPiBjaGFuZ2UgYXR0cmlidXRl
KSBvbiBzdWNjZXNzIGluIG9wZW4oT19UUlVOQyksIHRydW5jYXRlKCkgYW5kDQo+ID4gZnRydW5j
YXRlKCkuIEluIHByZXZpb3VzIGluY2FybmF0aW9ucyBvZiB0aGUgc3BlYywgdHJ1bmNhdGUoKSB3
b3VsZA0KPiA+IG9ubHkgc2V0IHRoZSB0aW1lIGlmIHRoZSBzaXplIHdhcyBjaGFuZ2VkOg0KPiAN
Cj4gSW50ZXJlc3RpbmcuwqDCoEJ1dCBpbiB0aGlzIGNhc2UgaGlzdG9yaWNhbCBQb3NpeCBhbmQg
dGh1cyBMaW51eA0KPiBiZWhhdmlvcg0KPiBzdGlsbCB0YWtlcyBwcmVjZWRlbmNlIGFuZCB3ZSdy
ZSBub3Qgc3VkZGVudGx5IGdvaW5nIHRvIGNoYW5nZQ0KPiBiZWhhdmlvci4NCj4gDQoNCg0KSW4g
dGhhdCBjYXNlIHRoZSBjbGllbnQgd2lsbCBiZSByZXF1aXJlZCB0byBjb250aW51ZSB0byBuZWVk
IHRvIHNlbmQNCm10aW1lL2N0aW1lIGluIG9yZGVyIHRvIGVuc3VyZSB0aGF0IHdlIGdldCB0aGUg
c2FtZSBoaXN0b3JpY2FsDQpzZW1hbnRpY3Mgdy5yLnQuIGZ0cnVuY2F0ZSgpIHZzIHRydW5jYXRl
KCkuDQoNCklPVzogSXQncyBub3QgYSBxdWVzdGlvbiBvZiB0aGUgY2xpZW50IGJlaW5nIGxhenkg
YWJvdXQgY2xlYXJpbmcgdGhlDQpmbGFncy4gSXQncyBhIHF1ZXN0aW9uIG9mIGVuZm9yY2luZyB0
aGUgY29ycmVjdCBzZW1hbnRpY3MuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMg
Y2xpZW50IG1haW50YWluZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRh
dGEuY29tDQo=

