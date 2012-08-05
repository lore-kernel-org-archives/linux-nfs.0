Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48963 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755279Ab2HEXfN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Aug 2012 19:35:13 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "makc@redhat.com" <makc@redhat.com>
Subject: Re: [PATCH RFC] nfs: allow coalescing of read/write requests under
 more circumstances
Date: Sun, 5 Aug 2012 23:34:55 +0000
Message-ID: <1344209694.4040.20.camel@lade.trondhjem.org>
References: <1344000550-25356-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1344000550-25356-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTA4LTAzIGF0IDA5OjI5IC0wNDAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4g
VGhpcyBwYXRjaCBpcyBhbiBSRkMgZm9yIGRlYWxpbmcgd2l0aCBhIHJlZ3Jlc3Npb24gaW4gd3Jp
dGUgcGVyZm9ybWFuY2UNCj4gd2hlbiB0aGVyZSBhcmUgbXVsdGlwbGUgcHJvY2Vzc2VzIGRvaW5n
IEkvTyB0byB0aGUgc2FtZSBwYWdlcyBvbiB0aGUNCj4gc2FtZSBtYWNoaW5lLiBFYXJsaWVyIHRo
aXMgd2VlaywgSSBvdXRsaW5lZCB0aGUgcHJvYmxlbSBoZXJlOg0KPiANCj4gICAgIGh0dHA6Ly93
d3cuc3Bpbmljcy5uZXQvbGlzdHMvbGludXgtbmZzL21zZzMxNzI4Lmh0bWwNCj4gDQo+IFRoaXMg
cGF0Y2ggc2VlbXMgdG8gcmVzb2x2ZSB0aGUgcHJvYmxlbSwgYnV0IEkgc3RpbGwgaGF2ZW4ndCBx
dWl0ZQ0KPiBjb252aW5jZWQgbXlzZWxmIHRoYXQgdGhpcyBhcHByb2FjaCBpcyByYWNlLWZyZWUu
IFRob3VnaHRzPw0KDQpJJ2QgcHJlZmVyIHRvIHJlcGxhY2UgdGhlICJwb2ludGVyIHRvIGxvY2sg
b3duZXIiIHdpdGggYSAicG9pbnRlciB0bw0Kb3Blbi9sb2NrIHN0YXRlaWQiLiBCeSB0YWdnaW5n
IHRoZSBkYXRhIHdpdGggdGhlIHNwZWNpZmljIHN0YXRlaWQsIHRoYXQNCndhcyBpbiBlZmZlY3Qg
d2hlbiB3ZSBjcmVhdGVkIHRoZSBuZnNfcGFnZSwgdGhlbiB3ZSBrbm93IHdoZW4gdG8gZmVuY2UN
Cm9mZiB0aGF0IHBhcnRpY3VsYXIgUkVBRCBvciBXUklURSBpZiBhIG5ldHdvcmsgcGFydGl0aW9u
IGNhdXNlcyBhbg0KaXJyZWNvdmVyYWJsZSBsb3NzIG9mIHRoZSBsb2NrLg0KDQpJJ20gcGxhbm5p
bmcgb24gZHJhZnRpbmcgYSBwYXRjaCBmb3IgdGhpcyB0b21vcnJvdy4uLg0KDQpDaGVlcnMNCiAg
VHJvbmQNCg==
