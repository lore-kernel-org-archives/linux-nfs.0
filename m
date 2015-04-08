Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7887 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754140AbbDHSlZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2015 14:41:25 -0400
From: "Hefty, Sean" <sean.hefty@intel.com>
To: Doug Ledford <dledford@redhat.com>,
        Michael Wang <yun.wang@profitbricks.com>
CC: Roland Dreier <roland@kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        "Tom Tucker" <tom@opengridcomputing.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
        Christoph Raisch <raisch@de.ibm.com>,
        infinipath <infinipath@intel.com>, "Eli Cohen" <eli@mellanox.com>,
        "Latif, Faisal" <faisal.latif@intel.com>,
        "Upinder Malhi" <umalhi@cisco.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Weiny, Ira" <ira.weiny@intel.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        "Nikolova, Tatyana E" <tatyana.e.nikolova@intel.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "Jack Morgenstein" <jackm@dev.mellanox.co.il>,
        Haggai Eran <haggaie@mellanox.com>,
        Ilya Nelkenbaum <ilyan@mellanox.com>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Bart Van Assche <bvanassche@acm.org>,
        Shachar Raindel <raindel@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Devesh Sharma <devesh.sharma@emulex.com>,
        Matan Barak <matanb@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        "Jiri Kosina" <jkosina@suse.cz>,
        Selvin Xavier <selvin.xavier@emulex.com>,
        "Mitesh Ahuja" <mitesh.ahuja@emulex.com>,
        Li RongQing <roy.qing.li@gmail.com>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        "Estrin, Alex" <alex.estrin@intel.com>,
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Tom Gundersen <teg@jklm.no>, Chuck Lever <chuck.lever@oracle.com>
Subject: RE: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
Date: Wed, 8 Apr 2015 18:41:22 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FBF0E8@ORSMSX109.amr.corp.intel.com>
References: <5523CCD5.6030401@profitbricks.com>
	 <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com>
