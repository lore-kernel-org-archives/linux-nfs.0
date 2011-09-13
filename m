Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:56694 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968Ab1IMIJp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2011 04:09:45 -0400
From: <tao.peng@emc.com>
To: <Trond.Myklebust@netapp.com>, <bhalevy@tonian.com>
CC: <bergwolf@gmail.com>, <gusev.vitaliy@nexenta.com>,
        <gusev.vitaliy@gmail.com>, <linux-nfs@vger.kernel.org>
Date: Tue, 13 Sep 2011 04:09:24 -0400
Subject: RE: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
Message-ID: <F19688880B763E40B28B2B462677FBF805C3299F96@MX09A.corp.emc.com>
References: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com>
	 <1315337382.16274.7.camel@lade.trondhjem.org> <4E669B21.30006@nexenta.com>
	 <1315348373.19556.22.camel@lade.trondhjem.org>
	 <F19688880B763E40B28B2B462677FBF805C3299CA3@MX09A.corp.emc.com>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B0ED3DF@SACMVEXC2-PRD.hq.netapp.com>
	 <CA+a=Yy71JNEgG4q0e69BWEjxqh71CTcfise6KKTyYkXGUM68Tw@mail.gmail.com>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B0ED4C8@SACMVEXC2-PRD.hq.netapp.com>
	 <F19688880B763E40B28B2B462677FBF805C3299D2F@MX09A.corp.emc.com>
	 <1315592430.17611.15.camel@lade.trondhjem.org>
	 <4E6B0E48.7050208@tonian.com>
	 <CA+a=Yy5fMHPcSU4EoSo1uiOUCfi8vjRVPAjEYGZ+M00CwZ8Z9g@mail.gmail.com>
	 <4E6E6C3B.2040605@tonian.com> <1315861851.8350.11.camel@lade.trondhjem.org>
In-Reply-To: <1315861851.8350.11.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

