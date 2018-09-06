Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:60555 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729073AbeIFS7T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Sep 2018 14:59:19 -0400
From: "Schumaker, Anna" <Anna.Schumaker@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "trondmy@gmail.com" <trondmy@gmail.com>
Subject: Re: [PATCH v2 29/34] SUNRPC: Convert the xprt->sending queue back to
 an ordinary wait queue
Date: Thu, 6 Sep 2018 14:23:30 +0000
Message-ID: <2d3a176db9c8faf2c9e9ffb41af6e9df5ec40ee9.camel@netapp.com>
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
         <20180904210549.81673-25-trond.myklebust@hammerspace.com>
         <20180904210549.81673-26-trond.myklebust@hammerspace.com>
         <20180904210549.81673-27-trond.myklebust@hammerspace.com>
         <20180904210549.81673-28-trond.myklebust@hammerspace.com>
         <20180904210549.81673-29-trond.myklebust@hammerspace.com>
         <20180904210549.81673-30-trond.myklebust@hammerspace.com>
         <04e17d9b133447da19470330767b9fd6cbeefc3f.camel@netapp.com>
In-Reply-To: <04e17d9b133447da19470330767b9fd6cbeefc3f.camel@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE4LTA5LTA2IGF0IDEwOjE3IC0wNDAwLCBBbm5hIFNjaHVtYWtlciB3cm90ZToN
Cj4gSGkgVHJvbmQsDQo+IA0KPiBPbiBUdWUsIDIwMTgtMDktMDQgYXQgMTc6MDUgLTA0MDAsIFRy
b25kIE15a2xlYnVzdCB3cm90ZToNCj4gPiBXZSBubyBsb25nZXIgbmVlZCBwcmlvcml0eSBzZW1h
bnRpY3Mgb24gdGhlIHhwcnQtPnNlbmRpbmcgcXVldWUsIGJlY2F1c2UNCj4gPiB0aGUgb3JkZXIg
aW4gd2hpY2ggdGFza3MgYXJlIHNlbnQgaXMgbm93IGRpY3RhdGVkIGJ5IHRoZWlyIHBvc2l0aW9u
IGluDQo+ID4gdGhlIHNlbmQgcXVldWUuDQo+ID4gTm90ZSB0aGF0IHRoZSBiYWNrbG9nIHF1ZXVl
IHJlbWFpbnMgYSBwcmlvcml0eSBxdWV1ZSwgbWVhbmluZyB0aGF0DQo+ID4gc2xvdCByZXNvdXJj
ZXMgYXJlIHN0aWxsIG1hbmFnZWQgaW4gb3JkZXIgb2YgdGFzayBwcmlvcml0eS4NCj4gPiANCj4g
PiBTaWduZWQtb2ZmLWJ5OiBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBoYW1tZXJz
cGFjZS5jb20+DQo+ID4gLS0tDQo+ID4gIG5ldC9zdW5ycGMveHBydC5jIHwgMjkgKysrKysrLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0NCj4gPiAgMSBmaWxlIGNoYW5nZWQsIDYgaW5zZXJ0aW9ucygr
KSwgMjMgZGVsZXRpb25zKC0pDQo+ID4gDQo+ID4gZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMveHBy
dC5jIGIvbmV0L3N1bnJwYy94cHJ0LmMNCj4gPiBpbmRleCBiYTlhZjI1ZDE0ZGUuLmViZTUyMzVj
NDg0YiAxMDA2NDQNCj4gPiAtLS0gYS9uZXQvc3VucnBjL3hwcnQuYw0KPiA+ICsrKyBiL25ldC9z
dW5ycGMveHBydC5jDQo+ID4gQEAgLTE4MSw3ICsxODEsNiBAQCBFWFBPUlRfU1lNQk9MX0dQTCh4
cHJ0X2xvYWRfdHJhbnNwb3J0KTsNCj4gPiAgaW50IHhwcnRfcmVzZXJ2ZV94cHJ0KHN0cnVjdCBy
cGNfeHBydCAqeHBydCwgc3RydWN0IHJwY190YXNrICp0YXNrKQ0KPiA+ICB7DQo+ID4gIAlzdHJ1
Y3QgcnBjX3Jxc3QgKnJlcSA9IHRhc2stPnRrX3Jxc3RwOw0KPiANCj4gQXMgb2YgdGhpcyBwYXRj
aCwgcmVxIGlzIG5vIGxvbmdlciB1c2VkIGVpdGhlci4gIENhbiBpdCBiZSByZW1vdmVkPw0KDQpO
ZXZlciBtaW5kLCBJIGxvb2tlZCBhdCB0aGUgbmV4dCBwYXRjaCBhbmQgc2F3IHRoYXQgaXQncyB1
c2VkIGFnYWluLg0KDQo+IA0KPiBUaGFua3MsDQo+IEFubmENCj4gDQo+ID4gLQlpbnQgcHJpb3Jp
dHk7DQo+ID4gIA0KPiA+ICAJaWYgKHRlc3RfYW5kX3NldF9iaXQoWFBSVF9MT0NLRUQsICZ4cHJ0
LT5zdGF0ZSkpIHsNCj4gPiAgCQlpZiAodGFzayA9PSB4cHJ0LT5zbmRfdGFzaykNCj4gPiBAQCAt
MTk3LDEzICsxOTYsNyBAQCBpbnQgeHBydF9yZXNlcnZlX3hwcnQoc3RydWN0IHJwY194cHJ0ICp4
cHJ0LCBzdHJ1Y3QNCj4gPiBycGNfdGFzayAqdGFzaykNCj4gPiAgCQkJdGFzay0+dGtfcGlkLCB4
cHJ0KTsNCj4gPiAgCXRhc2stPnRrX3RpbWVvdXQgPSAwOw0KPiA+ICAJdGFzay0+dGtfc3RhdHVz
ID0gLUVBR0FJTjsNCj4gPiAtCWlmIChyZXEgPT0gTlVMTCkNCj4gPiAtCQlwcmlvcml0eSA9IFJQ
Q19QUklPUklUWV9MT1c7DQo+ID4gLQllbHNlIGlmICghcmVxLT5ycV9udHJhbnMpDQo+ID4gLQkJ
cHJpb3JpdHkgPSBSUENfUFJJT1JJVFlfTk9STUFMOw0KPiA+IC0JZWxzZQ0KPiA+IC0JCXByaW9y
aXR5ID0gUlBDX1BSSU9SSVRZX0hJR0g7DQo+ID4gLQlycGNfc2xlZXBfb25fcHJpb3JpdHkoJnhw
cnQtPnNlbmRpbmcsIHRhc2ssIE5VTEwsIHByaW9yaXR5KTsNCj4gPiArCXJwY19zbGVlcF9vbigm
eHBydC0+c2VuZGluZywgdGFzaywgTlVMTCk7DQo+ID4gIAlyZXR1cm4gMDsNCj4gPiAgfQ0KPiA+
ICBFWFBPUlRfU1lNQk9MX0dQTCh4cHJ0X3Jlc2VydmVfeHBydCk7DQo+ID4gQEAgLTIzMSw3ICsy
MjQsNiBAQCBzdGF0aWMgdm9pZCB4cHJ0X2NsZWFyX2xvY2tlZChzdHJ1Y3QgcnBjX3hwcnQgKnhw
cnQpDQo+ID4gIGludCB4cHJ0X3Jlc2VydmVfeHBydF9jb25nKHN0cnVjdCBycGNfeHBydCAqeHBy
dCwgc3RydWN0IHJwY190YXNrICp0YXNrKQ0KPiA+ICB7DQo+ID4gIAlzdHJ1Y3QgcnBjX3Jxc3Qg
KnJlcSA9IHRhc2stPnRrX3Jxc3RwOw0KPiA+IC0JaW50IHByaW9yaXR5Ow0KPiA+ICANCj4gPiAg
CWlmICh0ZXN0X2FuZF9zZXRfYml0KFhQUlRfTE9DS0VELCAmeHBydC0+c3RhdGUpKSB7DQo+ID4g
IAkJaWYgKHRhc2sgPT0geHBydC0+c25kX3Rhc2spDQo+ID4gQEAgLTI1MSwxMyArMjQzLDcgQEAg
aW50IHhwcnRfcmVzZXJ2ZV94cHJ0X2Nvbmcoc3RydWN0IHJwY194cHJ0ICp4cHJ0LA0KPiA+IHN0
cnVjdA0KPiA+IHJwY190YXNrICp0YXNrKQ0KPiA+ICAJZHByaW50aygiUlBDOiAlNXUgZmFpbGVk
IHRvIGxvY2sgdHJhbnNwb3J0ICVwXG4iLCB0YXNrLT50a19waWQsIHhwcnQpOw0KPiA+ICAJdGFz
ay0+dGtfdGltZW91dCA9IDA7DQo+ID4gIAl0YXNrLT50a19zdGF0dXMgPSAtRUFHQUlOOw0KPiA+
IC0JaWYgKHJlcSA9PSBOVUxMKQ0KPiA+IC0JCXByaW9yaXR5ID0gUlBDX1BSSU9SSVRZX0xPVzsN
Cj4gPiAtCWVsc2UgaWYgKCFyZXEtPnJxX250cmFucykNCj4gPiAtCQlwcmlvcml0eSA9IFJQQ19Q
UklPUklUWV9OT1JNQUw7DQo+ID4gLQllbHNlDQo+ID4gLQkJcHJpb3JpdHkgPSBSUENfUFJJT1JJ
VFlfSElHSDsNCj4gPiAtCXJwY19zbGVlcF9vbl9wcmlvcml0eSgmeHBydC0+c2VuZGluZywgdGFz
aywgTlVMTCwgcHJpb3JpdHkpOw0KPiA+ICsJcnBjX3NsZWVwX29uKCZ4cHJ0LT5zZW5kaW5nLCB0
YXNrLCBOVUxMKTsNCj4gPiAgCXJldHVybiAwOw0KPiA+ICB9DQo+ID4gIEVYUE9SVF9TWU1CT0xf
R1BMKHhwcnRfcmVzZXJ2ZV94cHJ0X2NvbmcpOw0KPiA+IEBAIC0yODUsOCArMjcxLDcgQEAgc3Rh
dGljIHZvaWQgX194cHJ0X2xvY2tfd3JpdGVfbmV4dChzdHJ1Y3QgcnBjX3hwcnQNCj4gPiAqeHBy
dCkNCj4gPiAgCWlmICh0ZXN0X2FuZF9zZXRfYml0KFhQUlRfTE9DS0VELCAmeHBydC0+c3RhdGUp
KQ0KPiA+ICAJCXJldHVybjsNCj4gPiAgDQo+ID4gLQlpZiAocnBjX3dha2VfdXBfZmlyc3Rfb25f
d3EoeHBydGlvZF93b3JrcXVldWUsICZ4cHJ0LT5zZW5kaW5nLA0KPiA+IC0JCQkJX194cHJ0X2xv
Y2tfd3JpdGVfZnVuYywgeHBydCkpDQo+ID4gKwlpZiAocnBjX3dha2VfdXBfZmlyc3QoJnhwcnQt
PnNlbmRpbmcsIF9feHBydF9sb2NrX3dyaXRlX2Z1bmMsIHhwcnQpKQ0KPiA+ICAJCXJldHVybjsN
Cj4gPiAgCXhwcnRfY2xlYXJfbG9ja2VkKHhwcnQpOw0KPiA+ICB9DQo+ID4gQEAgLTI5Nyw4ICsy
ODIsNyBAQCBzdGF0aWMgdm9pZCBfX3hwcnRfbG9ja193cml0ZV9uZXh0X2Nvbmcoc3RydWN0IHJw
Y194cHJ0DQo+ID4gKnhwcnQpDQo+ID4gIAkJcmV0dXJuOw0KPiA+ICAJaWYgKFJQQ1hQUlRfQ09O
R0VTVEVEKHhwcnQpKQ0KPiA+ICAJCWdvdG8gb3V0X3VubG9jazsNCj4gPiAtCWlmIChycGNfd2Fr
ZV91cF9maXJzdF9vbl93cSh4cHJ0aW9kX3dvcmtxdWV1ZSwgJnhwcnQtPnNlbmRpbmcsDQo+ID4g
LQkJCQlfX3hwcnRfbG9ja193cml0ZV9mdW5jLCB4cHJ0KSkNCj4gPiArCWlmIChycGNfd2FrZV91
cF9maXJzdCgmeHBydC0+c2VuZGluZywgX194cHJ0X2xvY2tfd3JpdGVfZnVuYywgeHBydCkpDQo+
ID4gIAkJcmV0dXJuOw0KPiA+ICBvdXRfdW5sb2NrOg0KPiA+ICAJeHBydF9jbGVhcl9sb2NrZWQo
eHBydCk7DQo+ID4gQEAgLTQ5NSw4ICs0NzksNyBAQCB2b2lkIHhwcnRfd3JpdGVfc3BhY2Uoc3Ry
dWN0IHJwY194cHJ0ICp4cHJ0KQ0KPiA+ICAJaWYgKHhwcnQtPnNuZF90YXNrKSB7DQo+ID4gIAkJ
ZHByaW50aygiUlBDOiAgICAgICB3cml0ZSBzcGFjZTogd2FraW5nIHdhaXRpbmcgdGFzayBvbiAi
DQo+ID4gIAkJCQkieHBydCAlcFxuIiwgeHBydCk7DQo+ID4gLQkJcnBjX3dha2VfdXBfcXVldWVk
X3Rhc2tfb25fd3EoeHBydGlvZF93b3JrcXVldWUsDQo+ID4gLQkJCQkmeHBydC0+cGVuZGluZywg
eHBydC0+c25kX3Rhc2spOw0KPiA+ICsJCXJwY193YWtlX3VwX3F1ZXVlZF90YXNrKCZ4cHJ0LT5w
ZW5kaW5nLCB4cHJ0LT5zbmRfdGFzayk7DQo+ID4gIAl9DQo+ID4gIAlzcGluX3VubG9ja19iaCgm
eHBydC0+dHJhbnNwb3J0X2xvY2spOw0KPiA+ICB9DQo+ID4gQEAgLTE1OTYsNyArMTU3OSw3IEBA
IHN0YXRpYyB2b2lkIHhwcnRfaW5pdChzdHJ1Y3QgcnBjX3hwcnQgKnhwcnQsIHN0cnVjdA0KPiA+
IG5ldA0KPiA+ICpuZXQpDQo+ID4gIA0KPiA+ICAJcnBjX2luaXRfd2FpdF9xdWV1ZSgmeHBydC0+
YmluZGluZywgInhwcnRfYmluZGluZyIpOw0KPiA+ICAJcnBjX2luaXRfd2FpdF9xdWV1ZSgmeHBy
dC0+cGVuZGluZywgInhwcnRfcGVuZGluZyIpOw0KPiA+IC0JcnBjX2luaXRfcHJpb3JpdHlfd2Fp
dF9xdWV1ZSgmeHBydC0+c2VuZGluZywgInhwcnRfc2VuZGluZyIpOw0KPiA+ICsJcnBjX2luaXRf
d2FpdF9xdWV1ZSgmeHBydC0+c2VuZGluZywgInhwcnRfc2VuZGluZyIpOw0KPiA+ICAJcnBjX2lu
aXRfcHJpb3JpdHlfd2FpdF9xdWV1ZSgmeHBydC0+YmFja2xvZywgInhwcnRfYmFja2xvZyIpOw0K
PiA+ICANCj4gPiAgCXhwcnRfaW5pdF94aWQoeHBydCk7DQo=