In-Reply-To: <1428517786.2980.180.camel@redhat.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiBJJ20gY29uY2VybmVkIGFib3V0IHRoZSBwZXJmb3JtYW5jZSBpbXBsaWNhdGlvbnMgb2YgdGhp
cy4gIFRoZSBzaXplIG9mDQo+IHRoaXMgcGF0Y2hzZXQgYWxyZWFkeSBwb2ludHMgb3V0IGp1c3Qg
aG93IG1hbnkgcGxhY2VzIGluIHRoZSBjb2RlIHdlDQo+IGhhdmUgdG8gY2hlY2sgZm9yIHZhcmlv
dXMgYXNwZWN0cyBvZiB0aGUgZGV2aWNlIHRyYW5zcG9ydCBpbiBvcmRlciB0byBkbw0KPiB0aGUg
cmlnaHQgdGhpbmcuICBXaXRob3V0IGdvaW5nIHRocm91Z2ggdGhlIGVudGlyZSBsaXN0IHRvIHNl
ZSBob3cgbWFueQ0KPiBhcmUgb24gY3JpdGljYWwgaG90IHBhdGhzLCBJJ20gc3VyZSBzb21lIG9m
IHRoZW0gYXJlIG9uIGF0IGxlYXN0DQo+IHBhcnRpYWxseSBjcml0aWNhbCBob3QgcGF0aHMgKGxp
a2UgY3JlYXRpb24gb2YgbmV3IGNvbm5lY3Rpb25zKS4gIEkNCj4gd291bGQgcHJlZmVyIHRvIHNl
ZSB0aGlzIGNoYW5nZSBiZSBpbXBsZW1lbnRlZCB2aWEgYSBkZXZpY2UgYXR0cmlidXRlLA0KPiBu
b3QgYSBmdW5jdGlvbmFsIGNhbGwgcXVlcnkuICBUaGF0IGFkZHMgYSBuZWVkbGVzcyBmdW5jdGlv
biBjYWxsIGluDQo+IHRoZXNlIHBhdGhzLg0KDQpNeSBpbXByZXNzaW9uIG9mIHRoZXNlIGNoYW5n
ZXMgd2VyZSB0aGF0IHRoZXkgd291bGQgZXZlbnR1YWxseSBsZWFkIHRvIHRoZSBtZWNoYW5pc20g
dGhhdCB5b3Ugb3V0bGluZWQ6IA0KDQoNCj4gSSdtIGFsc28gY29uY2VybmVkIGFib3V0IHRoaXMu
ICBJIHdvdWxkIGxpa2UgdG8gc2VlIHRoaXMgZW51bQ0KPiBlc3NlbnRpYWxseSB0dXJuZWQgaW50
byBhIGJpdG1hcC4gIE9uZSB0aGF0IGlzIGNvbnN0cnVjdGVkIGluIHN1Y2ggYSB3YXkNCj4gdGhh
dCB3ZSBjYW4gYWx3YXlzIGdldCB0aGUgc3BlY2lmaWMgdGVzdCB3ZSBuZWVkIHdpdGggb25seSBv
bmUgY29tcGFyZQ0KPiBhZ2FpbnN0IHRoZSBvdmVyYWxsIHZhbHVlLiAgSW4gb3JkZXIgdG8gZG8g
c28sIHdlIG5lZWQgdG8gYnJlYWsgaXQgZG93bg0KPiBpbnRvIHRoZSBlc3NlbnRpYWwgZWxlbWVu
dHMgdGhhdCBhcmUgcGFydCBvZiBlYWNoIG9mIHRoZSB0cmFuc3BvcnRzLg0KPiBTbywgZm9yIGlu
c3RhbmNlLCB3ZSBjYW4gZGVmaW5lIHRoZSB0d28gbGluayBsYXllcnMgd2UgaGF2ZSBzbyBmYXIs
IHBsdXMNCj4gcmVzZXJ2ZSBvbmUgZm9yIE9QQSB3aGljaCB3ZSBrbm93IGlzIGNvbWluZzoNCj4g
DQo+IFJETUFfTElOS19MQVlFUl9JQiAgICAgICA9IDB4MDAwMDAwMDEsDQo+IFJETUFfTElOS19M
QVlFUl9FVEggICAgICA9IDB4MDAwMDAwMDIsDQo+IFJETUFfTElOS19MQVlFUl9PUEEgICAgICA9
IDB4MDAwMDAwMDQsDQo+IFJETUFfTElOS19MQVlFUl9NQVNLICAgICA9IDB4MDAwMDAwMGYsDQo+
IA0KPiBXZSBjYW4gdGhlbiBkZWZpbmUgdGhlIGN1cnJlbnRseSBrbm93biBoaWdoIGxldmVsIHRy
YW5zcG9ydCB0eXBlczoNCj4gDQo+IFJETUFfVFJBTlNQT1JUX0lCICAgICAgICA9IDB4MDAwMDAw
MTAsDQo+IFJETUFfVFJBTlNQT1JUX0lXQVJQICAgICA9IDB4MDAwMDAwMjAsDQo+IFJETUFfVFJB
TlNQT1JUX1VTTklDICAgICA9IDB4MDAwMDAwNDAsDQo+IFJETUFfVFJBTlNQT1JUX1VTTklDX1VE
UCA9IDB4MDAwMDAwODAsDQo+IFJETUFfVFJBTlNQT1JUX01BU0sgICAgICA9IDB4MDAwMDAwZjAs
DQo+IA0KPiBXZSBjb3VsZCB0aGVuIGRlZmluZSBiaXRzIGZvciB0aGUgSUIgbWFuYWdlbWVudCB0
eXBlczoNCj4gDQo+IFJETUFfTUdNVF9JQiAgICAgICAgICAgICA9IDB4MDAwMDAxMDAsDQo+IFJE
TUFfTUdNVF9PUEEgICAgICAgICAgICA9IDB4MDAwMDAyMDAsDQo+IFJETUFfTUdNVF9NQVNLICAg
ICAgICAgICA9IDB4MDAwMDBmMDAsDQo+IA0KPiBUaGVuIHdlIGhhdmUgc3BhY2UgdG8gZGVmaW5l
IHNwZWNpZmljIHF1aXJrczoNCj4gDQo+IFJETUFfU0VQQVJBVEVfUkVBRF9TR0UgICA9IDB4MDAw
MDEwMDAsDQo+IFJETUFfUVVJUktTX01BU0sgICAgICAgICA9IDB4ZmZmZmYwMDANCg0KSSB0b28g
d291bGQgbGlrZSB0byBzZWUgdGhpcyBhcyB0aGUgZW5kIHJlc3VsdCwgYnV0IEkgdGhpbmsgaXQn
cyBwb3NzaWJsZSB0byBzdGFnZSB0aGUgY2hhbmdlcyBieSBoYXZpbmcgdGhlIHN0YXRpYyBpbmxp
bmUgY2FsbHMgYmVpbmcgYWRkZWQgY29udmVydCB0byB1c2luZyB0aGVzZSBzb3J0IG9mIGF0dHJp
YnV0ZXMuDQoNCi0gU2Vhbg0K