SGksIFRyb25kLA0KPiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBsaW51eC1u
ZnMtb3duZXJAdmdlci5rZXJuZWwub3JnIFttYWlsdG86bGludXgtbmZzLW93bmVyQHZnZXIua2Vy
bmVsLm9yZ10NCj4gT24gQmVoYWxmIE9mIFRyb25kIE15a2xlYnVzdA0KPiBTZW50OiBUdWVzZGF5
LCBTZXB0ZW1iZXIgMTMsIDIwMTEgNToxMSBBTQ0KPiBUbzogQmVubnkgSGFsZXZ5DQo+IENjOiBQ
ZW5nIFRhbzsgUGVuZywgVGFvOyBndXNldi52aXRhbGl5QG5leGVudGEuY29tOyBndXNldi52aXRh
bGl5QGdtYWlsLmNvbTsNCj4gbGludXgtbmZzQHZnZXIua2VybmVsLm9yZw0KPiBTdWJqZWN0OiBS
ZTogW1BBVENIXSBuZnM6IGZpeCBpbmlmaW5pdGUgbG9vcCBhdCBuZnM0X2xheW91dGNvbW1pdF9y
ZWxlYXNlDQo+IA0KPiBPbiBNb24sIDIwMTEtMDktMTIgYXQgMTM6MzEgLTA3MDAsIEJlbm55IEhh
bGV2eSB3cm90ZToNCj4gPiBPbiAyMDExLTA5LTEyIDA3OjU2LCBQZW5nIFRhbyB3cm90ZToNCj4g
PiA+PiBUaGUgbGF5b3V0IHNlZ21lbnRzIGFyZSBub3QgcmVhbGx5IGluIHVzZSB3aGlsZSBpbiBM
QVlPVVRDT01NSVQuDQo+ID4gPj4gV2Ugb25seSBuZWVkIHRvIGdldCB0aGUgc3RhdGVpZCByaWdo
dCB3aXRoIHJlc3BlY3QgdG8gY29uY3VycmVudCBsYXlvdXQgcmVjYWxscy4NCj4gPiA+IExBWU9V
VENPTU1JVCB0YWtlcyBsc2VnIHJlZmVyZW5jZSB0byBtYXJrIHRoZW0gYXMgaW4gdXNlIHNvIHRo
YXQNCj4gPiA+IGxheW91dHJlY2FsbCBjYW5ub3QgZnJlZSB0aGVtLg0KPiA+ID4NCj4gPg0KPiA+
IEFuZCBpZiBsYXlvdXRyZWNhbGwgd291bGQgaGF2ZSBmcmVlZCBsYXlvdXQgc2VnbWVudHMgZHVy
aW5nIGxheW91dGNvbW1pdCwNCj4gPiB3aGF0IGlzIHlvdXIgc3BlY2lmaWMgY29uY2Vybj8NCj4g
DQo+IFRoYXQgbGF5b3V0Y29tbWl0IGlzIHN1cHBvc2VkIHRvIHJldHVybiBORlM0RVJSX0JBRF9M
QVlPVVQgaW4gdGhhdCBjYXNlDQo+IGFjY29yZGluZyB0byBzZWN0aW9uIDE4LjQyLjMgb2YgUkZD
NTY2MS4gSSBjYW4ndCBmaW5kIGFueXRoaW5nIGluIHRoZQ0KPiBlcnJhdGEgdGhhdCBjaGFuZ2Vz
IHRoYXQgcmVxdWlyZW1lbnQuDQpEbyB5b3UgbWVhbiB0aGF0IGlmIGNsaWVudCBzZW5kcyBsYXlv
dXRjb21taXQgYXQgdGhlIHNhbWUgdGltZSBhcyBzZXJ2ZXIgc2VuZHMgbGF5b3V0cmVjYWxsIGZv
ciBvdmVybGFwcGVkIHJhbmdlLCB0aGVuDQpzZXJ2ZXIgbXVzdCByZWplY3QgbGF5b3V0Y29tbWl0
IHdpdGggTkZTNEVSUl9CQURMQVlPVVQgd2hlbiByZWNlaXZpbmcgbGF5b3V0Y29tbWl0Pw0KDQpS
RkM1NjYxIHNlY3Rpb24gMTguNDIuMyBzYXlzOg0KICAgSWYgdGhlIGxheW91dCBpZGVudGlmaWVk
IGluIHRoZSBhcmd1bWVudHMgZG9lcyBub3QgZXhpc3QsIHRoZSBlcnJvcg0KICAgTkZTNEVSUl9C
QURMQVlPVVQgaXMgcmV0dXJuZWQuICBUaGUgbGF5b3V0IGJlaW5nIGNvbW1pdHRlZCBtYXkgYWxz
bw0KICAgYmUgcmVqZWN0ZWQgaWYgaXQgZG9lcyBub3QgY29ycmVzcG9uZCB0byBhbiBleGlzdGlu
ZyBsYXlvdXQgd2l0aCBhbg0KICAgaW9tb2RlIG9mIExBWU9VVElPTU9ERTRfUlcuDQoNCklNSE8s
IGluIHRoZSBhYm92ZSBjYXNlLCBzZXJ2ZXIgY2Fubm90IGRlY2lkZSBpZiB0aGUgbGF5b3V0IGV4
aXN0cyB1bnRpbCBjbGllbnQgcmV0dXJucyByZXNwb25zZSB0byBsYXlvdXRyZWNhbGwuIEJ1dCBJ
IGNhbid0IGZpbmQNCmFueSByZXF1aXJlbWVudCBpbiBSRkM1NjYxIHRoYXQgc2VydmVyIG11c3Qg
d2FpdCBmb3IgbGF5b3V0cmVjYWxsJ3MgcmVzcG9uc2UgYmVmb3JlIHByb2Nlc3NpbmcgbGF5b3V0
Y29tbWl0Lg0KDQpUaGFua3MsDQpUYW8NCg0KTu+/ve+/ve+/ve+/ve+/vXLvv73vv71577+977+9
77+9Yu+/vVjvv73vv73Hp3bvv71e77+9Kd66ey5u77+9K++/ve+/ve+/ve+/vXvvv73vv73vv70i
77+977+9Xm7vv71y77+977+977+9eu+/vRrvv73vv71o77+977+977+977+9Ju+/ve+/vR7vv71H
77+977+977+9aO+/vQMo77+96ZqO77+93aJqIu+/ve+/vRrvv70bbe+/ve+/ve+/ve+/ve+/vXrv
v73elu+/ve+/ve+/vWbvv73vv73vv71o77+977+977+9fu+/vW3vv70=
