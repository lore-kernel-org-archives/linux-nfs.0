Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:25629 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753355Ab2BGPe5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 10:34:57 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "xemul@parallels.com" <xemul@parallels.com>,
        "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jbottomley@parallels.com" <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 1/4] NFS: make nfs_client_list per net ns
Date: Tue, 7 Feb 2012 15:34:48 +0000
Message-ID: <1328628888.4124.16.camel@lade.trondhjem.org>
References: <20120123172605.29637.15682.stgit@localhost6.localdomain6>
	 <4F3143F4.3010502@netapp.com>
In-Reply-To: <4F3143F4.3010502@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDEyLTAyLTA3IGF0IDEwOjMyIC0wNTAwLCBCcnlhbiBTY2h1bWFrZXIgd3JvdGU6
DQo+IEkgZml4ZWQgdXAgbXkgYmlzZWN0IGFuZCBpZGVudGlmaWVkIHRoaXMgcGF0Y2ggaW5zdGVh
ZC4gIFRoZSBwcm9ibGVtIEknbSBzZWVpbmcgaXM6DQo+IA0KPiAgIENDIFtNXSAgZnMvbmZzL2Rl
bGVnYXRpb24ubw0KPiAgIENDIFtNXSAgZnMvbmZzL2lkbWFwLm8NCj4gZnMvbmZzL2lkbWFwLmM6
IEluIGZ1bmN0aW9uICdycGNfcGlwZWZzX2V2ZW50JzoNCj4gZnMvbmZzL2lkbWFwLmM6NTM1Ojk6
IGVycm9yOiBpbXBsaWNpdCBkZWNsYXJhdGlvbiBvZiBmdW5jdGlvbiAnbmV0X2dlbmVyaWMnIFst
V2Vycm9yPWltcGxpY2l0LWZ1bmN0aW9uLWRlY2xhcmF0aW9uXQ0KPiBmcy9uZnMvaWRtYXAuYzo1
MzU6NTA6IGVycm9yOiAnbmZzX25ldF9pZCcgdW5kZWNsYXJlZCAoZmlyc3QgdXNlIGluIHRoaXMg
ZnVuY3Rpb24pDQo+IGZzL25mcy9pZG1hcC5jOjUzNTo1MDogbm90ZTogZWFjaCB1bmRlY2xhcmVk
IGlkZW50aWZpZXIgaXMgcmVwb3J0ZWQgb25seSBvbmNlIGZvciBlYWNoIGZ1bmN0aW9uIGl0IGFw
cGVhcnMgaW4NCj4gZnMvbmZzL2lkbWFwLmM6NTQwOjgyOiBlcnJvcjogZGVyZWZlcmVuY2luZyBw
b2ludGVyIHRvIGluY29tcGxldGUgdHlwZQ0KPiBmcy9uZnMvaWRtYXAuYzo1NDA6MjI0OiBlcnJv
cjogZGVyZWZlcmVuY2luZyBwb2ludGVyIHRvIGluY29tcGxldGUgdHlwZQ0KPiBjYzE6IHNvbWUg
d2FybmluZ3MgYmVpbmcgdHJlYXRlZCBhcyBlcnJvcnMNCj4gDQo+IG1ha2VbMl06ICoqKiBbZnMv
bmZzL2lkbWFwLm9dIEVycm9yIDENCj4gbWFrZVsxXTogKioqIFtmcy9uZnNdIEVycm9yIDINCj4g
bWFrZTogKioqIFtmc10gRXJyb3IgMg0KPiANCj4gSSB0aGluayB5b3UgbmVlZCB0byBhZGQ6ICNp
bmNsdWRlICJuZXRucy5oIiB0byBpZG1hcC5jLg0KPiANCj4gLSBCcnlhbg0KDQpUaGF0IHNob3Vs
ZCBhbHJlYWR5IGJlIHRoZXJlIGluIHRoZSAnZGV2ZWwnIGJyYW5jaC4gU2VlIGNvbW1pdA0KMTcz
NDdkMDNjMDA4ZTJmNTA0YzMzYmI0OTA1Y2RhZDBhYmMwMTMxOS4NCg0KLS0gDQpUcm9uZCBNeWts
ZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xl
YnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
