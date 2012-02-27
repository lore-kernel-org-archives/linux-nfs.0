Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62015 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751738Ab2B0PBO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Feb 2012 10:01:14 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "xemul@parallels.com" <xemul@parallels.com>,
        "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jbottomley@parallels.com" <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 2/4] NFS: replace per-net client lock by mutex
Date: Mon, 27 Feb 2012 15:00:18 +0000
Message-ID: <1330354815.5541.24.camel@lade.trondhjem.org>
References: <20120227134623.13371.61185.stgit@localhost6.localdomain6>
	 <20120227134900.13371.96849.stgit@localhost6.localdomain6>
In-Reply-To: <20120227134900.13371.96849.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTAyLTI3IGF0IDE3OjQ5ICswNDAwLCBTdGFuaXNsYXYgS2luc2J1cnNreSB3
cm90ZToNCj4gTG9ja2RlcCBpcyBzYWQgb3RoZXJ3aXNlLCBiZWNhdXNlIGlub2RlIG11dGV4IGlz
IHRha2VuIG9uIFBpcGVGUyBkZW50cnkNCj4gY3JlYXRpb24sIHdoaWNoIGNhbiBiZSBjYWxsZWQg
b24gbW91bnQgbm90aWZpY2F0aW9uLCB3aGVyZSB0aGlzIHBlci1uZXQgY2xpZW50DQo+IGxvY2sg
aXMgdGFrZW4gb24gY2xpZW50cyBsaXN0IHdhbGsuDQo+IA0KPiBOb3RlOiBJIHVzZWQgc2ltcGxl
IG11dGV4IGluc3RlYWQgb2Ygcncgc2VtYXBob3JlIGJlY2F1c2Ugb2YNCj4gbmZzX3B1dF9jbGll
bnQtPmF0b21pY19kZWNfYW5kX211dGV4X2xvY2soKSBjYWxsLiBQcm9iYWJseSwgdGhlcmUgaXMg
YSBiZXR0ZXINCj4gc29sdXRpb24gaGVyZS4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IFN0YW5pc2xh
diBLaW5zYnVyc2t5IDxza2luc2J1cnNreUBwYXJhbGxlbHMuY29tPg0KPiANCg0KVGhpcyBpcyBv
dmVya2lsbC4uLiBXZSBlbmQgdXAgYmxvY2tpbmcgTkZTdjQgY2FsbGJhY2tzIHdoaWxlIHRoZQ0K
cnBjX3BpcGVmcyBub3RpZmllciBydW5zIHRocm91Z2ggdGhlIG5mc19jbGllbnRzIGNyZWF0aW5n
IG9yIGRlc3Ryb3lpbmcNCmlkbWFwcGVyIGRlbnRyaWVzLg0KDQpTdXJlbHkgdGhlIHJwY19waXBl
ZnNfZXZlbnQoKSBjYW4gdGFrZSBhIHJlZmVyZW5jZSB0byB0aGUgbmZzX2NsaWVudCBhbmQNCnRo
ZW4gZHJvcCB0aGUgc3Bpbl9sb2NrIGlmIGl0IHNlZXMgdGhhdCBpdCBuZWVkcyB0byBjcmVhdGUg
b3IgZGVzdHJveSBhDQpkZW50cnk/DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMg
Y2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0K
d3d3Lm5ldGFwcC5jb20NCg0K
