Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:54131 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933197Ab3HGVJ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 17:09:57 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Nix <nix@esperi.org.uk>
CC: Jeff Layton <jlayton@redhat.com>,
        =?utf-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>,
        Oleg Nesterov <oleg@redhat.com>, NFS list <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "dhowells@redhat.com" <dhowells@redhat.com>
Subject: Re: [3.10.4] NFS locking panic, plus persisting NFS shutdown panic
 from 3.9.*
Date: Wed, 7 Aug 2013 21:09:55 +0000
Message-ID: <1375909795.7280.58.camel@leira.trondhjem.org>
References: <8761vlv4z9.fsf@spindle.srvr.nix>
	 <20130805084436.69ee4415@corrin.poochiereds.net>
	 <87siyotcri.fsf@spindle.srvr.nix>
	 <20130805110427.509db424@tlielax.poochiereds.net>
	 <20130805111106.73d6ab90@tlielax.poochiereds.net>
	 <87zjswrvaq.fsf@spindle.srvr.nix>
	 <1375719301.7337.14.camel@leira.trondhjem.org>
	 <20130805133739.21654ecb@tlielax.poochiereds.net>
	 <1375726682.7337.29.camel@leira.trondhjem.org>
	 <20130805143311.4ae59067@tlielax.poochiereds.net>
	 <1375755693.7337.42.camel@leira.trondhjem.org>
	 <87iozhst0s.fsf@spindle.srvr.nix>
	 <1375889252.6488.1.camel@leira.trondhjem.org>
	 <87iozhmd0a.fsf@spindle.srvr.nix>
In-Reply-To: <87iozhmd0a.fsf@spindle.srvr.nix>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEzLTA4LTA3IGF0IDIyOjAxICswMTAwLCBOaXggd3JvdGU6DQo+IE9uIDcgQXVn
IDIwMTMsIFRyb25kIE15a2xlYnVzdCBzYWlkOg0KPiANCj4gPiBPbiBXZWQsIDIwMTMtMDgtMDcg
YXQgMTE6MTggKzAxMDAsIE5peCB3cm90ZToNCj4gPj4gT24gNiBBdWcgMjAxMywgVHJvbmQgTXlr
bGVidXN0IHZlcmJhbGlzZWQ6DQo+ID4+ID4gVHJ1ZS4gSG93IGFib3V0IHNvbWV0aGluZyBsaWtl
IHRoZSBmb2xsb3dpbmcgaW5zdGVhZC4gTm90ZSB0aGUgY2hhbmdlIHRvDQo+ID4+ID4gdGhlIG9y
aWdpbmFsIHBhdGNoLi4uDQo+ID4+IA0KPiA+PiBXZWxsLCB3aXRoIHRob3NlIGFwcGxpZWQgSSBj
b3VsZCByZWJvb3Qgd2l0aG91dCBhIHBhbmljIGZvciB0aGUgZmlyc3QNCj4gPj4gdGltZSBzaW5j
ZSAzLjgueDogbG9va2luZyBnb29kLiBJJ2xsIGdpdmUgaXQgYSByZWJvb3Qgb3IgdHdvIHdpdGgg
YQ0KPiA+PiBzeXN0ZW0gdGhhdCdzIG5vdCBob3QgZnJvbSBib290aW5nIHRob3VnaC4NCj4gPg0K
PiA+IENvdWxkIHlvdSBwbGVhc2UgYWxzbyB0cnkgYXBwbHlpbmcgb25seSB0aGUgMS8yIHBhdGNo
LCB0byBzZWUgaWYgdGhhdA0KPiA+IHN1ZmZpY2VzIHRvIHF1ZWxsIHRoZSBzaHV0ZG93biBwYW5p
Yz8NCj4gDQo+IEl0IGRvZXNuJ3Qgc3VmZmljZS4gSSBzZWUgdGhpcyBzZXZlcmVseSB0cnVuY2F0
ZWQgb29wczoNCj4gDQo+IFsgIDExNS43OTkwOTJdIEJVRzogdW5hYmxlIHRvIGhhbmRsZSBrZXJu
ZWwgTlVMTCBwb2ludGVyIGRlcmVmZXJlbmNlIGF0IDAwMDAwMDAwMDAwMDAwMDgNCj4gWyAgMTE1
LjgwMDI4NF0gSVA6IFs8ZmZmZmZmZmY4MTE2NWVjNj5dIHBhdGhfaW5pdCsweDExYy8weDM2Zg0K
PiBbICAxMTUuODAxNDYzXSBQR0QgMCANCj4gWyAgMTE1LjgwMjYyNV0gT29wczogMDAwMCBbIzFd
IFBSRUVNUFQgU01QIA0KPiBbICAxMTUuODAzODA1XSBNb2R1bGVzIGxpbmtlZCBpbjogW2xhc3Qg
dW5sb2FkZWQ6IG1pY3JvY29kZV0gDQo+IFsgIDExNS44MDQ5OTVdIENQVTogMyBQSUQ6IDExOTEg
Q29tbTogc2xlZXAgTm90IHRhaW50ZWQgMy4xMC41LTA1MzE3LWczYzlmNmZhLWRpcnR5ICMyDQo+
IFsgIDExNS44MDYyMDddIEhhcmR3YXJlIG5hbWU6IFN5c3RlbSBtYW51ZmFjdHVyZXIgU3lzdGVt
IFByb2R1Y3QgTmFtZS9QOEg2MS1NWCBVU0IzLCBCSU9TIDA1MDYgMDgvMTAvMjAxMg0KPiBbICAx
MTUuODA3NDUzXSB0YXNrOiBmZmZmODgwNDE4OWEwMDAwIHRpOiBmZmZmODgwM2Y3NGQ2MDAwIHRh
c2sudGk6IGZmZmY4ODAzZjc0ZDYwMDANCj4gDQpPSy4gVGhlbiBJJ2xsIG1hcmsgdGhlbSBib3Ro
IGZvciBzdGFibGUgaW5jbHVzaW9uIGluIDMuOSsuDQoNClRoYW5rcyBmb3IgdGVzdGluZyENCi0t
IA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBw
DQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg==
