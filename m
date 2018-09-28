Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-cys01nam02on0127.outbound.protection.outlook.com ([104.47.37.127]:61423
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726451AbeI2DEU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Sep 2018 23:04:20 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "aglo@umich.edu" <aglo@umich.edu>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/7] NFS: Convert lookups of the open context to RCU
Date: Fri, 28 Sep 2018 20:38:47 +0000
Message-ID: <6caf095d3bf43494d25dfe854f2cd87f8eab5adf.camel@hammerspace.com>
References: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
         <20180905192400.107485-2-trond.myklebust@hammerspace.com>
         <20180905192400.107485-3-trond.myklebust@hammerspace.com>
         <20180905192400.107485-4-trond.myklebust@hammerspace.com>
         <20180905192400.107485-5-trond.myklebust@hammerspace.com>
         <20180905192400.107485-6-trond.myklebust@hammerspace.com>
         <CAN-5tyG_qr7P8-2_yXAqDvQps0C06AQUuNuBBbYpUcWUsXEVYg@mail.gmail.com>
         <CAN-5tyGoywV9_cqv9jwHS7s58sX49baG4HXLn85ka-jHySxT0g@mail.gmail.com>
         <9dbc1442dd1e7bba1903a5ecf2855054ffcd0ee4.camel@gmail.com>
         <CAN-5tyH=YKiTb4ZWUeJgZg+TDJP9W2yP8acapKSs=km5RTU_6Q@mail.gmail.com>
         <cf7ee206ca825e243f671ccc3a0f3c332e144174.camel@hammerspace.com>
         <CAN-5tyGBufKA6Bn1AsB7yLviVGr5SHGyRc4z4hrKF-hScTrQXg@mail.gmail.com>
         <CAN-5tyGrjjGKG5KoDAgzLrnnzjGUqmf1iUD_AM=wbX8bD5Jk-g@mail.gmail.com>
         <983c9970070f98ac54526742e6c4de4b0ff7ad63.camel@hammerspace.com>
         <CAN-5tyGt+J=irZQgByH_nXOtXkztsyjjzLwEfrXHs2UzOZXEHA@mail.gmail.com>
