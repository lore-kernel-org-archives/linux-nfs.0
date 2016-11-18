Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:26380 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752301AbcKRWpA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2016 17:45:00 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: Fields Bruce James <bfields@fieldses.org>
CC: Kornievskaia Olga <aglo@umich.edu>,
        "tibbs@math.uh.edu" <tibbs@math.uh.edu>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
Date: Fri, 18 Nov 2016 22:44:52 +0000
Message-ID: <08D8E478-40ED-4DA7-B4B3-865BD2E02FB5@primarydata.com>
References: <20161117201753.GF20937@fieldses.org>
 <CAN-5tyHcaJCCdBaNbU4Mc=JuJXi9cDppuTVKKixrgVZMZS-DMg@mail.gmail.com>
 <20161117204618.GG20937@fieldses.org>
 <CAN-5tyHs1Xq4W2eJOMOW_Tv3=3hQLYhLdVwMDYixhGnaGsEH4Q@mail.gmail.com>
 <20161117212601.GA23130@fieldses.org>
 <1479419127.33885.5.camel@primarydata.com>
 <CAN-5tyFChQ0S4hUwGyWjaJ73hBpTZjJXVK3jm_M_4v1vgzVSjA@mail.gmail.com>
 <1479420942.33885.19.camel@primarydata.com>
 <CAN-5tyFazrkcBVor7YvbOPKGWSCDPH1-NLUjZBKJPoKBrzoy-g@mail.gmail.com>
 <1479422635.33885.30.camel@primarydata.com>
 <20161118205239.GH5424@fieldses.org>
In-Reply-To: <20161118205239.GH5424@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQo+IE9uIE5vdiAxOCwgMjAxNiwgYXQgMTU6NTIsIGJmaWVsZHNAZmllbGRzZXMub3JnIHdyb3Rl
Og0KPiANCj4gT24gVGh1LCBOb3YgMTcsIDIwMTYgYXQgMTA6NDM6NThQTSArMDAwMCwgVHJvbmQg
TXlrbGVidXN0IHdyb3RlOg0KPj4gT24gVGh1LCAyMDE2LTExLTE3IGF0IDE3OjI3IC0wNTAwLCBP
bGdhIEtvcm5pZXZza2FpYSB3cm90ZToNCj4+PiBPbiBUaHUsIE5vdiAxNywgMjAxNiBhdCA1OjE1
IFBNLCBUcm9uZCBNeWtsZWJ1c3QNCj4+PiA8dHJvbmRteUBwcmltYXJ5ZGF0YS5jb20+IHdyb3Rl
Og0KPj4+PiBXaGF0J3MgdGhlIGFsdGVybmF0aXZlPyBBc3N1bWUgdGhlIGNsaWVudCBwcmUtZW1w
dGl2ZWx5IGJ1bXBzIHRoZQ0KPj4+PiBzZXFpZA0KPj4+PiBpbnN0ZWFkIG9mIHJldHJ5aW5nLCB0
aGVuIHRoZSB1c2VyIHByZXNzZXMgQ3RybC1DIGFnYWluLiBSZXBlYXQgYQ0KPj4+PiBmZXcNCj4+
Pj4gbW9yZSB0aW1lcy4gSG93IGRvIEkgbm93IHJlc3luYyB0aGUgc2VxaWRzIGJldHdlZW4gdGhl
IGNsaWVudCBhbmQNCj4+Pj4gc2VydmVyIG90aGVyIHRoYW4gYnkgdHJhc2hpbmcgdGhlIHNlc3Np
b24/DQo+Pj4gDQo+Pj4gSSBkb24ndCBzZWUgYW55IGFsdGVybmF0aXZlcyB0aGFuIHRvIHJlc2V0
IGluIHRoYXQgY2FzZS4gQnV0IEkgdGhpbmsNCj4+PiBpdCdzIGJldHRlciB0aGVuIHRoZSBwb3Nz
aWJpbGl0eSBvZiBhY2NpZGVudGFsbHkgb3BlbmluZyBhIHdyb25nDQo+Pj4gZmlsZT8NCj4gDQo+
IFJlbWluZCBtZSB3aHkgeW91IGNhbid0IGNvbnRpbnVlIHJlc2VuZGluZyBhZnRlciB0aGUgQ3Ry
bC1DPyAgKEkgdGhvdWdodA0KPiB0aGlzIHdhcyBhbHJlYWR5IGRvbmUgZm9yIHNvbWUgbG9jayBh
bmQgb3RoZXIgY2FzZXM/KQ0KDQpXZeKAmWQgaGF2ZSB0byBkbyBpdCBmb3IgYWxsIFJQQyBjYWxs
cywgd2hpY2ggbWVhbnMgdGhleSB3b3VsZCBhbGwgaGF2ZSB0byBiZSBjb252ZXJ0ZWQgdG8gbm90
IHVzZSB0aGUgc3RhY2suIFRoZSByZXN1bHRpbmcgYmVoYXZpb3VyIHdvdWxkIGFsc28gYmUgY29u
ZnVzaW5nLCBhcyBvcGVyYXRpb25zIHdvdWxkIGNvbXBsZXRlIG91dHNpZGUgb2YgbG9ja2luZyBy
dWxlcyBldGMuIFNvLCBmb3IgaW5zdGFuY2UsIHlvdSB3b3VsZCBiZSBzZWVpbmcgc3VjY2Vzc2Z1
bGx5IGxvb2tlZCB1cCBmaWxlcyBteXN0ZXJpb3VzbHkgZGlzYXBwZWFyaW5nIGFzIHRoZSBhc3lu
Y2hyb25vdXMgdW5saW5rKCkgb3BlcmF0aW9uIHRoYXQgd2FzIGludGVycnVwdGVkIGNvbXBsZXRl
cywgb3IgZGlyZWN0b3JpZXMgbXlzdGVyaW91c2x5IGdldHRpbmcgcmVuYW1lZC4NCg0KPiANCj4+
IFRoZXkgc291bmQgZXF1YWxseSBiYWQgdG8gbWUgd2hpY2ggaXMgd2h5IEknbSBub3QgdW5kZXJz
dGFuZGluZyBob3cgYQ0KPj4gc2VydmVyIHdvdWxkIGZhaWwgdG8gaW1wbGVtZW50IHNvbWUgbWlu
aW1hbCBmb3JtIG9mIGZhbHNlIHJldHJ5DQo+PiBjaGVja2luZy4NCj4+IFRoZSBMaW51eCBORlN2
MyBEUkMgd2lsbCwgZm9yIGluc3RhbmNlLCBjaGVja3N1bSBhdCBsZWFzdCBzb21lIHBhcnQgb2YN
Cj4+IHRoZSBSUEMgYXJndW1lbnRzIGZvciBfYWxsXyBSUEMgY2FsbHMuIE1vc3QgTkZTdjQueCBj
bGllbnRzIHdpbGwgb25seQ0KPj4gYXNrIHRoYXQgeW91IGNoZWNrc3VtIHRoZSBub24taWRlbXBv
dGVudCBSUEMgY2FsbHMsIHdoaWNoIHNpZ25pZmljYW50bHkNCj4+IGN1dHMgZG93biBvbiB0aGUg
Y2FsY3VsYXRpb24gb3ZlcmhlYWQuDQo+IA0KPiBJJ2xsIGxvb2sgYXQgYWRkaW5nIGNoZWNrc3Vt
bWluZywgaXQgc2hvdWxkbid0IGJlIGhhcmQuDQoNClRoYW5rcy4NCg0K

