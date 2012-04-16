Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51831 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755071Ab2DPUZX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Apr 2012 16:25:23 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pstaubach@exagrid.com" <pstaubach@exagrid.com>,
        "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch@infradead.org" <hch@infradead.org>,
        "michael.brantley@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Date: Mon, 16 Apr 2012 20:25:06 +0000
Message-ID: <1334607906.2879.36.camel@lade.trondhjem.org>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	 <20120413150518.GA1987@us.ibm.com>
	 <20120413114236.0e557e01@tlielax.poochiereds.net>
	 <4F8B1B7B.3040304@itwm.fraunhofer.de>
	 <20120416073655.7cdb90cf@corrin.poochiereds.net>
	 <4F8C3036.2030702@itwm.fraunhofer.de>
	 <20120416134642.1754cd3e@corrin.poochiereds.net>
	 <1334604785.2879.23.camel@lade.trondhjem.org>
	 <20120416154322.0d95e435@corrin.poochiereds.net>
In-Reply-To: <20120416154322.0d95e435@corrin.poochiereds.net>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA0LTE2IGF0IDE1OjQzIC0wNDAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4g
T24gTW9uLCAxNiBBcHIgMjAxMiAxOTozMzowNSArMDAwMA0KPiAiTXlrbGVidXN0LCBUcm9uZCIg
PFRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29tPiB3cm90ZToNCj4gDQo+ID4gT24gTW9uLCAyMDEy
LTA0LTE2IGF0IDEzOjQ2IC0wNDAwLCBKZWZmIExheXRvbiB3cm90ZToNCj4gPiA+IFRoZSBxdWVz
dGlvbiBhYm91dCBsb29waW5nIGluZGVmaW5pdGVseSByZWFsbHkgY29tZXMgZG93biB0bzoNCj4g
PiA+IA0KPiA+ID4gMSkgaXMgYSBwZXJzaXN0ZW50IEVTVEFMRSBpbiBjb25qdW5jdGlvbiB3aXRo
IGEgc3VjY2Vzc2Z1bCBsb29rdXAgYQ0KPiA+ID4gc2l0dWF0aW9uIHRoYXQgd2UgZXhwZWN0IHRv
IGJlIHRlbXBvcmFyeS4gaS5lLiB3aWxsIHRoZSBhZG1pbiBhdCBzb21lDQo+ID4gPiBwb2ludCBi
ZSBhYmxlIHRvIGRvIHNvbWV0aGluZyBhYm91dCBpdD8gSWYgbm90LCB0aGVuIHRoZXJlJ3Mgbm8g
cG9pbnQNCj4gPiA+IGluIGNvbnRpbnVpbmcgdG8gcmV0cnkuIEFnYWluLCB0aGlzIGlzIGEgc2l0
dWF0aW9uIHRoYXQgKnJlYWxseSogc2hvdWxkDQo+ID4gPiBub3QgaGFwcGVuIGlmIHRoZSBmaWxl
c3lzdGVtIGlzIGRvaW5nIHRoZSByaWdodCB0aGluZy4NCj4gPiA+IA0KPiA+ID4gMikgSWYgdGhl
IGFkbWluIGNhbid0IGRvIGFueXRoaW5nIGFib3V0IGl0LCBpcyBpdCByZWFzb25hYmxlIHRvIGV4
cGVjdA0KPiA+ID4gdGhhdCB1c2VycyBjYW4gc2VuZCBhIGZhdGFsIHNpZ25hbCB0byBodW5nIGFw
cGxpY2F0aW9ucyBpZiB0aGlzDQo+ID4gPiBzaXR1YXRpb24gb2NjdXJzLg0KPiA+ID4gDQo+ID4g
PiBXZSBleHBlY3QgdGhhdCB0aGF0J3Mgb2sgaW4gb3RoZXIgc2l0dWF0aW9ucyB0byByZXNvbHZl
IGh1bmcNCj4gPiA+IGFwcGxpY2F0aW9ucywgc28gSSdtIG5vdCBzdXJlIEkgdW5kZXJzdGFuZCB3
aHkgaXQgd291bGRuJ3QgYmUNCj4gPiA+IGFjY2VwdGFibGUgaGVyZS4uLg0KPiA+IA0KPiA+IFRo
ZXJlIGFyZSBkZWZpbml0ZWx5IHBvdGVudGlhbGx5IHBlcnNpc3RlbnQgcGF0aG9sb2dpY2FsIHNp
dHVhdGlvbnMgdGhhdA0KPiA+IHRoZSBmaWxlc3lzdGVtIGNhbid0IGRvIGFueXRoaW5nIGFib3V0
LiBJZiB0aGUgcG9pbnQgb2Ygb3JpZ2luIGZvciB5b3VyDQo+ID4gcGF0aG5hbWUgKGZvciBpbnN0
YW5jZSB5b3VyIGN1cnJlbnQgZGlyZWN0b3J5IGluIHRoZSBjYXNlIG9mIGEgcmVsYXRpdmUNCj4g
PiBwYXRobmFtZSkgaXMgc3RhbGUsIHRoZW4gbm8gYW1vdW50IG9mIGxvb3BpbmcgaXMgZ29pbmcg
dG8gaGVscCB5b3UgdG8NCj4gPiByZWNvdmVyLg0KPiA+IA0KPiANCj4gT2sgLS0gUGV0ZXIgcHJl
dHR5IG11Y2ggc2FpZCBzb21ldGhpbmcgc2ltaWxhci4gUmV0cnlpbmcgaW5kZWZuaXRlbHkNCj4g
d2hlbiB0aGUgbG9va3VwIHJldHVybnMgRVNUQUxFIHByb2JhYmx5IHdvbid0IGhlbHAuIEknbSBv
ayB3aXRoDQo+IGJhc2ljYWxseSBsZXR0aW5nIHRoZSBWRlMgY29udGludWUgdG8gZG8gd2hhdCBp
dCBkb2VzIHRoZXJlIGFscmVhZHkuIElmDQo+IGl0IGdldHMgYW4gRVNUQUxFLCBpdCB0cmllcyBh
Z2FpbiB3aXRoIExPT0tVUF9SRVZBTCBzZXQgYW5kIHRoZW4gZ2l2ZXMNCj4gdXAgaWYgdGhhdCBk
b2Vzbid0IHdvcmsuDQo+IA0KPiBJZiBob3dldmVyLCB0aGUgb3BlcmF0aW9uIGl0c2VsZiBrZWVw
cyByZXR1cm5pbmcgRVNUQUxFLCBhcmUgd2UgT0sgdG8NCj4gcmV0cnkgaW5kZWZpbml0ZWx5IGFz
c3VtaW5nIHRoYXQgd2UnbGwgYnJlYWsgb3V0IG9mIHRoZSBsb29wIG9uIGZhdGFsDQo+IHNpZ25h
bHM/DQo+DQo+IEZvciBleGFtcGxlLCBzb21ldGhpbmcgbGlrZSB0aGUgdjIgcGF0Y2ggSSBzZW50
IGEgbGl0dGxlIHdoaWxlIGFnbz8NCg0KDQpXb24ndCBzb21ldGhpbmcgbGlrZSBmc3RhdGF0KEFU
X0ZEQ1dELCAiIiwgJnN0YXQsIEFUX0VNUFRZX1BBVEgpIHJpc2sNCmxvb3BpbmcgZm9yZXZlciB0
aGVyZSwgb3IgYW0gSSBtaXNzaW5nIHNvbWV0aGluZz8NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QN
CkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBu
ZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
