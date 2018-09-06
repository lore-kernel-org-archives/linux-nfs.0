Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:55133 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728905AbeIFSxc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Sep 2018 14:53:32 -0400
From: "Schumaker, Anna" <Anna.Schumaker@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "trondmy@gmail.com" <trondmy@gmail.com>
Subject: Re: [PATCH v2 29/34] SUNRPC: Convert the xprt->sending queue back to
 an ordinary wait queue
Date: Thu, 6 Sep 2018 14:17:40 +0000
Message-ID: <04e17d9b133447da19470330767b9fd6cbeefc3f.camel@netapp.com>
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
In-Reply-To: <20180904210549.81673-30-trond.myklebust@hammerspace.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SGkgVHJvbmQsDQoNCk9uIFR1ZSwgMjAxOC0wOS0wNCBhdCAxNzowNSAtMDQwMCwgVHJvbmQgTXlr
bGVidXN0IHdyb3RlOg0KPiBXZSBubyBsb25nZXIgbmVlZCBwcmlvcml0eSBzZW1hbnRpY3Mgb24g
dGhlIHhwcnQtPnNlbmRpbmcgcXVldWUsIGJlY2F1c2UNCj4gdGhlIG9yZGVyIGluIHdoaWNoIHRh
c2tzIGFyZSBzZW50IGlzIG5vdyBkaWN0YXRlZCBieSB0aGVpciBwb3NpdGlvbiBpbg0KPiB0aGUg
c2VuZCBxdWV1ZS4NCj4gTm90ZSB0aGF0IHRoZSBiYWNrbG9nIHF1ZXVlIHJlbWFpbnMgYSBwcmlv
cml0eSBxdWV1ZSwgbWVhbmluZyB0aGF0DQo+IHNsb3QgcmVzb3VyY2VzIGFyZSBzdGlsbCBtYW5h
Z2VkIGluIG9yZGVyIG9mIHRhc2sgcHJpb3JpdHkuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBUcm9u
ZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20+DQo+IC0tLQ0KPiAg
bmV0L3N1bnJwYy94cHJ0LmMgfCAyOSArKysrKystLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KPiAg
MSBmaWxlIGNoYW5nZWQsIDYgaW5zZXJ0aW9ucygrKSwgMjMgZGVsZXRpb25zKC0pDQo+IA0KPiBk
aWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy94cHJ0LmMgYi9uZXQvc3VucnBjL3hwcnQuYw0KPiBpbmRl
eCBiYTlhZjI1ZDE0ZGUuLmViZTUyMzVjNDg0YiAxMDA2NDQNCj4gLS0tIGEvbmV0L3N1bnJwYy94
cHJ0LmMNCj4gKysrIGIvbmV0L3N1bnJwYy94cHJ0LmMNCj4gQEAgLTE4MSw3ICsxODEsNiBAQCBF
WFBPUlRfU1lNQk9MX0dQTCh4cHJ0X2xvYWRfdHJhbnNwb3J0KTsNCj4gIGludCB4cHJ0X3Jlc2Vy
dmVfeHBydChzdHJ1Y3QgcnBjX3hwcnQgKnhwcnQsIHN0cnVjdCBycGNfdGFzayAqdGFzaykNCj4g
IHsNCj4gIAlzdHJ1Y3QgcnBjX3Jxc3QgKnJlcSA9IHRhc2stPnRrX3Jxc3RwOw0KDQpBcyBvZiB0
aGlzIHBhdGNoLCByZXEgaXMgbm8gbG9uZ2VyIHVzZWQgZWl0aGVyLiAgQ2FuIGl0IGJlIHJlbW92
ZWQ/DQoNClRoYW5rcywNCkFubmENCg0KPiAtCWludCBwcmlvcml0eTsNCj4gIA0KPiAgCWlmICh0
ZXN0X2FuZF9zZXRfYml0KFhQUlRfTE9DS0VELCAmeHBydC0+c3RhdGUpKSB7DQo+ICAJCWlmICh0
YXNrID09IHhwcnQtPnNuZF90YXNrKQ0KPiBAQCAtMTk3LDEzICsxOTYsNyBAQCBpbnQgeHBydF9y
ZXNlcnZlX3hwcnQoc3RydWN0IHJwY194cHJ0ICp4cHJ0LCBzdHJ1Y3QNCj4gcnBjX3Rhc2sgKnRh
c2spDQo+ICAJCQl0YXNrLT50a19waWQsIHhwcnQpOw0KPiAgCXRhc2stPnRrX3RpbWVvdXQgPSAw
Ow0KPiAgCXRhc2stPnRrX3N0YXR1cyA9IC1FQUdBSU47DQo+IC0JaWYgKHJlcSA9PSBOVUxMKQ0K
PiAtCQlwcmlvcml0eSA9IFJQQ19QUklPUklUWV9MT1c7DQo+IC0JZWxzZSBpZiAoIXJlcS0+cnFf
bnRyYW5zKQ0KPiAtCQlwcmlvcml0eSA9IFJQQ19QUklPUklUWV9OT1JNQUw7DQo+IC0JZWxzZQ0K
PiAtCQlwcmlvcml0eSA9IFJQQ19QUklPUklUWV9ISUdIOw0KPiAtCXJwY19zbGVlcF9vbl9wcmlv
cml0eSgmeHBydC0+c2VuZGluZywgdGFzaywgTlVMTCwgcHJpb3JpdHkpOw0KPiArCXJwY19zbGVl
cF9vbigmeHBydC0+c2VuZGluZywgdGFzaywgTlVMTCk7DQo+ICAJcmV0dXJuIDA7DQo+ICB9DQo+
ICBFWFBPUlRfU1lNQk9MX0dQTCh4cHJ0X3Jlc2VydmVfeHBydCk7DQo+IEBAIC0yMzEsNyArMjI0
LDYgQEAgc3RhdGljIHZvaWQgeHBydF9jbGVhcl9sb2NrZWQoc3RydWN0IHJwY194cHJ0ICp4cHJ0
KQ0KPiAgaW50IHhwcnRfcmVzZXJ2ZV94cHJ0X2Nvbmcoc3RydWN0IHJwY194cHJ0ICp4cHJ0LCBz
dHJ1Y3QgcnBjX3Rhc2sgKnRhc2spDQo+ICB7DQo+ICAJc3RydWN0IHJwY19ycXN0ICpyZXEgPSB0
YXNrLT50a19ycXN0cDsNCj4gLQlpbnQgcHJpb3JpdHk7DQo+ICANCj4gIAlpZiAodGVzdF9hbmRf
c2V0X2JpdChYUFJUX0xPQ0tFRCwgJnhwcnQtPnN0YXRlKSkgew0KPiAgCQlpZiAodGFzayA9PSB4
cHJ0LT5zbmRfdGFzaykNCj4gQEAgLTI1MSwxMyArMjQzLDcgQEAgaW50IHhwcnRfcmVzZXJ2ZV94
cHJ0X2Nvbmcoc3RydWN0IHJwY194cHJ0ICp4cHJ0LCBzdHJ1Y3QNCj4gcnBjX3Rhc2sgKnRhc2sp
DQo+ICAJZHByaW50aygiUlBDOiAlNXUgZmFpbGVkIHRvIGxvY2sgdHJhbnNwb3J0ICVwXG4iLCB0
YXNrLT50a19waWQsIHhwcnQpOw0KPiAgCXRhc2stPnRrX3RpbWVvdXQgPSAwOw0KPiAgCXRhc2st
PnRrX3N0YXR1cyA9IC1FQUdBSU47DQo+IC0JaWYgKHJlcSA9PSBOVUxMKQ0KPiAtCQlwcmlvcml0
eSA9IFJQQ19QUklPUklUWV9MT1c7DQo+IC0JZWxzZSBpZiAoIXJlcS0+cnFfbnRyYW5zKQ0KPiAt
CQlwcmlvcml0eSA9IFJQQ19QUklPUklUWV9OT1JNQUw7DQo+IC0JZWxzZQ0KPiAtCQlwcmlvcml0
eSA9IFJQQ19QUklPUklUWV9ISUdIOw0KPiAtCXJwY19zbGVlcF9vbl9wcmlvcml0eSgmeHBydC0+
c2VuZGluZywgdGFzaywgTlVMTCwgcHJpb3JpdHkpOw0KPiArCXJwY19zbGVlcF9vbigmeHBydC0+
c2VuZGluZywgdGFzaywgTlVMTCk7DQo+ICAJcmV0dXJuIDA7DQo+ICB9DQo+ICBFWFBPUlRfU1lN
Qk9MX0dQTCh4cHJ0X3Jlc2VydmVfeHBydF9jb25nKTsNCj4gQEAgLTI4NSw4ICsyNzEsNyBAQCBz
dGF0aWMgdm9pZCBfX3hwcnRfbG9ja193cml0ZV9uZXh0KHN0cnVjdCBycGNfeHBydCAqeHBydCkN
Cj4gIAlpZiAodGVzdF9hbmRfc2V0X2JpdChYUFJUX0xPQ0tFRCwgJnhwcnQtPnN0YXRlKSkNCj4g
IAkJcmV0dXJuOw0KPiAgDQo+IC0JaWYgKHJwY193YWtlX3VwX2ZpcnN0X29uX3dxKHhwcnRpb2Rf
d29ya3F1ZXVlLCAmeHBydC0+c2VuZGluZywNCj4gLQkJCQlfX3hwcnRfbG9ja193cml0ZV9mdW5j
LCB4cHJ0KSkNCj4gKwlpZiAocnBjX3dha2VfdXBfZmlyc3QoJnhwcnQtPnNlbmRpbmcsIF9feHBy
dF9sb2NrX3dyaXRlX2Z1bmMsIHhwcnQpKQ0KPiAgCQlyZXR1cm47DQo+ICAJeHBydF9jbGVhcl9s
b2NrZWQoeHBydCk7DQo+ICB9DQo+IEBAIC0yOTcsOCArMjgyLDcgQEAgc3RhdGljIHZvaWQgX194
cHJ0X2xvY2tfd3JpdGVfbmV4dF9jb25nKHN0cnVjdCBycGNfeHBydA0KPiAqeHBydCkNCj4gIAkJ
cmV0dXJuOw0KPiAgCWlmIChSUENYUFJUX0NPTkdFU1RFRCh4cHJ0KSkNCj4gIAkJZ290byBvdXRf
dW5sb2NrOw0KPiAtCWlmIChycGNfd2FrZV91cF9maXJzdF9vbl93cSh4cHJ0aW9kX3dvcmtxdWV1
ZSwgJnhwcnQtPnNlbmRpbmcsDQo+IC0JCQkJX194cHJ0X2xvY2tfd3JpdGVfZnVuYywgeHBydCkp
DQo+ICsJaWYgKHJwY193YWtlX3VwX2ZpcnN0KCZ4cHJ0LT5zZW5kaW5nLCBfX3hwcnRfbG9ja193
cml0ZV9mdW5jLCB4cHJ0KSkNCj4gIAkJcmV0dXJuOw0KPiAgb3V0X3VubG9jazoNCj4gIAl4cHJ0
X2NsZWFyX2xvY2tlZCh4cHJ0KTsNCj4gQEAgLTQ5NSw4ICs0NzksNyBAQCB2b2lkIHhwcnRfd3Jp
dGVfc3BhY2Uoc3RydWN0IHJwY194cHJ0ICp4cHJ0KQ0KPiAgCWlmICh4cHJ0LT5zbmRfdGFzaykg
ew0KPiAgCQlkcHJpbnRrKCJSUEM6ICAgICAgIHdyaXRlIHNwYWNlOiB3YWtpbmcgd2FpdGluZyB0
YXNrIG9uICINCj4gIAkJCQkieHBydCAlcFxuIiwgeHBydCk7DQo+IC0JCXJwY193YWtlX3VwX3F1
ZXVlZF90YXNrX29uX3dxKHhwcnRpb2Rfd29ya3F1ZXVlLA0KPiAtCQkJCSZ4cHJ0LT5wZW5kaW5n
LCB4cHJ0LT5zbmRfdGFzayk7DQo+ICsJCXJwY193YWtlX3VwX3F1ZXVlZF90YXNrKCZ4cHJ0LT5w
ZW5kaW5nLCB4cHJ0LT5zbmRfdGFzayk7DQo+ICAJfQ0KPiAgCXNwaW5fdW5sb2NrX2JoKCZ4cHJ0
LT50cmFuc3BvcnRfbG9jayk7DQo+ICB9DQo+IEBAIC0xNTk2LDcgKzE1NzksNyBAQCBzdGF0aWMg
dm9pZCB4cHJ0X2luaXQoc3RydWN0IHJwY194cHJ0ICp4cHJ0LCBzdHJ1Y3QgbmV0DQo+ICpuZXQp
DQo+ICANCj4gIAlycGNfaW5pdF93YWl0X3F1ZXVlKCZ4cHJ0LT5iaW5kaW5nLCAieHBydF9iaW5k
aW5nIik7DQo+ICAJcnBjX2luaXRfd2FpdF9xdWV1ZSgmeHBydC0+cGVuZGluZywgInhwcnRfcGVu
ZGluZyIpOw0KPiAtCXJwY19pbml0X3ByaW9yaXR5X3dhaXRfcXVldWUoJnhwcnQtPnNlbmRpbmcs
ICJ4cHJ0X3NlbmRpbmciKTsNCj4gKwlycGNfaW5pdF93YWl0X3F1ZXVlKCZ4cHJ0LT5zZW5kaW5n
LCAieHBydF9zZW5kaW5nIik7DQo+ICAJcnBjX2luaXRfcHJpb3JpdHlfd2FpdF9xdWV1ZSgmeHBy
dC0+YmFja2xvZywgInhwcnRfYmFja2xvZyIpOw0KPiAgDQo+ICAJeHBydF9pbml0X3hpZCh4cHJ0
KTsNCg==
