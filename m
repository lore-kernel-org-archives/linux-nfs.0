Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-by2nam01on0120.outbound.protection.outlook.com ([104.47.34.120]:37792
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932900AbeEWNmL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 May 2018 09:42:11 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "aglo@umich.edu" <aglo@umich.edu>,
        "rmacklem@uoguelph.ca" <rmacklem@uoguelph.ca>
CC: "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: question: re-try of operations in PNFS
Date: Wed, 23 May 2018 13:42:07 +0000
Message-ID: <5be0737d7bcb70f437a5db6b727b48f5992b96ae.camel@hammerspace.com>
References: <CAN-5tyH2OVzr5TTN_sCrKxEiXaDiPzh=8zykR__jq=k2ve5Vaw@mail.gmail.com>
         <955655871.7566389.1527021265316.JavaMail.zimbra@desy.de>
         <CAN-5tyE4gO9=pDtSPC+vbH4HuBs69Qyt8tSPFMM6_cg32BrH9A@mail.gmail.com>
         <YTOPR0101MB0953F9A6FE17FCD371233EC1DD6B0@YTOPR0101MB0953.CANPRD01.PROD.OUTLOOK.COM>
         <CAN-5tyHRj3F1=Xjdkj5TsX62kH7jtAZZGv9fSLVSoRh5QxUFAw@mail.gmail.com>
In-Reply-To: <CAN-5tyHRj3F1=Xjdkj5TsX62kH7jtAZZGv9fSLVSoRh5QxUFAw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE4LTA1LTIzIGF0IDA5OjI1IC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gT24gVHVlLCBNYXkgMjIsIDIwMTggYXQgODoyNiBQTSwgUmljayBNYWNrbGVtIDxybWFj
a2xlbUB1b2d1ZWxwaC5jYT4NCj4gd3JvdGU6DQo+ID4gT2xnYSBLb3JuaWV2c2thaWEgd3JvdGU6
DQo+ID4gW2dvb2Qgc3R1ZmYgc25pcHBlZF0NCj4gPiA+IFVwc3RyZWFtIGtlcm5lbC4gQnV0IEkn
bSBhcmd1aW5nIHRoYXQgdGhlcmUgc2hvdWxkbid0IGJlIGEgbmVlZA0KPiA+ID4gdG8NCj4gPiA+
IHNwZWNpZnkgYSBkYXRhc2VydmVyX3RpbWVvIGJlY2F1c2UgaXQgc2hvdWxkbid0IHRpbWVvdXQg
YXQgYWxsDQo+ID4gPiBqdXN0DQo+ID4gPiBsaWtlIE1EUyBvcGVyYXRpb25zLg0KPiA+IA0KPiA+
IElmL3doZW4gdGhlIHNlcnZlciBpcyBwcm92aWRpbmcgbWlycm9yZWQgRFNzLCBJJ3ZlIGZvdW5k
IHRoaXMNCj4gPiB0aW1lb3V0IHVzZWZ1bA0KPiA+IGluIHRoZSBGcmVlQlNEIGNsaWVudCBzaW5j
ZSBpdCBhbGxvd3MgdGhlIGNsaWVudCB0byBkZXRlY3QgYSBEUw0KPiA+IGZhaWx1cmUuDQo+ID4g
SXQgY2FuIHRoZW4gcmVwb3J0IHRoZSBmYWlsdXJlIHRvIHRoZSBNRFMgdmlhIExheW91dFJldHVy
biAob3INCj4gPiBhbm90aGVyIG9uZQ0KPiA+IG9uIE5GU3Y0LjIgd2hpY2ggSSBjYW4ndCByZW1l
bWJlciB0aGUgbmFtZSBvZiBzaW5jZSBJIGhhdmVuJ3QgZG9uZQ0KPiA+IDQuMjstKS4NCj4gPiAN
Cj4gPiBGb3Igbm9uLW1pcnJvcmVkIERTcywgdGhlIG9ubHkgdGhpbmcgSSBjYW4gdGhpbmsgb2Yg
KEkndmUgbmV2ZXINCj4gPiBzZWVuIHRoaXMpIHdvdWxkDQo+ID4gYmUgc29tZSBzb3J0IG9mIG5l
dHdvcmsgcGFydGl0aW9uaW5nIHN1Y2ggdGhhdCB0aGUgY2xpZW50IGNhbid0DQo+ID4gcmVhY2gg
dGhlIERTIGJ1dA0KPiA+IGNhbiByZWFjaCB0aGUgTURTLg0KPiA+IA0KPiA+IEkgaGF2ZSBubyBp
ZGVhIGlmIHRoaXMgaXMgcmVsZXZhbnQgdG8gTGludXgsIGJ1dCB0aG91Z2h0IEknZA0KPiA+IG1l
bnRpb24gaXQsIGp1c3QgaW4gY2FzZS4NCj4gPiBbbW9yZSBzdHVmZiBzbmlwcGVkXQ0KPiANCj4g
SXNuJ3QgcmV0cnlpbmcgbWFrZXMgdGhlIGltcGxlbWVudGF0aW9uIG5vdCBzcGVjIGNvbXBsaWFu
dD8NCg0KUmVwbGF5aW5nIGEgcmVxdWVzdCB3b3VsZCBub3QgYmUgc3BlYyBjb21wbGlhbnQuIFBs
YXlpbmcgbmV3IHJlcXVlc3RzDQppcyBwZXJmZWN0bHkgZmluZSAoZS5nLiBhZnRlciBwaWNraW5n
IHVwIGEgbmV3IGxheW91dCBvciByZWRpcmVjdGluZw0KdGhlIEkvTyB0byB0aGUgTURTKS4NCg0K
SGlzdG9yaWNhbGx5LCBJIHNlZW0gdG8gcmVtZW1iZXIgdGhhdCBhdCBvbmUgcG9pbnQgd2UgaW50
cm9kdWNlZCBhIDE1cw0KdGltZW91dCBvbiBJL08gcmVxdWVzdHMgdG8gdGhlIERTIGluIG9yZGVy
IHRvIGFsbG93IGZhc3QgZmFpbG92ZXIgb2YNCnRoZSBwTkZTIGNsaWVudCB3aGVuIHRoZSBEUyB3
YXMgZG93biBvciB1bnJlc3BvbnNpdmUuIEknbSBub3Qgc3VyZQ0Kd2hldGhlciBvciBub3QgdGhh
dCBtZWNoYW5pc20gc3RpbGwgZXhpc3RzIGFuZCB3aGV0aGVyIGl0IGlzIHdoYXQgeW91DQphcmUg
c2VlaW5nIGhlcmUuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1h
aW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoN
Cg==
