Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-co1nam03on0136.outbound.protection.outlook.com ([104.47.40.136]:18624
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726046AbeIETmo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Sep 2018 15:42:44 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "neilb@suse.com" <neilb@suse.com>,
        "aglo@umich.edu" <aglo@umich.edu>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4.1 session reset needs to update ->rsize and ->wsize -
 how???
Date: Wed, 5 Sep 2018 15:12:03 +0000
Message-ID: <f700a6d48218533ed2a3ca3a23c06c9cd40cf3c8.camel@hammerspace.com>
References: <87r2i8vq10.fsf@notabene.neil.brown.name>
         <f7f84aced6ae709b1c66e1475e8d79927fa29132.camel@hammerspace.com>
         <87o9dcvmk6.fsf@notabene.neil.brown.name>
         <CAN-5tyG0DXosk0RUCM6E+pj-EmMWW5tuKfPg4HJChp9snvcQAQ@mail.gmail.com>
In-Reply-To: <CAN-5tyG0DXosk0RUCM6E+pj-EmMWW5tuKfPg4HJChp9snvcQAQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE4LTA5LTA1IGF0IDA5OjQ0IC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gY29tbWl0IDAzMzg1MzMyNWZlM2JkYzcwODE5YThiOTc5MTViZDNiY2E0MWQzYWYNCj4g
QXV0aG9yOiBPbGdhIEtvcm5pZXZza2FpYSA8a29sZ2FAbmV0YXBwLmNvbT4NCj4gRGF0ZTogICBX
ZWQgTWFyIDggMTQ6Mzk6MTUgMjAxNyAtMDUwMA0KPiANCj4gICAgIE5GU3Y0LjEgcmVzcGVjdCBz
ZXJ2ZXIncyBtYXggc2l6ZSBpbiBDUkVBVEVfU0VTU0lPTg0KPiANCj4gICAgIEN1cnJlbnRseSBj
bGllbnQgZG9lc24ndCByZXNwZWN0IG1heCBzaXplcyBzZXJ2ZXIgcmV0dXJucyBpbg0KPiBDUkVB
VEVfU0VTU0lPTi4NCj4gICAgIG5mczRfc2Vzc2lvbl9zZXRfcndzaXplKCkgZ2V0cyBjYWxsZWQg
YW5kIHNlcnZlci0+cnNpemUsIHNlcnZlci0NCj4gPndzaXplIGFyZSAwDQo+ICAgICBzbyB0aGV5
IG5ldmVyIGdldCBzZXQgdG8gdGhlIHNpemVzIHJldHVybmVkIGJ5IHRoZSBzZXJ2ZXIuDQo+IA0K
PiAgICAgU2lnbmVkLW9mZi1ieTogT2xnYSBLb3JuaWV2c2thaWEgPGtvbGdhQG5ldGFwcC5jb20+
DQo+ICAgICBTaWduZWQtb2ZmLWJ5OiBBbm5hIFNjaHVtYWtlciA8QW5uYS5TY2h1bWFrZXJATmV0
YXBwLmNvbT4NCj4gDQoNCk9sZ2EsIEknbSBjb25mdXNlZCBieSB0aGF0IHBhdGNoLiBJdCBhcHBl
YXJzIHRvIGFzc3VtZSB0aGF0IHdlIHNob3VsZA0KYmUgdXNpbmcgdGhlIENSRUFURV9TRVNTSU9O
LCByZXF1ZXN0L3Jlc3BvbnNlIGxpbWl0cyBhcyBkZWZhdWx0IHZhbHVlcw0KaW5zdGVhZCBvZiBh
cyBsaW1pdHM/DQoNCkFGQUlDUywgdGhlIHJlYWwgcHJvYmxlbSB0aGVyZSBpcyB0aGF0IG5mczRf
c2VydmVyX2NvbW1vbl9zZXR1cCgpIGlzDQpjYWxsaW5nIG5mczRfc2Vzc2lvbl9zZXRfcndzaXpl
KCkgYmVmb3JlIHdlIGFjdHVhbGx5IHNldCB0aGUgci93c2l6ZSBpbg0KdGhlIGNhbGwgdG8gbmZz
X3Byb2JlX2ZzaW5mbygpLiBObz8NCg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZT
IGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNw
YWNlLmNvbQ0KDQoNCg==