In-Reply-To: <CAN-5tyGt+J=irZQgByH_nXOtXkztsyjjzLwEfrXHs2UzOZXEHA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE4LTA5LTI4IGF0IDE2OjE5IC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gT24gRnJpLCBTZXAgMjgsIDIwMTggYXQgNDowNyBQTSBUcm9uZCBNeWtsZWJ1c3QgPA0K
PiB0cm9uZG15QGhhbW1lcnNwYWNlLmNvbT4gd3JvdGU6DQo+ID4gDQo+ID4gT24gRnJpLCAyMDE4
LTA5LTI4IGF0IDE1OjU1IC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90ZToNCj4gPiA+IE9u
IEZyaSwgU2VwIDI4LCAyMDE4IGF0IDM6MTAgUE0gT2xnYSBLb3JuaWV2c2thaWEgPGFnbG9AdW1p
Y2guZWR1DQo+ID4gPiA+DQo+ID4gPiB3cm90ZToNCj4gPiA+ID4gDQo+ID4gPiBXYWl0LCB3aHkg
YXJlIHdlIHN1cHBvc2UgdG8gcmVjbGFpbSB0aGUgb3BlbiBzdGF0ZSB3aGVuIHdlIGhhdmUgYQ0K
PiA+ID4gdmFsaWQgb3BlbiBzdGF0ZWlkPyBXZSBkb24ndCBoYXZlIGFueSBjYWNoZWQgb3BlbnMg
dGhhdCBzZXJ2ZXINCj4gPiA+IGRvZXNuJ3QNCj4gPiA+IGtub3cgYWJvdXQuIFJGQzc1MzAgc2F5
cyAiaWYgdGhlIGZpbGUgaGFzIG90aGVyIG9wZW4gcmVmZXJlbmNlIiwNCj4gPiA+IEkNCj4gPiA+
IHRoaW5rIHRoZSBlbXBoYXNpcyBpcyBvbiAib3RoZXIiLiBJIGRvbid0IGJlbGlldmUgd2UgbmVl
ZCB0byBiZQ0KPiA+ID4gc2VuZGluZyBhbnl0aGluZyBiZXNpZGVzIHRoZSBsb2NrcyB0byB0aGUg
c2VydmVyLiBUaGVuIEknbSBiYWNrDQo+ID4gPiB0bw0KPiA+ID4gc3F1YXJlIG9uZS4NCj4gPiAN
Cj4gPiBIb2xkaW5nIGEgZGVsZWdhdGlvbiBkb2VzIG5vdCBpbXBseSB0aGF0IHdlIGhvbGQgYW4g
b3BlbiBzdGF0ZWlkLg0KPiA+IFVuZGVyDQo+ID4gTGludXgsIHRoZSBvcGVuIHN0YXRlaWQgZ2V0
cyBjbG9zZWQgYXMgc29vbiBhcyB0aGUgYXBwbGljYXRpb24NCj4gPiBjbG9zZXMNCj4gPiB0aGUg
ZmlsZS4NCj4gPiANCj4gPiBUaGUgZGVsZWdhdGlvbiwgb24gdGhlIG90aGVyIGhhbmQsIGlzIHJl
dGFpbmVkIHVudGlsIGVpdGhlciBpdCBpcw0KPiA+IHJlY2FsbGVkLCBvciB3ZSBzZWUgdGhhdCB0
aGUgZmlsZSBoYXMgbm90IGJlZW4gdXNlZCBmb3IgMiBsZWFzZQ0KPiA+IHBlcmlvZHMuDQo+IA0K
PiBPayBJIGFncmVlIHdpdGggYWxsIG9mIGl0IGJ1dCBJJ20gc2F5aW5nIGl0IGRvZXNuJ3QgbmVl
ZCB0byBiZQ0KPiByZWNsYWltZWQgdW5jb25kaXRpb25hbGx5IG9yIGFyZSB5b3Ugc2F5aW5nIHRo
YXQncyB3aGF0IHRoZSBsaW51eA0KPiBjbGllbnQgZG9lcz8gSW4gdGhpcyB0ZXN0IGNhc2UsIHRo
ZSBmaWxlIGhhc24ndCBiZWVuIGNsb3NlZCBvcg0KPiBleHBpcmVkLiBJJ20gc3RhdGluZyB0aGF0
IHRoZSBjbGllbnQgaGFzIGEgdmFsaWQgb3BlbiBzdGF0ZWlkIGFuZA0KPiBzaG91bGQgb25seSBi
ZSByZXF1aXJlZCB0byByZWNsYWltIHRoZSBsb2NrcyAod2hpY2ggd2l0aCB0aGlzIHBhdGNoDQo+
IGl0DQo+IGRvZXMpLg0KDQpBcyBJIHNhaWQgZWFybGllciwgdGhlIGNsaWVudCBpcyByZXF1aXJl
ZCB0byByZWNvdmVyIGFsbCBfY2FjaGVkXyBvcGVuDQphbmQgbG9jayBzdGF0ZS4gSWYgaXQgYWxy
ZWFkeSBob2xkcyBhbiBvcGVuIHN0YXRlaWQsIHRoZW4gaXQgc2hvdWxkIG5vdA0KbmVlZCB0byBy
ZWNsYWltIHRoZSBvcGVuIG1vZGVzIHRoYXQgYXJlIGNvdmVyZWQgYnkgdGhhdCBzdGF0ZWlkLA0K
aG93ZXZlciBpdCBtYXkgc3RpbGwgbmVlZCB0byByZWNsYWltIHRob3NlIG9wZW4gbW9kZXMgdGhh
dCB3ZXJlIG5vdA0KYWxyZWFkeSBzdWJqZWN0IHRvIGFuIGV4cGxpY2l0IE9QRU4gY2FsbC4NCg0K
SU9XOiBJZiB0aGUgZmlsZSB3YXMgZmlyc3Qgb3BlbmVkIHdpdGggYW4gb3BlbihPX1JEUlcpIGNh
bGwgYnkgdGhlDQphcHBsaWNhdGlvbiwgYnV0IGEgc2Vjb25kIGFwcGxpY2F0aW9uIHRoZW4gb3Bl
bmVkIGl0IHVzaW5nDQpvcGVuKE9fV1JPTkxZKSwgdGhlbiB3ZSBtYXkgYWxyZWFkeSBob2xkIGEg
c3RhdGVpZCB3aXRoIGENCiJTSEFSRV9BQ0NFU1NfQk9USCIgb3BlbiBtb2RlLCBob3dldmVyIHdl
IHdpbGwgc3RpbGwgbmVlZCB0byBzZW5kIGENCnJlY2xhaW0gZm9yIHRoZSBjYWNoZWQgU0hBUkVf
QUNDRVNTX1dSSVRFIG1vZGUsIHNvIHRoYXQgYSBsYXRlcg0KT1BFTl9ET1dOR1JBREUoU0hBUkVf
QUNDRVNTX1dSSVRFKSBjYW4gc3VjY2VlZC4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4
IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1t
ZXJzcGFjZS5jb20NCg0KDQo=
