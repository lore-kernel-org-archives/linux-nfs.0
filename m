Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcdn-iport-7.cisco.com ([173.37.86.78]:22735 "EHLO
        rcdn-iport-7.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754148AbeEaUOv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2018 16:14:51 -0400
From: "Shawn Lu (shawlu)" <shawlu@cisco.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: Joshua Watt <jpewhacker@gmail.com>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Is "unmount -f"  worked as expected?
Date: Thu, 31 May 2018 20:14:50 +0000
Message-ID: <F4D332EC-7636-4C62-AB73-D645310B16D1@cisco.com>
References: <8CC8F228-1A66-4A44-A23B-855E33F4D1D5@cisco.com>
 <0dae4862d6e5b754ba8f90a6391b6645fdf6889a.camel@gmail.com>
 <EE6D39C5-09BB-4133-9CF5-674038E1538F@cisco.com>
 <20180531151819.GC1298@fieldses.org>
 <C8362635-4E93-4C96-9827-E241565D27DF@cisco.com>
 <20180531173456.GE1298@fieldses.org>
 <D009E9C8-FB2B-4D93-BD91-EB4B47FCA983@cisco.com>
 <20180531192820.GB3557@fieldses.org>
In-Reply-To: <20180531192820.GB3557@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SGk6ICBCcmFjZToNCg0KID5PbiA1LzMxLzE4LCAxMjoyOCBQTSwgImJmaWVsZHNAZmllbGRzZXMu
b3JnIiA8YmZpZWxkc0BmaWVsZHNlcy5vcmc+IHdyb3RlOg0KDQogPiAgIE9uIFRodSwgTWF5IDMx
LCAyMDE4IGF0IDA2OjA0OjUyUE0gKzAwMDAsIFNoYXduIEx1IChzaGF3bHUpIHdyb3RlOg0KID4g
ICA+ICBZZXMsIFRoaXMgd2lsbCBhIGJpZyBpc3N1ZSBmb3IgY3Jvc3MgbW91bnQuICBMdWNraWx5
LCB3ZSBoYXZlIG5vdA0KID4gICA+ICBleHBlcmllbmNlIGl0IHlldCBkdWUgdG8gbG93IHRyYWZm
aWMuICANCiA+ICA+IA0KID4gID4gIEJ5IHRoZSB3YXksICB3aGF0IGlzIHlvdXIgc3VnZ2VzdGlv
biBvbiB0aGUgcm9hZCB0byBlbmhhbmNlIOKAnHVtb3VudA0KID4gICA+ICDigJNm4oCdID8gICBX
aWxsIGFkZCBrZXJuZWwgY29uZmlnIG9wdGlvbiB0byBzdXBwb3J0IGd1YXJhbnRlZWQgZm9yY2UN
CiA+ICAgPiAgdW5tb3VudCBoZWxwcz8NCiAgICANCiA+ICAgSSBob25lc3RseSBoYXZlbid0IGJl
ZW4gZm9sbG93aW5nIHRoYXQgZGlzY3Vzc2lvbi4gIElmIEkgd2VyZSBnb2luZyB0bw0KID4gICB3
b3JrIG9uIHRoaXMgSSdkIHN0YXJ0IGJ5IHN0dWR5aW5nIHRoZSBwcmV2aW91cyBkaXNjdXNzaW9u
IHRoYXQgSm9zaHVhDQogPiAgIHJlZmVyZW5jZXMuDQoNClRoYW5rcyBmb3Igc3VnZ2VzdGlvbi4g
IEkgaGF2ZSByb3VnaGx5IGdvIHRocm91Z2ggdGhhdCB0aHJlYWQuICAgSXQgc2VlbXMgdG8gbWUg
dGhlcmUNCmFyZSBzdGlsbCBkaXZlcmdlcyBvbiB0aGUgb3BpbmlvbnMuICBUaGF04oCZcyB3aHkg
SSBzdGlsbCBhc2sgYXJvdW5kIGZvciB3aGF0IHNob3VsZCBiZSB0aGUgZXhwZWN0ZWQgYmVoYXZp
b3IgZm9yIA0K4oCcdW1vdW50IOKAk2bigJ0uICBUaGVyZSBpcyBxdWl0ZSBhIGxvdCBjb25mdXNp
b24gY2F1c2VkIGJ5IGRpc2NyZXBhbmN5IGJldHdlZW4gTWFuIHBhZ2UgYW5kDQpyZWFsIGJlaGF2
aW9yIGZvciB0aGlzIG9wdGlvbi4gIA0KICA+LS1iLg0KICANClRoYW5rcywNClNoYXduIA0KICAg
IA0KDQo=
