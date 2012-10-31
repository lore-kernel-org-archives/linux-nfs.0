Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29019 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755428Ab2JaRpa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Oct 2012 13:45:30 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jonathan Nieder <jrnieder@gmail.com>
CC: Ben Hutchings <ben@decadent.org.uk>,
        "669314@bugs.debian.org" <669314@bugs.debian.org>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        Micheal Waltz <mwaltz@qualcomm.com>,
        "Gabriel Evanoff" <gevanoff@salk.edu>,
        "laurent+debian@u-picardie.fr" <laurent+debian@u-picardie.fr>
Subject: Re: [PATCH] nfs: Show original device name verbatim in
 /proc/*/mount{s,info}
Date: Wed, 31 Oct 2012 17:45:25 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA90929FA9E@SACEXCMBX04-PRD.hq.netapp.com>
References: <7941E5E1-488D-4D0B-A21A-4E389EF6EBBA@salk.edu>
	 <1350843832.22276.34.camel@deadeye.wl.decadent.org.uk>
	 <20121022000119.GB9057@elie.Belkin>
In-Reply-To: <20121022000119.GB9057@elie.Belkin>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gU3VuLCAyMDEyLTEwLTIxIGF0IDE3OjAxIC0wNzAwLCBKb25hdGhhbiBOaWVkZXIgd3JvdGU6
DQo+IChjYy1pbmcgTGF1cmVudCBpbiBjYXNlIGhlIHdhbnRzIHRvIHRlc3QuICBMYXVyZW50LCBh
ICJnaXQgYW0iLXJlYWR5DQo+ICBwYXRjaCBpcyBhdCBbMV0pDQo+IEJlbiBIdXRjaGluZ3Mgd3Jv
dGU6DQo+IA0KPiA+IFNpbmNlIGNvbW1pdCBjN2Y0MDRiICgndmZzOiBuZXcgc3VwZXJibG9jayBt
ZXRob2RzIHRvIG92ZXJyaWRlDQo+ID4gL3Byb2MvKi9tb3VudHtzLGluZm99JyksIG5mc19wYXRo
KCkgaXMgdXNlZCB0byBnZW5lcmF0ZSB0aGUgbW91bnRlZA0KPiA+IGRldmljZSBuYW1lIHJlcG9y
dGVkIGJhY2sgdG8gdXNlcmxhbmQuDQo+ID4NCj4gPiBuZnNfcGF0aCgpIGFsd2F5cyBnZW5lcmF0
ZXMgYSB0cmFpbGluZyBzbGFzaCB3aGVuIHRoZSBnaXZlbiBkZW50cnkgaXMNCj4gPiB0aGUgcm9v
dCBvZiBhbiBORlMgbW91bnQsIGJ1dCB1c2VybGFuZCBtYXkgZXhwZWN0IHRoZSBvcmlnaW5hbCBk
ZXZpY2UNCj4gPiBuYW1lIHRvIGJlIHJldHVybmVkIHZlcmJhdGltIChhcyBpdCB1c2VkIHRvIGJl
KS4gIE1ha2UgdGhpcw0KPiA+IGNhbm9uaWNhbGlzYXRpb24gb3B0aW9uYWwgYW5kIGNoYW5nZSB0
aGUgY2FsbGVycyBhY2NvcmRpbmdseS4NCj4gPg0KPiA+IFJlcG9ydGVkLWFuZC10ZXN0ZWQtYnk6
IENocmlzIEhpZXN0YW5kIDxjaGllc3RhbmRAc2Fsay5lZHU+DQo+ID4gUmVmZXJlbmNlOiBodHRw
Oi8vYnVncy5kZWJpYW4ub3JnLzY2OTMxNA0KPiA+IFNpZ25lZC1vZmYtYnk6IEJlbiBIdXRjaGlu
Z3MgPGJlbkBkZWNhZGVudC5vcmcudWs+DQo+ID4gQ2M6IDxzdGFibGVAdmdlci5rZXJuZWwub3Jn
PiAjIHYyLjYuMzkrDQoNCg0KVGhpcyBwYXRjaCB3aWxsIG5vdCBhcHBseSB0byB0aGUgdXBzdHJl
YW0ga2VybmVsOyBpdCBzZWVtcyByYXRoZXIgdG8NCmhhdmUgYmVlbiBnZW5lcmF0ZWQgaW5jcmVt
ZW50YWxseSBhZ2FpbnN0IGFuIG9sZGVyIHBhdGNoIGF0dGVtcHQuDQoNClBsZWFzZSByZWdlbmVy
YXRlIGFuZCByZXNlbmQgaWYgeW91IHdhbnQgdGhpcyBtZXJnZWQuLi4NCg0KLS0gDQpUcm9uZCBN
eWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15
a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0K
