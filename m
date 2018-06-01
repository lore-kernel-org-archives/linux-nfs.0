Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-cys01nam02on0103.outbound.protection.outlook.com ([104.47.37.103]:15632
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750771AbeFAAtY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 20:49:24 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "rgoldwyn@suse.de" <rgoldwyn@suse.de>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "agruenba@redhat.com" <agruenba@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
Subject: Re: nfs4_acl restricts copy_up in overlayfs
Date: Fri, 1 Jun 2018 00:49:20 +0000
Message-ID: <95e00ce46fe1f5fed50fe24947eee0dda51e0140.camel@hammerspace.com>
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
In-Reply-To: <d6fab628-6fd1-de33-2ca4-d82917205ce7@suse.de>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE4LTA1LTMxIGF0IDE2OjUzIC0wNTAwLCBHb2xkd3luIFJvZHJpZ3VlcyB3cm90
ZToNCj4gDQo+IE9uIDA1LzMxLzIwMTggMDg6MzAgQU0sIE1pa2xvcyBTemVyZWRpIHdyb3RlOg0K
PiA+IE9uIFRodSwgTWF5IDMxLCAyMDE4IGF0IDM6MTAgUE0sIFRyb25kIE15a2xlYnVzdA0KPiA+
IDx0cm9uZG15QGhhbW1lcnNwYWNlLmNvbT4gd3JvdGU6DQo+ID4gPiA+IA0KPiA+ID4gPiBJIHVu
ZGVyc3RhbmQuICBJZ25vcmluZyBuZnM0X2FjbCBpbiBvdmVybGF5ZnMgd2lsbCBoYXZlIHRoZQ0K
PiA+ID4gPiBzYW1lDQo+ID4gPiA+IHJlc3VsdCBhcyBhZGRpbmcgbm9hY2wgdG8gdGhlIHVuZGVy
bHlpbmcgTkZTIG1vdW50Lg0KPiANCj4gQWRkaW5nIG5vYWNsIGluIE5GUyBjbGllbnQgbW91bnQg
aGFzIG5vIGFmZmVjdCB0byBuZnM0X2FjbC4gT25seSBpZg0KPiB5b3UNCj4gYWRkIG5vYWNsIGlu
IHRoZSB1bmRlcmx5aW5nIGZpbGVzeXN0ZW0gb2YgZXhwb3J0ZWQgZGlyZWN0b3J5IGluIHRoZQ0K
PiBzZXJ2ZXIgZG9lcyB0aGUgbmZzNF9hY2wgZ28gYXdheS4NCg0KVGhhdCB3b3VsZCBhbHNvIGJl
IHNwZWNpZmljIHRvIExpbnV4IHNlcnZlcnMuDQoNClNvIGlmIHRoYXQgaXMgeW91ciBmaW5hbCBk
ZWNpc2lvbiwgdGhlbiB3aHkgbm90IGp1c3Qgc3RhdGUgaW4gdGhlDQpvdmVybGF5ZnMgbWFucGFn
ZSB0aGF0DQoNCiJPdXIgc2VjdXJpdHkgbW9kZWwgYXNzdW1lcyB0aGF0IHlvdSBhcmUgdXNpbmcg
YSBORlN2My1vbmx5IExpbnV4IGtuZnNkDQpiYXNlZCBzZXJ2ZXIgdGhhdCBoYXMgbW91bnRlZCB0
aGUgZmlsZXN5c3RlbSB3aXRoIHRoZSAnbm9hY2wnIG9wdGlvbiwNCnRoYXQgZXhwb3J0cyB0aGUg
ZmlsZXN5c3RlbSB3aXRoIHNlYz1zeXMgb25seSwgaGFzIGRpc2FibGVkIHNlcnZlciBzaWRlDQpp
ZGVudGl0eSBzcXVhc2hpbmcgYW5kIGhhcyBkaXNhYmxlZCB0aGUgLS1tYW5hZ2UtZ2lkcyBtb3Vu
dGQgb3B0aW9uIj8gDQoNCkF0IGxlYXN0IHRoYXQgd291bGQgYmUgaG9uZXN0Li4uDQoNCi0tIA0K
VHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNl
DQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg==
