Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:21203 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752474AbdGEU7e (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jul 2017 16:59:34 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "rkudyba@fordham.edu" <rkudyba@fordham.edu>,
        "greg@kroah.com" <greg@kroah.com>
CC: "kinglongmee@gmail.com" <kinglongmee@gmail.com>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Stable request to fix a reference leak and list
 corruption
Date: Wed, 5 Jul 2017 20:59:25 +0000
Message-ID: <1499288361.63624.2.camel@primarydata.com>
References: <20170628144758.12225-1-trond.myklebust@primarydata.com>
         <20170702085354.GA20685@kroah.com>
         <CAFHi+KQShB-m6GT87uKO=KN0AF-1t0+uXbW7UE2NFyi_wOSLDg@mail.gmail.com>
In-Reply-To: <CAFHi+KQShB-m6GT87uKO=KN0AF-1t0+uXbW7UE2NFyi_wOSLDg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE3LTA3LTA1IGF0IDE2OjI5IC0wNDAwLCBSb2JlcnQgS3VkeWJhIHdyb3RlOg0K
PiA+ID4gQ291bGQgd2UgcGxlYXNlIHF1ZXVlIHVwIHRoZSBmb2xsb3dpbmcgcGF0Y2ggYXMgYSBz
dGFibGUgZml4IGZvcg0KPiA+ID4gY29tbWl0IGE5NzRkZWVlNDc/IEl0IG5lZWRzIHRvIGJlIGFw
cGxpZWQgdG8gdjQuMTAgYW5kIG9sZGVyLg0KPiA+IA0KPiA+IE5vdyBhcHBsaWVkLCB0aGFua3Mu
DQo+IA0KPiBVbnRpbCBrZXJuZWwgNC4xMS45IGlzIGludG8gRmVkb3JhJ3MgdXBkYXRlcywgSSBk
b3duZ3JhZGVkIG91ciBzZXJ2ZXINCj4gYWN0aW5nIGFzIHRoZSBOSVMgbWFzdGVyIHRvIDQuMTAu
MTYtMjAwLiBCdXQgYWxsIE5JUyB1c2VycyB0aW1lIG91dA0KPiB3aXRoICJ5cHNlcnY6ICMwMTEt
PiBFcnJvciAjLTMuIENvdWxkIHRoaXMgYmUgYSBkaWZmZXJlbnQgaXNzdWUgd2l0aA0KPiBycGNi
aW5kIG9yIG5mcy11dGlscz8gSGVyZSBhcmUgc29tZSBkZWJ1ZyBlbmFibGVkIGxvZ3MgZm9yIFJQ
QyB3aXRoIGENCj4gZGlmZmVyZW50IGVycm9yICJ4c19lcnJvcl9yZXBvcnQgY2xpZW50IGZmZmY4
ZDgyMjNjYWEwMDAsIGVycm9yPTExMyINCj4gDQoNCkVycm9yIDExMyBpcyBFSE9TVFVOUkVBQ0gu
IEl0IG1lYW5zIHRoYXQgZWl0aGVyIHlvdXIgc2VydmVyIGlzIGRvd24sIG9yDQp0aGVyZSBpcyBz
b21lIG90aGVyIG5ldHdvcmtpbmcgaXNzdWUgdGhhdCBpcyBwcmV2ZW50aW5nIHRoZSBjbGllbnQg
ZnJvbQ0KY29ubmVjdGluZyB0byBpdCAoZS5nLiBhIGZpcmV3YWxsIHNldHRpbmcsIHJvdXRlIGNv
bmZpZ3VyYXRpb24sIGFycA0KY2FjaGUgcG9sbHV0aW9uPykuIEVpdGhlciB3YXksIGl0IGlzIHVu
cmVsYXRlZCB0byB0aGlzIHBhcnRpY3VsYXINCnBhdGNoLg0KDQotLSANClRyb25kIE15a2xlYnVz
dA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBQcmltYXJ5RGF0YQ0KdHJvbmQubXlrbGVi
dXN0QHByaW1hcnlkYXRhLmNvbQ0K

