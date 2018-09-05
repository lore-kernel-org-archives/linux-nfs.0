Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr680097.outbound.protection.outlook.com ([40.107.68.97]:44820
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726046AbeIEUAp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Sep 2018 16:00:45 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 23/34] SUNRPC: Move RPC retransmission stat counter to
 xprt_transmit()
Date: Wed, 5 Sep 2018 15:28:20 +0000
Message-ID: <4165cdf8162f9ca6aa1165c71e880632fda259ec.camel@hammerspace.com>
References: <20180904210549.81673-1-trond.myklebust@hammerspace.com>
         <20180904210549.81673-2-trond.myklebust@hammerspace.com>
         <20180904210549.81673-3-trond.myklebust@hammerspace.com>
         <20180904210549.81673-4-trond.myklebust@hammerspace.com>
         <20180904210549.81673-5-trond.myklebust@hammerspace.com>
         <20180904210549.81673-6-trond.myklebust@hammerspace.com>
         <20180904210549.81673-7-trond.myklebust@hammerspace.com>
         <20180904210549.81673-8-trond.myklebust@hammerspace.com>
         <20180904210549.81673-9-trond.myklebust@hammerspace.com>
         <20180904210549.81673-10-trond.myklebust@hammerspace.com>
         <20180904210549.81673-11-trond.myklebust@hammerspace.com>
         <20180904210549.81673-12-trond.myklebust@hammerspace.com>
         <20180904210549.81673-13-trond.myklebust@hammerspace.com>
         <20180904210549.81673-14-trond.myklebust@hammerspace.com>
         <20180904210549.81673-15-trond.myklebust@hammerspace.com>
         <20180904210549.81673-16-trond.myklebust@hammerspace.com>
         <20180904210549.81673-17-trond.myklebust@hammerspace.com>
         <20180904210549.81673-18-trond.myklebust@hammerspace.com>
         <20180904210549.81673-19-trond.myklebust@hammerspace.com>
         <20180904210549.81673-20-trond.myklebust@hammerspace.com>
         <20180904210549.81673-21-trond.myklebust@hammerspace.com>
         <20180904210549.81673-22-trond.myklebust@hammerspace.com>
         <20180904210549.81673-23-trond.myklebust@hammerspace.com>
         <20180904210549.81673-24-trond.myklebust@hammerspace.com>
         <0A486690-38DA-4377-8968-DF0008113479@oracle.com>
