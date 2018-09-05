Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-co1nam03on0111.outbound.protection.outlook.com ([104.47.40.111]:60729
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727195AbeIEUxu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Sep 2018 16:53:50 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 23/34] SUNRPC: Move RPC retransmission stat counter to
 xprt_transmit()
Date: Wed, 5 Sep 2018 16:07:50 +0000
Message-ID: <ef24000fac4084d52eabc141e3f3b768542431a4.camel@hammerspace.com>
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
         <4165cdf8162f9ca6aa1165c71e880632fda259ec.camel@hammerspace.com>
         <85D647A8-CD05-4B29-BD69-08F653EEF122@oracle.com>
In-Reply-To: <85D647A8-CD05-4B29-BD69-08F653EEF122@oracle.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDE4LTA5LTA1IGF0IDExOjMxIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBTZXAgNSwgMjAxOCwgYXQgMTE6MjggQU0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gdHJv
bmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IE9uIFdlZCwgMjAxOC0wOS0w
NSBhdCAxMDozMCAtMDQwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+ID4gPiA+IE9uIFNlcCA0LCAy
MDE4LCBhdCA1OjA1IFBNLCBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kbXlAZ21haWwuY29tPg0KPiA+
ID4gPiB3cm90ZToNCj4gPiA+ID4gDQo+ID4gPiA+IFNpZ25lZC1vZmYtYnk6IFRyb25kIE15a2xl
YnVzdCA8dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KPiA+ID4gPiA+DQo+ID4gPiA+
IC0tLQ0KPiA+ID4gPiBuZXQvc3VucnBjL2NsbnQuYyB8ICA2IC0tLS0tLQ0KPiA+ID4gPiBuZXQv
c3VucnBjL3hwcnQuYyB8IDEzICsrKysrKy0tLS0tLS0NCj4gPiA+ID4gMiBmaWxlcyBjaGFuZ2Vk
LCA2IGluc2VydGlvbnMoKyksIDEzIGRlbGV0aW9ucygtKQ0KPiA+ID4gPiANCj4gPiA+ID4gZGlm
ZiAtLWdpdCBhL25ldC9zdW5ycGMvY2xudC5jIGIvbmV0L3N1bnJwYy9jbG50LmMNCj4gPiA+ID4g
aW5kZXggMDMyYjcwNDJhZGI2Li4yMTcxM2JlZDgxMmEgMTAwNjQ0DQo+ID4gPiA+IC0tLSBhL25l
dC9zdW5ycGMvY2xudC5jDQo+ID4gPiA+ICsrKyBiL25ldC9zdW5ycGMvY2xudC5jDQo+ID4gPiA+
IEBAIC0xOTY3LDggKzE5NjcsNiBAQCBjYWxsX2Nvbm5lY3Rfc3RhdHVzKHN0cnVjdCBycGNfdGFz
aw0KPiA+ID4gPiAqdGFzaykNCj4gPiA+ID4gc3RhdGljIHZvaWQNCj4gPiA+ID4gY2FsbF90cmFu
c21pdChzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2spDQo+ID4gPiA+IHsNCj4gPiA+ID4gLQlpbnQgaXNf
cmV0cmFucyA9IFJQQ19XQVNfU0VOVCh0YXNrKTsNCj4gPiA+ID4gLQ0KPiA+ID4gPiAJZHByaW50
X3N0YXR1cyh0YXNrKTsNCj4gPiA+ID4gDQo+ID4gPiA+IAl0YXNrLT50a19hY3Rpb24gPSBjYWxs
X3RyYW5zbWl0X3N0YXR1czsNCj4gPiA+ID4gQEAgLTE5NzksMTAgKzE5NzcsNiBAQCBjYWxsX3Ry
YW5zbWl0KHN0cnVjdCBycGNfdGFzayAqdGFzaykNCj4gPiA+ID4gCWlmICgheHBydF9wcmVwYXJl
X3RyYW5zbWl0KHRhc2spKQ0KPiA+ID4gPiAJCXJldHVybjsNCj4gPiA+ID4gCXhwcnRfdHJhbnNt
aXQodGFzayk7DQo+ID4gPiA+IC0JaWYgKHRhc2stPnRrX3N0YXR1cyA8IDApDQo+ID4gPiA+IC0J
CXJldHVybjsNCj4gPiA+ID4gLQlpZiAoaXNfcmV0cmFucykNCj4gPiA+ID4gLQkJdGFzay0+dGtf
Y2xpZW50LT5jbF9zdGF0cy0+cnBjcmV0cmFucysrOw0KPiA+ID4gPiB9DQo+ID4gPiA+IA0KPiA+
ID4gPiAvKg0KPiA+ID4gPiBkaWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy94cHJ0LmMgYi9uZXQvc3Vu
cnBjL3hwcnQuYw0KPiA+ID4gPiBpbmRleCBmMTMwMWQzOTEzOTkuLmUyZjViNDY2OGE2NiAxMDA2
NDQNCj4gPiA+ID4gLS0tIGEvbmV0L3N1bnJwYy94cHJ0LmMNCj4gPiA+ID4gKysrIGIvbmV0L3N1
bnJwYy94cHJ0LmMNCj4gPiA+ID4gQEAgLTE5MSw4ICsxOTEsNiBAQCBpbnQgeHBydF9yZXNlcnZl
X3hwcnQoc3RydWN0IHJwY194cHJ0DQo+ID4gPiA+ICp4cHJ0LA0KPiA+ID4gPiBzdHJ1Y3QgcnBj
X3Rhc2sgKnRhc2spDQo+ID4gPiA+IAkJZ290byBvdXRfc2xlZXA7DQo+ID4gPiA+IAl9DQo+ID4g
PiA+IAl4cHJ0LT5zbmRfdGFzayA9IHRhc2s7DQo+ID4gPiA+IC0JaWYgKHJlcSAhPSBOVUxMKQ0K
PiA+ID4gPiAtCQlyZXEtPnJxX250cmFucysrOw0KPiA+ID4gPiANCj4gPiA+ID4gCXJldHVybiAx
Ow0KPiA+ID4gPiANCj4gPiA+ID4gQEAgLTI0Nyw3ICsyNDUsNiBAQCBpbnQgeHBydF9yZXNlcnZl
X3hwcnRfY29uZyhzdHJ1Y3QgcnBjX3hwcnQNCj4gPiA+ID4gKnhwcnQsIHN0cnVjdCBycGNfdGFz
ayAqdGFzaykNCj4gPiA+ID4gCX0NCj4gPiA+ID4gCWlmIChfX3hwcnRfZ2V0X2NvbmcoeHBydCwg
dGFzaykpIHsNCj4gPiA+ID4gCQl4cHJ0LT5zbmRfdGFzayA9IHRhc2s7DQo+ID4gPiA+IC0JCXJl
cS0+cnFfbnRyYW5zKys7DQo+ID4gPiA+IAkJcmV0dXJuIDE7DQo+ID4gPiA+IAl9DQo+ID4gPiA+
IAl4cHJ0X2NsZWFyX2xvY2tlZCh4cHJ0KTsNCj4gPiA+ID4gQEAgLTI4MSwxMiArMjc4LDggQEAg
c3RhdGljIGlubGluZSBpbnQgeHBydF9sb2NrX3dyaXRlKHN0cnVjdA0KPiA+ID4gPiBycGNfeHBy
dCAqeHBydCwgc3RydWN0IHJwY190YXNrICp0YXNrKQ0KPiA+ID4gPiBzdGF0aWMgYm9vbCBfX3hw
cnRfbG9ja193cml0ZV9mdW5jKHN0cnVjdCBycGNfdGFzayAqdGFzaywgdm9pZA0KPiA+ID4gPiAq
ZGF0YSkNCj4gPiA+ID4gew0KPiA+ID4gPiAJc3RydWN0IHJwY194cHJ0ICp4cHJ0ID0gZGF0YTsN
Cj4gPiA+ID4gLQlzdHJ1Y3QgcnBjX3Jxc3QgKnJlcTsNCj4gPiA+ID4gDQo+ID4gPiA+IC0JcmVx
ID0gdGFzay0+dGtfcnFzdHA7DQo+ID4gPiA+IAl4cHJ0LT5zbmRfdGFzayA9IHRhc2s7DQo+ID4g
PiA+IC0JaWYgKHJlcSkNCj4gPiA+ID4gLQkJcmVxLT5ycV9udHJhbnMrKzsNCj4gPiA+ID4gCXJl
dHVybiB0cnVlOw0KPiA+ID4gPiB9DQo+ID4gPiA+IA0KPiA+ID4gPiBAQCAtMTEyNiw2ICsxMTE5
LDcgQEAgdm9pZCB4cHJ0X3RyYW5zbWl0KHN0cnVjdCBycGNfdGFzayAqdGFzaykNCj4gPiA+ID4g
CXN0cnVjdCBycGNfcnFzdAkqcmVxID0gdGFzay0+dGtfcnFzdHA7DQo+ID4gPiA+IAlzdHJ1Y3Qg
cnBjX3hwcnQJKnhwcnQgPSByZXEtPnJxX3hwcnQ7DQo+ID4gPiA+IAl1bnNpZ25lZCBpbnQgY29u
bmVjdF9jb29raWU7DQo+ID4gPiA+ICsJaW50IGlzX3JldHJhbnMgPSBSUENfV0FTX1NFTlQodGFz
ayk7DQo+ID4gPiA+IAlpbnQgc3RhdHVzOw0KPiA+ID4gPiANCj4gPiA+ID4gCWRwcmludGsoIlJQ
QzogJTV1IHhwcnRfdHJhbnNtaXQoJXUpXG4iLCB0YXNrLT50a19waWQsDQo+ID4gPiA+IHJlcS0N
Cj4gPiA+ID4gPiBycV9zbGVuKTsNCj4gPiA+ID4gDQo+ID4gPiA+IEBAIC0xMTQwLDYgKzExMzQs
OCBAQCB2b2lkIHhwcnRfdHJhbnNtaXQoc3RydWN0IHJwY190YXNrICp0YXNrKQ0KPiA+ID4gPiAJ
CX0NCj4gPiA+ID4gCX0NCj4gPiA+ID4gDQo+ID4gPiA+ICsJcmVxLT5ycV9udHJhbnMrKzsNCj4g
PiA+ID4gKw0KPiA+ID4gDQo+ID4gPiBycV9udHJhbnMgaXMgdXNlZCBpbiB0d28gcGxhY2VzOg0K
PiA+ID4gDQo+ID4gPiAxLiBycGNfdXBkYXRlX3J0dA0KPiA+ID4gMi4gcnBjX2NvdW50X2lvc3Rh
dHNfbWV0cmljcw0KPiA+ID4gDQo+ID4gPiBCb3RoIG9mIHRoZXNlIGFwcGVhciB0byBhc3N1bWUg
dGhhdCBycV9udHJhbnMgaXMgY291bnRpbmcNCj4gPiA+IGZ1bGwgc3VjY2Vzc2Z1bCB0cmFuc21p
c3Npb25zIChpZSwgY2FsbHMgdGhhdCBhcHBlYXIgb24gdGhlDQo+ID4gPiB3aXJlKSwgbm90IGlu
dm9jYXRpb25zIG9mIC0+c2VuZF9yZXF1ZXN0KCkuDQo+ID4gPiANCj4gPiA+IENhbiB0aGlzIGNv
dW50ZXIgYmUgbW92ZWQgZG93biB0byB3aGVyZSBycGNyZXRyYW5zIGlzIHVwZGF0ZWQ/DQo+ID4g
PiANCj4gPiANCj4gPiBUaGUgcmVhc29uIHdoeSBJIGRvbid0IHdhbnQgdG8gdXBkYXRlIHJlcS0+
cnFfbnRyYW5zIGFmdGVyDQo+ID4gdHJhbnNtaXNzaW9uDQo+ID4gaXMgYmVjYXVzZSB0aGF0IHdv
dWxkIHJhY2Ugd2l0aCB0aGUgcmVwbHkgZnJvbSB0aGUgc2VydmVyICh3aGljaCBpcw0KPiA+IG5v
dA0KPiA+IGJsb2NrZWQgYnkgdGhlIFhQUlRfTE9DSykuIEluIHRoYXQgcmFjZSBzY2VuYXJpbywg
cnBjX3VwZGF0ZV9ydHQoKQ0KPiA+IGNvdWxkIHVwZGF0ZSB0aGUgUlRUIHZhbHVlIGJlZm9yZSB3
ZSd2ZSB1cGRhdGVkIHRoZSByZXEtPnJxX250cmFucywNCj4gPiBtZWFuaW5nIHRoYXQgd2UgbWln
aHQgYmUgbWVhc3VyaW5nIHRoZSByZXNwb25zZSB0aW1lIGFnYWluc3QgYQ0KPiA+IHJlcGx5IHRv
DQo+ID4gdGhlIG9yaWdpbmFsIHRyYW5zbWlzc2lvbiBvciB0byB0aGUgcmV0cmFuc21pc3Npb24g
dGhhdCB3YXMganVzdA0KPiA+IHNlbnQuDQo+ID4gVGhhdCB3b3VsZCBlbmQgdXAgYnJlYWtpbmcg
VmFuIEphY29ic2VuIGNvbmdlc3Rpb24gY29udHJvbCwgc2luY2UNCj4gPiB3ZQ0KPiA+IHJpc2sg
c2lnbmlmaWNhbnRseSB1bmRlcmVzdGltYXRpbmcgdGhlIFJUVCB2YWx1ZS4NCj4gDQo+IEJ1dCBm
b3IgdHJhbnNwb3J0cyB0aGF0IGRvbid0IHVzZSB4cHJ0X3VwZGF0ZV9ydHQsIGVycm9yDQo+IHJl
dHVybnMgZnJvbSAtPnNlbmRfcmVxdWVzdCgpIChsaWtlIC1FQUdBSU4gb3IgLUVOT0JVRlMpDQo+
IG1lYW5zIHRoYXQgcnFfbnRyYW5zIGlzIGNvdW50ZWQgdHdpY2UsIGFuZCBpdCBzaG93cyB1cCBh
cw0KPiBmYWxzZSByZXRyYW5zbWlzc2lvbnMuDQoNClRoYXQncyB0aGUgd2F5IGl0IGhhcyBhbHdh
eXMgd29ya2VkLiBUaGUgVmFuIEphY29ic2VuIGNvZGUgd2FzDQppbXBsZW1lbnRlZCBsb25nIGJl
Zm9yZSB0aGUgcGVyLXJlcXVlc3Qgc3RhdHMgd2VyZSBpbnRyb2R1Y2VkLCBhbmQgc28NCnRoZSBi
ZWhhdmlvdXIgb2YgcmVxLT5ycV9udHJhbnMgaGFzIGFsd2F5cyBiZWVuIHRvIHVwZGF0ZSB0aGUg
dmFsdWUNCmJlZm9yZSB3ZSB0cmFuc21pdC4NCg0KPiBXaGF0IGlmIHJxX250cmFucyB3YXMgYnVt
cGVkIGluIHRoZSB0cmFuc3BvcnQgY29kZSBpbnN0ZWFkPw0KDQpJZiB3ZSBtdXN0IGNoYW5nZSB0
aGUgYmVoYXZpb3VyLCB0aGVuIHdoeSBub3QganVzdCBoYXZlIHRoZSBnZW5lcmljDQpsYXllciAn
dW5idW1wJyB0aGUgY291bnRlciBvbiBhbiBpbmNvbXBsZXRlIHRyYW5zbWlzc2lvbj8NCg0KLS0g
DQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3Bh
Y2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
