Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:21236 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751110AbdBRAC3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Feb 2017 19:02:29 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "aglo@umich.edu" <aglo@umich.edu>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] NFSv4: Fix reboot recovery in copy offload
Date: Sat, 18 Feb 2017 00:02:22 +0000
Message-ID: <1487376138.62293.1.camel@primarydata.com>
References: <CAN-5tyFM88h5XMvnYQ3hnq6DgE_wsctFhjQuX_bAvUJkr3xKjw@mail.gmail.com>
         <20170217234232.62140-1-trond.myklebust@primarydata.com>
In-Reply-To: <20170217234232.62140-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE3LTAyLTE3IGF0IDE4OjQyIC0wNTAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IENvcHkgb2ZmbG9hZCBjb2RlIG5lZWRzIHRvIGJlIGhvb2tlZCBpbnRvIHRoZSBjb2RlIGZv
ciBoYW5kbGluZw0KPiBORlM0RVJSX0JBRF9TVEFURUlEIGJ5IGVuc3VyaW5nIHRoYXQgd2Ugc2V0
IHRoZSAic3RhdGVpZCIgZmllbGQNCj4gaW4gc3RydWN0IG5mczRfZXhjZXB0aW9uLg0KPiANCj4g
UmVwb3J0ZWQtYnk6IE9sZ2EgS29ybmlldnNrYWlhIDxhZ2xvQHVtaWNoLmVkdT4NCj4gRml4ZXM6
IDJlNzI0NDhiMDdkYzMgKCJORlM6IEFkZCBDT1BZIG5mcyBvcGVyYXRpb24iKQ0KPiBTaWduZWQt
b2ZmLWJ5OiBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20+
DQo+IC0tLQ0KDQp2MyBjaGFuZ2U6IGFzaWRlIGZyb20gdGhlIHBvaW50ZXIgaXNzdWUgaW4gX25m
czQyX3Byb2NfY29weSgpIHRoYXQgd2FzDQpub3RlZCBieSBPbGdhLCBJIHdlbnQgYmFjayB0byB0
aGUgb3JpZ2luYWwgZGVzaWduIGZvciByZWNvdmVyeS4gVGhlDQpmYWN0IHRoYXQgdGhpcyBpcyBO
RlN2NC4yIG1lYW5zIHRoYXQgd2Ugc2hvdWxkIGJlIGNhbGxpbmcgVEVTVF9TVEFURUlEDQpiZWZv
cmUgZGV0ZXJtaW5pbmcgdGhhdCB0aGUgQkFEX1NUQVRFSUQgYXBwbGllcy4NCg0KLS0gDQpUcm9u
ZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgUHJpbWFyeURhdGENCnRy
b25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