In-Reply-To: <0A486690-38DA-4377-8968-DF0008113479@oracle.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE4LTA5LTA1IGF0IDEwOjMwIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBTZXAgNCwgMjAxOCwgYXQgNTowNSBQTSwgVHJvbmQgTXlrbGVidXN0IDx0cm9uZG15QGdt
YWlsLmNvbT4NCj4gPiB3cm90ZToNCj4gPiANCj4gPiBTaWduZWQtb2ZmLWJ5OiBUcm9uZCBNeWts
ZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20+DQo+ID4gLS0tDQo+ID4gbmV0
L3N1bnJwYy9jbG50LmMgfCAgNiAtLS0tLS0NCj4gPiBuZXQvc3VucnBjL3hwcnQuYyB8IDEzICsr
KysrKy0tLS0tLS0NCj4gPiAyIGZpbGVzIGNoYW5nZWQsIDYgaW5zZXJ0aW9ucygrKSwgMTMgZGVs
ZXRpb25zKC0pDQo+ID4gDQo+ID4gZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMvY2xudC5jIGIvbmV0
L3N1bnJwYy9jbG50LmMNCj4gPiBpbmRleCAwMzJiNzA0MmFkYjYuLjIxNzEzYmVkODEyYSAxMDA2
NDQNCj4gPiAtLS0gYS9uZXQvc3VucnBjL2NsbnQuYw0KPiA+ICsrKyBiL25ldC9zdW5ycGMvY2xu
dC5jDQo+ID4gQEAgLTE5NjcsOCArMTk2Nyw2IEBAIGNhbGxfY29ubmVjdF9zdGF0dXMoc3RydWN0
IHJwY190YXNrICp0YXNrKQ0KPiA+IHN0YXRpYyB2b2lkDQo+ID4gY2FsbF90cmFuc21pdChzdHJ1
Y3QgcnBjX3Rhc2sgKnRhc2spDQo+ID4gew0KPiA+IC0JaW50IGlzX3JldHJhbnMgPSBSUENfV0FT
X1NFTlQodGFzayk7DQo+ID4gLQ0KPiA+IAlkcHJpbnRfc3RhdHVzKHRhc2spOw0KPiA+IA0KPiA+
IAl0YXNrLT50a19hY3Rpb24gPSBjYWxsX3RyYW5zbWl0X3N0YXR1czsNCj4gPiBAQCAtMTk3OSwx
MCArMTk3Nyw2IEBAIGNhbGxfdHJhbnNtaXQoc3RydWN0IHJwY190YXNrICp0YXNrKQ0KPiA+IAlp
ZiAoIXhwcnRfcHJlcGFyZV90cmFuc21pdCh0YXNrKSkNCj4gPiAJCXJldHVybjsNCj4gPiAJeHBy
dF90cmFuc21pdCh0YXNrKTsNCj4gPiAtCWlmICh0YXNrLT50a19zdGF0dXMgPCAwKQ0KPiA+IC0J
CXJldHVybjsNCj4gPiAtCWlmIChpc19yZXRyYW5zKQ0KPiA+IC0JCXRhc2stPnRrX2NsaWVudC0+
Y2xfc3RhdHMtPnJwY3JldHJhbnMrKzsNCj4gPiB9DQo+ID4gDQo+ID4gLyoNCj4gPiBkaWZmIC0t
Z2l0IGEvbmV0L3N1bnJwYy94cHJ0LmMgYi9uZXQvc3VucnBjL3hwcnQuYw0KPiA+IGluZGV4IGYx
MzAxZDM5MTM5OS4uZTJmNWI0NjY4YTY2IDEwMDY0NA0KPiA+IC0tLSBhL25ldC9zdW5ycGMveHBy
dC5jDQo+ID4gKysrIGIvbmV0L3N1bnJwYy94cHJ0LmMNCj4gPiBAQCAtMTkxLDggKzE5MSw2IEBA
IGludCB4cHJ0X3Jlc2VydmVfeHBydChzdHJ1Y3QgcnBjX3hwcnQgKnhwcnQsDQo+ID4gc3RydWN0
IHJwY190YXNrICp0YXNrKQ0KPiA+IAkJZ290byBvdXRfc2xlZXA7DQo+ID4gCX0NCj4gPiAJeHBy
dC0+c25kX3Rhc2sgPSB0YXNrOw0KPiA+IC0JaWYgKHJlcSAhPSBOVUxMKQ0KPiA+IC0JCXJlcS0+
cnFfbnRyYW5zKys7DQo+ID4gDQo+ID4gCXJldHVybiAxOw0KPiA+IA0KPiA+IEBAIC0yNDcsNyAr
MjQ1LDYgQEAgaW50IHhwcnRfcmVzZXJ2ZV94cHJ0X2Nvbmcoc3RydWN0IHJwY194cHJ0DQo+ID4g
KnhwcnQsIHN0cnVjdCBycGNfdGFzayAqdGFzaykNCj4gPiAJfQ0KPiA+IAlpZiAoX194cHJ0X2dl
dF9jb25nKHhwcnQsIHRhc2spKSB7DQo+ID4gCQl4cHJ0LT5zbmRfdGFzayA9IHRhc2s7DQo+ID4g
LQkJcmVxLT5ycV9udHJhbnMrKzsNCj4gPiAJCXJldHVybiAxOw0KPiA+IAl9DQo+ID4gCXhwcnRf
Y2xlYXJfbG9ja2VkKHhwcnQpOw0KPiA+IEBAIC0yODEsMTIgKzI3OCw4IEBAIHN0YXRpYyBpbmxp
bmUgaW50IHhwcnRfbG9ja193cml0ZShzdHJ1Y3QNCj4gPiBycGNfeHBydCAqeHBydCwgc3RydWN0
IHJwY190YXNrICp0YXNrKQ0KPiA+IHN0YXRpYyBib29sIF9feHBydF9sb2NrX3dyaXRlX2Z1bmMo
c3RydWN0IHJwY190YXNrICp0YXNrLCB2b2lkDQo+ID4gKmRhdGEpDQo+ID4gew0KPiA+IAlzdHJ1
Y3QgcnBjX3hwcnQgKnhwcnQgPSBkYXRhOw0KPiA+IC0Jc3RydWN0IHJwY19ycXN0ICpyZXE7DQo+
ID4gDQo+ID4gLQlyZXEgPSB0YXNrLT50a19ycXN0cDsNCj4gPiAJeHBydC0+c25kX3Rhc2sgPSB0
YXNrOw0KPiA+IC0JaWYgKHJlcSkNCj4gPiAtCQlyZXEtPnJxX250cmFucysrOw0KPiA+IAlyZXR1
cm4gdHJ1ZTsNCj4gPiB9DQo+ID4gDQo+ID4gQEAgLTExMjYsNiArMTExOSw3IEBAIHZvaWQgeHBy
dF90cmFuc21pdChzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2spDQo+ID4gCXN0cnVjdCBycGNfcnFzdAkq
cmVxID0gdGFzay0+dGtfcnFzdHA7DQo+ID4gCXN0cnVjdCBycGNfeHBydAkqeHBydCA9IHJlcS0+
cnFfeHBydDsNCj4gPiAJdW5zaWduZWQgaW50IGNvbm5lY3RfY29va2llOw0KPiA+ICsJaW50IGlz
X3JldHJhbnMgPSBSUENfV0FTX1NFTlQodGFzayk7DQo+ID4gCWludCBzdGF0dXM7DQo+ID4gDQo+
ID4gCWRwcmludGsoIlJQQzogJTV1IHhwcnRfdHJhbnNtaXQoJXUpXG4iLCB0YXNrLT50a19waWQs
IHJlcS0NCj4gPiA+cnFfc2xlbik7DQo+ID4gQEAgLTExNDAsNiArMTEzNCw4IEBAIHZvaWQgeHBy
dF90cmFuc21pdChzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2spDQo+ID4gCQl9DQo+ID4gCX0NCj4gPiAN
Cj4gPiArCXJlcS0+cnFfbnRyYW5zKys7DQo+ID4gKw0KPiANCj4gcnFfbnRyYW5zIGlzIHVzZWQg
aW4gdHdvIHBsYWNlczoNCj4gDQo+IDEuIHJwY191cGRhdGVfcnR0DQo+IDIuIHJwY19jb3VudF9p
b3N0YXRzX21ldHJpY3MNCj4gDQo+IEJvdGggb2YgdGhlc2UgYXBwZWFyIHRvIGFzc3VtZSB0aGF0
IHJxX250cmFucyBpcyBjb3VudGluZw0KPiBmdWxsIHN1Y2Nlc3NmdWwgdHJhbnNtaXNzaW9ucyAo
aWUsIGNhbGxzIHRoYXQgYXBwZWFyIG9uIHRoZQ0KPiB3aXJlKSwgbm90IGludm9jYXRpb25zIG9m
IC0+c2VuZF9yZXF1ZXN0KCkuDQo+IA0KPiBDYW4gdGhpcyBjb3VudGVyIGJlIG1vdmVkIGRvd24g
dG8gd2hlcmUgcnBjcmV0cmFucyBpcyB1cGRhdGVkPw0KPiANCg0KVGhlIHJlYXNvbiB3aHkgSSBk
b24ndCB3YW50IHRvIHVwZGF0ZSByZXEtPnJxX250cmFucyBhZnRlciB0cmFuc21pc3Npb24NCmlz
IGJlY2F1c2UgdGhhdCB3b3VsZCByYWNlIHdpdGggdGhlIHJlcGx5IGZyb20gdGhlIHNlcnZlciAo
d2hpY2ggaXMgbm90DQpibG9ja2VkIGJ5IHRoZSBYUFJUX0xPQ0spLiBJbiB0aGF0IHJhY2Ugc2Nl
bmFyaW8sIHJwY191cGRhdGVfcnR0KCkNCmNvdWxkIHVwZGF0ZSB0aGUgUlRUIHZhbHVlIGJlZm9y
ZSB3ZSd2ZSB1cGRhdGVkIHRoZSByZXEtPnJxX250cmFucywNCm1lYW5pbmcgdGhhdCB3ZSBtaWdo
dCBiZSBtZWFzdXJpbmcgdGhlIHJlc3BvbnNlIHRpbWUgYWdhaW5zdCBhIHJlcGx5IHRvDQp0aGUg
b3JpZ2luYWwgdHJhbnNtaXNzaW9uIG9yIHRvIHRoZSByZXRyYW5zbWlzc2lvbiB0aGF0IHdhcyBq
dXN0IHNlbnQuDQpUaGF0IHdvdWxkIGVuZCB1cCBicmVha2luZyBWYW4gSmFjb2JzZW4gY29uZ2Vz
dGlvbiBjb250cm9sLCBzaW5jZSB3ZQ0KcmlzayBzaWduaWZpY2FudGx5IHVuZGVyZXN0aW1hdGlu
ZyB0aGUgUlRUIHZhbHVlLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVu
dCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNv
bQ0KDQoNCg==
