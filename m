Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:27008 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751024AbeCHWBs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Mar 2018 17:01:48 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        "smayhew@redhat.com" <smayhew@redhat.com>
CC: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: nfs_commit_inode should redirty inode if the inode
 has outstanding requests
Date: Thu, 8 Mar 2018 22:01:42 +0000
Message-ID: <1520546500.91818.2.camel@primarydata.com>
References: <20180302160038.1598-1-smayhew@redhat.com>
         <20180305211619.GA29226@fieldses.org>
         <1520286491.21829.13.camel@primarydata.com>
         <20180307195313.kzqdboqk5j2hyrf3@tonberry.usersys.redhat.com>
         <1520455098.2858.4.camel@primarydata.com>
         <20180308130901.h2qbbzsuejggogut@tonberry.usersys.redhat.com>
         <20180308213904.GD16485@fieldses.org>
In-Reply-To: <20180308213904.GD16485@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE4LTAzLTA4IGF0IDE2OjM5IC0wNTAwLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3
cm90ZToNCj4gT24gVGh1LCBNYXIgMDgsIDIwMTggYXQgMDg6MDk6MDFBTSAtMDUwMCwgU2NvdHQg
TWF5aGV3IHdyb3RlOg0KPiA+IFllcywgdGhpcyB3b3Jrcy4gIEkgcmFuIGl0IHRocm91Z2ggYSBk
b3plbiBmaW8gcnVucyBvbiB2NC4xIGFuZA0KPiA+IDEwMDAgcnVucw0KPiA+IG9mIGdlbmVyaWMv
MjQ3IG9uIHYzL3Y0LjAvdjQuMS92NC4yIGFuZCBkaWRuJ3Qgc2VlIGFueSBFQlVTWQ0KPiA+IGVy
cm9ycy4NCj4gPiBBbHNvIHJhbiB0aGUgeGZzdGVzdHMgInF1aWNrIiBncm91cCAofjgwLTkwIHRl
c3RzKSBwbHVzIGdlbmVyaWMvMDc0DQo+ID4gb24NCj4gPiB2My92NC4wL3Y0LjEvdjQuMi4gIEZp
bmFsbHksIEkgZG91YmxlIGNoZWNrZWQgdGhlIHBhbmljIG9uIHVtb3VudA0KPiA+IGlzc3VlDQo+
ID4gdGhhdCBkYzRmZDlhYjAxYWIzIGZpeGVkIGFuZCB0aGF0IHN0aWxsIHdvcmtzIHRvby4NCj4g
DQo+IFdvcmtzIGZvciBtZSB0b28uDQo+IA0KPiAoWWVhaCwgSSBzZWUgdGhlcmUncyBhIG5ldyBw
YXRjaC4gIFRlc3RpbmcgcXVldWVkIHVwIGJ1dCBub3QgcnVuDQo+IHlldC4uLikuDQoNClNvcnJ5
IGZvciBwdWxsaW5nIHRoZSAibmV3IHBhdGNoIHN3aXRjaCIgb24geW91IGJvdGgsIGJ1dCBJIGZp
Z3VyZWQgaXQNCndvdWxkIGJlIGJldHRlciB0byByZS1leGFtaW5lIHdoZXJlIHRoZSByZXF1aXJl
bWVudCBmb3IgdGhlIGRpcnR5IGZsYWcNCmlzIGNvbWluZyBmcm9tLCBhbmQgdG8gZW5zdXJlIHRo
YXQgd2UgbWVldCB0aGF0IHJlcXVpcmVtZW50IG9uY2UgYW5kDQpmb3IgYWxsLg0KDQotLSANClRy
b25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBQcmltYXJ5RGF0YQ0K
dHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbQ0K

