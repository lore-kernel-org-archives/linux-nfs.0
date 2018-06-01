Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-sn1nam02on0109.outbound.protection.outlook.com ([104.47.36.109]:30848
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750852AbeFANQr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Jun 2018 09:16:47 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "rgoldwyn@suse.de" <rgoldwyn@suse.de>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "agruenba@redhat.com" <agruenba@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
Subject: Re: nfs4_acl restricts copy_up in overlayfs
Date: Fri, 1 Jun 2018 13:16:44 +0000
Message-ID: <828f320cde910a45983d91bddb6477d21c5cae33.camel@hammerspace.com>
References: <f74fae81-d1bc-1c0e-7b41-69502bd7c489@suse.de>
         <f2af62fdf8a5bb185ec75cff118178d58b28ceb4.camel@hammerspace.com>
         <2cf94c6b-e819-79af-4ac9-3b19d26dc6d9@suse.de>
         <75266c983a03f6dbfd5d1a39c94fa6d56a1a8a22.camel@hammerspace.com>
         <a0617bb0-b7a5-fab2-c72c-595e005bd8f7@suse.de>
         <20180531004554.GA29116@fieldses.org>
         <CAJfpegtoLpwo6aA9=uF72UDaKvv_Q3bUbv778VwnSDa72yO9Mw@mail.gmail.com>
         <128c74cb1507d7eab36ac8d32182dbbc7d3f9f88.camel@hammerspace.com>
         <CAJfpeguK9rmXK4F7wkE8of7gwDTV_KbM4yWAW8iGJ0RvOMH0-g@mail.gmail.com>
         <e692f5a6f612660ad0a64e083ed7a1398629aa6d.camel@hammerspace.com>
         <CAJfpegsW7CwZYJf_EH80aaYotMMBDk1BjR_RA6dz8e=Y3-ox5w@mail.gmail.com>
         <d6fab628-6fd1-de33-2ca4-d82917205ce7@suse.de>
         <95e00ce46fe1f5fed50fe24947eee0dda51e0140.camel@hammerspace.com>
         <c59d0be3-a10b-02c3-8126-3402a6a0eab1@suse.de>
In-Reply-To: <c59d0be3-a10b-02c3-8126-3402a6a0eab1@suse.de>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE4LTA2LTAxIGF0IDA2OjQwIC0wNTAwLCBHb2xkd3luIFJvZHJpZ3VlcyB3cm90
ZToNCj4gDQo+IE9uIDA1LzMxLzIwMTggMDc6NDkgUE0sIFRyb25kIE15a2xlYnVzdCB3cm90ZToN
Cj4gPiBPbiBUaHUsIDIwMTgtMDUtMzEgYXQgMTY6NTMgLTA1MDAsIEdvbGR3eW4gUm9kcmlndWVz
IHdyb3RlOg0KPiA+ID4gDQo+ID4gPiBPbiAwNS8zMS8yMDE4IDA4OjMwIEFNLCBNaWtsb3MgU3pl
cmVkaSB3cm90ZToNCj4gPiA+ID4gT24gVGh1LCBNYXkgMzEsIDIwMTggYXQgMzoxMCBQTSwgVHJv
bmQgTXlrbGVidXN0DQo+ID4gPiA+IDx0cm9uZG15QGhhbW1lcnNwYWNlLmNvbT4gd3JvdGU6DQo+
ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+IEkgdW5kZXJzdGFuZC4gIElnbm9yaW5nIG5mczRfYWNs
IGluIG92ZXJsYXlmcyB3aWxsIGhhdmUgdGhlDQo+ID4gPiA+ID4gPiBzYW1lDQo+ID4gPiA+ID4g
PiByZXN1bHQgYXMgYWRkaW5nIG5vYWNsIHRvIHRoZSB1bmRlcmx5aW5nIE5GUyBtb3VudC4NCj4g
PiA+IA0KPiA+ID4gQWRkaW5nIG5vYWNsIGluIE5GUyBjbGllbnQgbW91bnQgaGFzIG5vIGFmZmVj
dCB0byBuZnM0X2FjbC4gT25seQ0KPiA+ID4gaWYNCj4gPiA+IHlvdQ0KPiA+ID4gYWRkIG5vYWNs
IGluIHRoZSB1bmRlcmx5aW5nIGZpbGVzeXN0ZW0gb2YgZXhwb3J0ZWQgZGlyZWN0b3J5IGluDQo+
ID4gPiB0aGUNCj4gPiA+IHNlcnZlciBkb2VzIHRoZSBuZnM0X2FjbCBnbyBhd2F5Lg0KPiA+IA0K
PiA+IFRoYXQgd291bGQgYWxzbyBiZSBzcGVjaWZpYyB0byBMaW51eCBzZXJ2ZXJzLg0KPiANCj4g
U29ycnksIEkgZG9uJ3QgaGF2ZSBhY2Nlc3MgdG8gb3RoZXIgTkZTIGJhc2VkIHNlcnZlcnMuIERv
ZXMgdGhhdCBtZWFuDQo+ICJub2FjbCIgb3B0aW9uIG9uIE5GUyBjbGllbnQgbW91bnQgaGFzIGRp
ZmZlcmVudCBpbnRlcnByZXRhdGlvbnMgZm9yDQo+IGRpZmZlcmVudCBORlMgc2VydmVycz8gT3Ig
ZG8geW91IG1lYW4gdGhhdCBuZnM0X2FjbCBjYW5ub3QgYmUNCj4gZGlzYWJsZWQNCj4gZm9yIG90
aGVyIHR5cGUgb2Ygc2VydmVycz8NCg0KSSdtIG5vdCBzdXJlIGl0IGV2ZW4gbWFrZXMgc2Vuc2Ug
dG8gdHVybiBvZmYgZmlsZXN5c3RlbSBhY2xzIGlmIHlvdXINCnVuZGVybHlpbmcgZmlsZXN5c3Rl
bSBpcyBzb21ldGhpbmcgbGlrZSB6ZnMgb3IgYXBmcyAobGV0IGFsb25lIE5URlMpLg0KTGludXgg
cmVhbGx5IGlzIGJlaGluZCB0aGUgY3VydmUgaGVyZS4NCg0KPiA+IA0KPiA+IFNvIGlmIHRoYXQg
aXMgeW91ciBmaW5hbCBkZWNpc2lvbiwgdGhlbiB3aHkgbm90IGp1c3Qgc3RhdGUgaW4gdGhlDQo+
ID4gb3ZlcmxheWZzIG1hbnBhZ2UgdGhhdA0KPiANCj4gTm8sIHRoYXQgaXMgbm90IG15IGZpbmFs
IGRlY2lzaW9uLiBOZWl0aGVyIGlzIGl0IGZvciBtZSB0byBtYWtlLiBJIGFtDQo+IG1lcmVseSB0
cnlpbmcgdG8gZmluZCBhIHdheSB0byBtYWtlIHdyaXRlcyBvbiBvdmVybGF5ZnMgcG9zc2libGUg
d2l0aA0KPiBORlN2NCBpbiB0aGUgbG93ZXIgbGF5ZXIuDQo+IA0KDQouLi5hbmQgYWxsIEknbSBk
b2luZyBpcyBwb2ludGluZyBvdXQgdGhhdCBhcyBsb25nIGFzIHlvdSBpbnNpc3Qgb24NCmNsaWVu
dCBlbmZvcmNlbWVudCBvZiBmaWxlIHNlY3VyaXR5LCB0aGVuIHlvdSBhcmUgaGVhdmlseSBsaW1p
dGluZyB0aGUNCmxpc3Qgb2Ygc2VydmVycyBhbmQgc2VydmVyIGNvbmZpZ3VyYXRpb25zIHRoYXQg
eW91IHdpbGwgYmUgYWJsZSB0byB3b3JrDQpzYWZlbHkgd2l0aC4gVGhlcmUgaXMgYSByZWFzb24g
d2h5LCBpbiBhbGwgdGhlIDMwIHllYXJzIHNpbmNlIHRoZSBORlN2Mg0Kc3BlYyB3YXMgcmVsZWFz
ZWQsIG5vYm9keSBoYXMgYnVpbHQgc3VjaCBhIGNsaWVudC4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1
c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xl
YnVzdEBoYW1tZXJzcGFjZS5jb20NCg0K
