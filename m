Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from alln-iport-8.cisco.com ([173.37.142.95]:43600 "EHLO
        alln-iport-8.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755848AbeEaSEx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2018 14:04:53 -0400
From: "Shawn Lu (shawlu)" <shawlu@cisco.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: Joshua Watt <jpewhacker@gmail.com>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Is "unmount -f"  worked as expected?
Date: Thu, 31 May 2018 18:04:52 +0000
Message-ID: <D009E9C8-FB2B-4D93-BD91-EB4B47FCA983@cisco.com>
References: <8CC8F228-1A66-4A44-A23B-855E33F4D1D5@cisco.com>
 <0dae4862d6e5b754ba8f90a6391b6645fdf6889a.camel@gmail.com>
 <EE6D39C5-09BB-4133-9CF5-674038E1538F@cisco.com>
 <20180531151819.GC1298@fieldses.org>
 <C8362635-4E93-4C96-9827-E241565D27DF@cisco.com>
 <20180531173456.GE1298@fieldses.org>
In-Reply-To: <20180531173456.GE1298@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SGk6ICBCcnVjZToNCg0KDQo+T24gNS8zMS8xOCwgMTA6MzQgQU0sICJiZmllbGRzQGZpZWxkc2Vz
Lm9yZyIgPGJmaWVsZHNAZmllbGRzZXMub3JnPiB3cm90ZToNCg0KID4gIE9uIFRodSwgTWF5IDMx
LCAyMDE4IGF0IDA0OjUxOjQ5UE0gKzAwMDAsIFNoYXduIEx1IChzaGF3bHUpIHdyb3RlOg0KID4g
ICA+ID5PbiA1LzMxLzE4LCA4OjE4IEFNLCAiYmZpZWxkc0BmaWVsZHNlcy5vcmciIDxiZmllbGRz
QGZpZWxkc2VzLm9yZz4gd3JvdGU6DQogPiAgID4gID4gID4gT25lIGNhc2UgaXMgaW52b2x2ZWQg
d2l0aCAgY3Jvc3MgbW91bnRlZCBuZnMgZnJvbSBkaWZmZXJlbnQgaG9zdC4NCiA+ICAgPiAgICAg
DQogPiAgICA+ICA+ICBOb3RlOiBpbiB0aGVvcnkgSSB0aGluayB0aGVyZSBhcmUgc29tZSBkZWFk
bG9ja3MgcG9zc2libGUgaWYgY2xpZW50IGFuZA0KID4gICA+ICA+ICAgc2VydmVyIG1vdW50IGVh
Y2ggb3RoZXIuICAoRWFjaCBob3N0IGNvdWxkIGJlIHdhaXRpbmcgb24gdGhlIG90aGVyIG9uZQ0K
ID4gICA+ICA+ICAgdG8gcHJvY2VzcyB3cml0ZXMgYmVmb3JlIGl0IGNhbiBmcmVlIG1lbW9yeSB0
aGF0IGl0IG5lZWRzIHRvIG1ha2UNCiA+ICAgPiAgPiAgIHByb2dyZXNzLikNCiA+ICA+IA0KID4g
ICA+IFllcy4gIEkgaG9wZSBhZ2dyZXNzaXZlIHVtb3VudCAgd2lsbCAgaGVscCBieSBzZXR0aW5n
IGEgdmVyeSBzaG9ydCBncmFjZSBwZXJpb2QgYW5kIHRpbWVvdXQgYmVmb3JlIHVtb3VudC4NCiAg
ICANCiA+ICAgTm8sIHRoZSBkZWFkbG9jayBpc24ndCBhbiB1bm1vdW50aW5nIHByb2JsZW0sIGl0
J3MgYSBwcm9ibGVtIHRoYXQgY291bGQNCiA+ICBoYXBwZW4gZHVyaW5nIG5vcm1hbCBvcGVyYXRp
b24uICBJIGRvbid0IGtub3cgaWYgaXQncyBlYXN5IHRvIHJlcHJvZHVjZS4NCiA+ICAgWW91J2Qg
cHJvYmFibHkgbmVlZCBvbmUgb3IgYm90aCBob3N0cyB0byBiZSB3cml0aW5nIHRvIE5GUyB2ZXJ5
IHF1aWNrbHkuDQogICANCiBZZXMsIFRoaXMgd2lsbCBhIGJpZyBpc3N1ZSBmb3IgY3Jvc3MgbW91
bnQuICBMdWNraWx5LCB3ZSBoYXZlIG5vdCBleHBlcmllbmNlIGl0IHlldCBkdWUgdG8gbG93IHRy
YWZmaWMuICANCg0KIEJ5IHRoZSB3YXksICB3aGF0IGlzIHlvdXIgc3VnZ2VzdGlvbiBvbiB0aGUg
cm9hZCB0byBlbmhhbmNlIOKAnHVtb3VudCDigJNm4oCdID8gICBXaWxsIGFkZCBrZXJuZWwgY29u
ZmlnIG9wdGlvbiB0byBzdXBwb3J0IGd1YXJhbnRlZWQgZm9yY2UgdW5tb3VudCBoZWxwcz8NCiAg
PiAgLS1iLg0KDQpUaGFua3MsDQpTaGF3biANCiAgICANCg0K
